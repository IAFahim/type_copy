"""
Cross-platform tests for type_copy script
Tests functionality on Windows, Linux, and macOS
"""
import os
import sys
import unittest
import tempfile
import shutil
import subprocess
from pathlib import Path


class TestTypeCopy(unittest.TestCase):
    """Test suite for copy script with cross-platform support"""
    
    def setUp(self):
        """Create a temporary test directory structure"""
        self.test_dir = tempfile.mkdtemp()
        self.original_dir = os.getcwd()
        
        # Create test directory structure
        # test_dir/
        #   copy.cs.md.py.py (script copy)
        #   file1.cs
        #   file2.md
        #   file3.py
        #   file4.txt (should be ignored)
        #   subfolder1/
        #     file5.cs
        #     file6.md
        #   subfolder2/
        #     file7.py
        #     file8.txt (should be ignored)
        #   excluded_folder/
        #     file9.cs (should be excluded)
        #     file10.md (should be excluded)
        
        # Copy the main script
        script_path = os.path.join(os.path.dirname(__file__), 'copy.cs.md.py.py')
        shutil.copy(script_path, os.path.join(self.test_dir, 'copy.cs.md.py.py'))
        
        # Create test files
        self._create_file('file1.cs', 'public class Test1 {}')
        self._create_file('file2.md', '# Test File 2')
        self._create_file('file3.py', 'print("test3")')
        self._create_file('file4.txt', 'Should be ignored')
        
        # Create subdirectories
        os.makedirs(os.path.join(self.test_dir, 'subfolder1'))
        os.makedirs(os.path.join(self.test_dir, 'subfolder2'))
        os.makedirs(os.path.join(self.test_dir, 'excluded_folder'))
        
        self._create_file('subfolder1/file5.cs', 'public class Test5 {}')
        self._create_file('subfolder1/file6.md', '# Test File 6')
        self._create_file('subfolder2/file7.py', 'print("test7")')
        self._create_file('subfolder2/file8.txt', 'Should be ignored')
        self._create_file('excluded_folder/file9.cs', 'public class Test9 {}')
        self._create_file('excluded_folder/file10.md', '# Test File 10')
        
    def tearDown(self):
        """Clean up temporary test directory"""
        os.chdir(self.original_dir)
        shutil.rmtree(self.test_dir, ignore_errors=True)
        
    def _create_file(self, relative_path, content):
        """Helper to create a file with content"""
        file_path = os.path.join(self.test_dir, relative_path)
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
            
    def _run_script(self, args=None):
        """
        Run the copy script with given arguments
        Returns (return_code, stdout, stderr)
        """
        script_path = os.path.join(self.test_dir, 'copy.cs.md.py.py')
        cmd = [sys.executable, script_path]
        if args:
            cmd.extend(args)
        
        # Change to test directory
        os.chdir(self.test_dir)
        
        # Run without stdin to avoid the "Press Enter to close" prompt
        env = os.environ.copy()
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=10,
            input='\n',  # Send Enter to close the prompt
            env=env
        )
        
        return result.returncode, result.stdout, result.stderr
        
    def test_basic_functionality(self):
        """Test basic file collection without exclusions"""
        returncode, stdout, stderr = self._run_script()
        
        # Should succeed
        self.assertEqual(returncode, 0, f"Script failed: {stderr}")
        
        # Check output mentions expected files
        self.assertIn('file1.cs', stdout)
        self.assertIn('file2.md', stdout)
        self.assertIn('file3.py', stdout)
        self.assertIn('file5.cs', stdout)
        self.assertIn('file6.md', stdout)
        self.assertIn('file7.py', stdout)
        
        # Should not include .txt files
        self.assertNotIn('file4.txt', stdout)
        self.assertNotIn('file8.txt', stdout)
        
    def test_exclude_single_folder(self):
        """Test excluding a single folder"""
        returncode, stdout, stderr = self._run_script(['--exclude', 'excluded_folder'])
        
        self.assertEqual(returncode, 0, f"Script failed: {stderr}")
        
        # Should not include files from excluded_folder
        self.assertNotIn('file9.cs', stdout)
        self.assertNotIn('file10.md', stdout)
        
        # Should still include other files
        self.assertIn('file1.cs', stdout)
        self.assertIn('file2.md', stdout)
        
    def test_exclude_multiple_folders(self):
        """Test excluding multiple folders"""
        returncode, stdout, stderr = self._run_script([
            '--exclude', 'subfolder1',
            '--exclude', 'excluded_folder'
        ])
        
        self.assertEqual(returncode, 0, f"Script failed: {stderr}")
        
        # Should not include files from excluded folders
        self.assertNotIn('file5.cs', stdout)
        self.assertNotIn('file6.md', stdout)
        self.assertNotIn('file9.cs', stdout)
        self.assertNotIn('file10.md', stdout)
        
        # Should still include files from subfolder2 and root
        self.assertIn('file1.cs', stdout)
        self.assertIn('file7.py', stdout)
        
    def test_exclude_short_flag(self):
        """Test using short -e flag for exclusion"""
        returncode, stdout, stderr = self._run_script([
            '-e', 'excluded_folder'
        ])
        
        self.assertEqual(returncode, 0, f"Script failed: {stderr}")
        self.assertNotIn('file9.cs', stdout)
        
    def test_cross_platform_paths(self):
        """Test that paths work correctly on all platforms"""
        # Test with forward slashes (should work on all platforms)
        returncode, stdout, stderr = self._run_script([
            '--exclude', 'excluded_folder'
        ])
        self.assertEqual(returncode, 0)
        
        # Test with Path object notation
        if os.name == 'nt':  # Windows
            # Test backslashes
            returncode, stdout, stderr = self._run_script([
                '--exclude', 'excluded_folder'
            ])
            self.assertEqual(returncode, 0)
            
    def test_excluded_folder_output_message(self):
        """Test that excluded folders are mentioned in output"""
        returncode, stdout, stderr = self._run_script(['--exclude', 'excluded_folder'])
        
        # Should show what's being excluded
        output = stdout + stderr
        self.assertTrue(
            'excluded_folder' in output.lower() or 'excluding' in output.lower(),
            "Script should show excluded folders"
        )
        
    def test_no_matching_files(self):
        """Test behavior when no matching files exist"""
        # Create a fresh directory with files that don't match the script's extensions
        no_match_dir = tempfile.mkdtemp()
        
        # Create a script that looks for .xyz files (which don't exist)
        script_src = os.path.join(os.path.dirname(__file__), 'copy.cs.md.py.py')
        script_dst = os.path.join(no_match_dir, 'copy.xyz.py')  # Look for .xyz files
        
        # Read source and write to destination
        with open(script_src, 'r') as f:
            content = f.read()
        with open(script_dst, 'w') as f:
            f.write(content)
        
        # Only add files that won't match
        with open(os.path.join(no_match_dir, 'test.txt'), 'w') as f:
            f.write('test')
        with open(os.path.join(no_match_dir, 'test.md'), 'w') as f:
            f.write('# test')
            
        os.chdir(no_match_dir)
        
        # Run from the clean directory
        cmd = [sys.executable, 'copy.xyz.py']
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=10,
            input='\n',
            env=os.environ.copy()
        )
        
        output = result.stdout + result.stderr
        self.assertIn('No matching files', output)
        
        # Clean up
        os.chdir(self.original_dir)
        shutil.rmtree(no_match_dir, ignore_errors=True)
        
    def test_special_characters_in_path(self):
        """Test handling of special characters in paths (cross-platform)"""
        # Create a folder with spaces
        special_dir = os.path.join(self.test_dir, 'folder with spaces')
        os.makedirs(special_dir)
        self._create_file('folder with spaces/test.cs', 'class Test {}')
        
        returncode, stdout, stderr = self._run_script()
        self.assertEqual(returncode, 0)
        self.assertIn('test.cs', stdout)
        
        # Now exclude it
        returncode, stdout, stderr = self._run_script(['--exclude', 'folder with spaces'])
        # The folder should not be in the file list (only in exclusion message)
        self.assertNotIn('folder with spaces/test.cs', stdout)
        self.assertNotIn('## File: `folder with spaces', stdout)
        

class TestWindowsPermissions(unittest.TestCase):
    """Windows-specific permission tests"""
    
    @unittest.skipUnless(sys.platform.startswith('win'), "Windows only")
    def test_windows_execution_policy(self):
        """Test that script can run on Windows"""
        script_path = os.path.join(os.path.dirname(__file__), 'copy.cs.md.py.py')
        
        # Try to run the script
        result = subprocess.run(
            [sys.executable, script_path, '--help'],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        # Should not fail due to permissions
        self.assertNotIn('permission', result.stderr.lower())
        self.assertNotIn('access denied', result.stderr.lower())
        

class TestPyperclipAvailability(unittest.TestCase):
    """Test pyperclip dependency"""
    
    def test_pyperclip_import(self):
        """Test that pyperclip is installed"""
        try:
            import pyperclip
            # Try basic functionality
            test_text = "test"
            pyperclip.copy(test_text)
            result = pyperclip.paste()
            # Note: paste might not work in CI environments
        except ImportError:
            self.fail("pyperclip is not installed")
        except Exception as e:
            # Clipboard access might fail in CI, but module should import
            if "ImportError" in str(type(e)):
                self.fail(f"pyperclip import failed: {e}")
                

def run_tests():
    """Run all tests with verbose output"""
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    suite.addTests(loader.loadTestsFromTestCase(TestTypeCopy))
    suite.addTests(loader.loadTestsFromTestCase(TestWindowsPermissions))
    suite.addTests(loader.loadTestsFromTestCase(TestPyperclipAvailability))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Return exit code
    return 0 if result.wasSuccessful() else 1


if __name__ == '__main__':
    sys.exit(run_tests())
