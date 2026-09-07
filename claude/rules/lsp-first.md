# LSP-First Navigation (CRITICAL)

When the Serena MCP server is connected, ALL agents MUST use its symbolic tools over Grep for semantic navigation.

| Task | Serena Tool |
|------|-------------|
| File/symbol structure overview | `get_symbols_overview` |
| Find a symbol / read its body (definition) | `find_symbol` (`name_path`, `include_body`) |
| Who references / calls a symbol | `find_referencing_symbols` |
| Edit a symbol in place | `replace_symbol_body` / `insert_after_symbol` / `insert_before_symbol` |
| Broad text/pattern search | `search_for_pattern` |

Grep/Glob = fallback ONLY when the symbolic tools return empty or you're searching non-symbol text.
