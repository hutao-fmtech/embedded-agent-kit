#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/toolchains/env.sh"
# When a sample firmware tree exists, call its build.
# For now, toolchain presence is the gate for the scaffold.
command -v arm-none-eabi-gcc >/dev/null
echo "[check] scaffold OK — wire to real firmware build when ready."
