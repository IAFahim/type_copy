#!/bin/bash

# Script to copy all git-tracked programming language files to clipboard
# Includes directory tree structure and file information

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository"
    exit 1
fi

# Detect OS and set clipboard command
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CLIP_CMD="pbcopy"
elif command -v xclip > /dev/null 2>&1; then
    # Linux with xclip
    CLIP_CMD="xclip -selection clipboard"
elif command -v xsel > /dev/null 2>&1; then
    # Linux with xsel
    CLIP_CMD="xsel --clipboard --input"
else
    echo "Error: No clipboard utility found"
    echo "On Linux, please install xclip or xsel:"
    echo "  Ubuntu/Debian: sudo apt-get install xclip"
    echo "  Fedora: sudo dnf install xclip"
    exit 1
fi

# Common programming language file extensions
EXTENSIONS=(
    "*.c" "*.h"           # C
    "*.cpp" "*.cc" "*.cxx" "*.hpp" "*.hxx"  # C++
    "*.java"              # Java
    "*.py"                # Python
    "*.js" "*.jsx" "*.ts" "*.tsx"  # JavaScript/TypeScript
    "*.rb"                # Ruby
    "*.php"               # PHP
    "*.go"                # Go
    "*.rs"                # Rust
    "*.swift"             # Swift
    "*.kt" "*.kts"        # Kotlin
    "*.scala"             # Scala
    "*.m" "*.mm"          # Objective-C
    "*.cs"                # C#
    "*.vb"                # Visual Basic
    "*.pl" "*.pm"         # Perl
    "*.r" "*.R"           # R
    "*.lua"               # Lua
    "*.sh" "*.bash"       # Shell
    "*.sql"               # SQL
    "*.html" "*.css"      # Web
    "*.xml" "*.json" "*.yaml" "*.yml"  # Config/Data
)

# Temporary file to store content
TEMP_FILE=$(mktemp)

echo "Collecting git-tracked programming files..."

# Array to store all matched files
declare -a FILES

# Get all tracked files and filter by extensions
for ext in "${EXTENSIONS[@]}"; do
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            FILES+=("$file")
        fi
    done < <(git ls-files "$ext" 2>/dev/null)
done

# Sort files
IFS=$'\n' FILES=($(sort <<<"${FILES[*]}"))
unset IFS

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No programming files found in git repository"
    rm "$TEMP_FILE"
    exit 0
fi

# Generate directory tree
echo "DIRECTORY TREE" >> "$TEMP_FILE"
echo "==============" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Use tree if available, otherwise generate a simple tree
if command -v tree > /dev/null 2>&1; then
    tree -F --fromfile <(printf "%s\n" "${FILES[@]}") >> "$TEMP_FILE" 2>/dev/null
else
    # Simple tree generation
    for file in "${FILES[@]}"; do
        echo "$file" >> "$TEMP_FILE"
    done
fi

echo -e "\n\n" >> "$TEMP_FILE"

# Add file contents with metadata
echo "FILE CONTENTS" >> "$TEMP_FILE"
echo "=============" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

COUNT=0
for file in "${FILES[@]}"; do
    # Get file extension
    filename=$(basename "$file")
    extension="${filename##*.}"
    
    echo "--- $file | $filename | .$extension ---" >> "$TEMP_FILE"
    cat "$file" >> "$TEMP_FILE"
    echo -e "\n" >> "$TEMP_FILE"
    ((COUNT++))
    echo "Added: $file"
done

# Copy to clipboard
cat "$TEMP_FILE" | eval "$CLIP_CMD"

# Get file size
FILE_SIZE=$(wc -c < "$TEMP_FILE")

# Clean up
rm "$TEMP_FILE"

echo "==========================================="
echo "✓ Copied $COUNT files to clipboard!"
echo "Total size: $FILE_SIZE bytes"
