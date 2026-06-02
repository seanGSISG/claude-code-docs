#!/bin/bash
set -euo pipefail

# Claude Code Documentation Enhanced Helper Script
# This script extends the standard template with enhanced features
# Installation path: ~/.claude-code-docs/scripts/claude-docs-helper.sh

# Script version
ENHANCED_VERSION="0.6.0"

# Fixed installation path
DOCS_PATH="$HOME/.claude-code-docs"
SCRIPTS_PATH="$DOCS_PATH/scripts"

# Resolve a Python 3.9+ interpreter once. Prefer python3, fall back to python
# (common on Windows where the python3 shim may be absent). Empty if none found.
PYTHON_BIN=""
for _py_candidate in python3 python; do
    if command -v "$_py_candidate" >/dev/null 2>&1 && \
       "$_py_candidate" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 9) else 1)' >/dev/null 2>&1; then
        PYTHON_BIN="$_py_candidate"
        break
    fi
done

# Source the standard template for base functionality
TEMPLATE_PATH="$SCRIPTS_PATH/claude-docs-helper.sh.template"
TEMPLATE_AVAILABLE=true
if [[ -f "$TEMPLATE_PATH" ]]; then
    # Define a function to run template commands
    run_template_command() {
        bash "$TEMPLATE_PATH" "$@"
    }
else
    TEMPLATE_AVAILABLE=false
    # Provide minimal fallback when template is missing
    run_template_command() {
        echo "📚 COMMUNITY MIRROR: https://github.com/costiash/claude-code-docs"
        echo "📖 OFFICIAL DOCS: https://docs.anthropic.com/en/docs/claude-code"
        echo ""
        echo "⚠️  Template script missing - running in fallback mode"
        echo ""

        local topic="${1:-}"

        # Handle special commands
        case "$topic" in
            -t|--check|--help|-h|--version|--status)
                echo "This command requires the template script."
                echo "Please reinstall: curl -fsSL https://raw.githubusercontent.com/costiash/claude-code-docs/main/install.sh | bash"
                return 1
                ;;
        esac

        # Try to read documentation directly
        if [[ -n "$topic" && -d "$DOCS_PATH/docs" ]]; then
            # Sanitize topic to prevent path traversal attacks
            local safe_topic=$(echo "$topic" | sed 's/[^a-zA-Z0-9_-]//g')
            if [[ -z "$safe_topic" ]]; then
                echo "Invalid topic name: $topic"
                return 1
            fi

            # Try common filename patterns
            local doc_file=""
            local docs_dir="$DOCS_PATH/docs"
            for pattern in "${safe_topic}.md" "docs__en__${safe_topic}.md" "en__docs__claude-code__${safe_topic}.md"; do
                local candidate="$docs_dir/$pattern"
                if [[ -f "$candidate" ]]; then
                    # Security: Validate resolved path stays within docs directory
                    local resolved_path=$(cd "$(dirname "$candidate")" 2>/dev/null && pwd -P)/$(basename "$candidate")
                    local resolved_docs=$(cd "$docs_dir" 2>/dev/null && pwd -P)
                    if [[ "$resolved_path" == "$resolved_docs/"* ]]; then
                        doc_file="$candidate"
                        break
                    fi
                fi
            done

            if [[ -n "$doc_file" ]]; then
                echo "📄 Reading: $safe_topic"
                echo ""
                cat "$doc_file"
                return 0
            else
                echo "Could not find documentation for: $safe_topic"
                echo ""
            fi
        fi

        # List available documentation
        if [[ -d "$DOCS_PATH/docs" ]]; then
            echo "Available documentation files:"
            ls "$DOCS_PATH/docs" 2>/dev/null | grep '\.md$' | sed 's/\.md$//' | sort | head -20
            echo ""
            echo "(Showing first 20 files. Template needed for full functionality.)"
        else
            echo "Documentation directory not found."
        fi

        echo ""
        echo "To restore full functionality, reinstall:"
        echo "  curl -fsSL https://raw.githubusercontent.com/costiash/claude-code-docs/main/install.sh | bash"
        return 1
    }
fi

# Check if a Python 3.9+ interpreter was resolved
check_python() {
    [[ -n "$PYTHON_BIN" ]]
}

# Check if enhanced features are available
check_enhanced_available() {
    # Check Python version
    if ! check_python; then
        return 1
    fi

    # Check if lookup_paths.py exists
    if [[ ! -f "$SCRIPTS_PATH/lookup_paths.py" ]]; then
        return 1
    fi

    # Check if paths_manifest.json exists with enhanced paths
    if [[ ! -f "$DOCS_PATH/paths_manifest.json" ]]; then
        return 1
    fi

    # Read the file via shell redirection (the shell understands MSYS/Cygwin
    # paths like /c/Users/...); native Windows Python cannot open those paths.
    local path_count=$("$PYTHON_BIN" -c "import json, sys; print(json.load(sys.stdin)['metadata'].get('total_paths', 0))" < "$DOCS_PATH/paths_manifest.json" 2>/dev/null || echo "0")

    # Active manifest has ~270 paths (all available documentation)
    if [[ "$path_count" -ge 100 ]]; then
        return 0
    else
        return 1
    fi
}

# Enhanced search - uses lookup_paths.py for fuzzy path search
enhanced_search() {
    if ! check_enhanced_available; then
        echo "❌ Enhanced search not available"
        echo "   Requires: Python 3.9+, lookup_paths.py, enhanced manifest"
        echo "   Reinstall with enhanced features: curl -fsSL .../install.sh | bash"
        echo ""
        echo "Falling back to standard search..."
        echo ""
        run_template_command "$@"
        return
    fi

    local query="$*"
    echo "🔍 Searching documentation paths for: $query"
    echo ""

    if "$PYTHON_BIN" "$SCRIPTS_PATH/lookup_paths.py" "$query" 2>/dev/null; then
        echo ""
        echo "💡 Tip: Use '/docs <topic>' to read a specific document"
    else
        echo "⚠️  Search failed"
        echo "Falling back to standard search..."
        echo ""
        run_template_command "$@"
    fi
}

# Full-text content search over the live docs (ripgrep, grep fallback).
# No pre-built index — always current, no Python/index dependency.
search_content() {
    local query="$*"
    local docs_dir="$DOCS_PATH/docs"
    echo "📖 Searching documentation content for: $query"
    echo ""

    if [[ ! -d "$docs_dir" ]]; then
        echo "⚠️  Docs directory not found: $docs_dir"
        return 1
    fi

    # Use -l (files-with-matches) only: avoids parsing "FILE:COUNT" output,
    # which breaks on Windows drive-letter colons (C:/...). Filenames encode
    # the doc path, so the file list is enough for the agent to pick from.
    local matches=""
    if command -v rg >/dev/null 2>&1; then
        matches=$(rg --no-messages -l -i -- "$query" "$docs_dir" 2>/dev/null | head -20)
    elif command -v grep >/dev/null 2>&1; then
        matches=$(grep -rli --include='*.md' -- "$query" "$docs_dir" 2>/dev/null | head -20)
    else
        echo "⚠️  Neither rg nor grep is available for content search"
        return 1
    fi

    if [[ -z "$matches" ]]; then
        echo "No matches for: $query"
        return 0
    fi

    # Show the basename (filenames encode the doc path). Strip to the last
    # slash OR backslash so it works for /c/... , C:/... and Windows rg output
    # that joins the final segment with a backslash (docs\file.md).
    while IFS= read -r f; do
        [[ -n "$f" ]] && echo "• ${f##*[\\/]}"
    done <<< "$matches"
    echo ""
    echo "💡 Tip: Use '/docs <topic>' to read the full document"
}

# Validate all paths
validate_paths() {
    if ! check_enhanced_available; then
        echo "❌ Path validation not available"
        echo "   Requires: Python 3.9+, lookup_paths.py"
        echo ""
        return 1
    fi

    echo "🔍 Validating all documentation paths..."
    echo "This may take 30-60 seconds..."
    echo ""

    if "$PYTHON_BIN" "$SCRIPTS_PATH/lookup_paths.py" --validate-all 2>/dev/null; then
        echo ""
        echo "✅ Validation complete"
    else
        echo "⚠️  Validation failed"
        echo "   Check your internet connection"
    fi
}

# Update all documentation (fetch all paths)
update_all_docs() {
    if ! check_enhanced_available; then
        echo "❌ Enhanced update not available"
        echo "   Requires: Python 3.9+, main.py"
        echo ""
        echo "Falling back to standard git pull..."
        cd "$DOCS_PATH" && git pull
        return
    fi

    echo "🔄 Updating all documentation..."
    echo "This may take 2-3 minutes..."
    echo ""

    if "$PYTHON_BIN" "$SCRIPTS_PATH/main.py" --update-all 2>/dev/null; then
        echo ""
        echo "✅ Documentation updated successfully"
    else
        echo "⚠️  Enhanced update failed"
        echo "Falling back to git pull..."
        cd "$DOCS_PATH" && git pull
    fi
}

# Show enhanced help
show_enhanced_help() {
    run_template_command --help 2>/dev/null || run_template_command
    echo ""
    echo "─────────────────────────────────────────────────────────────────"
    echo "Enhanced Edition Commands (requires Python 3.9+):"
    echo "─────────────────────────────────────────────────────────────────"
    echo ""
    echo "Search & Discovery:"
    echo "  --search <query>        Fuzzy search across all documentation paths"
    echo "  --search-content <term> Full-text content search across all documentation"
    echo ""
    echo "Maintenance:"
    echo "  --validate              Validate all paths (check for 404s)"
    echo "  --update-all            Fetch all documentation pages"
    echo ""
    echo "Status:"
    echo "  --version               Show version information"
    echo "  --status                Show installation status"
    echo ""

    if check_enhanced_available; then
        echo "✅ Enhanced features: AVAILABLE"
    else
        echo "❌ Enhanced features: NOT AVAILABLE"
        if ! check_python; then
            echo "   Missing: Python 3.9+"
        else
            echo "   Missing: Enhanced installation files"
        fi
        echo "   Install: curl -fsSL .../install.sh | bash (answer Y)"
    fi
    echo ""
}

# Show version information
show_version() {
    echo "Claude Code Docs - Enhanced Edition v$ENHANCED_VERSION"
    echo ""
    echo "Components:"
    echo "  • Helper script: v$ENHANCED_VERSION"

    if [[ -f "$TEMPLATE_PATH" ]]; then
        local template_version=$(grep "SCRIPT_VERSION=" "$TEMPLATE_PATH" | head -1 | cut -d'"' -f2)
        echo "  • Template: v$template_version"
    fi

    if check_python; then
        local python_version=$("$PYTHON_BIN" --version 2>&1 | cut -d' ' -f2)
        echo "  • Python: $python_version ✓"
    else
        echo "  • Python: Not available"
    fi

    echo ""
    echo "Features:"
    if check_enhanced_available; then
        local path_count=$("$PYTHON_BIN" -c "import json, sys; print(json.load(sys.stdin)['metadata'].get('total_paths', 0))" < "$DOCS_PATH/paths_manifest.json" 2>/dev/null || echo "unknown")
        echo "  ✅ Enhanced features: ENABLED"
        echo "  ✅ Documentation paths: $path_count"
        echo "  ✅ Fuzzy search: Available"
        echo "  ✅ Content search: Available"
        echo "  ✅ Path validation: Available"
    else
        echo "  ❌ Enhanced features: DISABLED"
        echo "     (documentation files available; Python features require Python 3.9+)"
    fi
    echo ""
}

# Show installation status
show_status() {
    echo "Installation Status"
    echo "───────────────────"
    echo ""
    echo "Location: $DOCS_PATH"

    if [[ -d "$DOCS_PATH" ]]; then
        echo "Status: ✅ Installed"
    else
        echo "Status: ❌ Not found"
        return 1
    fi

    echo ""
    echo "Standard Features:"
    [[ -f "$TEMPLATE_PATH" ]] && echo "  ✅ Template script" || echo "  ❌ Template script"
    [[ -f "$DOCS_PATH/claude-docs-helper.sh" ]] && echo "  ✅ Helper script" || echo "  ❌ Helper script"
    [[ -d "$DOCS_PATH/docs" ]] && echo "  ✅ Documentation directory" || echo "  ❌ Documentation directory"

    local doc_count=$(find "$DOCS_PATH/docs" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    echo "  📄 Documentation files: $doc_count"

    echo ""
    echo "Enhanced Features:"

    if check_python; then
        local python_version=$("$PYTHON_BIN" --version 2>&1 | cut -d' ' -f2)
        echo "  ✅ Python $python_version"
    else
        echo "  ❌ Python 3.9+ (not available)"
    fi

    [[ -f "$SCRIPTS_PATH/lookup_paths.py" ]] && echo "  ✅ lookup_paths.py" || echo "  ❌ lookup_paths.py"
    [[ -f "$SCRIPTS_PATH/main.py" ]] && echo "  ✅ main.py" || echo "  ❌ main.py"
    [[ -f "$DOCS_PATH/paths_manifest.json" ]] && echo "  ✅ paths_manifest.json" || echo "  ❌ paths_manifest.json"

    if [[ -f "$DOCS_PATH/paths_manifest.json" ]]; then
        local path_count=$("$PYTHON_BIN" -c "import json, sys; print(json.load(sys.stdin)['metadata'].get('total_paths', 0))" < "$DOCS_PATH/paths_manifest.json" 2>/dev/null || echo "unknown")
        echo "  📊 Manifest paths: $path_count"
    fi

    echo ""
    if check_enhanced_available; then
        echo "Overall: ✅ Enhanced features AVAILABLE"
    else
        echo "Overall: ⚠️  Standard features only"
        echo ""
        echo "To enable enhanced features:"
        echo "  curl -fsSL https://raw.githubusercontent.com/costiash/claude-code-docs/main/install.sh | bash"
        echo "  (Answer 'y' to install enhanced features)"
    fi
    echo ""
}

# Main command handling
case "${1:-}" in
    --search)
        shift
        enhanced_search "$@"
        ;;
    --search-content)
        shift
        search_content "$@"
        ;;
    --validate)
        validate_paths
        ;;
    --update-all)
        update_all_docs
        ;;
    --help|-h)
        show_enhanced_help
        ;;
    --version)
        show_version
        ;;
    --status)
        show_status
        ;;
    *)
        # Delegate all other commands to standard template
        run_template_command "$@"
        ;;
esac

# Ensure script always exits successfully
exit 0
