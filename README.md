# Claude Code Documentation Tool

[![Last Update](https://img.shields.io/github/last-commit/seanGSISG/claude-code-docs/main.svg?label=docs%20updated)](https://github.com/seanGSISG/claude-code-docs/commits/main)
[![Python](https://img.shields.io/badge/python-3.9+-blue)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)](https://github.com/seanGSISG/claude-code-docs)
[![Mentioned in Awesome Claude Code](https://awesome.re/mentioned-badge.svg)](https://github.com/hesreallyhim/awesome-claude-code)

> **⭐ This is an enhanced fork of [ericbuess/claude-code-docs](https://github.com/ericbuess/claude-code-docs)**
>
> Built on Eric Buess's excellent foundation, this fork adds Python-powered search, validation, and auto-regeneration features while maintaining graceful degradation - everything works with or without Python.
>
> **For the original, simpler implementation:** [ericbuess/claude-code-docs](https://github.com/ericbuess/claude-code-docs)

---

**Fast, searchable access to Claude Code documentation - locally, always up-to-date.**

Stop hunting through scattered docs. This tool provides instant access to the full Claude documentation catalog covering API references, guides, examples, and changelogs.

## Key Features

- 🤖 **AI-Powered Search** - Ask questions naturally, Claude understands intent and routes intelligently
- 📚 **Complete Coverage** - Full mirror of the Anthropic docs sitemap, refreshed every 3 hours
- 🔍 **Semantic Understanding** - No primitive keyword matching, leverages Claude's language understanding
- ✅ **Auto-Validated** - Scheduled validation catches broken links and upstream URL churn
- 🔄 **Always Fresh** - Repository updated every 3 hours; run `/docs -t` to pull latest
- 🎯 **Graceful Degradation** - Works with or without Python

## How It Works

This tool takes a different approach to documentation access:

1. **Local Mirror** - Instead of fetching docs from the web each time, we keep a local copy that's always ready
2. **AI as the Interface** - You ask questions in plain English, Claude figures out which docs to read
3. **Smart Routing** - The `/docs` command understands context ("hooks in agent sdk" vs "cli hooks")
4. **Works Offline** - Once installed, docs are available even without internet

The magic is in combining a simple local file system with Claude's language understanding. No complex search engines or databases - just markdown files and AI smarts.

## What's Included

**Documentation Paths** (~1,250 tracked in manifest across five active categories; counts as of 2026-04):
- API Reference (~1,060 paths, ~85%) - Complete API docs, Admin API, Agent SDK
  - 🐍 **Python** | 📘 **TypeScript** | 🔷 **Go** | ☕ **Java** | 💎 **Ruby** | 🖥️ **CLI** (~98 docs each)
- Core Documentation (~143 paths, ~11%) - Guides, tutorials, best practices, prompt engineering
- Claude Code (~43 paths, ~3%) - CLI-specific docs: hooks, skills, MCP, sub-agents, plugins
- Release Notes (2 paths) - Version history
- Resources (1 path) - Additional resources

> 💡 **Multi-language support**: API documentation for Python, TypeScript, Go, Java, Ruby, and curl is mirrored and searchable.

> 🚀 **No Python required!** Core features including AI-powered semantic search work with just bash. Python 3.9+ enables advanced full-text search and path validation.

> ℹ️ **Note on Prompt Library**: Anthropic retired the standalone Prompt Library in April 2026; the prompt-engineering content was consolidated into `/docs/en/build-with-claude/prompt-engineering/*` and is now part of Core Documentation.

**Optional Python Features** (requires Python 3.9+):
- Full-text content search (`--search-content`)
- Fuzzy path matching (`--search`)
- HTTP validation (`--validate`)
- Auto-regeneration of manifests

## Installation

### Quick Install (2 minutes)

**One command:**
```bash
curl -fsSL https://raw.githubusercontent.com/seanGSISG/claude-code-docs/main/install.sh | bash
```

**What it does:**
1. Clones repository to `~/.claude-code-docs`
2. Installs the full documentation mirror (~1,000+ markdown files)
3. Sets up `/docs` command in Claude Code
4. Verifies installation integrity

**Python features activate automatically if Python 3.9+ is installed.**

### Installation Methods

**Method 1: Direct Install (interactive)**
```bash
curl -fsSL https://raw.githubusercontent.com/seanGSISG/claude-code-docs/main/install.sh | bash
```
Works on: Local terminals, iTerm2, Terminal.app, SSH with `-t` flag

**Method 2: Auto-Install (CI/CD-friendly)**
```bash
CLAUDE_DOCS_AUTO_INSTALL=yes curl -fsSL https://raw.githubusercontent.com/seanGSISG/claude-code-docs/main/install.sh | bash
```
Works on: **All environments** including GitHub Actions, Docker, cron jobs, SSH without `-t`

**Method 3: Download First (most reliable)**
```bash
curl -fsSL https://raw.githubusercontent.com/seanGSISG/claude-code-docs/main/install.sh -o install.sh
bash install.sh
```
Works on: All interactive shells

### Requirements

- **Required**: macOS 12+ or Linux (Ubuntu, Debian, Fedora, etc.)
- **Required**: git, jq, curl (usually pre-installed)
- **Optional**: Python 3.9+ (enables search/validation features)

## Upgrading

Re-run the installer — it detects the existing install and upgrades atomically:

```bash
curl -fsSL https://raw.githubusercontent.com/seanGSISG/claude-code-docs/main/install.sh | bash
```

Or pull the latest docs in place:

```bash
cd ~/.claude-code-docs && git pull
```

## Usage

### Basic Commands

**Quick access (no freshness check):**
```bash
/docs hooks        # Read hooks documentation instantly
/docs mcp          # Read MCP documentation
/docs memory       # Read memory features
```

**With freshness check:**
```bash
/docs -t           # Check sync status with GitHub
/docs -t hooks     # Check sync, then read hooks docs
```

**Special commands:**
```bash
/docs what's new   # Show recent documentation changes with diffs
/docs changelog    # Read official Claude Code release notes
/docs uninstall    # Get uninstall command
```

### AI-Powered Natural Language Queries

**The `/docs` command is AI-powered** - it leverages Claude's semantic understanding instead of primitive keyword matching. Ask questions naturally and Claude will intelligently route to the appropriate search functions.

**How it works:**
1. Claude analyzes your request semantically
2. Determines if you want direct documentation, content search, or path discovery
3. Routes to appropriate helper functions automatically
4. Presents results naturally with context

**Examples:**

```bash
# Complex semantic queries
/docs what are the best practices and recommended workflows using Claude Agent SDK in Python according to the official documentation?
→ Claude extracts: "best practices workflows Agent SDK Python"
→ Executes content search automatically
→ Returns relevant documentation with natural explanations

# Questions about features
/docs what environment variables exist and how do I use them?
→ Claude searches documentation content
→ Provides answer with documentation links

# Comparative questions
/docs explain the differences between hooks and MCP
→ Claude searches for both topics
→ Compares and explains naturally

# Discovery queries
/docs show me everything about memory features
→ Claude finds memory-related documentation
→ Lists and summarizes available docs

# Topic-specific searches
/docs find all mentions of authentication
→ Claude performs content search
→ Returns matching documentation sections

# Combined workflows
/docs -t what's new with extended thinking and how does it work?
→ Claude checks for updates
→ Searches for extended thinking documentation
→ Combines recent changes with explanation
```

**Behind the scenes:** Claude itself is the search engine. It can:
- Read documentation files directly
- Search content using grep
- Match filenames to topics
- Synthesize answers from multiple sources

**With Python 3.9+:** Optimized helper commands (`--search-content`, `--search`) provide faster, more accurate results.

**Without Python 3.9+:** Claude uses its native capabilities (file reading, grep, pattern matching) to find and present documentation. The AI-powered experience works either way - Python just makes it faster.

### Advanced Commands (Direct Access)

For power users who want direct access to helper functions:

```bash
# Fuzzy search across all tracked paths (requires Python 3.9+)
~/.claude-code-docs/claude-docs-helper.sh --search "keyword"

# Full-text content search (requires Python 3.9+)
~/.claude-code-docs/claude-docs-helper.sh --search-content "term"

# Validate all paths - check for 404s (requires Python 3.9+)
~/.claude-code-docs/claude-docs-helper.sh --validate

# Show installation status and available features
~/.claude-code-docs/claude-docs-helper.sh --status

# Show all commands
~/.claude-code-docs/claude-docs-helper.sh --help
```

**Note:** Most users should use the AI-powered `/docs` command instead of calling these directly. The AI provides better results through semantic understanding and intelligent routing.

## Architecture

**Single Installation** - Always installs complete repository:
- Full documentation mirror (~1,250 paths across five active categories)
- Modular Python packages for enhanced features
- Validation and unit test suites

**Modular Code Structure** - Python code organized into focused packages:
```
scripts/
├── fetcher/           # Documentation fetching (8 modules)
│   ├── config.py      # Constants and safety thresholds
│   ├── manifest.py    # Manifest file operations
│   ├── paths.py       # Path conversion and categorization
│   ├── sitemap.py     # Sitemap discovery and parsing
│   ├── content.py     # Content fetching and validation
│   ├── safeguards.py  # Safety checks (deletion prevention)
│   └── cli.py         # Main entry point
├── lookup/            # Search and validation (7 modules)
│   ├── config.py      # Configuration constants
│   ├── manifest.py    # Manifest loading utilities
│   ├── search.py      # Search functionality
│   ├── validation.py  # Path validation
│   ├── formatting.py  # Output formatting
│   └── cli.py         # Main entry point
├── fetch_claude_docs.py  # Thin wrapper (backwards compatible)
└── lookup_paths.py       # Thin wrapper (backwards compatible)
```

**Graceful Degradation** - Features adapt to environment:
- **Without Python**: Basic documentation reading via `/docs` command
- **With Python 3.9+**: Full-text search, fuzzy matching, validation, auto-regeneration

**No separate "modes"** - Everything is installed once, features activate when Python is available.

## How Updates Work

Documentation stays current through:

1. **Repository Updates** - GitHub Actions fetches new docs every 3 hours
2. **On-Demand Sync** - Run `/docs -t` to check for and pull updates
3. **Auto-Regeneration** - Manifests regenerate from sitemaps on each fetch
4. **Visual Feedback** - See "🔄 Updating documentation..." when updates occur
5. **Safety Validation** - Each sync validates against safeguard thresholds before committing

**Sitemap Sources:**
- `https://platform.claude.com/sitemap.xml` - Platform documentation
- `https://code.claude.com/docs/sitemap.xml` - Claude Code documentation

**Manual update:**
```bash
cd ~/.claude-code-docs && git pull
```

**Force reinstall:**
```bash
curl -fsSL https://raw.githubusercontent.com/seanGSISG/claude-code-docs/main/install.sh | bash
```

## Troubleshooting

### Command Not Found

**Problem:** `/docs` returns "command not found"

**Solution:**
1. Check: `ls ~/.claude/commands/docs.md`
2. Restart Claude Code
3. Re-run installer if needed

### Installation Errors

**"Installation cancelled" when using `curl | bash`:**

The installer needs to read your response, but stdin is consumed by the pipe in some environments.

**Solutions:**
1. Auto-install: `CLAUDE_DOCS_AUTO_INSTALL=yes curl ... | bash`
2. Download first: `curl ... -o install.sh && bash install.sh`
3. SSH with `-t`: `ssh -t user@server 'curl ... | bash'`

**"Running in non-interactive mode":**

This appears in CI/CD, Docker, cron, or SSH without `-t`. Use `CLAUDE_DOCS_AUTO_INSTALL=yes`.

**Other issues:**
- **"git/jq/curl not found"**: Install the missing tool
- **"Failed to clone"**: Check internet connection
- **"Failed to update settings.json"**: Check file permissions

### Documentation Not Updating

**Problem:** Documentation seems outdated

**Solution:**
1. `/docs -t` to force check and update
2. Manual: `cd ~/.claude-code-docs && git pull`
3. Check [GitHub Actions](https://github.com/seanGSISG/claude-code-docs/actions)
4. Reinstall as last resort

### Which Version?

Check your installation:
```bash
~/.claude-code-docs/claude-docs-helper.sh --version
```

Or:
```bash
cat ~/.claude-code-docs/README.md | head -1
```

## Platform Support

- ✅ **macOS**: Fully supported (tested on macOS 12+)
- ✅ **Linux**: Fully supported (Ubuntu, Debian, Fedora, etc.)
- ⏳ **Windows**: Not yet supported - [contributions welcome](#contributing)!

## Uninstalling

Complete removal:
```bash
/docs uninstall
```

Or manually:
```bash
~/.claude-code-docs/uninstall.sh
```

See [UNINSTALL.md](UNINSTALL.md) for manual removal instructions.

## Security

**Defense-in-Depth Approach:**
- Input sanitization (alphanumeric + safe chars only)
- Path traversal protection (prevents `../` attacks)
- Shell injection prevention (heredocs, env vars)
- Comprehensive security testing (13 test cases)

**Documentation Deletion Safeguards:**

The automated sync system includes multiple safeguards to prevent catastrophic documentation loss:

| Safeguard | Threshold | Purpose |
|-----------|-----------|---------|
| `MIN_DISCOVERY_THRESHOLD` | 200 paths | Refuses to proceed if sitemap discovery finds too few paths |
| `MAX_DELETION_PERCENT` | 10% | Never deletes more than 10% of existing files in one sync |
| `MIN_EXPECTED_FILES` | 250 files | Refuses if file count would drop below minimum |
| Workflow validation | Auto-revert | GitHub Actions automatically reverts on sync failure |

These safeguards protect against:
- Sitemap URLs returning errors (500, 401, etc.)
- Network failures during discovery
- Upstream documentation restructuring
- Accidental mass deletion bugs

**Operational Security:**
- All operations limited to documentation directory
- No external data transmission
- HTTPS-only GitHub clones
- You can fork and install from your own repository

**Validation:**
- Unit + validation test suites run in CI on Python 3.9–3.12
- Daily scheduled workflow validates every mirrored path is reachable

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Architecture overview
- Development setup
- Testing requirements
- PR guidelines
- Security standards

**Quick start for contributors:**
```bash
# Fork the repository
git clone https://github.com/YOUR_USERNAME/claude-code-docs.git
cd claude-code-docs

# Setup Python environment (optional, for enhanced features)
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"

# Run tests
pytest tests/ -v
```

## Acknowledgments

- **[Eric Buess](https://github.com/ericbuess)** - Creator of [claude-code-docs](https://github.com/ericbuess/claude-code-docs), the foundation for this project
- **[Anthropic](https://www.anthropic.com/)** - For Claude Code and the documentation

The original [ericbuess/claude-code-docs](https://github.com/ericbuess/claude-code-docs) provides a simpler, shell-only implementation. This fork extends it with optional Python features for users who need advanced search and validation.

## License

Documentation content belongs to Anthropic.
Tool code is open source - contributions welcome!
