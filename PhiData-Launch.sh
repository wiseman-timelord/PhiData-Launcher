#!/bin/bash
# PhiData-Launch

# Global variables for arguments and model paths
DEBUG_MODE="false"
USE_FASTAPI="true"
VERBOSE_LOGGING="false"
VIRTUAL_ENV_DIR=""
PHIDATA_DIR=""
LLAMA_DEFAULT_MODEL="/media/mastar/Store-Large_480/models/mradermacher/Llama-3.1-Nemotron-70B-Instruct-HF-GGUF/Llama-3.1-Nemotron-70B-Instruct-HF.Q4_K_M.gguf"
LLAMA_VISUAL_MODEL="/media/mastar/Store-Large_480/models/FiditeNemini/Llama-3.1-Unhinged-Vision-8B-GGUF/Llama-3.1-Unhinged-Vision-8B-q8_0.gguf"

# Initialization Block Start
if [ "$EUID" -ne 0 ]; then
    echo "Run as Sudo, and try again..."
    read -n 1 -s -r -p "Press any key to exit..."
    exit 1
else
    echo "Sudo Status: Active"
    sleep 1
fi
cd "$(dirname "$0")" || exit
PHIDATA_DIR="$(pwd)"
VIRTUAL_ENV_DIR="$PHIDATA_DIR/phidata-venv"
echo "Current Dir.: $(pwd)"
sleep 2
# Initialization Block End

# Function to print a separator line
print_separator() {
    echo "================================================================================"
}

# Function to print a data separator line (for information display)
print_data_separator() {
    echo "--------------------------------------------------------------------------------"
}

# Function to check if a package is installed
check_package() {
    if dpkg -l | grep -q "^ii.*$1 "; then
        return 0
    else
        return 1
    fi
}

# Check if Python 3 is installed
check_python_installed() {
    command -v python3 &> /dev/null
}

# Toggle arguments in the setup menu
toggle_args_menu() {
    while true; do
        clear
        print_separator
        echo "    Argument Setup Menu"
        print_separator
        echo
        echo "    1) Toggle Debug Mode"
        echo
        echo "    2) Toggle FastAPI"
        echo
        echo "    3) Toggle Verbose Logging"
        echo
        print_data_separator
        echo "    DEBUG_MODE: $DEBUG_MODE"
        echo
        echo "    USE_FASTAPI: $USE_FASTAPI"
        echo
        echo "    VERBOSE_LOGGING: $VERBOSE_LOGGING"
        echo
        print_separator
        read -p "Selection; Menu Options = 1-3, Back to Main = B: " opt
        case $opt in
            1) DEBUG_MODE=$([ "$DEBUG_MODE" == "false" ] && echo "true" || echo "false") ;;
            2) USE_FASTAPI=$([ "$USE_FASTAPI" == "true" ] && echo "false" || echo "true") ;;
            3) VERBOSE_LOGGING=$([ "$VERBOSE_LOGGING" == "false" ] && echo "true" || echo "false") ;;
            B|b) break ;;
            *) echo "Invalid option! Please choose 1-3 or B." ;;
        esac
        sleep 1
    done
}

# Enhanced install requirements function
install_requirements() {
    print_separator
    echo "    Checking and Installing Prerequisites..."
    print_separator

    local prerequisites_met=true

    # Check for sudo access
    if ! sudo -v; then
        echo "Error: This script requires sudo privileges to install system packages."
        return 1
    fi

    # 1. Check/Install Python 3
    echo "Checking Python 3..."
    if ! check_python_installed; then
        echo "Python 3 not found. Installing..."
        prerequisites_met=false
        sudo apt update
        sudo apt install -y python3
        if ! check_python_installed; then
            echo "Failed to confirm Python 3 installation!"
            return 1
        fi
    fi
    echo "✓ Python 3 installed and verified"
    print_data_separator

    # 2. Check/Install pip
    echo "Checking pip..."
    if ! command -v pip3 &> /dev/null; then
        echo "pip3 not found. Installing..."
        prerequisites_met=false
        sudo apt install -y python3-pip
        if ! command -v pip3 &> /dev/null; then
            echo "Failed to install pip3!"
            return 1
        fi
    fi
    echo "✓ pip installed and verified"
    print_data_separator

    # 3. Check/Install python3-venv
    echo "Checking python3-venv..."
    if ! check_package "python3-venv"; then
        echo "python3-venv not found. Installing..."
        prerequisites_met=false
        sudo apt install -y python3-venv
        if ! check_package "python3-venv"; then
            echo "Failed to install python3-venv!"
            return 1
        fi
    fi
    echo "✓ python3-venv installed and verified"
    print_data_separator

    # 4. Check/Install git
    echo "Checking git..."
    if ! command -v git &> /dev/null; then
        echo "git not found. Installing..."
        prerequisites_met=false
        sudo apt install -y git
        if ! command -v git &> /dev/null; then
            echo "Failed to install git!"
            return 1
        fi
    fi
    echo "✓ git installed and verified"
    print_data_separator

    # If any prerequisites were missing and had to be installed, suggest a shell restart
    if [ "$prerequisites_met" = false ]; then
        echo "Some new packages were installed. You might need to restart your shell."
        read -p "Press Enter to continue with PhiData installation, or Ctrl+C to exit and restart shell..."
    fi

    # Continue with PhiData virtual environment setup
    echo "Setting up PhiData virtual environment..."
    if [ ! -d "$VIRTUAL_ENV_DIR" ]; then
        python3 -m venv "$VIRTUAL_ENV_DIR"
        echo "✓ Virtual environment created at $VIRTUAL_ENV_DIR"
    fi

    # Activate and install dependencies
    source "$VIRTUAL_ENV_DIR/bin/activate"
    cd "$PHIDATA_DIR" || exit

    echo "Installing PhiData dependencies..."
    pip install -U pip  # Ensure pip is up to date
    pip install -U . fastapi uvicorn

    echo "✓ PhiData and dependencies installed successfully!"
    print_separator

    # Add pause before returning to menu
    read -n 1 -s -r -p "Press Any Key to Return to Menu..."
    echo # Add newline after key press
}

# Main Menu
while true; do
    print_separator
    echo "    PhiData-Launch"
    print_separator
    echo
    echo "    1) Install PhiData Requirements"
    echo
    echo "    2) Configure Arguments and Settings"
    echo
    echo "    3) Configure Models Used"
    echo
    echo "    4) Run PhiData Now"
    echo
    print_data_separator
    echo
    echo "    VENV Location:"
    echo "$VIRTUAL_ENV_DIR"
    echo
    echo "    Models Used:"
    echo "$(basename "$LLAMA_DEFAULT_MODEL")"
    echo "$(basename "$LLAMA_VISUAL_MODEL")"
    echo
    print_separator
    read -p "Selection; Menu Options 1-4, Exit Program = X: " opt
    case $opt in
        1) install_requirements ;;
        2) toggle_args_menu ;;
        3) toggle_models_menu ;;
        4) run_phidata ;;
        X|x) echo "    Exiting..." ; exit ;;
        *) echo "    Invalid option! Please choose 1-4 or X to exit." ;;
    esac
    sleep 1
done

