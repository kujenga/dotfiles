---
name: commit
description: |
  Format and create git commits. ALWAYS use this skill when making git commits.
  TRIGGER: Any time you are about to run `git commit`.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# Commit: Format and Create Git Commits

## Commit Message Format
```
<type>[(scope)]: <concise summary in imperative mood>

<optional body explaining context and rationale>
```
**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `perf`, `chore`
**Scope** (optional): package or module name, e.g., `feat(core):`, `fix(ingest):`

## What to Include

**Capture context aggressively from the conversation.** The commit message is the permanent record of *why* this change exists. Review the full chat history and distill anything a future reader would need to understand the decision — don't let institutional knowledge vanish when the conversation ends.

**Focus on WHY, not WHAT:**
- Rationale and design decisions — why this approach over alternatives
- Alternatives considered and why they were rejected
- Non-obvious implications of the change
- Links to every resource that informed the work: docs, Stack Overflow answers, GitHub issues, blog posts, API references, tutorials. These are especially easy to lose — if a URL appeared in the conversation, it probably belongs in the commit.
- Key findings from debugging or research — what was learned, not just the final fix
- Gotchas and surprises discovered along the way (non-obvious library behavior, subtle bugs, etc.)
- Constraints or requirements that drove the decision (user goals, deadlines, upstream dependencies)
- Decisions explicitly deferred, with reasoning (so future readers know it was intentional)

**Err on the side of too much context rather than too little.** A commit body that says "switched from library X to library Y" is far less useful than one that explains X doesn't support streaming (link to issue), Y's API is similar enough that migration was straightforward, and only the auth setup differs.

**Avoid:**
- Describing what changed (the diff shows this)
- Obvious implementation details
- Information better suited for inline code comments

## Commit Command Format

**Never use HEREDOCs for commit messages.** The `$(cat <<'EOF' ... EOF)` pattern involves nested shell operators (command substitution + here-document) which the Bash tool flags for manual approval every time. Instead, pass a single multi-line string to `-m`. The Bash tool's command parameter is a JSON string, so newlines are fine — this is a simple command with no nested operators:

```bash
git commit -m "type(scope): summary

Optional body with context.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

## Attribution
If using AI/agentic tools to generate commits, attribute appropriately:
```
Co-Authored-By: <Tool Name> <email-or-identifier>
```
