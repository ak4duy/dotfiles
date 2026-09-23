#!/usr/bin/env bash
set -e

install=(pacman -S --needed)

pkgs=(
  alacritty
  fastfetch
  fish
  git-cliff
  niri
  noctalia-shell
  neovim
  quickshell
  zed
  tmux
  git-cliff
)

"${install[@]}" "${pkgs[@]}"