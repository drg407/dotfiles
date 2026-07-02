---
name: spec
description: |
  Interview the user to produce a structured spec before planning or building — for features or non-trivial bug fixes. Use when the user wants to spec out a feature, fix a bug that needs reproduction/expected-vs-actual pinned down, says "let's spec this", "help me spec", "before we plan", or starts describing something they want to build or fix. This runs BEFORE plan mode — it extracts the actual goal, reproduction, and evaluation criteria so the plan has no ambiguity.
allowed-tools:
  - AskUserQuestion
  - Write
  - Read
  - Bash
---

# spec

Interview the user and produce a structured spec. The spec becomes the input to plan mode — it replaces vague task descriptions with precise, unambiguous requirements.

**Why this exists:** front-loading the full spec in one pass avoids the multi-turn back-and-forth that happens when requirements are revealed progressively. Underspecified prompts drawn out over several turns are the main driver of wasted rounds (and, on capped plans, wasted usage). Capture it all up front so plan/implement runs clean.

## When to use

- User wants to build something non-trivial (more than a one-liner fix)
- User is fixing a **bug** that isn't a trivial one-liner — reproduction and expected-vs-actual behavior are worth pinning down before diving in
- User says "let's spec this out", "help me think through X", or "before we plan..."
- You sense the request has unstated context (a goal behind the task)
- Anything that would benefit from defined success criteria before writing code

## Feature vs. bug

Adapt the interview to what's being spec'd:
- **Feature** — lead with goal-vs-task and definition of done (the default angles below).
- **Bug fix** — lead with **reproduction** (exact steps / input that triggers it), **expected vs. actual** behavior, and **scope of the fix** (what must NOT change / regress). Definition of done becomes "the repro no longer reproduces, and X still works."

## How to run

### Step 1 — Read context first

Before asking anything, read the relevant CLAUDE.md and any files the user mentions. You need to know the project, stack, and constraints so your questions are precise, not generic.

### Step 2 — Conduct the interview

Ask **3–5 targeted questions** using `AskUserQuestion`. Adapt to the project — don't ask boilerplate. Every question should have a clear reason: it either uncovers the actual goal, eliminates ambiguity, or defines a success criterion.

Always cover these angles (but phrase them for the specific project):

1. **Goal vs. task** — What outcome or decision does this feature drive? (Not just "what does it do" but "why does it exist")
2. **Definition of done** — How will you know it works? What's the measurable test?
3. **Constraints** — What must NOT change? Any existing patterns to follow or avoid?
4. **Scope boundary** — What is explicitly out of scope for this version?
5. **Edge cases / failure modes** — What should happen when it goes wrong?

Keep questions short. Use `multiSelect: false` unless the user genuinely needs to pick multiple things. One question per angle — don't bundle.

### Step 3 — Write the spec

After the interview, write the spec to a file: `~/.claude/specs/<kebab-case-feature-name>.md`

Use this structure exactly:

```markdown
# Spec: <Feature Name>

## Goal
<The actual outcome this achieves — one sentence, not a task description.>

## Context
<Relevant project/stack facts that constrain the implementation. Read from CLAUDE.md.>

<!-- Bug fixes only — delete this section for feature specs. -->
## Reproduction
<Exact steps or input that trigger the bug.>
- Expected: <what should happen>
- Actual: <what happens instead>

## Scope
### In scope
- <bullet>
### Out of scope
- <bullet>

## Requirements
<Numbered list of precise, testable requirements. Each one is a fact, not a direction.>
1. ...
2. ...

## Definition of Done
<Bulleted list of measurable success criteria. Each is verifiable — not "looks good" but "X does Y when Z.">
- [ ] ...
- [ ] ...

## Constraints
<Things that must not change, patterns to follow, APIs to use or avoid.>

## Failure Modes / Edge Cases
<What should happen when inputs are bad, empty, or unexpected — one line per case. This is where the edge-case interview answers land; don't let them dissolve into Requirements.>
- <case> → <expected behavior>

## Open Questions
<Anything unresolved that plan mode will need to decide. If none, write "None.">
```

### Step 4 — Hand off

After writing the spec file, tell the user:
- The spec path
- A one-line summary of what was captured
- Suggest: "Ready for `/plan`" — or if there are open questions, surface them first

## Rules

- Never skip the interview and jump straight to writing a spec. The interview is the point.
- Never ask generic questions like "what's your tech stack?" — you already read CLAUDE.md.
- If the user's request is already precise and small (a typo fix, a one-line change), say so and skip the skill.
- The spec is a file, not a chat message. Write it with the Write tool so it persists.
- If args are passed (e.g. `/spec add audio track switching`), use them as the starting context, not a reason to skip the interview.
