# Codex (OpenAI) — `codex`

Independent review / consultation via OpenAI Codex, run non-interactively.

- **Model:** `gpt-5.6-sol` (fallback latest default on error)
- **Reasoning effort:** `xhigh` for reviews
- Always read-only: `--sandbox read-only`, `--ephemeral` (no session files).
- Set `timeout: 600000` on the Bash call.
- **Background:** `codex exec` already captures the final message with `-o
  $output_file`, so to run in the background just add `run_in_background: true`
  and `Read` `$output_file` when the job completes. For `codex review`, redirect
  stdout to a temp file (`codex review --uncommitted > "$out_file" 2>&1`).

## A. Code review (preferred for the default consult)

Codex has a purpose-built reviewer that returns clean findings to stdout:

```bash
codex review --uncommitted            # working tree (staged + unstaged + untracked)
codex review --base <branch>          # diff against a base branch
codex review --commit <sha>           # a single commit
codex review --uncommitted "Focus on security and auth boundaries."  # focus / custom instructions
```

Custom instructions can also be piped: `… | codex review -`. Return its stdout
to the user; do not paraphrase.

**Review modes** (see SKILL.md → Review Modes) map onto the custom-instructions
argument:

- *Standard* — no extra instructions.
- *Security / Custom focus* — pass a focus line, e.g. `"Focus on security and
  auth boundaries."`
- *Adversarial* — pass the adversarial prompt below as the instructions:
  `codex review --uncommitted "$(cat <<'EOF' … EOF)"` (or use B/C with it).

Adversarial prompt (use instead of the defect prompt for design-challenge mode):

```
You are acting as a skeptical senior reviewer challenging a proposed change. Do NOT just hunt for bugs.
Question whether this is the right approach: interrogate the design choices, tradeoffs, and assumptions the change depends on.
Identify where the design could fail or fail to scale, hidden coupling or implicit invariants, and simpler or alternative approaches that were not taken.
For each point, explain the risk concretely and cite the affected file and line range.
End with a verdict on whether the chosen approach is sound, with a confidence score between 0 and 1. Propose nothing as an edit — this is review-only.
```

## B. Structured findings (when you want parseable JSON)

Use `codex exec` with OpenAI's published review prompt + the output schema. This
captures only the final message (no `[thinking]`/`[exec]` noise) and yields JSON
matching `references/codex-review-schema.json`.

Review prompt (use verbatim — the model is trained on it):

```
You are acting as a reviewer for a proposed code change made by another engineer.
Focus on issues that impact correctness, performance, security, maintainability, or developer experience.
Flag only actionable issues introduced by the pull request.
When you flag an issue, provide a short, direct explanation and cite the affected file and line range.
Prioritize severe issues and avoid nit-level comments unless they block understanding of the diff.
After listing findings, produce an overall correctness verdict ("patch is correct" or "patch is incorrect") with a concise justification and a confidence score between 0 and 1.
Ensure that file citations and line numbers are exactly correct using the tools available; if they are incorrect your comments will be rejected.
```

Assemble a prompt file (review prompt → optional CLAUDE.md/AGENTS.md context →
optional focus line → the diff), then:

```bash
prompt_file="$(mktemp)"; output_file="$(mktemp)"; stderr_log="$(mktemp)"
# ... write $prompt_file (instructions + diff) ...

codex exec \
  -c model='"gpt-5.3-codex"' \
  -c model_reasoning_effort='"xhigh"' \
  --sandbox read-only \
  --ephemeral \
  --output-schema ~/.claude/skills/consult/references/codex-review-schema.json \
  -o "$output_file" \
  - < "$prompt_file" \
  > /dev/null 2>"$stderr_log"
```

Then `Read` `$output_file`. If empty/missing, `Read` `$stderr_log` to diagnose.
Schema: `findings[]` each with `title`, `body`, `confidence_score`, `priority`
(0=info, 1=low, 2=med, 3=high), `code_location`; plus `overall_correctness`,
`overall_explanation`, `overall_confidence_score`. Present grouped by priority.

## C. Custom (non-review) consultation

For free-form questions, run `codex exec` read-only with the question + context:

```bash
prompt_file="$(mktemp)"
{ printf '%s\n\n' '<the user question>'
  printf 'Context (diff to consider):\n---\n'; git diff HEAD; printf '\n---\n'; } > "$prompt_file"

codex exec -c model='"gpt-5.3-codex"' --sandbox read-only --ephemeral \
  -o /tmp/codex-out.txt - < "$prompt_file" > /dev/null 2>/tmp/codex-err.txt
```

Read `/tmp/codex-out.txt` for the answer.

## Diff generation

| Scope | Command |
|-------|---------|
| Uncommitted (tracked) | `git diff HEAD` |
| Uncommitted (untracked) | `git ls-files --others --exclude-standard`, then `git diff --no-index /dev/null <file>` per file |
| Branch diff | `git diff <branch>...HEAD` |
| Specific commit | `git diff <sha>~1..<sha>` |

With `codex review` the diff is computed for you via the scope flags, so prefer
A unless you need structured JSON (B) or a non-review answer (C).

## Error handling

| Error | Action |
|-------|--------|
| `codex: command not found` | `npm i -g @openai/codex` |
| Auth error ("not supported … ChatGPT account") | Retry with `-c model='"gpt-5.2-codex"'`; log the fallback |
| `EPERM` / sandbox errors in logs | Expected — `codex exec` is sandboxed. Ignore. |
| Empty/missing `$output_file` | Read `$stderr_log` to diagnose |
| Timeout | Narrow the diff scope |
