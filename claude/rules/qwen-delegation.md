# Qwen Delegation Rules

When the qwen-pcvr MCP server is connected, actively delegate work to Qwen models instead of doing everything yourself. Qwen runs locally on the user's PCVR rig — it's free, private, and fast. Use it.

## Token-conscious delegation

Every token Claude generates costs money. Qwen tokens are free. Default to having Qwen do the work and Claude reviewing/applying the result. If a task takes more than ~2 sentences of Claude output to complete, it should probably be delegated. Claude's role is orchestrator — short prompts out to Qwen, short reviews back, short messages to the user. Save Claude's output for decisions, git ops, and user communication.

## Complexity routing

Before delegating, classify the task:

| Complexity | Path | Example |
|---|---|---|
| **Trivial** (<20 lines, single file, obvious fix) | Claude does it directly | typo fix, one-line rename, simple import |
| **Simple** (single file, clear spec) | nvfp4 writes → Claude reviews | utility function, config file, type defs |
| **Moderate** (multi-file or needs research) | agentworld researches → nvfp4 writes → Claude reviews | new feature with unknown API, library integration |
| **Complex** (architecture, security, performance) | q4 designs → nvfp4 implements → q4 reviews | cross-cutting refactor, auth flow, perf-critical path |

**Note:** `qwen-q4-uncensored` is for the user's direct use only — Claude does not delegate to it.

Don't run a 4-step pipeline for a trivial task. Match effort to complexity.

## When to delegate

### Research (agentworld — never for coding)
- **Web research**: any "find out about X", "how does Y work", "what are the options for Z" → `qwen_agent` with agentworld + web_search/web_fetch
- **Documentation lookup**: searching for API docs, library usage, configuration examples
- **Competitive analysis**: "how do others solve this", "find similar implementations"
- **Pre-coding research**: before implementing a feature, have agentworld search for existing patterns, gotchas, or prior art

### Code writing (qwen-nvfp4-fast)
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
- **Mechanical shell commands (<3 commands)**: if you already know the exact commands (gh pr create, gh pr merge, git push), run them directly — nvfp4 wastes steps on orientation (pwd, ls, git status) before reaching the actual command
- **Context-heavy small edits**: if the edit requires >200 lines of surrounding context to explain to Qwen and the change itself is small, keep it
- **MCP/tool configuration**: Claude manages its own config
- **Orchestration**: Claude decides what to delegate and when — Qwen doesn't orchestrate Claude

## Failure handling

- **Max retries**: if Qwen's output has >3 issues or is fundamentally wrong, discard and do it yourself. Don't iterate endlessly.
- **Fix cap**: 2 fix iterations max per task. If still broken after 2 rounds, Claude takes over.
- **Output validation**: after receiving Qwen's output, verify: (1) it compiles/runs if applicable, (2) no hallucinated APIs or imports, (3) addresses the spec. Any check failure counts toward the retry budget.
- **Server down**: if the MCP server errors or times out, do the work yourself — don't block the user waiting for infrastructure.
- **Learn from failures**: when Qwen output is discarded or hits the fix cap, write a feedback memory capturing why it failed and how to prevent it next time (e.g., "task was too vague for nvfp4 — include the interface definition" or "4+ file edits unreliable with nvfp4, use q4"). Similarly, when Q4 review catches recurring bugs in nvfp4 output, capture the pattern.

## Context budgeting

nvfp4-fast has 80K context. Before delegating, estimate total context:
- System prompt + tools: ~4K
- Your instruction/spec: ~2-5K  
- Files being read/edited: varies
- Tool call overhead: varies

**If estimated total >60K, use q4 (262K) instead of nvfp4.** For multi-file work touching 4+ files, default to q4.

## Latency awareness

- q4 at 74 t/s: a 5K-token response takes ~68s. Fine for background/async work. Avoid for interactive responses where the user is waiting.
- nvfp4 at 153 t/s: 2x faster. Good for interactive coding tasks.
- agentworld at 230 t/s: fastest. Good for quick research.

**If the user is actively waiting**, prefer nvfp4 or do it yourself. Reserve q4 for tasks where the user has asked for depth or the task is clearly non-urgent.

## Delegation patterns

### Pattern 1: Research → Code
1. agentworld researches the topic (web_search + web_fetch)
2. Claude reviews the research and makes design decisions
3. nvfp4 writes the code
4. (If >50 lines) q4 reviews the diff

### Pattern 2: Write → Review (daily driver)
1. nvfp4 writes or edits code via qwen_agent
2. (If >50 lines) q4 reviews the output via qwen_chat (fresh context, only sees the diff + spec)
3. If issues found, nvfp4 fixes (max 2 rounds)

### Pattern 3: Generate → Select (design decisions)
1. q4 generates 2-3 implementation approaches via qwen_chat
2. Claude evaluates and selects (or combines)
3. nvfp4 implements the chosen approach

### Pattern 4: Pre-flight Review
1. Claude drafts an implementation plan
2. q4 reviews the plan for gaps, missed edge cases, or better approaches
3. Claude finalizes and executes (or delegates execution to nvfp4)

### Abort rule
At any step, if the output is unhelpful or fundamentally wrong, Claude may skip remaining steps and do it directly rather than continuing the pipeline.

## Model selection cheat sheet

| Task | Model | Tool | Context limit |
|---|---|---|---|
| Web search/fetch | agentworld | qwen_agent | 128K |
| Write code (≤3 files, <60K ctx) | qwen-nvfp4-fast | qwen_agent | 80K |
| Write code (4+ files or >60K ctx) | qwen-q4 | qwen_agent | 262K |
| Review code/diffs | qwen-q4 | qwen_chat | 262K |
| Quick question / second opinion | qwen-nvfp4-fast | qwen_chat | 80K |
| Design brainstorming | qwen-q4 | qwen_chat | 262K |
| Codebase comprehension | qwen-q4 | qwen_agent | 262K |

## Step budget guidance

- **nvfp4 coding tasks**: max_steps 10-15 (default). Simple edits need fewer.
- **Q4 research/analysis tasks**: max_steps 20+. Q4 runs experiments thoroughly and tends to write the report last — if steps are too low, the deliverable gets cut off. Structure prompts as "do research, then write findings" rather than open-ended exploration.
- **Git/PR tasks**: max_steps 5-8 (commit + push + PR is 3-5 commands).
- **Simple single-command tasks**: don't delegate — run directly. nvfp4 wastes steps on orientation (pwd, ls, git status) before reaching the actual command.

## Mindset

Think of Qwen as a team of developers sitting next to you. They're capable, fast, and free. Don't do work they could do — but don't burn 5 minutes of delegation overhead on a 30-second fix either. Your job is to orchestrate, make decisions, handle git/user interaction, and verify quality. Their job is to research, write, and review code.
