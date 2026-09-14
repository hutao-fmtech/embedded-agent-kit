#!/usr/bin/env bash
# Source me: `source toolchains/env.sh`
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export EMBEDDED_AGENT_ROOT="$ROOT"

# Prefer an existing arm-none-eabi-gcc on PATH; otherwise print hint.
if command -v arm-none-eabi-gcc >/dev/null 2>&1; then
  echo "[env] arm-none-eabi-gcc: $(command -v arm-none-eabi-gcc)"
  arm-none-eabi-gcc -dumpversion || true
else
  echo "[env] WARN: arm-none-eabi-gcc not found on PATH."
  echo "      Install a GNU Arm Embedded Toolchain and re-source this file."
fi

if command -v cmake >/dev/null 2>&1; then
  echo "[env] cmake: $(cmake --version | head -n1)"
else
  echo "[env] WARN: cmake not found (optional for some projects)."
fi

export PATH="$PATH"
