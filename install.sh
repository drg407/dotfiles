#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CLAUDE="$HOME/.claude"

link_dir() {
    local src="$DOTFILES/claude/$1"
    local dst="$CLAUDE/$1"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "  Backing up $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    if [ ! -L "$dst" ]; then
        ln -s "$src" "$dst"
        echo "  Linked: $dst -> $src"
    else
        echo "  Already linked: $dst"
    fi
}

link_skill() {
    local src="$DOTFILES/claude/skills/$1"
    local dst="$CLAUDE/skills/$1"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "  Backing up $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    if [ ! -L "$dst" ]; then
        ln -s "$src" "$dst"
        echo "  Linked: $dst -> $src"
    else
        echo "  Already linked: $dst"
    fi
}

echo "==> Linking Claude rules..."
link_dir "rules"

echo "==> Linking Claude skills..."
for skill_dir in "$DOTFILES/claude/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    link_skill "$(basename "$skill_dir")"
done

echo "Done."
