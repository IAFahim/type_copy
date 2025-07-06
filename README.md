# Type Copy

Goes through all the files and folder in same folder and its sub folder and copies them to clipboard

## instructions
Copy and paste this file [copy.cs.md.py.py](copy.cs.md.py.py) to any folder and run it. It will copy all files with the extensions you specify to the clipboard.

## Example, if `copy.py` script has the following extensions before end of `.py`:
```
extensions = {'cs', 'md', 'py'} => copy.cs.md.py.py
All Files with .cs, .md, .py extensions will be copied to clipboard
```

The extensions of file you want to copy, put those extension in between the `copy.{extensions}.py` seprated by (.)dot. The script will go through all the files in current folder and its subfolders. And Copy them to the clipboard.


![Type Copy visual.png](docs/Type%20Copy%20visual.png)

## Example of usage:

```
D:\type_copy\copy.cs.md.py.py
copy.cs.md.py.py
{'md', 'py', 'cs'}
Processing: D:\type_copy\README.md
Processing: D:\type_copy\test\dir.test.cs
Processing: D:\type_copy\test\dir.test.md
Processing: D:\type_copy\test\dir.test.py
Combined length: 1706 from all {'md', 'py', 'cs'} total:4 files copied to clipboard!
```

[Requirements:](requirements.txt)
- Python installed
- pyperclip

## For Linux
You don't even need this libary
```bash
find . -type f \( -name "*.cs" -o -name "*.md" \) -exec cat {} \; | xclip -selection clipboard
```
Note: need xclip installed for unix


## Tutorial Video:

[Recording 2024-12-23 021135.mp4](docs/Recording%202024-12-23%20021135.mp4)

## Bonus: 
Try it with https://learn.microsoft.com/en-us/windows/dev-home/ 

### it unlocks this:
![image](https://github.com/user-attachments/assets/d060ff72-2520-437d-b723-e4989dbe93c6)
