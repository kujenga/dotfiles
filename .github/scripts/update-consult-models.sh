#!/usr/bin/env bash
# Point the /consult skill at the newest models the agent CLIs advertise.
#
# Codex: reads `codex debug models` and picks the two highest-priority listed
# models in the "-sol" workhorse family (primary + fallback). Works without
# auth — the CLI ships a bundled catalog, so install the latest @openai/codex
# first for an up-to-date answer.
#
# agy: reads `agy models` and picks the first Gemini "-high" variant. Needs a
# signed-in agy, so it is skipped when agy is missing or fails (e.g. in CI).
#
# pi: reads the model catalog bundled with pi and bumps each pinned family
# (Gemini Argon, GPT Astra, Grok) to its highest version. Works without auth
# (see list_pi_models). The Fireworks "*-latest" routers need no bumping.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
skill="$root/home/claude/skills/consult"
codex_md="$skill/agents/codex.md"
agy_md="$skill/agents/agy.md"
pi_md="$skill/agents/pi.md"

# Current value from a "- **<label>:** `<model>`" line.
current() { sed -n "s/^- \*\*$2:\*\* \`\([^\`]*\)\`.*/\1/p" "$1" | head -1; }

# Swap models across the skill. Placeholders first so a new value that equals
# another old value (fallback ← old primary) isn't rewritten twice.
olds=() news=()
queue() { [[ -n $1 && -n $2 && $1 != "$2" ]] && { olds+=("$1"); news+=("$2"); echo "$1 -> $2"; } || true; }
apply() {
  local i
  local -a files
  ((${#olds[@]})) || return 0
  mapfile -t files < <(git -C "$root" ls-files -- "$skill")
  for i in "${!olds[@]}"; do
    (cd "$root" && OLD="${olds[$i]}" TOK="@@MODEL$i@@" perl -pi -e 's/(?<![\w.-])\Q$ENV{OLD}\E(?![\w.-])/$ENV{TOK}/g' "${files[@]}")
  done
  for i in "${!news[@]}"; do
    (cd "$root" && NEW="${news[$i]}" TOK="@@MODEL$i@@" perl -pi -e 's/\Q$ENV{TOK}\E/$ENV{NEW}/g' "${files[@]}")
  done
}

mapfile -t sol < <(codex debug models | jq -r '
  [.models[] | select(.visibility == "list" and (.slug | test("^gpt-[0-9.]+-sol$")))]
  | sort_by(.priority) | .[0:2][] | .slug')
if ((${#sol[@]} < 2)); then
  echo "codex: expected at least two -sol models, got: ${sol[*]:-none}" >&2
  exit 1
fi
queue "$(current "$codex_md" Model)" "${sol[0]}"
queue "$(current "$codex_md" 'Fallback model')" "${sol[1]}"

if command -v agy >/dev/null && agy_list="$(agy models 2>/dev/null)"; then
  gemini="$(awk '$1 ~ /^gemini-.*-high$/ { print $1; exit }' <<<"$agy_list")"
  [[ -n $gemini ]] && queue "$(current "$agy_md" Model)" "$gemini"
else
  echo "agy: unavailable, leaving its model as is" >&2
fi

# pi only lists providers it has credentials for. Placeholder keys plus an
# empty config dir make it list the bundled catalog for those providers
# without touching (or needing) the user's real logins.
list_pi_models() {
  local tmp
  tmp="$(mktemp -d)"
  env PI_CODING_AGENT_DIR="$tmp" GEMINI_API_KEY=x OPENAI_API_KEY=x XAI_API_KEY=x \
    pi --offline --list-models | awk 'NR > 1 { print $1 "/" $2 }'
  rm -rf "$tmp"
}

# bump_pi <provider> <id regex>: move the pinned id to the newest in the
# catalog. Never downgrades if the catalog drops a model.
bump_pi() {
  local cur new
  cur="$(grep -oE "$2" "$pi_md" | head -1)"
  new="$(sed -n "s|^$1/||p" <<<"$pi_models" | grep -xE "$2" | sort -V | tail -1)"
  if [[ -z $cur || -z $new ]]; then
    echo "pi: no $1 model matching $2 (pinned: ${cur:-none})" >&2
    return 0
  fi
  [[ "$(printf '%s\n' "$cur" "$new" | sort -V | tail -1)" == "$new" ]] && queue "$cur" "$new"
}

if command -v pi >/dev/null && pi_models="$(list_pi_models)" && [[ -n $pi_models ]]; then
  bump_pi google 'gemini-[0-9.]+-argon'
  bump_pi openai 'gpt-[0-9.]+-astra'
  bump_pi xai 'grok-[0-9.]+'
else
  echo "pi: unavailable, leaving its models as is" >&2
fi

apply
