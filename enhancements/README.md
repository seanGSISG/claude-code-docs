# Enhancements Directory

Documentation for the enhanced features of claude-code-docs. This fork extends
[ericbuess/claude-code-docs](https://github.com/ericbuess/claude-code-docs) with ripgrep
content search and optional Python-based path search/validation, while staying backward
compatible.

## What's Inside

- **[FEATURES.md](FEATURES.md)** - Feature list and technical details
- **[CAPABILITIES.md](CAPABILITIES.md)** - Detailed capability documentation
- **[EXAMPLES.md](EXAMPLES.md)** - Practical usage examples

## Quick Start

```
/docs <topic>                     # read a doc
/docs <question>                  # AI-powered content search + synthesis
/docs --validate                  # HTTP-validate all paths (Python 3.9+)
~/.claude-code-docs/claude-docs-helper.sh --search-content "<query>"   # ripgrep
```

See [EXAMPLES.md](EXAMPLES.md) for more.

## Architecture

**Single installation, graceful degradation:**

- **Always available**: documentation reading + content search (ripgrep, `grep` fallback) —
  no pre-built index, no Python
- **With Python 3.9+**: fuzzy path search (`--search`), HTTP validation (`--validate`),
  manifest auto-regeneration

**Search system:**
- Content search — ripgrep over the live files (the built-in Grep tool, or `--search-content`)
- Path/topic search — filename matching (the Glob tool) or fuzzy `--search` (Python)

**Update system:** SHA256 change detection, selective fetching, deletion safeguards,
manifest regeneration from sitemaps (every 3 hours via GitHub Actions).

## Coverage

~1,702 documentation paths across four categories (~1,530 `.md` files):

| Category | Paths | Covers |
|---|---|---|
| API Reference | ~1,459 (~86%) | API docs, Admin API, Agent SDK, multi-language SDKs |
| Core Documentation | ~199 (~12%) | Guides, prompt engineering, evaluation, release notes |
| Claude Code | ~43 (~3%) | CLI setup, hooks, skills, MCP, sub-agents, plugins |
| Uncategorized | ~1 | Paths not yet assigned |

## Files in This Directory

```
enhancements/
├── README.md          # This file - directory overview
├── FEATURES.md        # Feature list and specs
├── CAPABILITIES.md    # Detailed capability documentation
└── EXAMPLES.md        # Usage examples
```

## License

Enhancements provided under the same license as upstream. Built on the excellent
foundation of [ericbuess/claude-code-docs](https://github.com/ericbuess/claude-code-docs).
