#!/bin/bash
# Django backend run script - Run this from anywhere in the AgriNova project

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Navigate to the Python project directory
cd "$SCRIPT_DIR/agri_python" || exit 1

# Run Django server
uv run python manage.py runserver 0.0.0.0:8000
