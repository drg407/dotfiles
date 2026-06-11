# Plans Must Be Implementable by Sonnet 4.6 Medium (All Projects)

When Opus (or any stronger model) writes a code implementation plan, the plan must be detailed enough that **Sonnet 4.6 medium can execute it without further reasoning or judgment calls.** The planning model does the thinking; the implementing model does the typing.

## Rule
A plan is only "done" when a less capable model could implement it mechanically. Before exiting plan mode, verify the plan contains:

- **Copy-pasteable code, not descriptions.** For a new file or a full rewrite, give the complete file contents. For a partial change, give the exact `old_string` → `new_string` (or "change line N from X to Y"). Never write "add a handler" or "wire it up" — show the literal code.
- **Exact locations.** Name the file and the symbol/line. Don't make the implementer search for where a change goes.
- **Verified call sites.** Before planning a signature/type change, grep for every caller and `#Preview`, list them, and include the edit for each. State explicitly when you've confirmed there are no other references.
- **Confirmed APIs.** Verify type names, parameter labels, and enum cases against the actual SDK/source (not memory). Note where you confirmed them.
- **Language gotchas + contingencies.** Call out the spots a weaker model would get wrong (Swift 6 concurrency, `@Observable`/`@Bindable`, tvOS focus, deprecated overloads), and give a fallback path for anything uncertain.
- **A concrete verification section.** Exact build command and step-by-step manual/test checks with expected results.

## Why
User explicitly wants to plan with a strong model and implement with a cheaper/faster one (Sonnet 4.6 medium). Any ambiguity left in the plan forces the implementer to reason — which is exactly what it can't reliably do — leading to wrong guesses, broken builds, and rework. See memory [[feedback_plan_detail_for_sonnet]].

## How to apply
- Writing a plan as Opus → assume the implementer cannot read the codebase or make decisions. If a step requires a judgment call, make the call in the plan.
- After drafting → reread each step and ask "could Sonnet paste this in and move on?" If not, replace prose with literal code/edits.
- If the user asks "can sonnet implement this?" → treat it as a request to harden the plan to this bar, then confirm.
- Genuinely open design decisions belong to the user (via AskUserQuestion) before finalizing — not left as ambiguity for the implementer.
