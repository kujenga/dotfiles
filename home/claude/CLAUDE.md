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

## Commit Guidelines

### When to Commit
- After completing each logical unit of work (feature implementation, bug fix, refactoring)
- When code reaches a stable, working state
- Before switching to a new task

### Commit Message Format
```
<type>: <concise summary in imperative mood>

<optional body explaining context and rationale>
```
**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `perf`, `chore`

### What to Include

**Focus on WHY, not WHAT:**
- Rationale and design decisions
- Tradeoffs or alternatives considered
- Non-obvious implications of the change
- Context useful for future code review or git blame
- Links to relevant tutorials, issues, or documentation

**Avoid:**
- Describing what changed (the diff shows this)
- Obvious implementation details
- Information better suited or covered by inline code comments

### Attribution
If using AI/agentic tools to generate commits, attribute appropriately:
```
Co-Authored-By: <Tool Name> <email-or-identifier>
```

## Development Workflow

1. Install dependencies using the project's package manager
2. Use the package manager's run command for scripts
3. Keep implementations simple and focused
4. Refer to project-specific documentation for implementation details
5. Make logical commits with clear messages
6. Consider environment-specific concerns (local dev, CI/CD, production)
