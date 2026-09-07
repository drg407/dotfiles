# LSP-First Navigation

When the Serena MCP server is connected, prefer its symbolic tools over Grep/Read for semantic navigation **when the target warrants it**.

## When to reach for Serena

Use Serena when at least one is true:
- Target file is **>500 lines** (whole-file Read gets expensive)
- You need **cross-file references** (`find_referencing_symbols` beats Grep — it understands scoping and returns caller context inline)
- You're editing a **named symbol** (`replace_symbol_body` sends less diff context than `Edit` for large functions/classes)
- You need a **structural overview** of an unfamiliar file (`get_symbols_overview` returns ~1KB vs a full Read)

## When native Read/Grep is fine

- Small files (<500 lines) — the whole file fits in what Serena's tool preamble costs
- Text-only searches (log strings, error messages, config values)
- Single-line edits where you already know the location

## Tool map (when Serena is the right call)

| Task | Serena Tool |
|------|-------------|
| File/symbol structure overview | `get_symbols_overview` |
| Find a symbol / read its body | `find_symbol` (`name_path_pattern`, `include_body`) |
| Who references / calls a symbol | `find_referencing_symbols` |
| Edit a symbol in place | `replace_symbol_body` / `insert_after_symbol` / `insert_before_symbol` |
| Broad text/pattern search | `search_for_pattern` |

Note: `find_symbol` takes `name_path_pattern` (not `name_path`) as the required arg.

## Why (2026-09-06 head-to-head)

Verified on qwen-mcp `server.ts` (1010 lines):
- Serena `find_symbol runAgentLoop`: ~5.5KB (function body only) vs `Read` full file: ~35KB → **~30KB saved**
- Serena `find_referencing_symbols`: ~400B with 3-line context vs `Grep` + follow-up Read: ~2-5KB
- Serena `get_symbols_overview`: ~1KB grouped by kind vs built-in `LSP documentSymbol`: ~15KB (dumps every nested var/property)

The built-in `LSP` tool is a viable fallback but requires `typescript-language-server` + `typescript` installed in Claude's cwd node_modules (not the target project's) — Serena bundles its own language servers.
