# Enhanced Features

This fork extends [ericbuess/claude-code-docs](https://github.com/ericbuess/claude-code-docs) with additional capabilities.

## What's Enhanced

### 1. Active Documentation Path Tracking

**Enhanced Edition**: ~1,702 documentation paths tracked in the manifest covering:
- API Reference (~1,459 paths, ~86%) - Complete API docs, multi-language SDKs, Agent SDK
- Core Documentation (~199 paths, ~12%) - Guides, prompt engineering, release notes
- Claude Code (~43 paths, ~3%) - CLI-specific docs: hooks, skills, MCP, sub-agents, plugins
- Uncategorized (~1 path)

**Files downloaded**: ~1,530 `.md` files. See `paths_manifest.json` for the full list.

### 2. Content Search (ripgrep)

**Command**: `--search-content "query"` (or the built-in **Grep** tool).

Searches across all documentation text, over the **live files** — there is no pre-built
index, so results are always current. Uses ripgrep when available and falls back to
`grep`; no Python required.

### 3. Path Validation

**Command**: `--validate` (requires Python 3.9+)

Validates that all tracked paths are reachable.

- HTTP reachability testing
- Parallel validation (ThreadPoolExecutor)
- Broken-link detection and detailed reports

**Implementation**: `scripts/lookup_paths.py` → `scripts/lookup/`

### 4. Fuzzy Path Search

**Command**: `--search "query"` (requires Python 3.9+), or the built-in **Glob** tool
(filenames encode the doc path).

- Fuzzy matching across all tracked paths with relevance ranking
- Category filtering and suggestions

### 5. Testing

**Location**: `tests/` (unit + integration + validation), run with `pytest` or
`pytest --cov=scripts`.

### 6. Documentation Fetching

**Script**: `scripts/fetch_claude_docs.py` → `scripts/fetcher/`

- SHA256-based change detection (only fetch what changed)
- Retry logic with backoff, rate limiting, progress tracking
- Safety thresholds that refuse catastrophic deletions (see README → Security)

### 7. Cross-Platform Support

Works on macOS, Linux, and Windows (Git Bash). The helper resolves `python3` or
`python`, reads UTF-8 output correctly under legacy Windows code pages, and uses
ripgrep/`grep` for content search.

### 8. GitHub Actions

- `update-docs.yml` - Fetch docs every 3 hours (with deletion safeguards)
- `test.yml` - Run the test suite on push/PR
- `validate.yml` - Daily path validation
- `coverage.yml` - Coverage reporting

## Installation

Install via the `claude-docs` plugin (see the main README → Install). The plugin pulls
this repository into `~/.claude-code-docs` and keeps it current. A standalone installer
(`install.sh`) is also available.

**Always available**: documentation reading and ripgrep content search.
**With Python 3.9+**: fuzzy path search, HTTP validation, manifest auto-regeneration.

## Feature Availability

| Feature | Without Python | With Python 3.9+ |
|---------|----------------|------------------|
| Documentation reading | ✅ | ✅ |
| Content search | ✅ ripgrep / `grep` | ✅ ripgrep / `grep` |
| Path search | ✅ Glob (filenames) | ✅ + fuzzy `--search` |
| Validation | — | ✅ HTTP reachability |
| Updates | git pull | + auto-fetch + validation |
| Dependencies | git, jq, curl, ripgrep* | + Python 3.9+, requests |

\* The Claude Code Grep tool bundles ripgrep; `grep` is the universal fallback.

## License

Enhancements are provided under the same license as upstream. See LICENSE file.

## Acknowledgments

Built on the excellent foundation of [ericbuess/claude-code-docs](https://github.com/ericbuess/claude-code-docs).
