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
copy.cs.md.py.py
{'cs', 'md', 'py'}
Processing: D:\type_copy\test.cs
Processing: D:\type_copy\test.md
Processing: D:\type_copy\test.py
Processing: D:\type_copy\FolderTest\dir.test.cs
Processing: D:\type_copy\FolderTest\dir.test.md
Processing: D:\type_copy\FolderTest\dir.test.py
Processing: D:\type_copy\FolderTest\README.md
Combined length: 163 from all {'cs', 'md', 'py'} total:7 files copied to clipboard!
```

[Requirements:](requirements.txt)
- Python installed
- pyperclip

## Tutorial Video:

[Recording 2024-12-23 021135.mp4](docs/Recording%202024-12-23%20021135.mp4)

## Bonus: 
Try it with https://learn.microsoft.com/en-us/windows/dev-home/ 

### it unlocks this:
![image](https://github.com/user-attachments/assets/d060ff72-2520-437d-b723-e4989dbe93c6)
