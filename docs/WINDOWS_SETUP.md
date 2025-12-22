# Windows Setup Guide for Type Copy

This guide helps you set up and run Type Copy on Windows systems.

## Prerequisites

### Quick Setup (Recommended)

The easiest way to get started on Windows is to use the automatic setup script:

1. **Download the repository**
2. **Double-click `setup.bat`** or run in Command Prompt:
   ```cmd
   setup.bat
   ```

The setup script will automatically:
- ✅ Check if Python is installed
- ✅ Download and install Python if needed
- ✅ Add Python to PATH
- ✅ Install pyperclip
- ✅ Verify everything works
- ✅ Run Type Copy

**For PowerShell users:**
```powershell
# Right-click setup.ps1 → "Run with PowerShell"
# Or run as Administrator:
powershell -ExecutionPolicy Bypass -File setup.ps1
```

### Manual Setup

If you prefer manual installation or the automatic setup doesn't work:

### 1. Install Python

1. Download Python from [python.org](https://www.python.org/downloads/)
2. **IMPORTANT**: During installation, check "Add Python to PATH"
3. Click "Install Now"
4. Verify installation:
   ```cmd
   python --version
   ```

### 2. Install Dependencies

Open Command Prompt or PowerShell and run:
```cmd
pip install pyperclip
```

## Common Windows Issues & Solutions

### Issue 1: "python is not recognized"

**Problem**: Windows can't find Python in the PATH.

**Solution**:
1. Find your Python installation (usually `C:\Users\YourName\AppData\Local\Programs\Python\Python3XX\`)
2. Add to PATH manually:
   - Right-click "This PC" → Properties
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "User variables", select "Path" and click "Edit"
   - Click "New" and add: `C:\Users\YourName\AppData\Local\Programs\Python\Python3XX\`
   - Click "New" again and add: `C:\Users\YourName\AppData\Local\Programs\Python\Python3XX\Scripts\`
   - Click OK on all dialogs
   - **Restart Command Prompt/PowerShell**

### Issue 2: "Running scripts is disabled on this system"

**Problem**: PowerShell execution policy blocks scripts.

**Solution A - Recommended (Run directly with Python)**:
```cmd
python copy.cs.md.py.py
```

**Solution B - Change Execution Policy (One-time setup)**:
1. Open PowerShell as Administrator (Right-click Start → "Windows PowerShell (Admin)")
2. Run:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Type `Y` and press Enter
4. Close PowerShell

**Solution C - Bypass for single run**:
```powershell
powershell -ExecutionPolicy Bypass -File copy.cs.md.py.py
```

### Issue 3: "pip is not recognized"

**Problem**: pip is not in PATH.

**Solution**:
```cmd
python -m pip install pyperclip
```

### Issue 4: "Access Denied" or Permission Errors

**Problem**: Windows User Account Control (UAC) or antivirus blocking execution.

**Solutions**:
1. Run Command Prompt as Administrator
2. Add Python folder to antivirus exclusions
3. Use a folder in your user directory (not Program Files)

### Issue 5: Clipboard Not Working

**Problem**: Pyperclip can't access clipboard.

**Solution**: Ensure no other applications are blocking clipboard access. Close any clipboard managers temporarily.

## Creating Easy-to-Use Shortcuts

### Method 1: Batch File (Recommended)

Create `run_copy.bat` in the same folder as the script:

```batch
@echo off
cd /d "%~dp0"
python copy.cs.md.py.py %*
if errorlevel 1 (
    echo.
    echo ERROR: Script failed to run.
    echo Make sure Python and pyperclip are installed.
    pause
)
```

Now you can:
- Double-click `run_copy.bat` to run
- Or drag it to your Start Menu for quick access

### Method 2: With Exclusions

Create `run_copy_no_tests.bat`:
```batch
@echo off
cd /d "%~dp0"
python copy.cs.md.py.py --exclude test --exclude node_modules
pause
```

### Method 3: Desktop Shortcut

1. Right-click `run_copy.bat` → "Create shortcut"
2. Move shortcut to Desktop
3. Right-click shortcut → Properties
4. Click "Change Icon" and choose one you like
5. In "Start in" field, enter the folder containing your code

### Method 4: PowerShell Script (Alternative)

Create `run_copy.ps1`:
```powershell
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir
python copy.cs.md.py.py $args
Read-Host "Press Enter to close"
```

Run with:
```powershell
powershell -ExecutionPolicy Bypass -File run_copy.ps1
```

## Running from Any Folder

### Option 1: Add Script Location to PATH

1. Open Environment Variables (Win + Pause → Advanced → Environment Variables)
2. Under "User variables", select "Path" → Edit
3. Click "New" and add the folder containing `copy.cs.md.py.py`
4. Click OK
5. Restart Command Prompt

Now you can run from anywhere:
```cmd
cd C:\MyProject
python copy.cs.md.py.py
```

### Option 2: Create a Global Batch File

1. Create `typecopy.bat` in `C:\Users\YourName\` (or any PATH folder):
   ```batch
   @echo off
   python "C:\Path\To\copy.cs.md.py.py" %*
   ```
2. Add `C:\Users\YourName\` to PATH
3. Run from anywhere:
   ```cmd
   typecopy --exclude test
   ```

## Windows Terminal Integration

If you use Windows Terminal:

1. Open Settings (Ctrl + ,)
2. Click "Open JSON file"
3. Under "profiles" → "defaults", add:
   ```json
   "commandline": "cmd.exe /k python copy.cs.md.py.py"
   ```

Or create a new profile:
```json
{
    "name": "Type Copy",
    "commandline": "cmd.exe /k cd /d C:\\Projects && python copy.cs.md.py.py",
    "icon": "📋"
}
```

## File Explorer Context Menu (Advanced)

Add "Copy to Clipboard" to right-click menu:

1. Create `add_context_menu.reg`:
   ```reg
   Windows Registry Editor Version 5.00

   [HKEY_CLASSES_ROOT\Directory\Background\shell\TypeCopy]
   @="Copy Code Files"
   "Icon"="C:\\Windows\\System32\\shell32.dll,134"

   [HKEY_CLASSES_ROOT\Directory\Background\shell\TypeCopy\command]
   @="cmd.exe /c cd /d \"%V\" && python \"C:\\Path\\To\\copy.cs.md.py.py\" && pause"
   ```

2. Double-click to add to registry
3. Now right-click in any folder → "Copy Code Files"

**To remove**: Create `remove_context_menu.reg`:
```reg
Windows Registry Editor Version 5.00

[-HKEY_CLASSES_ROOT\Directory\Background\shell\TypeCopy]
```

## Testing Your Setup

Run this command to test everything:
```cmd
python test_copy.py
```

If all tests pass, you're ready to go! ✅

## Performance Tips

1. **Exclude large folders**: Always exclude `node_modules`, `dist`, `build`, etc.
   ```cmd
   python copy.cs.md.py.py --exclude node_modules --exclude dist
   ```

2. **Use SSD**: Running from an SSD is much faster than HDD

3. **Antivirus exclusion**: Add the script folder to antivirus exclusions for faster scanning

## Troubleshooting

### Script runs but nothing in clipboard

1. Check if another app is using clipboard
2. Try running as Administrator
3. Verify pyperclip is installed: `pip list | findstr pyperclip`
4. Test pyperclip manually:
   ```python
   python -c "import pyperclip; pyperclip.copy('test'); print(pyperclip.paste())"
   ```

### Script freezes or hangs

1. Check if you're scanning a huge directory (use exclusions)
2. Check if you're in a network drive (copy to local disk first)
3. Press Ctrl+C to cancel

### Colors not showing in Command Prompt

Windows 10 version 1511+ supports ANSI colors by default. If you don't see colors:
1. Use Windows Terminal instead of cmd.exe
2. Or enable in registry:
   ```cmd
   reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1
   ```

## Security Notes

✅ **Safe**: This script only reads files and copies to clipboard
✅ **No network**: No data is sent anywhere
✅ **Open source**: You can review all code
⚠️ **Clipboard**: Be careful when copying sensitive data
⚠️ **Execution policy**: Only change if you understand the risks

## Getting Help

If you're still having issues:

1. Check Python version: `python --version` (need 3.7+)
2. Check pip works: `pip --version`
3. Reinstall pyperclip: `pip uninstall pyperclip && pip install pyperclip`
4. Try in a fresh folder with just one test file
5. Open an issue on GitHub with your error message

## Example Workflow

Here's a complete example for a new Windows user:

```cmd
# 1. Install Python (from python.org)

# 2. Open Command Prompt and install dependency
pip install pyperclip

# 3. Download the script to your project folder
# (Place copy.cs.md.py.py in C:\Projects\MyApp)

# 4. Navigate to your project
cd C:\Projects\MyApp

# 5. Run the script
python copy.cs.md.py.py --exclude test

# 6. Paste the result into ChatGPT, Claude, or your code review
# Press Ctrl+V
```

That's it! 🎉

## Additional Resources

- [Python Windows FAQ](https://docs.python.org/3/faq/windows.html)
- [pip documentation](https://pip.pypa.io/en/stable/)
- [PowerShell Execution Policies](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies)
