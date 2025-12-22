#!/bin/bash
# ============================================================================
# Type Copy - Automatic Python Setup Script (Linux/macOS)
# ============================================================================
# This script will:
# 1. Check if Python is installed
# 2. If not, provide instructions to install Python
# 3. Install required packages (pyperclip)
# 4. Install clipboard utilities (Linux only)
# 5. Verify installation
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}============================================================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}============================================================================${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}[$1]${NC} $2"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

get_package_manager() {
    if check_command apt-get; then
        echo "apt"
    elif check_command dnf; then
        echo "dnf"
    elif check_command yum; then
        echo "yum"
    elif check_command pacman; then
        echo "pacman"
    elif check_command brew; then
        echo "brew"
    else
        echo "unknown"
    fi
}

# ============================================================================
# Main Script
# ============================================================================

print_header "Type Copy - Auto Setup"

OS=$(detect_os)
PKG_MANAGER=$(get_package_manager)

echo -e "${GRAY}Operating System: $OS${NC}"
echo -e "${GRAY}Package Manager: $PKG_MANAGER${NC}"
echo ""

# Step 1: Check Python
print_step "1/5" "Checking Python installation..."

PYTHON_CMD=""
if check_command python3; then
    PYTHON_CMD="python3"
elif check_command python; then
    # Check if it's Python 3
    PYTHON_VERSION=$(python --version 2>&1 | grep -oP '\d+\.\d+' | head -1)
    MAJOR_VERSION=$(echo "$PYTHON_VERSION" | cut -d. -f1)
    if [ "$MAJOR_VERSION" -ge 3 ]; then
        PYTHON_CMD="python"
    fi
fi

if [ -n "$PYTHON_CMD" ]; then
    VERSION=$($PYTHON_CMD --version 2>&1)
    print_success "Python is installed: $VERSION"
    echo ""
else
    print_warning "Python 3 is not installed"
    echo ""
    echo -e "${CYAN}Installing Python...${NC}"
    echo ""
    
    case "$OS" in
        macos)
            if check_command brew; then
                echo "Installing Python via Homebrew..."
                brew install python3
                PYTHON_CMD="python3"
            else
                print_error "Homebrew not found"
                echo ""
                echo "Please install Homebrew first:"
                echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                echo ""
                echo "Or install Python manually:"
                echo "  Download from: https://www.python.org/downloads/"
                exit 1
            fi
            ;;
        linux)
            case "$PKG_MANAGER" in
                apt)
                    echo "Installing Python via apt..."
                    sudo apt-get update
                    sudo apt-get install -y python3 python3-pip
                    PYTHON_CMD="python3"
                    ;;
                dnf)
                    echo "Installing Python via dnf..."
                    sudo dnf install -y python3 python3-pip
                    PYTHON_CMD="python3"
                    ;;
                yum)
                    echo "Installing Python via yum..."
                    sudo yum install -y python3 python3-pip
                    PYTHON_CMD="python3"
                    ;;
                pacman)
                    echo "Installing Python via pacman..."
                    sudo pacman -S --noconfirm python python-pip
                    PYTHON_CMD="python3"
                    ;;
                *)
                    print_error "Could not determine package manager"
                    echo ""
                    echo "Please install Python 3 manually:"
                    echo "  Ubuntu/Debian: sudo apt install python3 python3-pip"
                    echo "  Fedora:        sudo dnf install python3 python3-pip"
                    echo "  Arch:          sudo pacman -S python python-pip"
                    exit 1
                    ;;
            esac
            ;;
        *)
            print_error "Unsupported operating system"
            exit 1
            ;;
    esac
    
    # Verify installation
    if check_command "$PYTHON_CMD"; then
        VERSION=$($PYTHON_CMD --version 2>&1)
        print_success "Python installed: $VERSION"
    else
        print_error "Python installation failed"
        exit 1
    fi
    echo ""
fi

# Step 2: Check pip
print_step "2/5" "Checking pip installation..."

PIP_CMD=""
if check_command pip3; then
    PIP_CMD="pip3"
elif check_command pip; then
    PIP_CMD="pip"
elif check_command "$PYTHON_CMD" && $PYTHON_CMD -m pip --version >/dev/null 2>&1; then
    PIP_CMD="$PYTHON_CMD -m pip"
fi

if [ -n "$PIP_CMD" ]; then
    print_success "pip is installed"
else
    print_warning "pip is not installed, installing..."
    
    case "$OS" in
        macos)
            brew install python3
            PIP_CMD="pip3"
            ;;
        linux)
            case "$PKG_MANAGER" in
                apt)
                    sudo apt-get install -y python3-pip
                    ;;
                dnf)
                    sudo dnf install -y python3-pip
                    ;;
                yum)
                    sudo yum install -y python3-pip
                    ;;
                pacman)
                    sudo pacman -S --noconfirm python-pip
                    ;;
            esac
            PIP_CMD="pip3"
            ;;
    esac
    
    if ! check_command pip3; then
        print_error "Could not install pip"
        exit 1
    fi
    print_success "pip installed"
fi
echo ""

# Step 3: Install clipboard utilities (Linux only)
if [ "$OS" = "linux" ]; then
    print_step "3/5" "Checking clipboard utilities..."
    
    if check_command xclip || check_command xsel || check_command wl-copy; then
        print_success "Clipboard utility is installed"
    else
        print_warning "No clipboard utility found"
        echo "  Installing xclip..."
        
        case "$PKG_MANAGER" in
            apt)
                sudo apt-get install -y xclip
                ;;
            dnf)
                sudo dnf install -y xclip
                ;;
            yum)
                sudo yum install -y xclip
                ;;
            pacman)
                sudo pacman -S --noconfirm xclip
                ;;
        esac
        
        if check_command xclip; then
            print_success "xclip installed"
        else
            print_warning "Could not install xclip automatically"
            echo "  Please install manually: sudo apt install xclip (or equivalent)"
        fi
    fi
    echo ""
else
    print_step "3/5" "Checking clipboard support..."
    print_success "macOS has built-in clipboard support (pbcopy)"
    echo ""
fi

# Step 4: Install Python packages
print_step "4/5" "Installing required Python packages..."
echo ""

# Check if pyperclip is already installed
if $PYTHON_CMD -c "import pyperclip" 2>/dev/null; then
    print_success "pyperclip is already installed"
else
    echo "  Installing pyperclip..."
    
    # Try with --user flag first (no sudo needed)
    if $PIP_CMD install --user pyperclip >/dev/null 2>&1; then
        print_success "pyperclip installed successfully"
    elif $PIP_CMD install pyperclip >/dev/null 2>&1; then
        print_success "pyperclip installed successfully"
    else
        print_error "Failed to install pyperclip"
        echo ""
        echo "Please run manually:"
        echo "  $PIP_CMD install pyperclip"
        exit 1
    fi
fi

echo ""

# Step 5: Verify installation
print_step "5/5" "Verifying installation..."

# Test Python
if $PYTHON_CMD --version >/dev/null 2>&1; then
    print_success "Python is working"
else
    print_error "Python verification failed"
    exit 1
fi

# Test pyperclip
if $PYTHON_CMD -c "import pyperclip" 2>/dev/null; then
    print_success "pyperclip is working"
else
    print_error "pyperclip verification failed"
    exit 1
fi

echo ""

# Success!
print_header "Setup Complete!"

echo -e "${GREEN}Python and all dependencies are now installed and configured.${NC}"
echo ""
echo -e "${CYAN}You can now use Type Copy!${NC}"
echo ""
echo -e "${YELLOW}Usage:${NC}"
echo "  $PYTHON_CMD copy.cs.md.py.py                  - Copy all files"
echo "  $PYTHON_CMD copy.cs.md.py.py --exclude test   - Exclude folders"
echo "  $PYTHON_CMD copy.cs.md.py.py --help           - Show help"
echo ""

# Create a convenient alias suggestion
echo -e "${YELLOW}Pro Tip:${NC}"
echo "Add this to your ~/.bashrc or ~/.zshrc for easy access:"
echo "  alias typecopy='$PYTHON_CMD $(pwd)/copy.cs.md.py.py'"
echo ""

# Ask to run Type Copy
if [ -f "copy.cs.md.py.py" ]; then
    echo -e "${GRAY}Press Enter to run Type Copy now, or Ctrl+C to exit...${NC}"
    read -r
    $PYTHON_CMD copy.cs.md.py.py "$@"
else
    print_error "copy.cs.md.py.py not found in current directory"
    echo "Please make sure this script is in the same folder as copy.cs.md.py.py"
    exit 1
fi
