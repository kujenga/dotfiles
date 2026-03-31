# Development Guidelines

## Code Comments

**When to add comments:**
- Non-obvious design decisions or implementation choices
- Temporary workarounds or compatibility fixes (with issue links)
- Performance optimizations that aren't self-evident
- Deviations from standard patterns or best practices
- Complex algorithms where intent isn't clear from code alone
- Configuration choices in dependency files (pyproject.toml, package.json, etc.)

**When NOT to comment:**
- Obvious code that describes what it does (e.g., `# increment counter`)
- Information that's clear from well-named variables and functions
- Redundant explanations of standard patterns

**Format:**
- Keep comments concise and focused on "why" not "what"
- Include links to issues, docs, or RFCs for context
- Place comments immediately above the relevant code

## Search & Navigation

### Use ripgrep (`rg`) instead of `grep`

Always prefer `rg` over `grep` for searching the codebase. ripgrep is faster, respects `.gitignore` automatically, and has better defaults for code search.

**Common patterns:**
```bash
# Search for a string
rg "pattern"

# Search in specific file types only
rg "pattern" --type py
rg "pattern" --type ts

# Case-insensitive
rg -i "pattern"

# Show context lines around matches
rg -C 3 "pattern"

# Search for a whole word
rg -w "myFunction"

# List only filenames with matches
rg -l "pattern"

# Search including normally-ignored files
rg --no-ignore "pattern"

# Multiline search
rg --multiline "pattern"

# Search with a regex, show only the match (not full line)
rg -o "pattern"
```

**Never use plain `grep -r`** — it will scan `node_modules`, `.git`, build artifacts, and other ignored directories, producing slow and noisy results.

## Package Management

**Always use modern, project-specific package managers.** Choose the tool appropriate for your ecosystem:
- Python: `uv` (never pip directly, unless already explicitly used by the project)
- JavaScript/TypeScript: `npm`, `yarn`, or `pnpm` (following any existing conventions in the project)
- Rust: `cargo`
- Go: `go mod`

### Core Principles
- **Single source of truth**: All dependencies defined in project manifest files
- **Dependency groups/scopes**: Separate environment-specific dependencies (dev, prod, etc.)
- **Reproducible environments**: Lock files ensure consistent installations
- **Fast operations**: Use modern, efficient package managers

### Best Practices

**DO:**
- ✅ Use the project's designated package manager
- ✅ Define dependencies in project manifest files
- ✅ Use dependency groups/scopes for environment-specific packages
- ✅ Commit lock files to ensure reproducible builds
- ✅ Use the package manager's run command for scripts

**DON'T:**
- ❌ Mix package managers in the same environment
- ❌ Manually edit lock files
- ❌ Add platform-specific packages to core dependencies without consideration
- ❌ Install dependencies globally when project-local is appropriate

## Documentation

When you need to reference library APIs or best practices:
1. Use available documentation services (Context7, DevDocs, official docs)
2. Search for the correct library/version identifier
3. Query with specific questions about API usage
4. Reference returned code snippets and documentation in implementation

### Notion

When a Notion link appears in context (e.g., referenced in CLAUDE.md, AGENTS.md, or user messages), always use the Notion MCP tools (`notion-fetch`, `notion-search`) to retrieve the content rather than fetching via WebFetch. The Notion MCP has authenticated access and returns structured content; WebFetch will fail on Notion's authenticated pages.

## Commit Guidelines

### Commit As You Go

Commit incrementally as each logical unit of work is completed — don't batch everything into one commit at the end. Each commit should represent a coherent, working state.

- **Commit after completing each task or logical unit** (a new module, a bug fix, a config change)
- **Group related changes** into a single commit (e.g., a model + its tests, a config fix across multiple files)
- **Separate unrelated changes** into distinct commits (e.g., a housekeeping fix shouldn't be bundled with a feature)
- **Absorb mistakes into the relevant commit** — if a commit introduced a typo or broke something *in its own changes*, amend it rather than creating a "fix typo" follow-up. Use `git commit --amend` for the most recent commit, or `git rebase -i` to fixup an earlier one. **Only amend when the fix is directly related to the commit being amended** — never fold unrelated changes into an existing commit, even if the user asks to amend. If the change is unrelated, make a separate commit.

When creating commits, use the `/commit` skill for message formatting and command syntax.

## Development Workflow

1. Install dependencies using the project's package manager
2. Use the package manager's run command for scripts
3. Keep implementations simple and focused
4. Refer to project-specific documentation for implementation details
5. Make logical commits with clear messages
6. Consider environment-specific concerns (local dev, CI/CD, production)
