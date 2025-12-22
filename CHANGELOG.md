# Changelog

All notable changes to Type Copy will be documented in this file.

## [2.1.0] - 2025-12-22

### Added
- **Automatic Setup Scripts**: Three new installation scripts for hassle-free setup
  - `setup.bat` - Windows batch script with Python auto-installation
  - `setup.ps1` - PowerShell script with advanced features
  - `setup.sh` - Linux/macOS bash script with OS detection
- **Python Auto-Installation**: Setup scripts can download and install Python automatically
- **PATH Auto-Configuration**: Automatically adds Python to system PATH
- **Package Auto-Installation**: Installs pyperclip without user intervention
- **Clipboard Tool Detection**: Linux setup installs xclip/xsel automatically
- **Environment Verification**: All setup scripts verify installation success

### Features of Setup Scripts
- **Smart Detection**: Checks existing Python installations before downloading
- **Cross-Platform**: Works on Windows 10/11, macOS, and major Linux distros
- **User-Friendly**: Color-coded output with clear progress indicators
- **Error Handling**: Detailed error messages and fallback options
- **Zero Config**: No manual PATH editing or registry changes needed

## [2.0.0] - 2025-12-22

### Added
- **Folder Exclusion**: New `--exclude` / `-e` flag to exclude specific folders
  - Example: `python copy.cs.md.py.py --exclude test --exclude docs`
  - Can be used multiple times for multiple exclusions
  - Works with relative paths and handles spaces in folder names
- **Command-line Arguments**: Full argparse integration with `--help` support
- **Cross-Platform Tests**: Comprehensive test suite (`test_copy.py`)
  - Tests basic functionality, exclusions, and edge cases
  - Platform-specific tests for Windows, macOS, and Linux
  - 10 test cases covering all major features
- **Windows Support Documentation**: 
  - New `docs/WINDOWS_SETUP.md` with detailed Windows setup guide
  - Covers execution policies, PATH setup, and common issues
  - Batch file examples for easy Windows usage
- **Testing Documentation**: New `docs/TESTING.md` with testing guide
- **Windows Batch Files**: 
  - `run_copy.bat` - Smart launcher with dependency checking
  - `run_copy_no_tests.bat` - Quick launcher with exclusions
- **Better Error Messages**: More informative output when things go wrong
- **Exclusion Feedback**: Shows which folders are being excluded during scan

### Changed
- **Improved Documentation**: Complete rewrite of `README.md`
  - Added feature highlights with emojis
  - Step-by-step installation guide
  - Platform-specific requirements clearly listed
  - Windows execution policy explained
  - Better examples and use cases
- **Enhanced Output**: Shows excluded folders during scanning
- **Code Structure**: Added proper imports (argparse, pathlib)

### Fixed
- Path handling for excluded directories on all platforms
- Edge case where excluded folder names appear in output
- Binary file detection improvements
- Cross-platform path normalization

### Technical Details
- Minimum Python version: 3.7+
- Dependencies: pyperclip >= 1.9.0
- Tested on: macOS, Windows 10/11, Ubuntu 20.04+

## [1.0.0] - 2024-12-23

### Initial Release
- Basic file scanning and clipboard copying
- Extension detection from filename
- Markdown formatting with syntax highlighting
- Auto-ignore common folders (.git, node_modules, etc.)
- Colored console output
- File statistics (count, size, token estimate)
- Support for 20+ programming languages

---

## Migration Guide

### Upgrading from 1.x to 2.0

No breaking changes! All existing usage continues to work.

**New features you can start using:**

1. **Exclude folders** (optional):
   ```bash
   # Before (scans everything)
   python copy.cs.md.py.py
   
   # After (skip test folders)
   python copy.cs.md.py.py --exclude test --exclude node_modules
   ```

2. **Get help** (optional):
   ```bash
   python copy.cs.md.py.py --help
   ```

3. **Run tests** (optional):
   ```bash
   python test_copy.py
   ```

4. **Use batch files on Windows** (optional):
   - Just double-click `run_copy.bat` instead of typing commands

That's it! Your existing scripts and workflows will work unchanged.
