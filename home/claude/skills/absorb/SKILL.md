---
name: absorb
version: 1.0.0
description: |
  Automatically fold staged changes into the right commits using git-absorb.
  Stages fixes, runs absorb with dry-run preview, and optionally rebases.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - AskUserQuestion
---

# Absorb: Fold Fixes into the Right Commits

You are running the `/absorb` workflow. This uses [git-absorb](https://github.com/tummychow/git-absorb) to automatically create fixup commits that target the correct parent commits, then optionally squash them via autosquash rebase.

## When to use

- You have a feature branch with multiple commits
- You've made small fixes (review feedback, typos, tweaks) that logically belong in earlier commits
- You want atomic commits without manual `--fixup` SHA hunting or interactive rebase

## Workflow

### Step 1: Check prerequisites

```bash
git absorb --version
```

If not installed, tell the user to install it (`brew install git-absorb`, `cargo install git-absorb`, etc.) and stop.

### Step 2: Assess the situation

Run these in parallel:

```bash
git status --short
```

```bash
git log --oneline -20
```

Identify:
- **Unstaged changes** — these need to be staged for absorb to consider them
- **Already staged changes** — ready for absorb
- **Recent commits** — the candidates absorb will try to match against

If there are no staged or unstaged changes, tell the user there's nothing to absorb and stop.

### Step 3: Stage changes

If there are unstaged changes but nothing staged, ask the user what to stage:
- **All changes**: `git add -A`
- **Specific files**: `git add <files>`

If changes are already staged, proceed directly.

### Step 4: Dry run

Always preview first:

```bash
git absorb --dry-run --verbose
```

Show the user what absorb plans to do — which hunks map to which commits. If absorb can't match any hunks, explain why (changes may not commute with any recent commit, or may be new code that doesn't modify existing lines).

### Step 5: Confirm and run

Ask the user to confirm, presenting these options:
1. **Absorb and rebase** — `git absorb --and-rebase` (creates fixup commits and squashes them immediately)
2. **Absorb only** — `git absorb` (creates fixup commits for manual review before rebasing)
3. **Abort** — do nothing

Run the chosen command.

### Step 6: Verify

```bash
git log --oneline -15
```

Show the resulting commit history. If fixup commits were created without rebase, remind the user they can squash with:
```
git rebase -i --autosquash <base>
```

## Options reference

Pass these through when the user requests them:

| Flag | Use when |
|------|----------|
| `--base <ref>` | Branch has many commits; set explicit base (e.g., `--base main`) |
| `--force` | Skip all safety checks (non-author commits, detached HEAD) |
| `--one-fixup-per-commit` | Prefer one fixup per target commit instead of per-hunk |
| `--whole-file` | Match by file rather than hunk (use with care) |

## Recovery

If something went wrong after absorb:
```bash
git reset --soft PRE_ABSORB_HEAD
```
This restores the pre-absorb state. The ref is created automatically by git-absorb.

## Important notes

- git-absorb only considers **staged** changes (the index)
- It searches the last 10 commits by default (configurable via `[absorb] maxStack` in `.gitconfig` or `--base`)
- Changes that don't map to any existing commit are left staged — they aren't lost
- It won't modify commits by other authors unless `--force` or `--force-author` is passed
- **Never use `-i` (interactive) flags** — not supported in this environment
