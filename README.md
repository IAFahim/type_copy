# Type Copy

A powerful Python script that scans directories and copies files with specified extensions to your clipboard in a well-formatted Markdown structure. Perfect for sharing code with LLMs, code reviews, or documentation.

> **🎉 What's New in v2.1.0:**
> - **One-Command Setup**: Run `setup.bat` (Windows) or `./setup.sh` (Unix) to automatically install Python, configure PATH, and install dependencies!
> - **Zero Configuration**: No manual Python installation or PATH editing needed
> - **All Platforms**: Windows, macOS, and Linux support with platform-specific installers

## ✨ Features

- 📁 **Smart Extension Filtering**: Specify extensions in the filename itself (e.g., `copy.cs.md.py.py`)
- 🚫 **Folder Exclusion**: Exclude specific folders from scanning (e.g., `node_modules`, `dist`)
- 🎯 **One-Command Setup**: Automatic installation scripts for all platforms
- 🌳 **Recursive Scanning**: Automatically scans subdirectories
- 📊 **Detailed Statistics**: Shows file count, size, and estimated LLM tokens
- 🎨 **Syntax Highlighting**: Outputs Markdown with proper language tags
- 🔍 **Auto-ignore**: Skips common junk folders (`.git`, `node_modules`, etc.)
- 🖥️ **Cross-Platform**: Works on Windows, macOS, and Linux

## 🚀 Quick Start

### Automatic Setup (Recommended)

**Windows:**
```cmd
# Download the repository and run:
setup.bat
```
This will automatically:
- ✅ Download and install Python if needed
- ✅ Add Python to PATH
- ✅ Install pyperclip
- ✅ Verify everything works
- ✅ Run Type Copy

**Windows (PowerShell):**
```powershell
# Run as Administrator for best results
.\setup.ps1
```

**macOS/Linux:**
```bash
# Make executable and run:
chmod +x setup.sh
./setup.sh
```

### Manual Setup

1. **Install Python** (3.7 or higher)
   - Windows: Download from [python.org](https://www.python.org/downloads/)
   - macOS: `brew install python3` or download from python.org
   - Linux: Usually pre-installed, or `sudo apt install python3`

2. **Install dependencies:**
   ```bash
   pip install pyperclip
   ```

3. **Download the script:**
   - Copy [copy.cs.md.py.py](copy.cs.md.py.py) to any folder you want to scan

### Basic Usage

The extensions you want to copy are specified in the filename itself:

```
copy.cs.md.py.py → Copies .cs, .md, .py files
copy.js.ts.json.py → Copies .js, .ts, .json files
copy.html.css.py → Copies .html, .css files
```

Simply run the script:
```bash
python copy.cs.md.py.py
```

### Advanced Usage

**Exclude specific folders:**
```bash
python copy.cs.md.py.py --exclude test
python copy.cs.md.py.py --exclude node_modules --exclude dist
python copy.cs.md.py.py -e test -e docs  # Short flag
```

**Get help:**
```bash
python copy.cs.md.py.py --help
```


![Type Copy visual.png](docs/Type%20Copy%20visual.png)

## 📖 Example Output

```
D:\type_copy\copy.cs.md.py.py
Scanning: D:\type_copy...
Added: README.md
Added: test\dir.test.cs
Added: test\dir.test.md
Added: test\dir.test.py
--------------------------------------------------
✔ Success! Copied to clipboard.
  Files:  4
  Size:   1.67 KB
  Tokens: ~426 (LLM Context)
--------------------------------------------------

Press Enter to close...
```

**With exclusions:**
```bash
python copy.cs.md.py.py --exclude test
Scanning: D:\type_copy...
Excluding: test
Added: README.md
--------------------------------------------------
✔ Success! Copied to clipboard.
  Files:  1
  Size:   0.85 KB
  Tokens: ~213 (LLM Context)
--------------------------------------------------
```

## 📋 Requirements

- Python 3.7 or higher
- [pyperclip](requirements.txt) library (`pip install pyperclip`)

### Platform-Specific Requirements

**Linux:**
Requires a clipboard utility:
```bash
# Ubuntu/Debian
sudo apt install xclip

# Fedora
sudo dnf install xclip

# Arch
sudo pacman -S xclip
```

**macOS:**
No additional requirements (uses built-in `pbcopy`)

**Windows:**
No additional requirements (uses built-in clipboard API)

## 🪟 Windows Setup Guide

### **IMPORTANT: Execution Policy**

On Windows, you may need to allow Python script execution. If you see an error like "cannot be loaded because running scripts is disabled", follow these steps:

#### Method 1: Run with Python directly (Recommended)
```cmd
python copy.cs.md.py.py
```

#### Method 2: Modify Execution Policy (Administrator)
Open PowerShell as Administrator and run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

This allows locally created scripts to run. This is safe and recommended by Microsoft.

#### Method 3: Bypass for single execution
```powershell
powershell -ExecutionPolicy Bypass -File copy.cs.md.py.py
```

### Creating a Windows Shortcut

For easy access, create a `.bat` file:

1. Create `run_copy.bat` in the same folder:
   ```batch
   @echo off
   python copy.cs.md.py.py %*
   pause
   ```

2. Double-click `run_copy.bat` to run

Or with exclusions:
```batch
@echo off
python copy.cs.md.py.py --exclude node_modules --exclude dist %*
pause
```

## 🧪 Testing

Run the test suite to verify everything works on your platform:

```bash
python test_copy.py
```

The test suite includes:
- ✅ Basic file collection
- ✅ Folder exclusion (single and multiple)
- ✅ Cross-platform path handling
- ✅ Windows permissions
- ✅ Special characters in paths
- ✅ Edge cases

See [TESTING.md](docs/TESTING.md) for detailed testing guide.

## 🔧 Configuration

### Setup Scripts

Three setup scripts are provided for easy installation:

| Script | Platform | Features |
|--------|----------|----------|
| `setup.bat` | Windows (CMD) | Auto-downloads Python, sets PATH, installs packages |
| `setup.ps1` | Windows (PowerShell) | Same as .bat but with better error handling |
| `setup.sh` | macOS/Linux | Detects OS, installs Python & clipboard tools |

**Running setup scripts:**

```cmd
# Windows - Double-click or run:
setup.bat

# Windows PowerShell (as Admin):
powershell -ExecutionPolicy Bypass -File setup.ps1

# macOS/Linux:
chmod +x setup.sh && ./setup.sh
```

All setup scripts will:
1. Check if Python is installed
2. Install Python if missing (with user consent)
3. Add Python to PATH
4. Install required packages (pyperclip)
5. Verify installation
6. Run Type Copy

### Auto-ignored Folders
The script automatically ignores these common folders:
- `.git`, `.vs`, `.idea` (version control & IDEs)
- `Library`, `Temp`, `obj`, `Builds` (Unity/build artifacts)
- `__pycache__`, `node_modules` (Python/Node packages)

### Auto-ignored Files
- `.DS_Store` (macOS)
- `Thumbs.db` (Windows)

### Supported Languages
The script includes syntax highlighting for 20+ languages including:
C#, JavaScript, TypeScript, Python, Java, C/C++, HTML, CSS, SCSS, XML, YAML, JSON, Markdown, Bash, SQL, GLSL/HLSL, and more.

## 🐧 Linux Alternative

For a quick one-liner without this library:
```bash
find . -type f \( -name "*.cs" -o -name "*.md" \) -exec cat {} \; | xclip -selection clipboard
```
Note: Requires `xclip` installed

## 🎥 Tutorial Video

[Recording 2024-12-23 021135.mp4](docs/Recording%202024-12-23%20021135.mp4)

## 💡 Pro Tips

1. **For AI/LLM Context**: Use the token estimate to stay within context limits
2. **Large Projects**: Exclude build/dependency folders with `--exclude`
3. **Windows Dev Home**: Try with [Windows Dev Home](https://learn.microsoft.com/en-us/windows/dev-home/) for enhanced features
4. **Git Integration**: Check out [git-copy.sh](git-copy.sh) for git-aware copying

## 🤝 Contributing

Found a bug or want to contribute? Feel free to open an issue or PR!

## 📜 License

Free to use and modify for any purpose.

---

## 📚 Documentation

- **[Quick Reference](docs/QUICK_REFERENCE.md)** - Command cheat sheet
- **[Setup Scripts Guide](docs/SETUP_SCRIPTS.md)** - Automatic installation details
- **[Windows Setup Guide](docs/WINDOWS_SETUP.md)** - Detailed Windows instructions  
- **[Testing Guide](docs/TESTING.md)** - How to run and write tests
- **[Changelog](CHANGELOG.md)** - Version history and updates
