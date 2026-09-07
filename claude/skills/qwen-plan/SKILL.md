---
name: qwen-plan
description: |
  Write and drive an implementation plan for the local Qwen model running under Pi
  (pi CLI against the z13 llama-server at 192.168.10.75:8080). Use when the user wants
  to hand implementation work to the local model, asks for "a plan for Qwen", "a PLAN.md",
  "let the local model do it", mentions driving Pi step by step, or asks to review what
  Qwen implemented. Also use when writing any plan a weaker model must execute
  mechanically. The core of this skill is the PRE-FLIGHT AUDIT in section 2 — run it
  before handing any plan over.
---

# Planning for the local Qwen model

Claude decides what and why. Qwen does the typing. Claude reviews between every step.

Across supervised runs, Qwen3.8-27B followed instructions faithfully. **Every defect traced back to the plan, not the model.** Section 2 is the point of this skill.

## 1. Write the plan

Put it in a file, never a prompt string — Qwen loses volatile details across turns. Pi-driven → `PLAN.md` in project root. Claude Code implementer → `~/Developer/claudeCode`.

Use `references/plan-template.md` as the skeleton. Non-negotiables:

- **Numbered steps, each independently verifiable.** 2–6 min per step works well; a single 31-min step did not. Prefer more, smaller steps.
- **Literal code, not descriptions.** Full contents for new files; exact `find → replace` for edits. Never "wire it up".
- **Each step carries its verification command and expected output.**
- **Concrete paths and symbol names.** Never "the parser".
- Name traps a weaker model falls into; give a fallback for anything uncertain.

Cross-references between steps (`apply §2.7 Edit A here`) are fine — Qwen resolved them correctly.

## 2. PRE-FLIGHT AUDIT — run before handing over

Each item exists because skipping it shipped a defect.

- **Three-way consistency.** Prose rule, literal code, and expected output must agree. Qwen once caught `rsplit(":", 1)` beneath prose saying "first `:`".
- **Derived properties get a truth table.** Any computed property built on an enum or state machine gets a table over every case; the plan says "this table is the specification".
- **Reconcile every new count/status string with the existing UI.** List what already displays the same number, require agreement.
- **Verify call sites before any signature/type change.** Grep for every caller and preview; list them; include the edit for each; state explicitly when there are no others.
- **Re-count the file list.** Definition-of-done totals must match itemized steps. (Got wrong twice; Qwen flagged both.)
- **Check API availability floors.** Flag anything newer than deployment target. Say which API to use instead.
- **Add a dead-code step** when deleting a symbol's last call site (otherwise `periphery scan` flags it later).
- **Confirm CLI flags exist** before putting them in the plan (`--help`).

Per step, ask: *could this be pasted in and executed with no further reasoning?* If not, replace prose with literal code.

## 3. Drive the loop

One step per invocation. Never batch.

```bash
cd <project>
pi -p --session-id <plan-slug> --mode json \
   --model llamacpp/qwen3.8-27b \
   "Read PLAN.md. Implement step 3 only. Do not start step 4."
```

- `--session-id` keeps context across steps (prefix caching is real).
- `--mode json` gives parseable output.
- `qwen3.8-27b` for judgement; `qwen-agentworld-35b-a3b` (~60 tok/s) for bulk mechanical edits.
- Expect 2–6 min per step. Background it and wait; don't poll aggressively.

**Never cancel a request that just asked for a different model.** A swap takes 15–20s; cancelling mid-swap wedges the router (evicted model stays `loaded`, later requests queue behind a child that never answers). Recovery needs a z13 restart. Batch by model instead of alternating. If everything hangs while `/health` returns OK, that is the wedge — not your code.

## 4. Review every step before continuing

Not a formality. Run the step's verification command yourself, read the actual diff, confirm `~/.pi/agent/AGENTS.md` obligations were met — specifically that hostile-input checks were **left behind as a test file**, not merely run once.

Don't relay Qwen's claims. Re-run them:
- Run build/test yourself; quote real output.
- If it claims a regression test guards a bug, **mutate the fix and watch the test go RED**, then restore. Verify tree is clean.
- Check that files it said it left alone are untouched.

Then report and wait for the user. Don't merge, PR, or continue unprompted.

## Related

`~/dotfiles/claude/rules/plans-implementable-by-sonnet.md` covers the Claude Code implementer case. Overlaps but differs — keep separate until more runs show what's common.
