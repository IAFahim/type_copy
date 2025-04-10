import os
import pyperclip  # Install this library: pip install pyperclip


def combine_files_to_clipboard(root_dir, extension: set[str], basename: str) -> (int, str):
    """
    Combines all files with a specific extension from a root directory and its
    subdirectories (including nested subdirectories) into a string and copies
    it to the clipboard.

    Args:
        root_dir: The root directory to search for files.
        extension: The file extension to look for (e.g., ".cs").
    """

    combined_text = ""
    file_added = 0
    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename == basename:
                continue
            ext = os.path.splitext(filename)[1][1:]  # Get the file extension without the dot
            if ext not in extension:
                continue
            file_added += 1
            filepath = os.path.join(dirpath, filename)
            print(f"Processing: {filepath}")  # Print the filename for debugging
            with open(filepath, "rb") as infile:  # Open in binary mode
                content = infile.read()
                try:
                    content = content.decode("utf-8-sig")  # Try UTF-8 with BOM
                except UnicodeDecodeError:
                    content = content.decode("latin-1",
                                             errors="replace")  # Fallback to Latin-1 and replace undecodable characters
                if content.startswith('\ufeff'):  # Check for BOM
                    content = content[3:]  # Remove BOM if present
                combined_text += content
                combined_text += "\n"

    return file_added, combined_text


if __name__ == "__main__":
    print(__file__)
    this_base_name = os.path.basename(__file__)
    print(this_base_name)
    # take all files with the same extension as the current file .py
    file_extensions = set(this_base_name.split(".")[1:-1])
    print(file_extensions)
    file_added, combined_text = combine_files_to_clipboard(os.getcwd(), file_extensions, this_base_name)
    pyperclip.copy(combined_text)
    print(f"Combined length: {len(combined_text)} from all {file_extensions} total:{file_added} files copied to clipboard!")
