#!/usr/bin/env python3

import argparse
import fcntl
import json
import logging
import os
import socket
import subprocess
from pathlib import Path

OUTPUT = "HDMI-A-1"
WORKSPACES = {str(number) for number in range(11, 21)}
LOG = logging.getLogger("niri-portrait-stack")


def choose_stack(windows, workspaces, window_id):
    eligible = {
        workspace["id"]
        for workspace in workspaces
        if workspace.get("output") == OUTPUT and workspace.get("name") in WORKSPACES
    }
    window = next((item for item in windows if item["id"] == window_id), None)
    if window is None or window.get("workspace_id") not in eligible:
        return None
    position = window.get("layout", {}).get("pos_in_scrolling_layout")
    if window.get("is_floating", False) or position is None:
        return None

    columns = {}
    for item in windows:
        item_position = item.get("layout", {}).get("pos_in_scrolling_layout")
        if (
            item.get("workspace_id") == window["workspace_id"]
            and not item.get("is_floating", False)
            and item_position is not None
        ):
            columns.setdefault(item_position[0], []).append(item["id"])

    column = position[0]
    if len(columns.get(column, [])) != 1:
        return None
    for neighbor, direction in ((column - 1, "left"), (column + 1, "right")):
        peers = columns.get(neighbor, [])
        if len(peers) == 1:
            return direction, peers[0]
    return None


def query(subject):
    result = subprocess.run(
        ["niri", "msg", "--json", subject],
        check=True,
        capture_output=True,
        text=True,
        timeout=5,
    )
    return json.loads(result.stdout)


def action(name, window_id):
    subprocess.run(
        ["niri", "msg", "action", name, "--id", str(window_id)],
        check=True,
        capture_output=True,
        text=True,
        timeout=5,
    )


def arrange(window_ids=None):
    workspaces = query("workspaces")
    windows = query("windows")
    if window_ids is None:
        window_ids = [
            window["id"]
            for window in sorted(
                windows,
                key=lambda item: (
                    item.get("workspace_id") or 0,
                    item.get("layout", {}).get("pos_in_scrolling_layout") or [0, 0],
                ),
            )
        ]
    for window_id in window_ids:
        pair = choose_stack(windows, workspaces, window_id)
        if pair is None:
            continue
        direction, peer_id = pair
        action("consume-or-expel-window-" + direction, window_id)
        action("reset-window-height", window_id)
        action("reset-window-height", peer_id)
        LOG.info("Stacked windows %s and %s", peer_id, window_id)
        windows = query("windows")


def placement(window):
    return window.get("workspace_id"), window.get("is_floating", False)


def handle_event(event, placements, outputs):
    if "WorkspacesChanged" in event:
        updated = {
            item["id"]: (item.get("output"), item.get("name"))
            for item in event["WorkspacesChanged"]["workspaces"]
        }
        moved_here = any(
            output == OUTPUT
            and name in WORKSPACES
            and outputs.get(workspace_id) != (output, name)
            for workspace_id, (output, name) in updated.items()
        )
        outputs.clear()
        outputs.update(updated)
        if moved_here:
            arrange()
    elif "WindowsChanged" in event:
        windows = event["WindowsChanged"]["windows"]
        placements.clear()
        placements.update((item["id"], placement(item)) for item in windows)
        arrange()
    elif "WindowOpenedOrChanged" in event:
        window = event["WindowOpenedOrChanged"]["window"]
        previous = placements.get(window["id"])
        placements[window["id"]] = placement(window)
        if previous != placement(window):
            arrange([window["id"]])
    elif "WindowClosed" in event:
        placements.pop(event["WindowClosed"]["id"], None)


def watch(socket_path):
    placements, outputs = {}, {}
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
        connection.connect(socket_path)
        connection.sendall(b'"EventStream"\n')
        with connection.makefile("r", encoding="utf-8") as events:
            for line in events:
                event = json.loads(line)
                if "Err" in event:
                    raise RuntimeError(event["Err"])
                try:
                    handle_event(event, placements, outputs)
                except (subprocess.SubprocessError, ValueError) as error:
                    LOG.warning("Could not arrange portrait windows: %s", error)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--once", action="store_true", help="Arrange existing windows and exit"
    )
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(name)s: %(message)s")
    if args.once:
        arrange()
        return

    socket_path = os.environ.get("NIRI_SOCKET")
    if not socket_path:
        parser.error("NIRI_SOCKET is unset; run this inside a Niri session")
    runtime_dir = Path(os.environ.get("XDG_RUNTIME_DIR", Path(socket_path).parent))
    with (runtime_dir / "niri-portrait-stack.lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            LOG.info("Already running")
            return
        watch(socket_path)


if __name__ == "__main__":
    main()
