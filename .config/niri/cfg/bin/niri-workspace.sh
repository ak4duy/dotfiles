#!/usr/bin/env bash
set -euo pipefail

operation="${1:-}"
slot="${2:-}"

MAIN="DP-1"
SECOND="HDMI-A-1"

if [[ ! "$operation" =~ ^(switch|move)$ ]] || [[ ! "$slot" =~ ^([1-9]|10)$ ]]; then
    echo "Usage: $0 {switch|move} {1..10}" >&2
    exit 1
fi

output="$(niri msg --json focused-output | jq -er '.name')"

if [[ "$output" == "$MAIN" ]]; then
    case "$slot" in
        1) target="web" ;;
        2) target="chat" ;;
        3) target="code" ;;
        4) target="work" ;;
        5) target="term" ;;
        *) target="$slot" ;;
    esac
elif [[ "$output" == "$SECOND" ]]; then
    target="$((slot + 10))"
else
    echo "Unsupported output: $output (expected $MAIN or $SECOND)" >&2
    exit 1
fi

if ! index="$(niri msg --json workspaces | jq -er \
    --arg target "$target" --arg output "$output" \
    '.[] | select(.name == $target and .output == $output) | .idx')"; then
    echo "Workspace '$target' is not available on $output; check the loaded Niri config." >&2
    exit 1
fi

case "$operation" in
    switch)
        niri msg action focus-workspace "$index"
        ;;
    move)
        niri msg action move-column-to-workspace --focus false "$index"
        ;;
esac
