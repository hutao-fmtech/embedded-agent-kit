#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
task="${1:-l1-compile-fix}"
echo "[eval] running $task"
bash "$ROOT/eval/tasks/$task/check.sh"
echo "[eval] PASS $task"
