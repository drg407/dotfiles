# PLAN — <project / feature>

**Implementer:** local Qwen3 (pi CLI). **Repo:** `<absolute path>`

Implement **one step per invocation**, in order. Paste the literal code given. Change nothing
else. Do not redesign. If a "find this text" block does not match, stop and report the
mismatch with the text you actually found.

---

## 0. How we work

### Branching
```bash
cd <repo>
git checkout main && git pull
git checkout -b feature/<slug>
```
Never commit to `main`. Do not merge, do not open a PR, do not push to `main`.
Leave these files alone (pre-existing, not yours): `<list>`.

### Commit
One commit unless told otherwise. Imperative subject ≤72 chars, short body.
**No `Co-Authored-By` trailer.**

### Code rules
`<language/version, lint rules, no force unwraps, string localisation, etc.>`

**Do not use `<API>`** — `<reason: availability floor above the deployment target>`.
Use `<alternative>` instead.

### Build & verify
```bash
<build command>
<test command>
<lint command>
```
`<Any generator step — e.g. xcodegen generate — and when it is required.>`

---

## 1. The behaviour being specified

`<For any derived property or state-dependent rule, give a truth table covering every case.>`

| state | input | property A | property B | bucket |
|---|---|---|---|---|
| … | … | … | … | … |

**This table is the specification. Every edit below implements exactly it. Do not deviate.**

Consequences, all intended:
- `<spell out anything that looks like a bug but is not>`

---

## 2. File-by-file changes

`<N>` files: `<x>` new, `<y>` edited. Do them in this order.

### 2.1 NEW FILE — `<path>`

Create the file with exactly this content:

```<lang>
<full file contents>
```

### 2.2 EDIT — `<path>`

Find:

```<lang>
<exact existing text>
```

Replace with:

```<lang>
<exact new text>
```

`<Repeat per file. For a change duplicated across parallel files, say so explicitly and give
both, or extract the shared piece into its own step.>`

---

## 3. Verification

```bash
<commands, in order>
```

Expected:
1. `<command>` → `<exact expected output>`
2. `<...>` → `<...>`. If you see `<known failure>`, you missed `<step>`.
3. Tests → **0 failures**. Record the baseline count before your first edit; the total
   afterwards should be baseline + `<n>`.

Manual checks (need a running app / credentials — say plainly if you cannot run them):
1. `<step>` → `<expected>`

**Paste the real command output. Do not claim success without it.**

---

## 4. Definition of done

- [ ] On branch `feature/<slug>`, never `main`
- [ ] `<x>` new + `<y>` edited = `<total>` paths — *(re-count this against section 2)*
- [ ] Build green, tests pass, lint clean, dead-code scan clean
- [ ] One commit, imperative subject, no `Co-Authored-By`
- [ ] Files listed in §0 still untouched
- [ ] No merge, no PR, no push to `main`

## 5. If you get stuck

Do not guess, do not invent APIs. If a find-block does not match, stop and report it. If the
build fails in a way this plan does not anticipate, report the full error instead of trying an
alternative design. If you think a step in this plan is wrong, say so and stop.
