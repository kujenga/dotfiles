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
   - **Default (no custom question):** general second-opinion review. Ask
     scope + focus in the same `AskUserQuestion` call if not already known:
     - Scope: "Uncommitted changes" (default) · "Branch diff vs main" ·
       "Specific commit"
     - Focus: "General" (default) · "Security" · "Performance" · "Error handling"
   - **Custom question:** forward the user's question to the agent(s) verbatim,
     attaching the relevant diff/files as context. Skip the focus question.

   Combine all needed questions into a single `AskUserQuestion` (max 4). If the
   user's invocation already answered everything, ask nothing and run.

4. **Show the diff preview** (for review/scoped jobs) — see Scope Helpers. Stop
   if empty; warn + confirm if very large (>2000 lines changed).

5. **Run** the agent(s) per their `agents/<key>.md`. Set `timeout: 600000` on
   the Bash call. For "Both", issue both Bash calls in one response (parallel) —
   all invocations are read-only, so there's no contention.

6. **Present results** (see Output Handling).

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
## Codex (gpt-5.3-codex)
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
→ ask agent + scope + focus → preview diff → run → present

User: consult codex on the uncommitted changes
→ agent=codex, scope=uncommitted known → ask focus (or default General) → run

User: ask agy whether this retry logic could deadlock
→ agent=agy, custom question, attach relevant diff → run → present verbatim

User: get a second opinion from both on my branch vs main, security focus
→ agents=both, scope=branch, focus=security → run in parallel → compare
```
