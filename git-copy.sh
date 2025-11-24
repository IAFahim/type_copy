#!/bin/bash

# Installation Configuration
INSTALL_DIR="/usr/local/bin"
TOOL_NAME="git-copy"
TARGET_PATH="$INSTALL_DIR/$TOOL_NAME"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "🚀 ${YELLOW}Installing Git Code Copy Utility...${NC}"

# 1. Check for Sudo/Permissions
if [ ! -w "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Need sudo permissions to write to $INSTALL_DIR${NC}"
    SUDO="sudo"
else
    SUDO=""
fi

# 2. Write the script content to the target file
echo -e "📝 Writing script to ${TARGET_PATH}..."

$SUDO tee "$TARGET_PATH" > /dev/null << 'EOF'
#!/bin/bash

# ==============================================================================
# 📋 GIT CODE COPY UTILITY
# ==============================================================================

# --- 1. CONFIGURATION GROUPS ---
GROUP_CPP=("*.c" "*.h" "*.cpp" "*.cc" "*.cxx" "*.hpp" "*.hxx" "*.rs" "*.go" "*.swift")
GROUP_JAVA=("*.java" "*.kt" "*.kts" "*.scala")
GROUP_WEB=("*.html" "*.htm" "*.css" "*.scss" "*.sass" "*.less" "*.js" "*.jsx" "*.ts" "*.tsx")
GROUP_SCRIPT=("*.py" "*.rb" "*.php" "*.pl" "*.pm" "*.lua" "*.sh" "*.bash" "*.zsh")
GROUP_DOTNET=("*.cs" "*.razor" "*.csproj" "*.json")
GROUP_DATA=("*.sql" "*.xml" "*.json" "*.yaml" "*.yml" "*.toml" "*.ini" "*.md")
GROUP_BUILD=("Dockerfile" "Makefile" "Gemfile" "package.json")

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

# --- 3. ARGUMENT PARSING ---
declare -a EXTENSIONS
add_group() { for ext in "${@}"; do EXTENSIONS+=("$ext"); done; }

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo -e "${BOLD}Usage:${NC} git copy [filter]..."
    echo -e "  No args  : Copy all default groups."
    echo -e "  web      : Copy only Web group."
    echo -e "  js       : Copy only *.js files."
    exit 0
fi

if [ $# -eq 0 ]; then
    add_group "${GROUP_CPP[@]}" "${GROUP_JAVA[@]}" "${GROUP_WEB[@]}" "${GROUP_SCRIPT[@]}" "${GROUP_DOTNET[@]}" "${GROUP_DATA[@]}" "${GROUP_BUILD[@]}"
else
    for arg in "$@"; do
        case "$arg" in
            web|frontend)   add_group "${GROUP_WEB[@]}" ;;
            cpp|c|rust|go)  add_group "${GROUP_CPP[@]}" ;;
            java|jvm)       add_group "${GROUP_JAVA[@]}" ;;
            script|backend) add_group "${GROUP_SCRIPT[@]}" ;;
            dotnet|csharp)  add_group "${GROUP_DOTNET[@]}" ;;
            data|config)    add_group "${GROUP_DATA[@]}" ;;
            *)
                if [[ "$arg" == *"."* ]]; then EXTENSIONS+=("$arg"); else EXTENSIONS+=("*.$arg"); fi
                ;;
        esac
    done
fi

# --- 4. LANGUAGE DETECTION ---
get_language() {
    local fname=$(basename "$1")
    local ext="${fname##*.}"
    case "$fname" in Dockerfile) echo "dockerfile"; return ;; Makefile) echo "makefile"; return ;; package.json) echo "json"; return ;; esac
    case "$ext" in
        cs) echo "csharp" ;; razor) echo "razor" ;; c|h) echo "c" ;; cpp|hpp|cc) echo "cpp" ;;
        java) echo "java" ;; kt|kts) echo "kotlin" ;; py) echo "python" ;; rb) echo "ruby" ;;
        php) echo "php" ;; go) echo "go" ;; rs) echo "rust" ;; swift) echo "swift" ;;
        js|jsx) echo "javascript" ;; ts|tsx) echo "typescript" ;; sh|bash|zsh) echo "bash" ;;
        sql) echo "sql" ;; xml|csproj) echo "xml" ;; json) echo "json" ;; yaml|yml) echo "yaml" ;;
        md) echo "markdown" ;; html) echo "html" ;; css) echo "css" ;; scss) echo "scss" ;;
        *) echo "$ext" ;;
    esac
}

# --- 5. EXECUTION ---
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}Error: Not a git repository.${NC}"
    exit 1
fi

TEMP_FILE=$(mktemp /tmp/gitcode.XXXXXX)
echo -e "${BLUE}Scanning for files...${NC}"

declare -a FILES
for ext in "${EXTENSIONS[@]}"; do
    if [[ "$ext" == *"*"* ]]; then CMD="git ls-files \"$ext\""; else CMD="git ls-files | grep \"$ext$\""; fi
    while IFS= read -r file; do
        if [ -f "$file" ] && [ "$(basename "$file")" != "$SCRIPT_NAME" ]; then FILES+=("$file"); fi
    done < <(eval "$CMD" 2>/dev/null)
done

if [ ${#FILES[@]} -gt 0 ]; then IFS=$'\n' FILES=($(sort -u <<<"${FILES[*]}")); unset IFS; fi
TOTAL_FILES=${#FILES[@]}

if [ "$TOTAL_FILES" -eq 0 ]; then
    echo -e "${YELLOW}No matching files found.${NC}"
    rm "$TEMP_FILE"
    exit 0
fi

# PART A: FILE CONTENTS
COUNT=0
TOTAL_LINES=0
for file in "${FILES[@]}"; do
    ((COUNT++))
    printf "\r${BLUE}[%3d/%3d]${NC} %-50s" "$COUNT" "$TOTAL_FILES" "$(basename "$file")"
    if grep -qI . "$file" 2>/dev/null; then :; elif [ -s "$file" ]; then continue; fi
    
    lang=$(get_language "$file")
    line_count=$(wc -l < "$file" | tr -d ' ')
    
    {
        echo "## File: \`$file\`"; echo ""; echo "\`\`\`$lang"; cat "$file"; echo ""; echo "\`\`\`"; echo "";
    } >> "$TEMP_FILE"
    TOTAL_LINES=$((TOTAL_LINES + line_count))
done
printf "\r\033[K"

# PART B: TREE
echo "---" >> "$TEMP_FILE"
echo "# Project Context" >> "$TEMP_FILE"
echo "\`\`\`" >> "$TEMP_FILE"
if command -v tree > /dev/null 2>&1; then
    tree -F --fromfile <(printf "%s\n" "${FILES[@]}") >> "$TEMP_FILE" 2>/dev/null
else
    printf "%s\n" "${FILES[@]}" >> "$TEMP_FILE"
fi
echo "\`\`\`" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# PART C: FOOTER
echo "**Summary:** $COUNT files | $TOTAL_LINES lines" >> "$TEMP_FILE"
cat "$TEMP_FILE" | eval "$CLIP_CMD"
CLIPBOARD_SIZE=$(wc -c < "$TEMP_FILE")
MB_SIZE=$(awk "BEGIN {printf \"%.2f\", $CLIPBOARD_SIZE/1024/1024}")
rm "$TEMP_FILE"

echo -e "${GREEN}${BOLD}✓ Copied to clipboard!${NC}"
echo -e "Files: $COUNT | Lines: $TOTAL_LINES | Size: ${MB_SIZE} MB"
EOF

# 3. Set Permissions
$SUDO chmod +x "$TARGET_PATH"

echo -e "${GREEN}✅ Installed successfully to $TARGET_PATH${NC}"

# 4. Linux Check (xclip/xsel)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! command -v xclip > /dev/null && ! command -v xsel > /dev/null && ! command -v wl-copy > /dev/null; then
        echo -e "${YELLOW}⚠️  Warning: Linux requires a clipboard tool.${NC}"
        echo "   Install one of these:"
        echo "   sudo apt install xclip   # Debian/Ubuntu"
        echo "   sudo dnf install xclip   # Fedora"
    fi
fi

echo -e ""
echo -e "🎉 ${BOLD}How to use:${NC}"
echo -e "   Go to any git folder and run:"
echo -e "   ${BOLD}git copy${NC}       (Copies all files)"
echo -e "   ${BOLD}git copy web${NC}   (Copies web files)"
