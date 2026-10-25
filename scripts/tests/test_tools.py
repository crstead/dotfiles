"""Exercise tool version checks and failure handling without network access."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPTS = Path(__file__).resolve().parents[1]


class ToolTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-tools-")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.bin = self.home / ".local/bin"
        self.bin.mkdir(parents=True)
        self.work = self.home / "temporary"
        self.work.mkdir()
        self.env = {**os.environ, "HOME": str(self.home), "TMPDIR": str(self.work),
                    "PATH": f"{self.bin}:{os.environ['PATH']}"}

    def executable(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/sh\n" + body + "\n")
        path.chmod(0o755)

    def run_script(self, code):
        return subprocess.run(
            ["bash", "-eu", "-c", 'source "$1/helpers.sh"; source "$1/packages.sh"; source "$1/neovim.sh"; ' + code, "bash", str(SCRIPTS)],
            env=self.env, capture_output=True, text=True,
        )

    def test_version_boundaries(self):
        result = self.run_script("""
            version_at_least 22.0.0 22.0.0
            version_at_least 24.1.0 22.0.0
            version_at_least 0.27.1 0.26.1
            ! version_at_least 0.26.0 0.26.1
            ! version_at_least 18.20.8 22.0.0
            ! version_at_least 22.0.0-rc.1 22.0.0
            ! version_at_least invalid 22.0.0
        """)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_bad_checksum_preserves_tree_sitter(self):
        self.executable("tree-sitter", "echo 'tree-sitter 0.25.0'")
        self.executable("curl", '\n'.join([
            'while [ "$#" -gt 0 ]; do',
            '    if [ "$1" = -o ]; then output="$2"; shift; fi',
            '    shift',
            'done',
            'echo corrupt > "$output"',
        ]))
        before = (self.bin / "tree-sitter").read_bytes()
        result = self.run_script("if install_tree_sitter; then exit 97; fi")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("FAILED", result.stdout)
        self.assertEqual((self.bin / "tree-sitter").read_bytes(), before)
        self.assertFalse(list(self.work.iterdir()))

    def test_nvm_installs_default_and_removes_only_legacy_links(self):
        nvm_dir = self.home / ".nvm"
        nvm_dir.mkdir()
        (nvm_dir / "nvm.sh").write_text(
            'nvm() { printf "%s\\n" "$*" >> "$HOME/nvm-calls"; }\n'
        )
        self.executable("curl", "exit 99")
        legacy = self.home / ".local/share/node-v22.1.0-linux-x64/bin/node"
        (self.bin / "node").symlink_to(legacy)
        self.executable("npm", "echo custom-npm")
        (self.bin / "npx").symlink_to(self.home / "custom-npx")
        result = self.run_script("install_node")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.home / "nvm-calls").read_text().splitlines(),
                         ["install --lts", "alias default lts/*", "use --lts"])
        self.assertFalse((self.bin / "node").is_symlink())
        self.assertEqual((self.bin / "npm").read_text(), "#!/bin/sh\necho custom-npm\n")
        self.assertEqual(os.readlink(self.bin / "npx"), str(self.home / "custom-npx"))


if __name__ == "__main__":
    unittest.main()
