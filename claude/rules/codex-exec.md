# Codex via Bash (All Projects)

There is no Codex MCP server. `codex mcp-server` was deprecated and then removed from the Codex CLI in 0.155.0, and the MCP entry was deleted on 2026-10-05. To get a Codex (OpenAI) second opinion, call the CLI non-interactively from Bash.

## Command

```bash
codex exec -s read-only --ephemeral --color never \
  -C <project dir> -o <scratchpad>/codex-last.txt \
  "<prompt>" </dev/null > <scratchpad>/codex-log.txt 2>&1
```

Then read `<scratchpad>/codex-last.txt`. It holds only Codex's final message. The log file has the full transcript; read it only if the call fails.

- `-s read-only`: the default. Use `-s workspace-write` only when the user explicitly wants Codex to edit files. Never use `danger-full-access`.
- `-C <dir>`: the repo Codex should look at. Outside a git repo, add `--skip-git-repo-check`.
- `--ephemeral`: don't save the session.
- `</dev/null`: always include it. Without it, Codex waits on stdin.
- Set a Bash `timeout` of 300000 or more. Calls take about 30s to several minutes.

## When to use

Only when the user asks for Codex/OpenAI, or for a non-Qwen second opinion on a hard design or review question. Qwen remains the default delegate (see qwen-delegation.md).

## Failure handling

If the log shows `401` or `refresh token was revoked`, the login has expired. Tell the user to run `! codex login`. Don't retry.
