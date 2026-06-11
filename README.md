# dotfiles

Personal config, managed with symlinks.

## Contents

- `claude/skills/` — Custom Claude Code skills (user-authored; plugin skills reinstalled via plugin)
- `claude/rules/` — Claude Code global rules applied across all projects

## Restore on a new machine

1. Clone: `git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles`
2. Run: `cd ~/dotfiles && bash install.sh`
3. Reinstall Claude Code plugins (e.g. Firecrawl MCP) to restore plugin-managed skills

## How sync works

`~/.claude/rules` and each user skill under `~/.claude/skills/` are symlinks into this repo. Any edits show up immediately in `git status`.

## What NOT to commit when adding more dotfiles

Never commit files with API keys, tokens, or secrets (e.g. `~/.claude/settings.json`, shell history, `.env` files).
