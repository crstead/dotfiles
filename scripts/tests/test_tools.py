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

    def test_bad_checksums_preserve_existing_tools(self):
        self.executable("node", "echo v18.19.1")
        self.executable("tree-sitter", "echo 'tree-sitter 0.25.0'")
        self.executable("curl", '''
            while [ "$#" -gt 0 ]; do
                if [ "$1" = -o ]; then output="$2"; shift; fi
                shift
            done
            case "$output" in
                *SHASUMS256.txt)
                    printf '%064d  node-v22.99.1-linux-x64.tar.xz\\n' 0 > "$output"
                    printf '%064d  node-v22.99.1-linux-arm64.tar.xz\\n' 0 >> "$output" ;;
                *) echo corrupt > "$output" ;;
            esac
        ''')
        before = {name: (self.bin / name).read_bytes() for name in ["node", "tree-sitter"]}
        result = self.run_script("if install_node; then exit 98; fi; if install_tree_sitter; then exit 97; fi")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("FAILED", result.stdout)
        for name, content in before.items():
            self.assertEqual((self.bin / name).read_bytes(), content)
        self.assertFalse(list(self.work.iterdir()))


if __name__ == "__main__":
    unittest.main()
