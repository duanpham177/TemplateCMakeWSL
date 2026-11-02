#!/usr/bin/env bash
# Usage: ./build-wsl.sh [preset]   (default: wsl-gcc-debug)
set -euo pipefail
cd "$(dirname "$0")"
preset="${1:-wsl-gcc-debug}"
cmake --preset "$preset"
cmake --build --preset "$preset"
