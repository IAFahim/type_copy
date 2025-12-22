# Setup Scripts Documentation

This document explains the automatic setup scripts for Type Copy.

## Overview

Type Copy includes three setup scripts that automate the entire installation process:

| Script | Platform | Language | Best For |
|--------|----------|----------|----------|
| `setup.bat` | Windows | Batch | All Windows users, double-click to run |
| `setup.ps1` | Windows | PowerShell | Advanced Windows users, better error handling |
| `setup.sh` | macOS/Linux | Bash | Unix-based systems |

## What the Setup Scripts Do

All scripts perform these steps:

1. **Check Python Installation**
   - Detects if Python 3.7+ is installed
   - Checks if Python is accessible in PATH

2. **Install Python (if needed)**
   - Downloads Python 3.12.1 from python.org (Windows)
   - Uses package manager (brew, apt, dnf, etc.) on Linux/macOS
   - Installs silently with recommended options

3. **Configure PATH**
   - Adds Python to user PATH automatically
   - Adds Scripts folder to PATH (for pip)
   - Refreshes environment without restart

4. **Install Dependencies**
   - Installs pyperclip via pip
   - Upgrades pip to latest version
   - Verifies successful installation

5. **Additional Setup (Linux)**
   - Installs xclip or xsel for clipboard support
   - Detects package manager automatically

6. **Verification**
   - Tests Python execution
   - Tests pyperclip import
   - Shows success message

7. **Launch Type Copy**
   - Optionally runs the main script
   - Passes command-line arguments through

## Usage

### Windows - setup.bat

**Easiest method (GUI):**
```
1. Download the repository
2. Double-click setup.bat
3. Wait for installation
4. Press Enter to run Type Copy
```

**Command line:**
```cmd
cd C:\path\to\type_copy
setup.bat

# With arguments for Type Copy
setup.bat --exclude test --exclude docs
```

**Features:**
- ✅ Works on all Windows versions (7, 8, 10, 11)
- ✅ No admin rights required (installs for current user)
- ✅ Color-coded output
- ✅ Automatic Python download (25 MB)
- ✅ PATH modification
- ✅ Error messages in plain English

**What it does:**
1. Checks for Python in PATH
2. If not found, downloads Python 3.12.1 from python.org
3. Installs Python silently with these options:
   - `InstallAllUsers=0` (current user only)
   - `PrependPath=1` (add to PATH)
   - `Include_pip=1` (include pip)
4. Refreshes environment variables
5. Installs pyperclip
6. Runs Type Copy

### Windows - setup.ps1

**Command line:**
```powershell
# Basic usage
.\setup.ps1

# Skip Python installation
.\setup.ps1 -SkipPythonInstall

# Quiet mode (no prompts)
.\setup.ps1 -Quiet
```

**Right-click method:**
```
1. Right-click setup.ps1
2. Select "Run with PowerShell"
3. If blocked, run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Features:**
- ✅ Better error handling than .bat
- ✅ Colored output with Write-Host
- ✅ Parameter support
- ✅ Admin detection
- ✅ Detailed progress messages
- ✅ Professional output formatting

**Parameters:**
- `-SkipPythonInstall` - Don't install Python, just check
- `-Quiet` - Don't prompt to run Type Copy

**What it does:**
Same as setup.bat but with:
- Better error messages
- PowerShell-native file downloads
- More robust PATH detection
- Environment variable refresh
- Progress indicators

### macOS/Linux - setup.sh

**Command line:**
```bash
# Make executable (first time only)
chmod +x setup.sh

# Run setup
./setup.sh

# With arguments for Type Copy
./setup.sh --exclude test
```

**Features:**
- ✅ Auto-detects OS (macOS, Ubuntu, Fedora, Arch, etc.)
- ✅ Uses system package manager
- ✅ Installs clipboard tools (Linux)
- ✅ Color-coded output
- ✅ sudo prompts only when needed
- ✅ Creates alias suggestion

**What it does:**

**macOS:**
1. Checks for Python 3
2. If not found, installs via Homebrew
3. Installs pyperclip via pip
4. Uses built-in pbcopy for clipboard

**Linux:**
1. Detects package manager (apt/dnf/yum/pacman)
2. Installs Python 3 and pip
3. Installs clipboard utility (xclip/xsel)
4. Installs pyperclip
5. Verifies all components

## Requirements

### Windows
- **Windows 7 or later** (tested on 10/11)
- **Internet connection** (to download Python)
- **~100 MB disk space** (for Python)
- **Optional**: Administrator rights (for system-wide PATH)

### macOS
- **macOS 10.13+** (High Sierra or later)
- **Homebrew** (will prompt to install if missing)
- **Internet connection**
- **Xcode Command Line Tools** (installed by Homebrew)

### Linux
- **Debian/Ubuntu**: apt package manager
- **Fedora**: dnf package manager
- **RHEL/CentOS**: yum package manager
- **Arch**: pacman package manager
- **Internet connection**
- **sudo access** (for package installation)

## Troubleshooting

### Windows

**"Python download failed"**
- Check internet connection
- Firewall/antivirus may be blocking download
- Download manually from: https://www.python.org/downloads/
- Make sure to check "Add Python to PATH"

**"Access denied" or "Permission error"**
- Run setup.bat as Administrator
- Or install Python manually for current user

**"Python installed but not accessible"**
- Restart Command Prompt
- Or restart computer
- Or run: `refreshenv` (if you have Chocolatey)

**"pyperclip installation failed"**
```cmd
python -m pip install --user pyperclip
```

**PowerShell execution policy error:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### macOS

**"Homebrew not found"**
Install Homebrew first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**"Command Line Tools not installed"**
```bash
xcode-select --install
```

**"Permission denied"**
```bash
chmod +x setup.sh
./setup.sh
```

### Linux

**"Package manager not found"**
- Script supports apt, dnf, yum, pacman
- For other distros, install Python manually:
  ```bash
  # Find your distro's Python package
  # Usually: python3, python3-pip
  ```

**"xclip installation failed"**
```bash
# Ubuntu/Debian
sudo apt install xclip

# Fedora
sudo dnf install xclip

# Arch
sudo pacman -S xclip
```

**"pip not found"**
```bash
python3 -m ensurepip
# or
sudo apt install python3-pip
```

## Advanced Usage

### Custom Python Version (Windows)

Edit setup.bat and change:
```batch
set PYTHON_VERSION=3.12.1
set PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe
```

### Silent Installation (No Prompts)

**Windows:**
```cmd
echo. | setup.bat
```

**PowerShell:**
```powershell
.\setup.ps1 -Quiet
```

**Linux/macOS:**
```bash
yes | ./setup.sh
```

### Install to Custom Location (Windows)

Modify setup.bat before the install line:
```batch
"%INSTALLER_PATH%" /quiet InstallAllUsers=0 PrependPath=1 TargetDir=C:\MyPython
```

### Verify Installation

All platforms:
```bash
python --version
python -c "import pyperclip; print('OK')"
```

## Security Considerations

### What the Scripts Do (Security)

✅ **Safe operations:**
- Download from official python.org (Windows)
- Use official package managers (Linux/macOS)
- Install to user directory (no admin needed)
- Modify user PATH only (not system PATH)
- Install from official PyPI (pyperclip)

⚠️ **Requires trust:**
- Downloads executables from internet (Windows)
- Modifies PATH environment variable
- Installs software packages
- May use sudo (Linux)

### Verification

Before running, you can review the scripts:
- `setup.bat` - Plain text batch file
- `setup.ps1` - Plain text PowerShell
- `setup.sh` - Plain text shell script

All scripts are open source and can be audited.

### Recommended: Manual Installation

If you prefer not to run automated scripts:
1. Install Python manually from python.org
2. Check "Add Python to PATH"
3. Run: `pip install pyperclip`

## Uninstallation

To remove everything installed by setup scripts:

**Windows:**
1. Go to: Settings → Apps → Apps & features
2. Find "Python 3.12" → Uninstall
3. Remove from PATH (optional):
   - Search "Environment Variables"
   - Edit user PATH
   - Remove Python entries

**macOS:**
```bash
brew uninstall python3
pip3 uninstall pyperclip
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt remove python3 python3-pip xclip

# Fedora
sudo dnf remove python3 python3-pip xclip
```

## Support

If the setup scripts don't work:

1. **Check requirements** (internet, disk space)
2. **Try manual installation** (see README.md)
3. **Check documentation** (WINDOWS_SETUP.md)
4. **Open an issue** with error messages

## Contributing

To improve the setup scripts:

1. Test on your platform
2. Report issues with OS/version details
3. Submit pull requests with fixes
4. Add support for new package managers

## Version History

- **v2.1.0** (2025-12-22) - Added automatic setup scripts
  - setup.bat for Windows
  - setup.ps1 for PowerShell
  - setup.sh for Linux/macOS
