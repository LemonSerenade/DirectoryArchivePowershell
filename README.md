# Directory Archive Powershell

Powershell-based directory listing generator with Windows Form GUI.
Allows users to generate a report of a folder and its subfolders in a selected directory.

## Features

- Generate directory reports from a selected folder
- Export reports in:
  - TXT format
  - CSV format
- Output modes:
  - Single report file containing all folders and files
  - Separate report file for each folder/subfolder
- Folder scope selection:
  - Root folder only
  - Root folder and subfolders
  - Subfolders only
- Optional file size information
- Optional directory tree reporting
- Includes folder metadata:
  - Folder path
  - Creation time
  - Last modified time


## Requirements

- Windows PowerShell 5.1 or later
- Windows operating system

## Installation

Clone the repository:

```bash
git clone https://github.com/LemonSerenade/DirectoryArchivePowershell.git
```

Open PowerShell and run:

```powershell
.\dirScript.ps1
```

## Usage

1. Select the root folder to scan.
2. Select the destination folder for generated reports.
3. Choose:
   - Output format (TXT/CSV)
   - Output mode
   - Folder scope
   - Optional file size information
4. Click **Generate**.