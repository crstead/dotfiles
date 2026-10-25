"""Check fresh-install .profile replacement using Bash and real Stow."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "stow.sh"


class StowTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-stow-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo"
        self.home = self.root / "home"
        (self.repo / "stow").mkdir(parents=True)
        self.home.mkdir()
        (self.repo / "stow/.profile").write_text("# managed profile\n")
        (self.repo / "stow/.zshrc").write_text("# managed zsh\n")
        self.profile = self.home / ".profile"
        self.profile.write_text("# Ubuntu default\n")

    def install(self):
        return subprocess.run(
            ["bash", "-eu", "-c", 'source "$1"; stow_dotfiles', "bash", str(SCRIPT)],
            env={**os.environ, "HOME": str(self.home), "DOTFILES_DIR": str(self.repo)},
            capture_output=True, text=True,
        )

    def test_replace_default_without_backup(self):
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(self.profile.is_symlink())
        self.assertEqual(self.profile.read_text(), "# managed profile\n")
        self.assertFalse(list(self.home.glob("dotfiles-backup.*")))

    def test_other_conflicts_preserve_default(self):
        (self.home / ".zshrc").write_text("# existing settings\n")
        self.assertNotEqual(self.install().returncode, 0)
        self.assertFalse(self.profile.is_symlink())
        self.assertEqual(self.profile.read_text(), "# Ubuntu default\n")
        self.assertEqual((self.home / ".zshrc").read_text(), "# existing settings\n")

    def test_missing_replacement_preserves_default(self):
        (self.repo / "stow/.profile").unlink()
        self.assertNotEqual(self.install().returncode, 0)
        self.assertEqual(self.profile.read_text(), "# Ubuntu default\n")

    def test_missing_profile_and_repeat_install(self):
        self.profile.unlink()
        self.assertEqual(self.install().returncode, 0)
        link = os.readlink(self.profile)
        self.assertEqual(self.install().returncode, 0)
        self.assertEqual(os.readlink(self.profile), link)
        self.assertFalse(list(self.home.glob("dotfiles-backup.*")))

    def test_profile_directory_is_preserved(self):
        self.profile.unlink()
        self.profile.mkdir()
        (self.profile / "keep").write_text("original")
        self.assertNotEqual(self.install().returncode, 0)
        self.assertEqual((self.profile / "keep").read_text(), "original")

    def test_foreign_and_dangling_symlinks_are_preserved(self):
        self.profile.unlink()
        for target in [self.root / "other-profile", self.root / "missing"]:
            if target.name == "other-profile":
                target.write_text("original")
            self.profile.symlink_to(target)
            self.assertNotEqual(self.install().returncode, 0)
            self.assertEqual(os.readlink(self.profile), str(target))
            self.profile.unlink()


if __name__ == "__main__":
    unittest.main()
