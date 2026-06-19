# Antigravity (Google) — `agy`

Independent review / consultation via Google's Antigravity CLI, run
non-interactively in print mode. Backed by Gemini (and optionally Claude / OSS)
models depending on the user's plan.

- **Non-interactive flag:** `-p` / `--print` (alias `--prompt`) — runs one prompt
  and prints the response, then exits.
- **Print timeout:** defaults to 5m; override with `--print-timeout` if needed.
  Set `timeout: 600000` on the Bash call regardless.
- **Read-only by design here:** feed the diff/context *as text in the prompt* so
  agy needs no tool calls and can't touch files. Do **not** pass
  `--dangerously-skip-permissions`.

## Invocation

Build the full instructions + diff into the prompt and pass it as the `-p`
argument. (agy print mode takes the prompt as an argument, not stdin.)

```bash
prompt="$(
  printf '%s\n\n' 'You are reviewing a proposed code change. Report only actionable issues affecting correctness, security, performance, maintainability, or DX. Cite file and line for each. Do not modify any files; this is review-only.'
  printf 'Diff to review:\n---\n'
  git diff HEAD
  printf '\n---\n'
)"
agy -p "$prompt"
```

For a **custom question**, swap the first paragraph for the user's question
verbatim and keep the diff/context block. For **branch/commit** scope, replace
`git diff HEAD` with the matching diff command (see SKILL.md Scope Helpers).

Return agy's stdout to the user; don't paraphrase. Attribute findings to
Antigravity.

## Caveats

- **ARG_MAX:** the diff is passed as a CLI argument, so extremely large diffs can
  fail with "Argument list too long". The skill already warns above ~2000 lines —
  narrow the scope (branch/commit/path) rather than dumping a huge diff.
- agy normally runs agentically in the cwd. We deliberately avoid that here by
  inlining the diff, so the review reflects exactly what we send and nothing on
  disk gets modified.

## Follow-ups

To continue a prior agy consultation in a later turn:

```bash
agy -c -p "<follow-up question>"          # continue most recent conversation
agy --conversation <ID> -p "<follow-up>"  # resume a specific conversation
```

## Error handling

| Error | Action |
|-------|--------|
| `agy: command not found` | Tell user to install the Antigravity CLI (`agy`) |
| Auth / not signed in | Tell user to sign in to Antigravity |
| "Argument list too long" | Narrow the diff scope (see ARG_MAX caveat) |
| Hang until print-timeout | Prompt likely triggered a tool call — ensure context is inlined as text, not requested via files |
| Timeout | Narrow the scope or raise `--print-timeout` |
