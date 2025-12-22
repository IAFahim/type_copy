# ============================================================================
# Type Copy - Automatic Python Setup Script (PowerShell)
# ============================================================================
# This script will:
# 1. Check if Python is installed
# 2. If not, download and install Python automatically
# 3. Add Python to PATH
# 4. Install required packages (pyperclip)
# 5. Verify installation
# ============================================================================

param(
    [switch]$SkipPythonInstall,
    [switch]$Quiet
)

# Requires PowerShell 5.1+
#Requires -Version 5.1

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# ============================================================================
# Configuration
# ============================================================================

$PYTHON_VERSION = "3.12.1"
$PYTHON_URL = "https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION-amd64.exe"
$REQUIRED_PACKAGES = @("pyperclip")

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Step, [string]$Message)
    Write-Host "[$Step] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Error-Message {
    param([string]$Message)
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

function Write-Warning-Message {
    param([string]$Message)
    Write-Host "[WARNING] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-PythonInstalled {
    try {
        $version = python --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
    }
    catch {
        return $false
    }
    return $false
}

function Get-PythonInstallPath {
    # Common Python installation locations
    $locations = @(
        "$env:LOCALAPPDATA\Programs\Python\Python3*",
        "$env:PROGRAMFILES\Python3*",
        "${env:PROGRAMFILES(X86)}\Python3*",
        "C:\Python3*"
    )
    
    foreach ($pattern in $locations) {
        $paths = Get-ChildItem -Path (Split-Path $pattern) -Directory -Filter (Split-Path $pattern -Leaf) -ErrorAction SilentlyContinue
        foreach ($path in $paths) {
            if (Test-Path "$($path.FullName)\python.exe") {
                return $path.FullName
            }
        }
    }
    return $null
}

function Add-PythonToPath {
    param([string]$PythonPath)
    
    $scriptsPath = Join-Path $PythonPath "Scripts"
    
    # Get current user PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    # Check if already in PATH
    if ($currentPath -like "*$PythonPath*") {
        Write-Success "Python already in PATH"
        return $true
    }
    
    # Add to PATH
    $newPath = "$PythonPath;$scriptsPath;$currentPath"
    
    try {
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        $env:Path = "$PythonPath;$scriptsPath;$env:Path"
        Write-Success "Python added to PATH"
        return $true
    }
    catch {
        Write-Error-Message "Failed to add Python to PATH: $_"
        return $false
    }
}

function Install-Python {
    Write-Header "Python Installation"
    
    Write-Step "2/5" "Downloading Python $PYTHON_VERSION..."
    Write-Host "  URL: $PYTHON_URL" -ForegroundColor Gray
    Write-Host "  Size: ~25 MB" -ForegroundColor Gray
    Write-Host ""
    
    $installerPath = Join-Path $env:TEMP "python-installer.exe"
    
    try {
        # Enable TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # Download with progress
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($PYTHON_URL, $installerPath)
        
        Write-Success "Python installer downloaded"
    }
    catch {
        Write-Error-Message "Failed to download Python installer"
        Write-Host "  Error: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please download Python manually from:" -ForegroundColor Yellow
        Write-Host "  https://www.python.org/downloads/" -ForegroundColor Cyan
        Write-Host ""
        return $false
    }
    
    Write-Host ""
    Write-Step "3/5" "Installing Python..."
    Write-Host "  This may take 2-3 minutes..." -ForegroundColor Gray
    Write-Host ""
    
    try {
        # Install Python silently
        $installArgs = @(
            "/quiet",
            "InstallAllUsers=0",
            "PrependPath=1",
            "Include_test=0",
            "Include_pip=1",
            "Include_launcher=1"
        )
        
        $process = Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Success "Python installed successfully"
        }
        else {
            Write-Error-Message "Python installation failed with exit code: $($process.ExitCode)"
            return $false
        }
    }
    catch {
        Write-Error-Message "Failed to install Python: $_"
        return $false
    }
    finally {
        # Clean up installer
        if (Test-Path $installerPath) {
            Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        }
    }
    
    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    return $true
}

function Install-Package {
    param([string]$PackageName)
    
    # Check if already installed
    try {
        python -c "import $PackageName" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$PackageName is already installed"
            return $true
        }
    }
    catch {
        # Not installed, continue
    }
    
    Write-Host "  Installing $PackageName..." -ForegroundColor Gray
    
    try {
        # Upgrade pip first
        python -m pip install --quiet --upgrade pip 2>&1 | Out-Null
        
        # Install package
        python -m pip install --quiet $PackageName
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$PackageName installed successfully"
            return $true
        }
        else {
            Write-Error-Message "Failed to install $PackageName"
            return $false
        }
    }
    catch {
        Write-Error-Message "Failed to install $PackageName: $_"
        return $false
    }
}

# ============================================================================
# Main Script
# ============================================================================

Write-Header "Type Copy - Auto Setup"

# Check admin rights
if (-not (Test-Administrator)) {
    Write-Warning-Message "Not running as Administrator"
    Write-Host "  Some features may require admin rights" -ForegroundColor Gray
    Write-Host "  Right-click and 'Run as Administrator' for full setup" -ForegroundColor Gray
    Write-Host ""
}

# Step 1: Check Python
Write-Step "1/5" "Checking Python installation..."

if (Test-PythonInstalled) {
    $version = python --version 2>&1
    Write-Success "Python is already installed: $version"
    Write-Host ""
}
else {
    Write-Host "  Python is not installed or not in PATH" -ForegroundColor Yellow
    Write-Host ""
    
    if ($SkipPythonInstall) {
        Write-Error-Message "Python not found and -SkipPythonInstall specified"
        exit 1
    }
    
    # Install Python
    $installed = Install-Python
    
    if (-not $installed) {
        Write-Host ""
        Write-Error-Message "Python installation failed"
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host ""
    
    # Verify installation
    Start-Sleep -Seconds 2
    
    if (-not (Test-PythonInstalled)) {
        Write-Error-Message "Python installed but not accessible"
        Write-Host ""
        Write-Host "Please restart your computer and try again" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Step 4: Verify PATH
Write-Step "4/5" "Verifying Python PATH..."

if (Test-PythonInstalled) {
    Write-Success "Python is accessible"
    $version = python --version 2>&1
    Write-Host "  Version: $version" -ForegroundColor Gray
}
else {
    Write-Warning-Message "Python not in PATH, attempting to fix..."
    
    $pythonPath = Get-PythonInstallPath
    
    if ($pythonPath) {
        Write-Host "  Found Python at: $pythonPath" -ForegroundColor Gray
        Add-PythonToPath -PythonPath $pythonPath
        
        # Refresh and test again
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        if (-not (Test-PythonInstalled)) {
            Write-Error-Message "Could not make Python accessible"
            Write-Host "  Please restart your computer" -ForegroundColor Yellow
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
    else {
        Write-Error-Message "Could not locate Python installation"
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""

# Step 5: Install packages
Write-Step "5/5" "Installing required packages..."
Write-Host ""

$allInstalled = $true
foreach ($package in $REQUIRED_PACKAGES) {
    $installed = Install-Package -PackageName $package
    if (-not $installed) {
        $allInstalled = $false
    }
}

Write-Host ""

if (-not $allInstalled) {
    Write-Error-Message "Some packages failed to install"
    Write-Host "  Please run manually: pip install pyperclip" -ForegroundColor Yellow
    Write-Host ""
}

# Success!
Write-Header "Setup Complete!"

Write-Host "Python and all dependencies are now installed and configured." -ForegroundColor Green
Write-Host ""
Write-Host "You can now use Type Copy!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  python copy.cs.md.py.py                  - Copy all files"
Write-Host "  python copy.cs.md.py.py --exclude test   - Exclude folders"
Write-Host "  python copy.cs.md.py.py --help           - Show help"
Write-Host ""

if (-not $Quiet) {
    Write-Host "Press any key to run Type Copy now..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Run Type Copy
    $scriptPath = Join-Path $PSScriptRoot "copy.cs.md.py.py"
    
    if (Test-Path $scriptPath) {
        Write-Host ""
        python $scriptPath $args
    }
    else {
        Write-Error-Message "copy.cs.md.py.py not found in current directory"
        Write-Host "  Please make sure this script is in the same folder" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
}
