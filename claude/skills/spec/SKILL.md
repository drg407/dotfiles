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

Interview the user and produce a structured spec. Spec becomes input to plan mode — replaces vague task descriptions with precise, unambiguous requirements. Front-loading avoids the multi-turn back-and-forth of progressive requirement reveals.

## When to use

- Building something non-trivial (more than a one-liner)
- Bug fix that isn't trivial — reproduction and expected-vs-actual worth pinning down
- User says "let's spec this", "help me think through X", "before we plan..."
- The request has unstated context (goal behind the task)

## Feature vs. bug

- **Feature** — lead with goal-vs-task and definition of done.
- **Bug** — lead with **reproduction**, **expected vs. actual**, and **scope of the fix** (what must NOT regress). "Done" = repro no longer reproduces AND X still works.

## How to run

### Step 1 — Read context first

Before asking anything, read CLAUDE.md and any files the user mentioned. Your questions must be project-specific, not generic.

### Step 2 — Interview: 3–5 targeted questions via `AskUserQuestion`

Adapt to the project. Every question uncovers the actual goal, eliminates ambiguity, or defines a success criterion.

Cover these angles (phrase for the project):
1. **Goal vs. task** — What outcome does this drive? (Why, not what.)
2. **Definition of done** — Measurable test?
3. **Constraints** — What must NOT change? Patterns to follow/avoid?
4. **Scope boundary** — What's out of scope for this version?
5. **Edge cases** — What happens on bad/empty/unexpected input?
6. **Validation** — How will you know it works? What tests, what manual checks? Plan this before writing code, not after.

One question per angle. No bundling. `multiSelect: false` unless the user genuinely picks multiple things.

### Step 3 — Write to `~/.claude/specs/<kebab-name>.md`

```markdown
# Spec: <Name>

## Goal
<Outcome achieved — one sentence, not a task description.>

## Context
<Project/stack facts that constrain the implementation. Read from CLAUDE.md.>

<!-- Bug fixes only — delete for features. -->
## Reproduction
<Exact steps or input.>
- Expected: <what should happen>
- Actual: <what happens>

## Scope
### In scope
- <bullet>
### Out of scope
- <bullet>

## Requirements
1. <Precise, testable fact — not a direction.>

## Definition of Done
- [ ] <Verifiable: X does Y when Z. Not "looks good".>

## Constraints
<What must not change; patterns/APIs to use or avoid.>

## Failure Modes / Edge Cases
- <case> → <expected behavior>

## Validation Plan
How correctness will be verified — planned BEFORE implementation, not after.
- **Automated tests:** <what to test, what kind (unit/integration/e2e), key assertions>
- **Manual checks:** <exact steps to verify the feature works end-to-end>
- **Edge case coverage:** <which edge cases from above get explicit tests>
- **Regression guard:** <what existing behavior must still pass>

## Open Questions
<Or "None.">
```

### Step 4 — Hand off

Tell the user the spec path, one-line summary, and suggest "Ready for `/plan`" — or surface open questions first.

## Rules

- Never skip the interview. The interview is the point.
- No generic questions — you already read CLAUDE.md.
- Trivial requests (typo, one-line): say so and skip the skill.
- Spec is a file on disk, not a chat message.
- `/spec add X` — treat args as starting context, not a reason to skip the interview.
