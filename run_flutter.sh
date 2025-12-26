#!/bin/bash
# Flutter run script - Run this from anywhere in the AgriNova project

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Navigate to the Flutter project directory
cd "$SCRIPT_DIR/agri_flutter" || exit 1

# Run flutter with all passed arguments
flutter "$@"
