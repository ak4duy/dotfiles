#!/usr/bin/env bash
set -e

install=(yay -S --needed)

pkgs=(
  alacritty
  fastfetch
  fish
  niri
  noctalia-shell
  neovim
  quickshell
  zed
  tmux
)

"${install[@]}" "${pkgs[@]}"