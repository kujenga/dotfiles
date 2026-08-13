---
name: consult
description: "Consult external coding agents (OpenAI Codex, Google Antigravity/agy) for a second opinion, code review, or any custom question. Runs them via CLI and reports back. Use when the user says consult, second opinion, external review, ask codex/antigravity/agy, or mentions /consult."
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - AskUserQuestion
---

# Consult

Shell out to external coding-agent CLIs to get an independent perspective from a
different model. The default job is a **general second opinion / code review** of
the current changes, but the user can ask any agent any custom question.

## Available Agents

| Key | Agent | CLI | Details |
|-----|-------|-----|---------|
| `codex` | OpenAI Codex | `codex` | [agents/codex.md](agents/codex.md) |
| `agy` | Google Antigravity | `agy` | [agents/agy.md](agents/agy.md) |

Each agent file is self-contained: it documents how to invoke that CLI for both
review and free-form consultation, plus its error handling. To add an agent,
drop a new `agents/<key>.md` following the same shape and list it above.

## When to Use

- Getting a second opinion on code from a different model
- Reviewing uncommitted work, a branch diff, or a specific commit before a PR
- Asking another agent a focused/custom question (design, approach, a bug, etc.)
- Comparing how multiple models answer the same thing

## When NOT to Use

- No external CLI is installed / authenticated (see error table)
- You want *Claude's own* review or answer — just answer directly
- The task requires the external agent to **modify** files. This skill is
  read-only by design; consultation, not delegation.

## Decision Flow

1. **Parse the request.** Pull out anything the user already gave: agent(s),
   scope, and a custom question/focus. Only ask about what's missing.

2. **Pick the agent(s).** If the user named one (or "both"/"all"), use it. If
   not, ask with `AskUserQuestion` (header "Agent"):
   - "Codex (Recommended)" → `codex`
   - "Antigravity (agy)" → `agy`
   - "Both" → run in parallel

   Default to Codex when the user clearly wants a review but doesn't care which.

3. **Determine the job.**
   - **Default (no custom question):** a second-opinion review. Ask scope, mode,
     and (conditionally) project context in the same `AskUserQuestion` call if
     not already known:
     - Scope: "Uncommitted changes" (default) · "Branch diff vs main" ·
       "Specific commit"
     - Review mode: "Standard review" (default) · "Security focus" · "Adversarial
       — challenge the design" · "Custom focus" (then they name it, e.g.
       performance, error handling). See [Review Modes](#review-modes).
     - Project context — **only if** a `CLAUDE.md` or `AGENTS.md` exists in the
       repo root: "Include it (check against our standards)" · "Standard review".
       See [Project Context](#project-context).
   - **Custom question:** forward the user's question to the agent(s) verbatim,
     attaching the relevant diff/files as context. Skip the mode question (still
     offer project context if a conventions file exists and it's relevant).

   Combine all needed questions into a single `AskUserQuestion` (max 4). Detect
   answers the user already gave in their invocation (e.g. "adversarial",
   "security", "vs main", "--background") and skip those questions. If everything
   is already answered, ask nothing and run.

4. **Show the diff preview** (for review/scoped jobs) — see Scope Helpers. Stop
   if empty; warn + confirm if very large (>2000 lines changed).

5. **Foreground or background?** See [Background Execution](#background-execution).
   Honor an explicit `--wait` (foreground) or `--background`. Otherwise estimate
   from the preview: a tiny diff (1–2 files) → recommend foreground; anything
   larger or unclear → recommend background. Ask with a 2-option
   `AskUserQuestion` (recommended option first). Skip this for a quick custom Q&A
   that's obviously fast.

6. **Run** the agent(s) per their `agents/<key>.md`. Set `timeout: 600000` on
   the Bash call. For "Both", issue both Bash calls in one response (parallel) —
   all invocations are read-only, so there's no contention. For background, pass
   `run_in_background: true` and write output to temp files (see Background
   Execution).

7. **Present results** (see Output Handling).

## Scope Helpers

```bash
# Auto-detect default branch
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
  | sed 's@^refs/remotes/origin/@@' || echo main
```

| Scope | Diff command | Preview |
|-------|-------------|---------|
| Uncommitted | `git diff HEAD` + untracked files | `git diff --stat HEAD` |
| Branch diff | `git diff <branch>...HEAD` | `git diff --stat <branch>...HEAD` |
| Specific commit | `git diff <sha>~1..<sha>` | `git diff --stat <sha>~1..<sha>` |

Uncommitted scope **must include untracked files** — `git diff HEAD` alone
misses new files:

```bash
{
  git diff HEAD
  git ls-files --others --exclude-standard | while IFS= read -r f; do
    git diff --no-index /dev/null "$f" 2>/dev/null || true
  done
}
```

## Review Modes

The review mode sets which prompt the agent runs with. Each `agents/<key>.md`
carries the exact prompt text for both modes.

- **Standard review** (default) — defect-finding: flag actionable issues that
  impact correctness, security, performance, maintainability, or DX, with
  `file:line` citations and an overall correctness verdict.
- **Security focus / Custom focus** — the standard review prompt plus a focus
  line ("Focus: …") steering it at one area (security, performance, error
  handling, or whatever the user named).
- **Adversarial — challenge the design** — a *different* job: instead of hunting
  defects, question whether the chosen approach is the right one. Probe the
  design choices, tradeoffs, and assumptions; identify where the design could
  fail, what it implicitly depends on, and what simpler/alternative approaches
  exist. Still **review-only** — propose nothing as an edit. Use the adversarial
  prompt from the agent file rather than the defect prompt.

## Project Context

When the user opts in (and a conventions file exists), prepend it to the prompt
so the review checks against the project's standards. Read `CLAUDE.md` first,
else `AGENTS.md`, from the repo root, and insert it before the diff:

```
Project conventions and standards:
---
<contents of CLAUDE.md or AGENTS.md>
---
```

Both agents support this — it's just a block in the prompt text.

## Background Execution

For anything beyond a tiny/fast job, run the consult in the background so the
user isn't blocked.

- **Foreground:** run normally; present results when the Bash call returns.
- **Background:** pass `run_in_background: true` on the Bash call and **write the
  agent's output to a temp file** (Codex already uses `-o $output_file`; for agy,
  redirect stdout: `agy -p "$prompt" > "$out_file" 2>&1`). Tell the user it's
  running and that you'll report back when it finishes — they can keep working.
  When the background job completes you'll be re-invoked; `Read` the temp file(s)
  and present results then.
- **Both agents in background:** launch each as its own background Bash call,
  each writing to its own temp file.

## Output Handling

- **Verbatim first.** Report the agent's findings faithfully. Don't soften,
  inflate, or silently "correct" them — attribute them to the agent ("Codex
  flagged…"). You can add a short note where you disagree, clearly marked as
  your own.
- **Single agent:** present its findings, grouped by priority/severity, with
  `file:line` references and the overall verdict.
- **Multiple agents:** show each under its own header, then summarize where they
  **agree** and **diverge**.

```
## Codex (<MODEL>)
<findings>

## Antigravity (agy)
<findings>

**Agreement:** …   **Divergence:** …
```

## Safety

- All invocations are **read-only**: Codex runs `--sandbox read-only`; agy is
  fed the diff as text so it needs no tool calls and can't edit files. Never
  pass write-sandbox or `--dangerously-*` flags for a consult.
- Don't let a consulted agent's output drive file changes on its own — surface
  it to the user; they decide what to act on.

## Error Handling

| Error | Action |
|-------|--------|
| `codex: command not found` | Tell user: `npm i -g @openai/codex` |
| `agy: command not found` | Tell user: install Antigravity CLI (`agy`) |
| Auth / not-logged-in | Tell user to authenticate that CLI (`codex login`, etc.) |
| Empty diff | Tell user there's nothing to review |
| Very large diff (>2000 lines) | Warn and confirm before running |
| Timeout | Inform user, suggest narrowing the scope |
| One agent of several unavailable | Run the available ones, note the skip |

## Examples

```
User: /consult
→ ask agent + scope + mode (+ project context if CLAUDE.md exists)
→ preview diff → pick foreground/background → run → present

User: consult codex on the uncommitted changes
→ agent=codex, scope=uncommitted known → ask mode (+ context) → preview
→ foreground/background → run

User: ask agy whether this retry logic could deadlock
→ agent=agy, custom question, attach relevant diff → (likely foreground) → present verbatim

User: adversarial review of my branch vs main, in the background
→ agents=?, scope=branch, mode=adversarial, background known
→ ask agent only → preview → run with run_in_background → report when done

User: get a second opinion from both on my branch vs main, security focus
→ agents=both, scope=branch, mode=security → preview → run in parallel → compare
```
