# Mining past sessions

Read only when `$ARGUMENTS` asks about earlier sessions, or when the current session yields
too little evidence. Everything here is local and personal — never commit transcript contents.

## Prompt index

`~/.claude/history.jsonl`, one line per user prompt:
`{display, pastedContents, project, sessionId, timestamp}` (timestamp in ms). Best entry point:

```bash
jq -r 'select(.project == "'"$PWD"'") | [(.timestamp/1000 | todate), .sessionId, .display] | @tsv' \
  ~/.claude/history.jsonl | tail -50
```

## Transcripts

`~/.claude/projects/<munged-cwd>/<sessionId>.jsonl`, where `<munged-cwd>` is the working
directory with every non-alphanumeric character replaced by `-`
(`/Users/aaron/Developer/dotfiles` → `-Users-aaron-Developer-dotfiles`). `ls -t` gives newest
first. These files are large — always filter, never `cat`:

```bash
# Human turns only. Tool results are also role=user, hence the string check; isSidechain skips subagents.
jq -r 'select(.type == "user" and .isSidechain != true and (.message.content | type == "string")) | .message.content' <session>.jsonl

# Assistant prose — what the agent concluded and reported
jq -r 'select(.type == "assistant" and .isSidechain != true) | .message.content[]? | select(.type == "text") | .text' <session>.jsonl

# Commands that were actually run
jq -r '.message.content[]? | select(.type == "tool_use" and .name == "Bash") | .input.command' <session>.jsonl
```

## What to grep for

- Corrective language in human turns: `no,` `actually` `instead` `I meant` `don't` `stop`
- Near-identical prompts recurring across sessions — a missing skill or doc
- Failed command followed by a retry of the same intent — a wrong path or stale instruction

Also worth a look: `~/.claude/plans/` for saved plans, and the project memory directory, to
avoid proposing something already captured.
