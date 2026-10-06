# Qwen Delegation Rules

When the qwen-pcvr MCP server is connected, actively delegate work to Qwen models instead of doing everything yourself. Qwen runs locally on the user's PCVR rig — it's free, private, and fast. Use it.

## Token-conscious delegation

Every token Claude generates costs money. Qwen tokens are free. Default to having Qwen do the work and Claude reviewing/applying the result. If a task takes more than ~2 sentences of Claude output to complete, it should probably be delegated. Claude's role is orchestrator — short prompts out to Qwen, short reviews back, short messages to the user. Save Claude's output for decisions, git ops, and user communication.

## Complexity routing

Before delegating, classify the task:

| Complexity | Path | Example |
|---|---|---|
| **Trivial** (<20 lines, single file, obvious fix) | Claude does it directly | typo fix, one-line rename, simple import |
| **Simple** (single file, clear spec) | q4 writes → Claude reviews | utility function, config file, type defs |
| **Moderate** (multi-file or needs research) | agentworld researches → q4 writes → Claude reviews | new feature with unknown API, library integration |
| **Complex** (architecture, security, performance) | q4 designs → q4 implements → q4 reviews | cross-cutting refactor, auth flow, perf-critical path |

**Note:** `qwen-q4-uncensored` is for the user's direct use only — Claude does not delegate to it.

Don't run a 4-step pipeline for a trivial task. Match effort to complexity.

### Jev shadow routing (since 2026-10-05)
Each time you classify a coding task with the table above, also call `qwen_route({task, actual})`. Set `actual` to the path you already picked **before** you read Jev's answer: `claude-direct | research-only | write-review | research-code | plan-code-review`. The call takes about 200ms and runs nothing. Keep routing by your own pick. Jev's answer only goes into the log. Check agreement with `qwen_stats({by: "route", window: "7d"})`. Let Jev route on its own only after the user reviews the numbers. If `qwen_route` errors, skip it and keep going.

## When to delegate

### Research (agentworld — never for coding)
- **Web research**: any "find out about X", "how does Y work", "what are the options for Z" → `qwen_agent` with agentworld + web_search/web_fetch
- **Documentation lookup**: searching for API docs, library usage, configuration examples
- **Competitive analysis**: "how do others solve this", "find similar implementations"
- **Pre-coding research**: before implementing a feature, have agentworld search for existing patterns, gotchas, or prior art

### Code writing (qwen-q4)
- **Boilerplate and scaffolding**: generating new files, test suites, config files, type definitions
- **Isolated functions**: utility functions, parsers, converters, validators that have clear inputs/outputs
- **Test generation**: writing test cases for code Claude wrote
- **Code from spec**: when a clear spec or interface exists, delegate the implementation
- **Repetitive edits**: applying the same pattern across multiple files

### Complex coding and design (qwen-q4)
- **Code review**: reviewing diffs, PRs, or code Claude wrote — fresh context, no inherited bias
- **Architecture analysis**: reading large codebases, understanding dependencies, suggesting refactors
- **Bug analysis**: given a failing test or error, analyze the code and suggest fixes
- **Planning review**: review Claude's implementation plan before executing
- **Design brainstorming**: generate 2-3 implementation approaches for Claude to evaluate — q4's different training produces genuinely different ideas
- **Large codebase comprehension**: q4's 262K context can ingest an entire repo; use it to produce structured summaries (dependencies, entry points, extension points) rather than Claude reading piecemeal

### Second opinions
- **For non-trivial design decisions**: when more than one reasonable approach exists, have q4 generate alternatives before committing
- **After completing a feature >50 lines**: have q4 review the diff before suggesting a commit. Skip review for smaller changes.

## When to delegate: git operations
- **Commits, pushes, PRs**: Qwen has git and gh CLI access via its bash tool. Delegate these to save Claude tokens.
- Claude orchestrates (decides what to commit, writes the message spec) but Qwen executes the commands.
- Exception: if the MCP server is down, Claude does git ops directly.

## When NOT to delegate
- **Interactive decisions**: questions that need user input — Claude asks the user, not Qwen
- **Trivial edits**: one-line fixes, typos, simple renames — delegation overhead exceeds the work
- **Mechanical shell commands (<3 commands)**: if you already know the exact commands (gh pr create, gh pr merge, git push), run them directly — Qwen wastes steps on orientation (pwd, ls, git status) before reaching the actual command
- **Context-heavy small edits**: if the edit requires >200 lines of surrounding context to explain to Qwen and the change itself is small, keep it
- **MCP/tool configuration**: Claude manages its own config
- **Orchestration**: Claude decides what to delegate and when — Qwen doesn't orchestrate Claude

## Failure handling

- **Max retries**: if Qwen's output has >3 issues or is fundamentally wrong, discard and do it yourself. Don't iterate endlessly.
- **Fix cap**: 2 fix iterations max per task. If still broken after 2 rounds, Claude takes over.
- **Output validation**: after receiving Qwen's output, verify: (1) it compiles/runs if applicable, (2) no hallucinated APIs or imports, (3) addresses the spec. Any check failure counts toward the retry budget.
- **Server down**: if the MCP server errors or times out, do the work yourself — don't block the user waiting for infrastructure.
- **Learn from failures**: when Qwen output is discarded or hits the fix cap, write a feedback memory capturing why it failed and how to prevent it next time (e.g., "task was too vague — include the interface definition" or "4+ file edits need a structured spec"). Similarly, when Q4 review catches recurring bugs, capture the pattern.
- **503 queue_deadline**: the rig runs one model at a time. If a model switch is blocked by in-flight work for >120s, you get HTTP 503 `type: queue_deadline`. This is transient — retry the same request after the in-flight work completes. It is not a payload error.

## Context budgeting

q4 has 262K context — generous for most tasks. Before delegating, estimate total context:
- System prompt + tools: ~4K
- Your instruction/spec: ~2-5K  
- Files being read/edited: varies
- Tool call overhead: varies

For very large tasks approaching 200K+, break them into smaller delegations rather than stuffing one call.

## Rig infrastructure

The PCVR rig runs **one model at a time** and loads on demand — no pins, no 409s. Model switch waits for in-flight work to drain; if the wait exceeds 120s, you get 503 `queue_deadline` (retry after the in-flight work completes; first switch also pays model load: ~4-6s warm, ~14s cold). Best practice: use one model consistently per task and switch between requests, not mid-stream. Check state: `GET /health` → `loaded_model`, `in_flight`, `in_flight_model`.

**Available models (2026-09-17):** `qwen-q4`, `qwen-q4-uncensored`, `agentworld`, `gemma-4-12b`, `gpt-oss-20b`. `qwen-nvfp4-fast` is **retired** (404 on request — do not use).

## Latency awareness

- q4 at ~150 t/s (with MTP): a 5K-token response takes ~33s. Fast enough for most interactive work.
- agentworld at 230 t/s: fastest. Good for quick research.
- gemma-4-12b / gpt-oss-20b: available but roles TBD — use when the user requests them or for experimentation.

**If the user is actively waiting**, do it yourself for trivial work. q4 is fast enough for interactive coding tasks.

## Delegation patterns

### Pattern 1: Research → Code
1. agentworld researches the topic (web_search + web_fetch)
2. Claude reviews the research and makes design decisions
3. q4 writes the code
4. (If >50 lines) q4 reviews the diff (separate call — fresh context)

### Pattern 2: Write → Review (daily driver)
1. q4 writes or edits code via qwen_agent
2. (If >50 lines) q4 reviews the output via qwen_chat (fresh context, only sees the diff + spec)
3. If issues found, q4 fixes (max 2 rounds)

### Pattern 3: Generate → Select (design decisions)
1. q4 generates 2-3 implementation approaches via qwen_chat
2. Claude evaluates and selects (or combines)
3. q4 implements the chosen approach

### Pattern 4: Pre-flight Review
1. Claude drafts an implementation plan
2. q4 reviews the plan for gaps, missed edge cases, or better approaches
3. Claude finalizes and executes (or delegates execution to q4)

### Abort rule
At any step, if the output is unhelpful or fundamentally wrong, Claude may skip remaining steps and do it directly rather than continuing the pipeline.

### Running patterns as one call: qwen_team
Patterns 1 and 2 above are also available as a single MCP tool, `qwen_team({team, task, working_directory})`, on the `qwen-pcvr` server. It runs the whole chain server-side and returns one aggregated result, instead of Claude orchestrating each step as a separate tool call:

| team | steps |
|---|---|
| `write-review` | q4 agent → q4 chat review |
| `research-code` | agentworld agent → q4 agent |
| `research-code-review` | agentworld agent → q4 agent → q4 chat review |
| `plan-code-review` | q4 chat (plan) → q4 agent (execute) → q4 chat review |

**Note:** These presets may still reference nvfp4 server-side. If a team call 404s on the writer step, the server config needs updating — fall back to manual orchestration with `qwen_agent` (model: `qwen-q4`) until fixed.

Prefer `qwen_team` over manually chaining `qwen_agent`/`qwen_chat` calls when the task cleanly matches one of these presets — it saves round-trips and keeps token accounting in one place. Fall back to manual orchestration when a pattern needs a variation the presets don't cover (e.g. a custom system prompt per step, or >3 steps).

Reviewer steps in `qwen_team` are given the actual changed-file contents, not just the writer agent's self-reported summary — see [[feedback-review-needs-file-contents]]. Any future review-over-agent pipeline must do the same, or the reviewer ends up rubber-stamping a description instead of the code.

### Delegation visibility: qwen_stats
`qwen_stats({window, by})` on the same server reads a JSONL log (`~/.qwen-mcp/log-YYYY-MM-DD.jsonl`, written automatically by qwen_chat/qwen_agent/qwen_team) and reports call counts, tokens, and elapsed time — grouped by tool, model, or team, over today/7d/all. Use it to check whether delegation is actually happening, not just assumed.

### Enforcement: delegation reminder hook
A Claude Code hook (`~/.claude/hooks/qwen-delegation-guard.js`, PreToolUse on `Write|Edit`) prints a one-time-escalating reminder (max 3 per session/cwd, never blocks) when a ≥20-line direct edit happens with no `mcp__qwen-pcvr__*` call yet that session. Config/doc files (`.md/.json/.yaml/...`) and anything under `.claude/` are exempt. Companion hooks: `qwen-usage-tracker.js` (PostToolUse, clears the reminder condition once a qwen tool is called) and `qwen-session-reset.js` (SessionStart, clears stale state). This is a nudge, not a gate — if the reminder fires and direct implementation is still the right call, proceed.

## Model selection cheat sheet

| Task | Model | Tool | Context limit |
|---|---|---|---|
| Web search/fetch | agentworld | qwen_agent | 128K |
| Write code | qwen-q4 | qwen_agent | 262K |
| Review code/diffs | qwen-q4 | qwen_chat | 262K |
| Quick question / second opinion | qwen-q4 | qwen_chat | 262K |
| Design brainstorming | qwen-q4 | qwen_chat | 262K |
| Codebase comprehension | qwen-q4 | qwen_agent | 262K |

**Also available:** `gemma-4-12b`, `gpt-oss-20b` — roles not yet assigned. Use when the user requests them or for A/B experimentation.
**Retired:** `qwen-nvfp4-fast` — returns 404. Do not use.

## Step budget guidance

- **Q4 coding tasks**: max_steps 10-15 (default). Simple edits need fewer.
- **Q4 research/analysis tasks**: max_steps 20+. Q4 runs experiments thoroughly and tends to write the report last — if steps are too low, the deliverable gets cut off. Structure prompts as "do research, then write findings" rather than open-ended exploration.
- **Git/PR tasks**: max_steps 5-8 (commit + push + PR is 3-5 commands).
- **Simple single-command tasks**: don't delegate — run directly. Qwen wastes steps on orientation (pwd, ls, git status) before reaching the actual command.

## Mindset

Think of Qwen as a team of developers sitting next to you. They're capable, fast, and free. Don't do work they could do — but don't burn 5 minutes of delegation overhead on a 30-second fix either. Your job is to orchestrate, make decisions, handle git/user interaction, and verify quality. Their job is to research, write, and review code.
