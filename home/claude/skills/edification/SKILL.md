---
name: edification
description: |
  Reflects on a working session and improves the agent setup itself — CLAUDE.md, AGENTS.md,
  memory, skills, settings — so the next session goes better. Biased toward pruning and
  sharpening over adding: context is a budget, a stale instruction is worse than a missing
  one, and finding nothing worth changing is a valid outcome. Use when asked to reflect,
  capture learnings, improve your setup, or review what could have gone better. Claude should
  also invoke this near the end of a session that generated learnings worth keeping, rather
  than waiting to be asked: repeated corrections or heavy back-and-forth, an assumption that
  proved wrong, a doc or skill that didn't match reality, something rediscovered that an
  earlier session already knew, or recurring permission friction. It proposes before editing
  anything, so invoking it is safe.
---

# Edification

Make the next session cheaper and more accurate by changing the context the agent reads. The
deliverable is a small set of approved edits, plus context pulled from the human that no amount
of code-reading could supply. It is not a report.

`$ARGUMENTS` — blank: this session. A topic: scope to it. A date range or session id: mine past
sessions, see `references/mining-history.md`.

## The bias

Context is a budget, not a filing cabinet. Every line added displaces code the agent could have
read instead, and a stale line is worse than a missing one because the model will follow it.

So **prefer deleting, correcting, and sharpening over adding.** Ending with three lines removed
and one line fixed is a good outcome. Finding nothing that earns a change is a valid outcome —
say so and stop.

Cut on sight:

- Steps a capable model already takes ("read the file first", "run the tests")
- Restatements of intent that change no behavior
- Enumerated procedures and tool nudges written to prop up weaker models
- Anything derivable from the code, git history, or `--help`

Keep: true invariants (security, destructive operations, org rules), non-obvious facts (why the
weird thing is weird), exact paths and commands that would otherwise cost a search, and
corrections the human actually made. Reserve *always* and *never* for things that are.

## Surfaces

| Surface | Where | Holds |
|---|---|---|
| Repo agent docs | `AGENTS.md`, `CLAUDE.md`, nested per-directory | Team-shared conventions, commands, gotchas |
| Personal overrides | `CLAUDE.local.md`, `.claude/settings.local.json` | Machine- or user-specific bits |
| Global instructions | `~/.claude/CLAUDE.md` | Cross-project facts and preferences |
| Memory | the memory directory named in the session context, plus its `MEMORY.md` index | Durable facts, feedback, project state |
| Skills | `~/.claude/skills/`, project skill directories | Repeatable workflows — fix stale steps, split bloat, delete dead ones |
| Harness | `settings.json` permissions and hooks | Permission friction, "always do X after Y" |

Each learning lands on exactly one surface — the narrowest one that covers the cases. If
`update-docs`, `update-config`, or `fewer-permission-prompts` are available here, hand them
their surface rather than duplicating their logic.

## Working method

**Look for friction, not accomplishments.** Corrections the human made. Assumptions that proved
false. Docs that didn't match reality. Things rediscovered that an earlier session already knew.
Repeated permission prompts. Instructions carried all session and never used. Tie each finding
to a specific moment — a finding you can't point at is a guess.

**Interview the human when there's a real gap.** Optional, but the highest-value thing this
skill can collect: any time you made a call by guessing, or a finding turns on intent you can't
read off the code, the answer is in their head and nowhere else. Worth asking about:

- *Your findings* — which are real, which are noise, what did they notice that you missed.
- *The gaps* — why the odd thing is odd, temporary or permanent, what order things actually
  matter in, what that external system does that you can't see.

Ask about specific moments; "any other context?" gets nothing back. `AskUserQuestion` suits this
well. Keep answers close to verbatim before condensing — the phrasing often carries the reason.
Skip what they already volunteered, and skip the interview entirely when the session was
straightforward and nothing hinged on a guess.

**Propose before editing.** A numbered list ordered by friction prevented; for each, the learning
and its *why*, the exact file, whether it's an add / fix / delete, and the evidence. Wait for
approval and expect to be cut down.

**Apply minimally.** Read the target first and update in place rather than appending a
near-duplicate. Show the diffs. Ask before committing repo files; personal files under
`~/.claude/` need no ceremony.

Close with what changed, what you deliberately left out, and what's still unknown.
