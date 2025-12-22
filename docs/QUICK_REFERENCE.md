# Type Copy - Quick Reference

## Quick Setup

### Automatic Installation
```bash
# Windows - Double-click or run:
setup.bat

# Windows PowerShell:
.\setup.ps1

# macOS/Linux:
chmod +x setup.sh && ./setup.sh
```

### Manual Installation
```bash
pip install pyperclip
```

## Basic Usage
```bash
# Copy all .cs, .md, .py files in current directory
python copy.cs.md.py.py

# Copy all .js, .ts, .json files
python copy.js.ts.json.py

# Copy all .html, .css files
python copy.html.css.py
```

## Exclude Folders
```bash
# Exclude single folder
python copy.cs.md.py.py --exclude test

# Exclude multiple folders
python copy.cs.md.py.py --exclude test --exclude docs

# Short flag
python copy.cs.md.py.py -e node_modules -e dist -e build

# Common exclusions for web projects
python copy.js.ts.py --exclude node_modules --exclude dist --exclude .next

# Common exclusions for .NET projects
python copy.cs.py --exclude bin --exclude obj --exclude packages
```

## Command-Line Options
```bash
--help, -h              Show help message
--exclude PATH, -e PATH Exclude a folder (can use multiple times)
```

## File Naming Convention
The script name determines which extensions to copy:
```
copy.{extension1}.{extension2}.py

Examples:
copy.cs.md.py.py        → Copies .cs, .md, .py files
copy.js.ts.jsx.tsx.py   → Copies .js, .ts, .jsx, .tsx files
copy.html.css.js.py     → Copies .html, .css, .js files
```

## Auto-Ignored Folders
These folders are always ignored automatically:
- `.git`, `.vs`, `.idea` (Version control & IDEs)
- `Library`, `Temp`, `obj`, `Builds` (Build artifacts)
- `__pycache__`, `node_modules` (Package folders)

## Auto-Ignored Files
- `.DS_Store` (macOS)
- `Thumbs.db` (Windows)

## Output Format
Files are copied to clipboard as Markdown with syntax highlighting:
```markdown
## File: `src/main.cs`
```csharp
public class Program {
    // code here
}
```

## File: `README.md`
```markdown
# Project
```

---
# Project Context
```text
src/main.cs
README.md
```

**Summary:** 2 files | 150 lines
```

## Platform-Specific

### Windows
```cmd
# Direct Python execution (recommended)
python copy.cs.md.py.py

# Using batch file
run_copy.bat

# With exclusions
run_copy_no_tests.bat

# PowerShell bypass
powershell -ExecutionPolicy Bypass -File copy.cs.md.py.py
```

### macOS / Linux
```bash
# Standard execution
python3 copy.cs.md.py.py

# Make executable (one-time)
chmod +x copy.cs.md.py.py
./copy.cs.md.py.py
```

## Common Workflows

### Share code with AI/LLM
```bash
python copy.cs.md.py.py --exclude test --exclude docs
# Paste into ChatGPT, Claude, etc.
```

### Code Review
```bash
python copy.cs.md.py.py --exclude node_modules
# Paste into review tool or email
```

### Documentation
```bash
python copy.md.py  # Only markdown files
# Paste into documentation
```

### Backup snippets
```bash
python copy.cs.js.py --exclude dist
# Paste into notes or backup system
```

## Troubleshooting

### Python not found
```bash
# Windows - Check PATH
python --version

# macOS/Linux - Use python3
python3 --version
```

### pyperclip not installed
```bash
pip install pyperclip
# or
python -m pip install pyperclip
```

### Script runs but clipboard empty
1. Close clipboard managers
2. Try running as administrator (Windows)
3. Check if file matched: Look for "Added: filename" in output

### Files not copied
Check:
1. File extension matches script name
2. Folder not in auto-ignore list
3. File not excluded with `--exclude`

### "No matching files found"
1. Rename script to match desired extensions
2. Verify files exist in directory
3. Check if all folders are excluded

## Performance Tips

```bash
# Always exclude large folders
python copy.cs.md.py.py -e node_modules -e dist -e build

# Don't run in root directory
cd /specific/project && python copy.cs.md.py.py

# Exclude binary/media folders
python copy.cs.md.py.py -e assets -e images -e videos
```

## Testing
```bash
# Run test suite
python test_copy.py

# Should output: OK (skipped=1) on macOS/Linux
# Should output: OK on Windows
```

## File Locations

| File | Purpose |
|------|---------|
| `copy.cs.md.py.py` | Main script (rename as needed) |
| `test_copy.py` | Test suite |
| `run_copy.bat` | Windows launcher |
| `run_copy_no_tests.bat` | Windows launcher with exclusions |
| `requirements.txt` | Python dependencies |

## Documentation

- [README.md](../README.md) - Full documentation
- [WINDOWS_SETUP.md](WINDOWS_SETUP.md) - Windows-specific guide
- [TESTING.md](TESTING.md) - Testing guide
- [CHANGELOG.md](../CHANGELOG.md) - Version history

## Support

1. Check output for error messages
2. Run tests: `python test_copy.py`
3. See [WINDOWS_SETUP.md](WINDOWS_SETUP.md) for Windows issues
4. Open GitHub issue with error details

## Examples by Language

### C# Project
```bash
python copy.cs.csproj.py --exclude bin --exclude obj
```

### JavaScript/TypeScript Project
```bash
python copy.js.ts.tsx.jsx.py --exclude node_modules --exclude dist
```

### Python Project
```bash
python copy.py.txt.py --exclude __pycache__ --exclude venv
```

### Web Project
```bash
python copy.html.css.js.py --exclude node_modules
```

### Full Stack
```bash
python copy.cs.js.html.css.py -e node_modules -e bin -e obj -e dist
```

---

**Pro Tip**: Create different named copies for different purposes:
- `copy.cs.py` - Only C# files
- `copy.js.ts.py` - Only JS/TS files  
- `copy.md.py` - Only docs
- `copy.full.cs.js.html.css.py` - Everything
