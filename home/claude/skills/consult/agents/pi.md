# pi — multi-provider frontier models

`pi` is a provider-agnostic coding agent, so one CLI reaches frontier models
from many vendors. Use it for models the other agents can't reach, Gemini 4
Argon above all. Run it non-interactively with **all tools disabled**, so the
model only sees what we send it.

## Models

Pass these as `--model <provider>/<id>`. `pi --list-models <search>` shows what
the logged-in providers offer.

| Key | Model | `--model` | Notes |
|-----|-------|-----------|-------|
| `argon` | Gemini 4 Argon | `google/gemini-4-argon` | Default for pi. Google API key route. Fallback: `openrouter/google/gemini-4-argon` (its max output is much higher, 943.7K vs 32.8K, so use it for very long answers too) |
| `astra` | GPT-6 Astra | `openai/gpt-6-astra` | OpenAI's top frontier tier. Codex covers the everyday `-sol` models |
| `grok` | Grok | `xai/grok-4.7` | |
| `kimi` | Kimi (open weights) | `fireworks/accounts/fireworks/routers/kimi-latest` | Fireworks `*-latest` routers track new releases on their own |
| `glm` | GLM (open weights) | `fireworks/accounts/fireworks/routers/glm-latest` | |
| `qwen` | Qwen Max (open weights) | `fireworks/accounts/fireworks/routers/qwen-max-latest` | |

Anything else in `pi --list-models` works the same way (`openrouter/...`
covers most vendors). Don't consult Claude models through pi: that's just
asking yourself.

## Invocation

Write the instructions and the diff to a prompt file and attach it with
`@file`. Unlike agy, this sidesteps ARG_MAX, so large diffs work.

```bash
prompt_file="$(mktemp)"; out_file="$(mktemp)"
{
  printf '%s\n\n' 'You are reviewing a proposed code change. Report only actionable issues affecting correctness, security, performance, maintainability, or DX. Cite file and line for each. Do not modify any files; this is review-only.'
  # Optional project context (when the user opts in and CLAUDE.md/AGENTS.md exists):
  # printf 'Project conventions and standards:\n---\n'; cat CLAUDE.md; printf '\n---\n\n'
  printf 'Diff to review:\n---\n'
  git diff HEAD
  printf '\n---\n'
} > "$prompt_file"

pi -p --model google/gemini-4-argon --thinking high \
  --no-tools --no-session --no-context-files --no-extensions --no-skills --no-mcp --offline \
  @"$prompt_file" "Follow the instructions in the attached file." \
  > "$out_file" 2>&1
```

Then `Read` `$out_file`. Swap the first paragraph depending on the job, as in
[agy.md](agy.md): the user's question verbatim for a custom question, plus a
focus line for security/custom focus, or the adversarial design-challenge
instruction. For branch/commit scope, use the matching diff command (see
SKILL.md → Scope Helpers).

- **Flags:** `--no-tools` keeps it read-only. The other `--no-*` flags stop
  your local pi setup (AGENTS.md/CLAUDE.md, extensions, skills, MCP servers)
  from leaking into the consult. `--offline` skips startup update checks; model
  calls still go out.
- **Thinking:** `--thinking` takes `off|minimal|low|medium|high|xhigh|max`.
  Use `high` for reviews and `xhigh`/`max` for adversarial or hard design
  questions.
- **Several models:** run one Bash call per model in the same response
  (parallel), each writing its own `$out_file`, and title each result with
  its model, e.g. `## pi: Gemini 4 Argon`.
- **Background:** add `run_in_background: true`, then `Read` `$out_file` when
  the job completes.

Return the output verbatim and credit it to the model, not to "pi".

## Follow-ups

`--no-session` keeps consults ephemeral, so there is nothing to resume. For a
follow-up, re-run with the earlier answer and the new question added to the
prompt file.

## Error handling

| Error | Action |
|-------|--------|
| `pi: command not found` | `npm i -g @earendil-works/pi-coding-agent` |
| "No models available" / auth error for a provider | Tell user to log in: run `pi`, then `/login`, or set that provider's API key env var |
| Argon fails on `google/` (quota, region, key) | Retry with `openrouter/google/gemini-4-argon`; log the fallback |
| Model not found | `pi update` to refresh model catalogs, then `pi --list-models <search>` |
| Timeout | Narrow the scope, or lower `--thinking` |
