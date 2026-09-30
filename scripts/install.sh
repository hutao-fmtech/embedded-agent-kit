#!/usr/bin/env bash
# One-shot installer: pinned dsh check + embedded-workbench + kit skills.
# Does NOT enable flash erase, pull debugger MCP, or touch hardware.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Keep in sync with docs/dsh-pin.md
DSH_PIN="${DSH_PIN:-0.2.0-rc.2}"
DSH_PKG="@deepseek-ai/dsh@${DSH_PIN}"
# Pin workbench to tag v0.9.1 (package name on GitHub: dsh-embedded-workbench)
WORKBENCH_SPEC="${WORKBENCH_SPEC:-github:AmethystLuna/embedded-workbench#v0.9.1}"
WORKBENCH_PKG_NAME="dsh-embedded-workbench"
WORKBENCH_VERSION_HINT="0.9.1"
DSH_PROFILE="${DSH_PROFILE:-web}"
SKIP_WORKBENCH="${SKIP_WORKBENCH:-0}"

err() { echo "[install] ERROR: $*" >&2; }
info() { echo "[install] $*"; }
die() { err "$*"; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1
  Fix: install it and re-run from the repo root: bash scripts/install.sh"
}

need_cmd node
need_cmd npm
need_cmd npx
need_cmd mkdir
need_cmd cp

NODE_MAJOR="$(node -p "process.versions.node.split('.')[0]" 2>/dev/null || echo 0)"
if [[ "${NODE_MAJOR}" -lt 22 ]]; then
  err "Node.js ${NODE_MAJOR} detected ($(node -v))."
  err "@deepseek-ai/dsh@${DSH_PIN} expects Node ≥ 22.19 for a clean runtime."
  die "upgrade Node (e.g. Node 22 LTS), then re-run bash scripts/install.sh"
fi

info "repo root: $ROOT"
info "dsh pin: ${DSH_PIN} (see docs/dsh-pin.md)"
info "workbench: ${WORKBENCH_SPEC} (${WORKBENCH_PKG_NAME}@${WORKBENCH_VERSION_HINT})"
info "security: flash erase / debugger MCP are NOT installed by default"

info "checking dsh --version…"
if ! DSH_VER_OUT="$(npx -y -p "${DSH_PKG}" dsh --version 2>&1)"; then
  die "failed to run dsh via npx -p ${DSH_PKG}
  Check network access to the npm registry and that Node ≥ 22.19.
  Output was:
${DSH_VER_OUT}"
fi
DSH_VER="$(printf '%s\n' "${DSH_VER_OUT}" | tail -n1 | tr -d '[:space:]')"
if [[ "${DSH_VER}" != "${DSH_PIN}" ]]; then
  die "dsh version mismatch: got '${DSH_VER}', expected pin '${DSH_PIN}'
  Refusing floating / unexpected builds. See docs/dsh-pin.md."
fi
info "dsh --version OK (${DSH_VER})"

run_dsh() {
  npx -y -p "${DSH_PKG}" dsh "$@"
}

# dsh profiles use a pnpm workspace; `pnpm add` needs ignore-workspace-root-check
# or -w. Seed .npmrc before plugin add so dsh's internal pnpm succeeds.
ensure_profile_npmrc() {
  local dsh_home profile_dir
  dsh_home="${DSH_HOME:-${HOME}/.dsh}"
  profile_dir="${dsh_home}/profiles/${DSH_PROFILE}"
  mkdir -p "${profile_dir}"
  local npmrc="${profile_dir}/.npmrc"
  if [[ -f "${npmrc}" ]] && grep -q '^ignore-workspace-root-check=true' "${npmrc}"; then
    info "profile .npmrc already allows workspace-root add (${npmrc})"
  else
    info "seeding ${npmrc} (ignore-workspace-root-check=true)"
    touch "${npmrc}"
    if ! grep -q '^ignore-workspace-root-check=' "${npmrc}" 2>/dev/null; then
      echo 'ignore-workspace-root-check=true' >> "${npmrc}"
    fi
  fi
}

plugin_output_failed() {
  # dsh plugin may exit 0 even when pnpm failed — detect known failure markers.
  printf '%s\n' "$1" | grep -Eqi 'plugin command failed|pnpm was not found|ERR_PNPM_|Command failed'
}

if [[ "${SKIP_WORKBENCH}" != "1" ]]; then
  need_cmd pnpm
  info "pnpm: $(command -v pnpm) ($(pnpm -v 2>/dev/null || echo unknown))"
  # Ensure profile exists (dump-config initializes from shipped template when needed)
  run_dsh --profile "${DSH_PROFILE}" --dump-config >/dev/null 2>&1 || true
  ensure_profile_npmrc

  info "adding workbench plugin to profile '${DSH_PROFILE}'…"
  info "(dependency / bundles key: ${WORKBENCH_PKG_NAME})"
  set +e
  WB_OUT="$(run_dsh plugin --profile "${DSH_PROFILE}" add "${WORKBENCH_SPEC}" 2>&1)"
  WB_EC=$?
  set -e
  printf '%s\n' "${WB_OUT}" | sed 's/^/[install:workbench] /'
  if [[ ${WB_EC} -ne 0 ]] || plugin_output_failed "${WB_OUT}"; then
    err "dsh plugin add failed (exit ${WB_EC})."
    err "Common causes: missing pnpm, no network/GitHub access, or pnpm allowBuilds gate."
    err "Ensure pnpm is on PATH (corepack enable && corepack prepare pnpm@9 --activate)."
    err "Or skip workbench for skills-only: SKIP_WORKBENCH=1 bash scripts/install.sh"
    exit 1
  fi
  info "workbench plugin step finished"
else
  info "SKIP_WORKBENCH=1 — not running dsh plugin add"
fi

info "linking kit skills → .dsh/skills/"
mkdir -p "${ROOT}/.dsh/skills"
cp -R "${ROOT}/bundles/kit-bundle/skills/"* "${ROOT}/.dsh/skills/"

EXPECTED_SKILLS=(
  board-bringup-stm32
  clock-and-boot
  coding-standard
  hardfault-playbook
)
MISSING=0
for s in "${EXPECTED_SKILLS[@]}"; do
  if [[ ! -f "${ROOT}/.dsh/skills/${s}/SKILL.md" ]]; then
    err "missing skill after link: .dsh/skills/${s}/SKILL.md"
    MISSING=1
  else
    info "skill present: ${s}"
  fi
done
[[ "${MISSING}" -eq 0 ]] || die "kit skills link incomplete"

cat <<MSG

[install] Done.

Next steps:
  1. source toolchains/env.sh
  2. Open a dsh session, e.g.:
       npx -y -p ${DSH_PKG} dsh --profile ${DSH_PROFILE}
     Ask: What embedded / kit skills do you have?
  3. Optional L1 eval (needs arm-none-eabi-gcc):
       bash eval/runner.sh l1-compile-fix
       # or: npm run eval:l1

Notes:
  - Pin file: docs/dsh-pin.md (do not use floating @latest)
  - Board pack stm32-smoke is a template — scripts may exit non-zero; label 未上板
  - Debugger MCP / flash erase are opt-in (see README Debugger section + SECURITY.md)
MSG
