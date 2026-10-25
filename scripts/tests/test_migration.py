"""Exercise migration failures without touching the real home directory."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]


class MigrationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo"
        self.home = self.root / "home"
        self.bin = self.root / "bin"
        (self.repo / "scripts").mkdir(parents=True)
        self.source = self.home / ".config/demo"
        self.source.mkdir(parents=True)
        (self.source / "original").write_text("keep me")
        self.bin.mkdir()
        shutil.copy2(ROOT / "scripts/add-stow-config.sh", self.repo / "scripts")
        self.env = {**os.environ, "HOME": str(self.home),
                    "PATH": f"{self.bin}:{os.environ['PATH']}"}

    def mock(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/sh\n" + body + "\n")
        path.chmod(0o755)

    def run_migration(self):
        return subprocess.run(
            ["bash", str(self.repo / "scripts/add-stow-config.sh"), "demo"],
            env=self.env, capture_output=True, text=True,
        )

    def assert_original_preserved(self):
        self.assertEqual((self.source / "original").read_text(), "keep me")
        self.assertFalse((self.repo / "stow/.config/demo").exists())

    def test_partial_stow_failure_removes_link_and_restores_original(self):
        self.mock("stow", 'ln -s "$HOME/../repo/stow/.config/demo" "$HOME/.config/demo"; exit 1')
        self.assertNotEqual(self.run_migration().returncode, 0)
        self.assertFalse(self.source.is_symlink())
        self.assert_original_preserved()

    def test_failed_restore_keeps_backup_and_copy(self):
        real_mv = shutil.which("mv")
        self.mock("mv", f'if [ "$1" = "--" ]; then exit 1; fi\nexec "{real_mv}" "$@"')
        self.mock("stow", "exit 1")
        result = self.run_migration()
        self.assertNotEqual(result.returncode, 0)
        backups = list((self.home / ".config").glob(".demo.stow-backup.*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual((backups[0] / "original").read_text(), "keep me")
        self.assertTrue((self.repo / "stow/.config/demo/original").exists())

    def test_successful_migration(self):
        result = self.run_migration()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(self.source.is_symlink() or (self.source / "original").is_symlink())
        self.assertEqual((self.source / "original").read_text(), "keep me")
        self.assertFalse(list((self.home / ".config").glob(".demo.stow-backup.*")))


if __name__ == "__main__":
    unittest.main()
