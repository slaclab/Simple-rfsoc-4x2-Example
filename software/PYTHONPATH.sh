#!/usr/bin/env bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PYTHONPATH="$PYTHONPATH:$(realpath "$SCRIPT_DIR/../firmware/submodules/surf/python")"
export PYTHONPATH="$PYTHONPATH:$(realpath "$SCRIPT_DIR/../firmware/submodules/axi-soc-ultra-plus-core/python")"
export PYTHONPATH="$PYTHONPATH:$(realpath "$SCRIPT_DIR/../firmware/python")"
