import os
import pyperclip  # Install this library: pip install pyperclip


def combine_files_to_clipboard(root_dir, extension):
    """
    Combines all files with a specific extension from a root directory and its
    subdirectories (including nested subdirectories) into a string and copies
    it to the clipboard.

    Args:
        root_dir: The root directory to search for files.
        extension: The file extension to look for (e.g., ".cs").
    """

    combined_text = ""
    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith(extension):
                filepath = os.path.join(dirpath, filename)
                print(f"Processing: {filepath}")  # Print the filename for debugging
                with open(filepath, "rb") as infile:  # Open in binary mode
                    content = infile.read()
                    try:
                        content = content.decode("utf-8-sig")  # Try UTF-8 with BOM
                    except UnicodeDecodeError:
                        content = content.decode("latin-1", errors="replace")  # Fallback to Latin-1 and replace undecodable characters
                    if content.startswith('\ufeff'):  # Check for BOM
                        content = content[3:]  # Remove BOM if present
                    combined_text += content
                    combined_text += "\n"

    pyperclip.copy(combined_text)
    print(f"Combined text from all {extension} files copied to clipboard!")


basename = os.path.basename(__file__)
print(basename)
file_extension = basename.split(".")[-2]
print(file_extension)

combine_files_to_clipboard(os.getcwd(), file_extension)