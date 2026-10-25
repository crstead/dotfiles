#!/usr/bin/env python3
"""Toggle built-in panels on lid events without hardcoding connector numbers."""

import json
import subprocess
import sys


def lid_commands(outputs, closed):
    def internal(output):
        return output["name"].startswith(("eDP-", "LVDS-", "DSI-"))

    # Keep a usable display when closing the lid without an active monitor.
    external_active = any(o.get("active") and not internal(o) for o in outputs)
    action = "disable" if closed and external_active else "enable"
    return [f'output {json.dumps(o["name"])} {action}' for o in outputs if internal(o)]


if __name__ == "__main__":
    if sys.argv[1:] not in (["open"], ["closed"]):
        sys.exit("Usage: lid.py open|closed")
    result = subprocess.run(
        ["swaymsg", "-r", "-t", "get_outputs"],
        check=True, capture_output=True, text=True,
    )
    for command in lid_commands(json.loads(result.stdout), sys.argv[1] == "closed"):
        subprocess.run(["swaymsg", command], check=True)
