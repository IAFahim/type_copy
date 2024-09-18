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
                with open(filepath, "r", encoding="utf-8-sig") as infile:
                    combined_text += infile.read()
                    combined_text += "\n"  # Add a newline between files

    pyperclip.copy(combined_text)
    print(f"Combined text from all {extension} files copied to clipboard!")

basename = os.path.basename(__file__)
print(basename)
file_extension = basename.split(".")[-2]
print(file_extension)

combine_files_to_clipboard(os.getcwd(), file_extension)