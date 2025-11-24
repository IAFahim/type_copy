#!/bin/bash

# ==============================================================================
# 📋 GIT CODE COPY UTILITY
# ==============================================================================
# Usage:
#   ./copy-code.sh           -> Copies all tracked files defined in groups below.
#   ./copy-code.sh web       -> Copies only Web group (html, css, js...).
#   ./copy-code.sh js py     -> Copies only Javascript and Python files.
#   ./copy-code.sh --help    -> Shows help menu.
# ==============================================================================

# --- 1. CONFIGURATION GROUPS (EASY EDIT) ---
# Comment out lines here to permanently ignore specific file types.
# You can also add your own extensions to these arrays.

# C / C++ / Systems
GROUP_CPP=("*.c" "*.h" "*.cpp" "*.cc" "*.cxx" "*.hpp" "*.hxx" "*.rs" "*.go" "*.swift")

# Java / JVM
GROUP_JAVA=("*.java" "*.kt" "*.kts" "*.scala")

# Web (Frontend)
GROUP_WEB=("*.html" "*.htm" "*.css" "*.scss" "*.sass" "*.less" "*.js" "*.jsx" "*.ts" "*.tsx")

# Backend / Scripting
GROUP_SCRIPT=("*.py" "*.rb" "*.php" "*.pl" "*.pm" "*.lua" "*.sh" "*.bash" "*.zsh")

# .NET
GROUP_DOTNET=("*.cs" "*.razor" "*.csproj" "*.json")

# Data / Config / Documentation
GROUP_DATA=("*.sql" "*.xml" "*.json" "*.yaml" "*.yml" "*.toml" "*.ini" "*.md")

# Build Files (Exact matches)
GROUP_BUILD=("Dockerfile" "Makefile" "Gemfile" "package.json")

# ==============================================================================
# ⚙️ INTERNAL LOGIC (DO NOT EDIT BELOW UNLESS YOU KNOW BASH)
# ==============================================================================

SCRIPT_NAME=$(basename "$0")
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# --- 2. CLIPBOARD DETECTION ---
if [[ "$OSTYPE" == "darwin"* ]]; then
    CLIP_CMD="pbcopy"
elif command -v xclip > /dev/null 2>&1; then
    CLIP_CMD="xclip -selection clipboard"
elif command -v xsel > /dev/null 2>&1; then
    CLIP_CMD="xsel --clipboard --input"
elif command -v wl-copy > /dev/null 2>&1; then
    CLIP_CMD="wl-copy"
else
    echo -e "${YELLOW}Error: No clipboard tool found (install xclip, xsel, or wl-copy).${NC}"
    exit 1
fi

# --- 3. ARGUMENT PARSING & EXTENSION BUILDING ---
declare -a EXTENSIONS

add_group() { for ext in "${@}"; do EXTENSIONS+=("$ext"); done; }

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo -e "${BOLD}Usage:${NC} ./copy-code.sh [filter] [filter]..."
    echo -e "  No args  : Copy all default groups configured in script."
    echo -e "  web      : Copy only Web group."
    echo -e "  cpp      : Copy only C/C++/Rust/Go."
    echo -e "  js       : Copy only *.js files (adhoc filter)."
    exit 0
fi

# If no arguments provided, load ALL groups
if [ $# -eq 0 ]; then
    add_group "${GROUP_CPP[@]}"
    add_group "${GROUP_JAVA[@]}"
    add_group "${GROUP_WEB[@]}"
    add_group "${GROUP_SCRIPT[@]}"
    add_group "${GROUP_DOTNET[@]}"
    add_group "${GROUP_DATA[@]}"
    add_group "${GROUP_BUILD[@]}"
else
    # Parse arguments dynamically
    for arg in "$@"; do
        case "$arg" in
            # Group Keywords
            web|frontend)   add_group "${GROUP_WEB[@]}" ;;
            cpp|c|rust|go)  add_group "${GROUP_CPP[@]}" ;;
            java|jvm)       add_group "${GROUP_JAVA[@]}" ;;
            script|backend) add_group "${GROUP_SCRIPT[@]}" ;;
            dotnet|csharp)  add_group "${GROUP_DOTNET[@]}" ;;
            data|config)    add_group "${GROUP_DATA[@]}" ;;
            
            # Specific extensions (User typed "js" -> add "*.js")
            *)
                if [[ "$arg" == *"."* ]]; then
                    EXTENSIONS+=("$arg") # User typed "*.js"
                else
                    EXTENSIONS+=("*.$arg") # User typed "js"
                fi
                ;;
        esac
    done
fi

# --- 4. LANGUAGE DETECTION (MAC COMPATIBLE) ---
get_language() {
    local fname=$(basename "$1")
    local ext="${fname##*.}"
    
    # Specific files
    case "$fname" in
        Dockerfile) echo "dockerfile"; return ;;
        Makefile)   echo "makefile"; return ;;
        package.json) echo "json"; return ;;
    esac

    # Extensions
    case "$ext" in
        cs)             echo "csharp" ;;
        razor)          echo "razor" ;;
        c|h)            echo "c" ;;
        cpp|hpp|cc)     echo "cpp" ;;
        java)           echo "java" ;;
        kt|kts)         echo "kotlin" ;;
        py)             echo "python" ;;
        rb)             echo "ruby" ;;
        php)            echo "php" ;;
        go)             echo "go" ;;
        rs)             echo "rust" ;;
        swift)          echo "swift" ;;
        js|jsx)         echo "javascript" ;;
        ts|tsx)         echo "typescript" ;;
        sh|bash|zsh)    echo "bash" ;;
        sql)            echo "sql" ;;
        xml|csproj)     echo "xml" ;;
        json)           echo "json" ;;
        yaml|yml)       echo "yaml" ;;
        md)             echo "markdown" ;;
        html)           echo "html" ;;
        css)            echo "css" ;;
        scss)           echo "scss" ;;
        *)              echo "$ext" ;;
    esac
}

# --- 5. EXECUTION ---

# Check Git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}Error: Not a git repository.${NC}"
    exit 1
fi

TEMP_FILE=$(mktemp /tmp/gitcode.XXXXXX)

echo -e "${BLUE}Scanning for files...${NC}"

# Gather Files
declare -a FILES
for ext in "${EXTENSIONS[@]}"; do
    # Handle exact filenames vs wildcards
    if [[ "$ext" == *"*"* ]]; then
        CMD="git ls-files \"$ext\""
    else
        CMD="git ls-files | grep \"$ext$\""
    fi
    
    while IFS= read -r file; do
        # SAFETY CHECK: Ignore self, ignore .git, ensure file exists
        if [ -f "$file" ] && [ "$(basename "$file")" != "$SCRIPT_NAME" ]; then
            FILES+=("$file")
        fi
    done < <(eval "$CMD" 2>/dev/null)
done

# Deduplicate
if [ ${#FILES[@]} -gt 0 ]; then
    IFS=$'\n' FILES=($(sort -u <<<"${FILES[*]}"))
    unset IFS
fi

TOTAL_FILES=${#FILES[@]}

if [ "$TOTAL_FILES" -eq 0 ]; then
    echo -e "${YELLOW}No matching files found.${NC}"
    rm "$TEMP_FILE"
    exit 0
fi

# Build Output
echo "# Project Context" >> "$TEMP_FILE"
echo "\`\`\`" >> "$TEMP_FILE"
if command -v tree > /dev/null 2>&1; then
    tree -F --fromfile <(printf "%s\n" "${FILES[@]}") >> "$TEMP_FILE" 2>/dev/null
else
    printf "%s\n" "${FILES[@]}" >> "$TEMP_FILE"
fi
echo "\`\`\`" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

COUNT=0
TOTAL_LINES=0
TOTAL_SIZE=0

for file in "${FILES[@]}"; do
    ((COUNT++))
    
    # Progress UI
    printf "\r${BLUE}[%3d/%3d]${NC} %-50s" "$COUNT" "$TOTAL_FILES" "$(basename "$file")"

    # Skip Binary
    if grep -qI . "$file" 2>/dev/null; then :; elif [ -s "$file" ]; then continue; fi

    lang=$(get_language "$file")
    line_count=$(wc -l < "$file" | tr -d ' ')
    file_size=$(wc -c < "$file" | tr -d ' ')

    {
        echo "## File: \`$file\`"
        echo ""
        echo "\`\`\`$lang"
        cat "$file"
        echo ""
        echo "\`\`\`"
        echo ""
    } >> "$TEMP_FILE"

    TOTAL_LINES=$((TOTAL_LINES + line_count))
    TOTAL_SIZE=$((TOTAL_SIZE + file_size))
done

# Clear Progress line
printf "\r\033[K"

# Summary footer
echo "---" >> "$TEMP_FILE"
echo "**Summary:** $COUNT files | $TOTAL_LINES lines" >> "$TEMP_FILE"

# Copy
cat "$TEMP_FILE" | eval "$CLIP_CMD"

# Stats
CLIPBOARD_SIZE=$(wc -c < "$TEMP_FILE")
TOKENS=$((CLIPBOARD_SIZE / 4))
MB_SIZE=$(awk "BEGIN {printf \"%.2f\", $CLIPBOARD_SIZE/1024/1024}")

rm "$TEMP_FILE"

echo -e "${GREEN}${BOLD}✓ Copied to clipboard!${NC}"
echo -e "Files: $COUNT | Lines: $TOTAL_LINES | Tokens: ~$TOKENS | Size: ${MB_SIZE} MB"
