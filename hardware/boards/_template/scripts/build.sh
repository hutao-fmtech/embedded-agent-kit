#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/toolchains/env.sh"

echo "[build] Template: point this script at your firmware CMake/Make project."
if ! command -v arm-none-eabi-gcc >/dev/null 2>&1; then
  echo "[build] FAIL: arm-none-eabi-gcc missing" >&2
  exit 1
fi
echo "[build] Toolchain OK (no firmware tree wired yet). Status: 未上板"
exit 0
