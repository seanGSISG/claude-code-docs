# Usage Examples

Practical examples for using claude-code-docs.

## Table of Contents

1. [Using the /docs Command](#using-the-docs-command)
2. [Search From the Agent (Grep / Glob)](#search-from-the-agent-grep--glob)
3. [Command-Line Reference](#command-line-reference)

## Using the /docs Command

The primary interface is the AI-powered `/docs` command in Claude Code. Ask naturally —
Claude syncs the latest docs, locates the relevant files, and synthesizes an answer.

```
/docs mcp
/docs how do hooks work in the Agent SDK?
/docs what's the difference between extended thinking and streaming?
/docs what's new
```

Behind the scenes the skill: (1) pulls the latest docs, (2) locates files with ripgrep
(content) or filename matching (topic), and (3) reads only the most relevant files.

## Search From the Agent (Grep / Glob)

These use Claude Code's built-in tools (bundled ripgrep) over `~/.claude-code-docs/docs`:

```
# Content search — candidate files
Grep(pattern: "tool use", path: "<docs dir>", output_mode: "files_with_matches")

# Content search — rank by match count
Grep(pattern: "memory", path: "<docs dir>", output_mode: "count")

# Topic / path lookup — filenames encode the path
Glob(pattern: "**/*hooks*.md", path: "<docs dir>")
# -> claude-code__hooks.md, docs__en__hooks.md
```

## Command-Line Reference

The helper at `~/.claude-code-docs/claude-docs-helper.sh` (also runnable standalone):

| Command | Description | Needs Python? |
|---|---|---|
| `--search-content "<query>"` | Content search (ripgrep, `grep` fallback) | No |
| `--search "<query>"` | Fuzzy path search | Yes (3.9+) |
| `<topic>` | Read a doc directly by name | No |
| `-t` | Freshness check + sync | No |
| `-t <topic>` | Sync, then read a topic | No |
| `"what's new"` | Recent documentation changes | No |
| `changelog` | Claude Code release notes | No |
| `--validate` | HTTP-validate all paths | Yes (3.9+) |
| `--status` | Installation status and feature availability | No |
| `--help` | Show all commands | No |

### Examples

```bash
# Content search (no Python needed)
~/.claude-code-docs/claude-docs-helper.sh --search-content "model context protocol"

# Read a specific topic
~/.claude-code-docs/claude-docs-helper.sh hooks

# Check freshness, then read
~/.claude-code-docs/claude-docs-helper.sh -t skills

# Fuzzy path search (Python 3.9+)
~/.claude-code-docs/claude-docs-helper.sh --search "extended thinking"
```

### Updating

The `claude-docs` plugin syncs on every `/docs` request, and `/docs-update` forces a
sync on demand. Manually:

```bash
cd ~/.claude-code-docs && git pull
```
