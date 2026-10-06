#!/usr/bin/env bash

target="$1"

niri msg action move-column-to-workspace --focus false "$target"