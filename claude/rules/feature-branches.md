# Feature Branch Workflow (All Projects)

Always work on a feature branch. Never commit directly to `main` (or `master`).

## Rule
- At the start of any coding session, check the current branch. If on `main`, create a feature branch first: `git checkout -b feature/short-description`
- Commit and push to the feature branch throughout the session
- Only merge to `main` after the user confirms testing is good — either by merging the PR or asking to merge/push to main explicitly

## Why
User explicitly requires this on all projects. Direct commits to main bypass review and make it harder to roll back work-in-progress.

## How to apply
- Starting work on a new feature/fix → `git checkout -b feature/description`
- User says "commit and push" → commit and push to the **current feature branch**, not main
- User says "merge" or "looks good, merge it" → then merge to main
- Never use `git push origin main` directly unless the user explicitly says to push to main
