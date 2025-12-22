import os
import sys
import time
import argparse
from pathlib import Path

# Try to import pyperclip
try:
    import pyperclip
except ImportError:
    print("Error: 'pyperclip' is not installed.")
    print("Please run: pip install pyperclip")
    input("Press Enter to exit...")
    sys.exit(1)

# --- CONFIGURATION & MAPPINGS ---
# Map extensions to Markdown languages for syntax highlighting
LANG_MAP = {
    ".cs": "csharp", ".js": "javascript", ".ts": "typescript", ".py": "python",
    ".java": "java", ".cpp": "cpp", ".h": "cpp", ".c": "c",
    ".html": "html", ".css": "css", ".scss": "scss", ".xml": "xml",
    ".yaml": "yaml", ".yml": "yaml", ".json": "json", ".md": "markdown",
    ".sh": "bash", ".sql": "sql", ".shader": "glsl", ".hlsl": "glsl"
}

# Always ignore these specific junk files/folders
IGNORE_FOLDERS = {".git", ".vs", ".idea", "Library", "Temp", "obj", "Builds", "__pycache__", "node_modules"}
IGNORE_FILES = {".DS_Store", "Thumbs.db"}

def get_target_extensions():
    """Parses filename 'copy.cs.js.py' -> {'.cs', '.js'}"""
    name = os.path.basename(__file__)
    parts = name.split('.')
    if len(parts) < 3: return set()
    
    # Get everything between first name and last extension
    exts = set()
    for p in parts[1:-1]:
        exts.add("." + p.lower())
    return exts

def format_size(bytes_size):
    """Returns human readable size"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if bytes_size < 1024.0:
            return f"{bytes_size:.2f} {unit}"
        bytes_size /= 1024.0
    return f"{bytes_size:.2f} TB"

def process_directory(root_dir, target_exts, exclude_paths=None):
    output_content = ""
    file_list = [] # For the "Project Structure" section
    total_files = 0
    total_bytes = 0
    
    # Normalize exclude paths to absolute paths
    excluded_dirs = set()
    if exclude_paths:
        for exclude in exclude_paths:
            abs_path = os.path.abspath(os.path.join(root_dir, exclude))
            excluded_dirs.add(abs_path)

    print(f"\033[96mScanning: {root_dir}...\033[0m") # Cyan text
    if excluded_dirs:
        print(f"\033[93mExcluding: {', '.join(exclude_paths)}\033[0m")
    
    for dirpath, dirnames, filenames in os.walk(root_dir):
        # Check if current directory should be excluded
        abs_dirpath = os.path.abspath(dirpath)
        if any(abs_dirpath.startswith(excluded) for excluded in excluded_dirs):
            dirnames[:] = []  # Don't descend into this directory
            continue
            
        # Filter directories in-place
        dirnames[:] = [d for d in dirnames 
                      if d not in IGNORE_FOLDERS 
                      and os.path.abspath(os.path.join(dirpath, d)) not in excluded_dirs]
        
        for filename in filenames:
            # Skip this script
            if filename == os.path.basename(__file__): continue
            if filename in IGNORE_FILES: continue

            # Extension Logic
            _, ext = os.path.splitext(filename)
            ext = ext.lower()

            # Strict Meta Check: Only allow .meta if explicitly requested
            if ext == ".meta" and ".meta" not in target_exts:
                continue

            # Check if extension matches
            if ext in target_exts:
                filepath = os.path.join(dirpath, filename)
                rel_path = os.path.relpath(filepath, root_dir)
                
                # Determine Markdown language
                md_lang = LANG_MAP.get(ext, ext.replace(".", ""))

                try:
                    with open(filepath, "rb") as f:
                        raw_data = f.read()
                        
                    # Decode
                    try:
                        content = raw_data.decode("utf-8-sig")
                    except UnicodeDecodeError:
                        content = raw_data.decode("latin-1", errors="replace")

                    # Skip binary files that accidentally matched
                    if '\0' in content: continue

                    # --- BUILD MARKDOWN OUTPUT ---
                    output_content += f"## File: {rel_path}\n"
                    output_content += f"```{md_lang}\n"
                    output_content += content
                    output_content += f"\n```\n\n"

                    # Add to stats
                    file_list.append(rel_path)
                    total_files += 1
                    total_bytes += len(raw_data)
                    print(f"Added: {rel_path}")

                except Exception as e:
                    print(f"\033[91mFailed to read {rel_path}: {e}\033[0m")

    # --- APPEND PROJECT STRUCTURE (Like the Bash script) ---
    if total_files > 0:
        output_content += "\n_Project Structure:_\n"
        output_content += "```text\n"
        for path in sorted(file_list):
            output_content += f"{path}\n"
        output_content += "```\n"

    return total_files, total_bytes, output_content

if __name__ == "__main__":
    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description="Copy files with specific extensions to clipboard",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python copy.cs.md.py.py                          # Copy all files
  python copy.cs.md.py.py --exclude test           # Exclude 'test' folder
  python copy.cs.md.py.py --exclude test docs      # Exclude multiple folders
  python copy.cs.md.py.py -e node_modules -e dist  # Short flag
        """
    )
    parser.add_argument(
        '--exclude', '-e',
        action='append',
        default=[],
        metavar='PATH',
        help='Exclude a folder or path (can be used multiple times)'
    )
    
    args = parser.parse_args()
    
    # Setup
    script_dir = os.path.dirname(os.path.abspath(__file__))
    target_exts = get_target_extensions()

    if not target_exts:
        print("\033[93mWARNING: No extensions found in filename!\033[0m")
        print("Rename this file like: 'copy.cs.xml.py'")
        input("Press Enter to exit...")
    else:
        # Run
        start_time = time.time()
        count, size, text = process_directory(script_dir, target_exts, args.exclude)
        
        if count > 0:
            pyperclip.copy(text)
            
            # Calculate stats
            human_size = format_size(size)
            # Rough token estimate (1 token ~= 4 chars)
            tokens = len(text) // 4 
            
            # Print Fancy Success Message (Green)
            print("-" * 50)
            print(f"\033[92m✔ Success! Copied to clipboard.\033[0m")
            print(f"  Files:  \033[1m{count}\033[0m")
            print(f"  Size:   \033[1m{human_size}\033[0m")
            print(f"  Tokens: \033[1m~{tokens}\033[0m (LLM Context)")
            print("-" * 50)
        else:
            print("\033[93mNo matching files found.\033[0m")

        input("\nPress Enter to close...")
