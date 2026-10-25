"""Verify --check with real Stow and isolated home/configuration fixtures."""

import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]


class CheckTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-check-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo"
        self.home = self.root / "home"
        self.bin = self.root / "bin"
        self.marker = self.root / "unexpected-command"
        self.home.mkdir()
        self.bin.mkdir()
        self.repo.mkdir()
        shutil.copy2(ROOT / "install.sh", self.repo)
        shutil.copytree(ROOT / "scripts", self.repo / "scripts",
                        ignore=shutil.ignore_patterns("tests", "__pycache__"))
        shutil.copytree(ROOT / "system", self.repo / "system")
        for name in [".profile", ".zprofile", ".zshenv", ".zshrc", ".gitconfig",
                     ".config/nvim/init.lua"]:
            path = self.repo / "stow" / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("")
        shutil.copy2(ROOT / "stow/.stow-local-ignore", self.repo / "stow")
        # Any installer command that could write, use the network, or launch
        # Neovim fails loudly if the check path accidentally executes it.
        for command in ["sudo", "apt", "git", "curl", "wget", "npm", "make",
                        "chsh", "install", "mkdir", "mv", "cp", "rm", "ln", "nvim"]:
            path = self.bin / command
            path.write_text('#!/bin/sh\nprintf "%s\\n" "$0" >> "$CHECK_MARKER"\nexit 99\n')
            path.chmod(0o755)
        self.env = {**os.environ, "HOME": str(self.home),
                    "PATH": f"{self.bin}:{os.environ['PATH']}",
                    "CHECK_MARKER": str(self.marker)}

    def snapshot(self):
        result = {}
        for base in [self.repo, self.home]:
            for path in [base, *base.rglob("*")]:
                mode = path.lstat().st_mode
                if path.is_symlink():
                    contents = os.readlink(path)
                elif path.is_file():
                    contents = hashlib.sha256(path.read_bytes()).hexdigest()
                else:
                    contents = None
                result[str(path)] = (mode, contents)
        return result

    def run_check(self, *args):
        before = self.snapshot()
        result = subprocess.run(
            ["/bin/bash", str(self.repo / "install.sh"), *args],
            env=self.env, capture_output=True, text=True,
        )
        self.assertEqual(before, self.snapshot(), "Check changed the fixture")
        self.assertFalse(self.marker.exists(), "Check executed an installer command")
        return result

    def test_clean_home(self):
        result = self.run_check("--check")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("0 error(s)", result.stdout)

    def test_stock_profile_is_expected(self):
        (self.home / ".profile").write_text("# stock profile\n")
        result = self.run_check("--check")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("will replace ~/.profile", result.stdout)

    def test_missing_source_and_invalid_json(self):
        (self.repo / "system/90-clamshell.conf").unlink()
        (self.repo / "system/firefox/policies.json").write_text("{")
        result = self.run_check("--check")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Missing or unreadable source", result.stdout)
        self.assertIn("Invalid Firefox policy JSON", result.stdout)

    def test_broken_module_is_checked_without_sourcing(self):
        (self.repo / "scripts/packages.sh").write_text("if\n")
        result = self.run_check("--check")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Invalid Bash syntax", result.stdout)
        self.assertIn("Checks complete:", result.stdout)

if __name__ == "__main__":
    unittest.main()
