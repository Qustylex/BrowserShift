#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VENV_DIR="$SCRIPT_DIR/.venv"
VENV_PY="$VENV_DIR/bin/python"

echo
echo "            BrowserShift Launcher"
echo

if [ -x "$VENV_PY" ]; then
    echo "  [OK] Virtual environment found."
else
    PYEXE=""
    for candidate in python3.13 python3.12 python3.11 python3 python; do
        if command -v "$candidate" >/dev/null 2>&1; then
            PYEXE="$(command -v "$candidate")"
            break
        fi
    done
    if [ -z "$PYEXE" ]; then
        echo "  [X] Python 3.11+ not found. Install it and retry."
        exit 1
    fi
    echo "  [OK] Using Python: $PYEXE"
    echo "  [*] Creating virtual environment..."
    "$PYEXE" -m venv "$VENV_DIR"
    echo "  [*] Upgrading pip..."
    "$VENV_PY" -m pip install --upgrade pip --quiet
    echo "  [*] Installing BrowserShift and dependencies..."
    "$VENV_PY" -m pip install -e "$SCRIPT_DIR" --quiet
    echo "  [OK] Setup complete."
    echo
fi

echo "  [*] Starting BrowserShift..."
echo
exec "$VENV_PY" -m browsershift.main