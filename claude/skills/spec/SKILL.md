---
name: spec
description: |
  Interview the user to produce a structured feature spec before planning or building. Use when the user wants to spec out a feature, says "let's spec this", "help me spec", "before we plan", or starts describing a feature they want to build. This runs BEFORE plan mode — it extracts the actual goal and evaluation criteria so the plan has no ambiguity.
allowed-tools:
  - AskUserQuestion
  - Write
  - Read
  - Bash
---

# spec

Interview the user and produce a structured spec. The spec becomes the input to plan mode — it replaces vague task descriptions with precise, unambiguous requirements.

## When to use

- User wants to build something non-trivial (more than a one-liner fix)
- User says "let's spec this out", "help me think through X", or "before we plan..."
- You sense the request has unstated context (a goal behind the task)
- Anything that would benefit from defined success criteria before writing code

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
