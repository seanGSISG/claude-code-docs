# Enhanced Documentation Capabilities

This document describes the actual capabilities of the enhanced edition of
claude-code-docs, based on the mirrored documentation from the Anthropic sitemaps.

## Documentation Coverage

### Path Statistics

- **Total paths tracked**: ~1,702 documentation paths (in `paths_manifest.json`)
- **Files downloaded**: ~1,530 `.md` files
- **Auto-discovery**: paths discovered from the official sitemaps, manifest regenerated automatically

### Category Breakdown

Documentation is organized into four categories (approximate, as of 2026-06):

1. **API Reference** (~1,459 paths, ~86%) - Messages/Files/Batch APIs, Admin API,
   Agent SDK, and multi-language SDK docs (Python, TypeScript, Go, Java, Kotlin, Ruby)
2. **Core Documentation** (~199 paths, ~12%) - About Claude, build-with-Claude
   (prompt engineering, streaming, extended thinking), evaluation, release notes
3. **Claude Code** (~43 paths, ~3%) - CLI setup, hooks, skills, MCP, memory, sub-agents, plugins
4. **Uncategorized** (~1 path)

## Search

### Content Search (ripgrep)

**Command**: `--search-content <query>` (or the built-in **Grep** tool)

- **Live search**: runs over the actual `.md` files — no pre-built index, always current
- **Engine**: ripgrep when available, with `grep` as the universal fallback
- **No Python required**: works on any platform out of the box
- **Output**: matching doc filenames (which encode the path) for the agent to read

### Fuzzy Path Search

**Command**: `--search <query>` (requires Python 3.9+), or the built-in **Glob** tool

Fuzzy matching across all tracked paths with relevance ranking, category filtering, and
suggestions. Since filenames encode the path, `Glob("**/*<topic>*.md")` over the docs
directory is the fastest path lookup and needs no Python.

### Direct Topic Read

`claude-docs-helper.sh <topic>` reads a specific doc by name (path-traversal protected).

## Validation

**Command**: `--validate` (requires Python 3.9+)

HTTP reachability testing of all documentation paths (parallel via ThreadPoolExecutor),
with broken-link detection and detailed reports. Implemented in `scripts/lookup/`.

## Fetching & Updates

`scripts/fetch_claude_docs.py` → `scripts/fetcher/`:

- SHA256-based change detection (only fetch what changed)
- Retry with backoff, rate limiting, progress tracking
- Deletion safeguards that refuse catastrophic loss (see README → Security)
- Manifest regeneration from sitemaps on each fetch

Updates land via the `update-docs.yml` workflow every 3 hours; `--validate` runs daily.

## Cross-Platform

Works on macOS, Linux, and Windows (Git Bash). The helper resolves `python3` or
`python`, emits UTF-8 correctly under legacy Windows code pages, and uses ripgrep/`grep`
for content search.

## Dependencies

- **Required**: git, jq, curl, and ripgrep (the Grep tool bundles it; `grep` is the fallback)
- **Optional**: Python 3.9+ and `requests` (fuzzy path search, validation, fetching)
