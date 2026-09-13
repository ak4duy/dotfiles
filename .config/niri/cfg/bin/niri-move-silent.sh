#!/usr/bin/env bash

target="$1"

current="$(niri msg --json workspaces | jq -r '.[] | select(.is_active) | .idx')"

niri msg action move-column-to-workspace "$target"
niri msg action focus-workspace "$current"