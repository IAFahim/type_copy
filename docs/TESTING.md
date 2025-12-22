# Testing Guide for Type Copy

This guide explains how to test the Type Copy script on different platforms.

## Running Tests

### Prerequisites
```bash
pip install pyperclip
```

### Run All Tests
```bash
python test_copy.py
```

Or with more verbose output:
```bash
python test_copy.py -v
```

## Test Coverage

The test suite verifies:

### ✅ Core Functionality Tests
- **Basic file collection**: Scans directories and collects files with matching extensions
- **Extension filtering**: Only includes files with extensions specified in filename
- **Recursive scanning**: Processes subdirectories correctly
- **Auto-ignore**: Skips `.git`, `node_modules`, etc.

### ✅ Exclusion Tests
- **Single folder exclusion**: `--exclude test`
- **Multiple folder exclusion**: `--exclude test --exclude docs`
- **Short flag**: `-e node_modules -e dist`
- **Exclusion messages**: Verifies user is informed about excluded paths

### ✅ Cross-Platform Tests
- **Path handling**: Works on Windows (backslash), Unix (forward slash)
- **Special characters**: Handles spaces and special chars in paths
- **Platform detection**: Tests run correctly on Windows, macOS, Linux

### ✅ Edge Cases
- **No matching files**: Proper message when no files match extensions
- **Empty directories**: Handles directories with no files
- **Binary files**: Skips binary files automatically

### ✅ Dependency Tests
- **Pyperclip availability**: Verifies clipboard library is installed
- **Import checks**: Ensures all required modules are available

## Platform-Specific Testing

### Windows Testing

On Windows, additional tests verify:
- Script runs without "execution policy" errors
- Paths with backslashes work correctly
- Works from Command Prompt and PowerShell

Run Windows-specific tests:
```cmd
python test_copy.py TestWindowsPermissions
```

### macOS Testing

On macOS:
- Clipboard access via `pbcopy` works
- Forward slash paths handled correctly
- Works in Terminal

### Linux Testing

On Linux:
- Clipboard tools (`xclip`, `xsel`, `wl-copy`) detected
- Forward slash paths handled correctly
- Works in various terminal emulators

## Manual Testing Checklist

Beyond automated tests, manually verify:

### Basic Usage
- [ ] Double-click script (on Windows with `.bat` file)
- [ ] Run from command line
- [ ] Check clipboard contains expected content
- [ ] Verify file count and size in output

### Exclusion Feature
- [ ] Exclude one folder
- [ ] Exclude multiple folders
- [ ] Exclude nested folders
- [ ] Verify excluded files not in output

### Different Extensions
- [ ] Rename script to `copy.js.ts.py`
- [ ] Verify only JS/TS files copied
- [ ] Rename to `copy.html.css.py`
- [ ] Verify only HTML/CSS files copied

### Edge Cases
- [ ] Run in empty directory
- [ ] Run in directory with only excluded folders
- [ ] Run with extremely long file paths
- [ ] Run with many files (1000+)

## CI/CD Testing

For continuous integration, clipboard access might be limited. The test suite handles this gracefully:

```bash
# Tests will pass even if clipboard is unavailable
python test_copy.py
```

## Creating Test Data

To create a test directory structure:

```bash
mkdir -p test_project/{src,dist,node_modules,test}
echo "class Test {}" > test_project/src/test.cs
echo "console.log('hi')" > test_project/src/test.js
echo "# Test" > test_project/README.md
echo "build output" > test_project/dist/app.js
echo "package" > test_project/node_modules/package.js
```

Then test:
```bash
cd test_project
python ../copy.cs.js.py --exclude node_modules --exclude dist
```

## Troubleshooting Tests

### Tests Fail with "ModuleNotFoundError"
```bash
pip install pyperclip
```

### Tests Fail with "Permission denied"
On Linux/macOS:
```bash
chmod +x copy.cs.md.py.py
```

### Clipboard Tests Fail in CI
This is expected in headless environments. Tests are designed to pass with limited clipboard access.

### Tests Timeout
Increase timeout in `test_copy.py`:
```python
timeout=30  # Instead of default 10
```

## Performance Testing

To test performance with large directories:

```bash
# Create 1000 test files
for i in {1..1000}; do echo "test $i" > test_$i.py; done

# Time the execution
time python copy.cs.md.py.py
```

Expected performance:
- **100 files**: < 1 second
- **1,000 files**: 1-3 seconds
- **10,000 files**: 10-30 seconds

## Adding New Tests

To add a new test:

1. Open `test_copy.py`
2. Add method to `TestTypeCopy` class:
   ```python
   def test_my_feature(self):
       """Test description"""
       # Setup
       self._create_file('test.cs', 'content')
       
       # Execute
       returncode, stdout, stderr = self._run_script(['--my-flag'])
       
       # Assert
       self.assertEqual(returncode, 0)
       self.assertIn('expected output', stdout)
   ```
3. Run tests: `python test_copy.py`

## Test Maintenance

### Update tests when:
- Adding new command-line flags
- Changing output format
- Adding new auto-ignore folders
- Modifying exclusion logic

### Verify tests on:
- Windows 10/11
- macOS 11+
- Ubuntu 20.04+
- Python 3.7, 3.8, 3.9, 3.10, 3.11, 3.12

## Test Results Reference

**Expected output on macOS/Linux:**
```
test_basic_functionality ... ok
test_cross_platform_paths ... ok
test_exclude_multiple_folders ... ok
test_exclude_short_flag ... ok
test_exclude_single_folder ... ok
test_excluded_folder_output_message ... ok
test_no_matching_files ... ok
test_special_characters_in_path ... ok
test_windows_execution_policy ... skipped 'Windows only'
test_pyperclip_import ... ok

----------------------------------------------------------------------
Ran 10 tests in 0.4s

OK (skipped=1)
```

**Expected output on Windows:**
```
test_basic_functionality ... ok
test_cross_platform_paths ... ok
test_exclude_multiple_folders ... ok
test_exclude_short_flag ... ok
test_exclude_single_folder ... ok
test_excluded_folder_output_message ... ok
test_no_matching_files ... ok
test_special_characters_in_path ... ok
test_windows_execution_policy ... ok
test_pyperclip_import ... ok

----------------------------------------------------------------------
Ran 10 tests in 0.5s

OK
```

All platforms should show "OK" status! ✅
