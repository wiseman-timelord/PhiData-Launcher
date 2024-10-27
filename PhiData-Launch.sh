#!/bin/bash
# PhiData-Launch

# Global variables for arguments and model paths
DEBUG_MODE="false"
USE_FASTAPI="true"
VERBOSE_LOGGING="false"
VIRTUAL_ENV_DIR=""
PHIDATA_DIR=""
LLAMA_DEFAULT_MODEL=""
LLAMA_VISUAL_MODEL=""
PERSISTENCE_FILE="./data/persistence.txt"

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

# Function to load model paths from persistence file or initialize it
load_or_initialize_models() {
    if [ ! -f "$PERSISTENCE_FILE" ]; then
        echo "Persistence file not found. Initializing..."
        mkdir -p "$(dirname "$PERSISTENCE_FILE")"
        echo "" > "$PERSISTENCE_FILE"
        echo "" >> "$PERSISTENCE_FILE"
    fi

    # Read models from persistence file
    LLAMA_DEFAULT_MODEL=$(sed -n '1p' "$PERSISTENCE_FILE")
    LLAMA_VISUAL_MODEL=$(sed -n '2p' "$PERSISTENCE_FILE")

    # Validate model paths
    [ ! -f "$LLAMA_DEFAULT_MODEL" ] && LLAMA_DEFAULT_MODEL=""
    [ ! -f "$LLAMA_VISUAL_MODEL" ] && LLAMA_VISUAL_MODEL=""
}
load_or_initialize_models

# Function to save model paths to persistence file
save_models_to_persistence() {
    echo "$LLAMA_DEFAULT_MODEL" > "$PERSISTENCE_FILE"
    echo "$LLAMA_VISUAL_MODEL" >> "$PERSISTENCE_FILE"
}

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
        echo
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

# Set models in the models configuration menu
toggle_models_menu() {
    while true; do
        clear
        print_separator
        echo "    Model Configuration Menu"
        print_separator
        echo
        echo "    1) Set Instruct Model Path"
        echo
        echo "    2) Set Visual Model Path"
        echo
        print_data_separator
        echo
        echo "    Instruct Model:"
        echo "$(basename "$LLAMA_DEFAULT_MODEL")"
        echo
        echo "    Visual Model:"
        echo "$(basename "$LLAMA_VISUAL_MODEL")"
        echo
        echo
        print_separator
        read -p "Selection; Menu Options = 1-2, Back to Main = B: " opt
        case $opt in
            1)
                read -p "Enter path for DEFAULT Model: " LLAMA_DEFAULT_MODEL_NEW
                [ -f "$LLAMA_DEFAULT_MODEL_NEW" ] && LLAMA_DEFAULT_MODEL="$LLAMA_DEFAULT_MODEL_NEW" || echo "Invalid path!"
                ;;
            2)
                read -p "Enter path for VISUAL Model: " LLAMA_VISUAL_MODEL_NEW
                [ -f "$LLAMA_VISUAL_MODEL_NEW" ] && LLAMA_VISUAL_MODEL="$LLAMA_VISUAL_MODEL_NEW" || echo "Invalid path!"
                ;;
            B|b) break ;;
            *) echo "Invalid option! Please choose 1-2 or B." ;;
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

# Validate VENV
validate_venv() {
    if [ ! -d "$VIRTUAL_ENV_DIR" ]; then
        echo "Virtual environment not found at: $VIRTUAL_ENV_DIR"
        echo "Please run 'Install PhiData Requirements' first."
        return 1
    fi

    if [ ! -f "$VIRTUAL_ENV_DIR/bin/activate" ]; then
        echo "Virtual environment appears corrupted: missing activation script"
        echo "Please remove $VIRTUAL_ENV_DIR and run 'Install PhiData Requirements' again."
        return 1
    }

    return 0
}

# Run PhiData with selected options
run_phidata() {
    print_separator
    echo "    Running PhiData with the following options:"
    echo "    Debug Mode: $DEBUG_MODE"
    echo "    Use FastAPI: $USE_FASTAPI"
    echo "    Verbose Logging: $VERBOSE_LOGGING"
    echo "    Default Model: $(basename "$LLAMA_DEFAULT_MODEL")"
    echo "    Visual Model: $(basename "$LLAMA_VISUAL_MODEL")"
    print_separator

    # Save current model paths before running
    save_models_to_persistence

    if ! validate_venv; then
        read -n 1 -s -r -p "Press any key to return to menu..."
        return 1
    fi

    if ! source "$VIRTUAL_ENV_DIR/bin/activate"; then
        echo "Failed to activate virtual environment!"
        read -n 1 -s -r -p "Press any key to return to menu..."
        return 1
    fi

    # Base command
    CMD="python3 run_phidata.py"

    # Add configuration flags
    [ "$DEBUG_MODE" == "true" ] && CMD="$CMD --debug"
    [ "$USE_FASTAPI" == "true" ] && CMD="$CMD --fastapi"
    [ "$VERBOSE_LOGGING" == "true" ] && CMD="$CMD --verbose"

    # Add model paths if they exist
    if [ -f "$LLAMA_DEFAULT_MODEL" ]; then
        CMD="$CMD --default-model \"$LLAMA_DEFAULT_MODEL\""
    else
        echo "    WARNING: Default model not found at: $LLAMA_DEFAULT_MODEL"
    fi

    if [ -f "$LLAMA_VISUAL_MODEL" ]; then
        CMD="$CMD --visual-model \"$LLAMA_VISUAL_MODEL\""
    else
        echo "    WARNING: Visual model not found at: $LLAMA_VISUAL_MODEL"
    fi

    echo "    Executing: $CMD"
    if ! eval "$CMD"; then
        echo "Failed to execute PhiData!"
        read -n 1 -s -r -p "Press any key to return to menu..."
        return 1
    fi
    sleep 2
}

# Strip model paths for displaying
strip_model_path() {
    basename "$1"
}

# Main Menu
while true; do
    clear
    print_separator
    echo "    PhiData-Launch"
    print_separator
    echo
    echo "    1) Install PhiData Requirements"
    echo "    2) Configure Arguments and Settings"
    echo "    3) Configure Models Used"
    echo "    4) Run PhiData Now"
    echo
    print_data_separator
    echo
    echo "    VENV Location:"
    echo "$VIRTUAL_ENV_DIR"
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
        X|x)
            echo "    Saving configuration..."
            save_models_to_persistence
            echo "    Exiting..."
            exit ;;
        *) echo "    Invalid option! Please choose 1-4 or X to exit." ;;
    esac
    sleep 1
done
