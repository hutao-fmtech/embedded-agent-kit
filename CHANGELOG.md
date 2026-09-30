# Changelog

All notable changes to Embedded Agent Kit are documented in this file.

The format is based on Keep a Changelog, and this project uses SemVer-style
tags (`vMAJOR.MINOR.PATCH`). GitHub Releases for `v*` tags extract the matching
`## X.Y.Z` section via `.github/workflows/release.yml`.

## 0.2.0 — 2026-09-30

### Added

- Authoritative `dsh` pin document (`docs/dsh-pin.md`) for `@deepseek-ai/dsh@0.2.0-rc.2`
  with install/verify commands and companion workbench pin notes.
- One-shot installer `scripts/install.sh` (pinned dsh check + workbench plugin + kit skills link).
  Does not enable flash erase or install debugger MCP by default.
- CI workflow (`.github/workflows/ci.yml`): skill frontmatter checks, `bash -n` on kit scripts,
  optional dsh smoke (skip-ok), L1 eval CT with toolchain skip-ok.
- CD workflow (`.github/workflows/release.yml`): tag `v*` → GitHub Release notes from this file.
- Reference board-info for `hardware/boards/stm32-smoke` (documented template fields, **未上板**).
- Optional board pack template at `hardware/boards/_template/`.

### Changed

- README Quick start now references only the authoritative pin (no floating `@latest`).
- ROADMAP v0.2 items aligned with reproducible install + CI/CD/CT boundary.
- Version metadata bumped toward `0.2.0`.
- Profile/workbench dependency key corrected to GitHub package name `dsh-embedded-workbench`,
  pinned at tag `v0.9.1`. Upgraded from scaffold-declared `0.7.1` / scoped `@amethystluna/...`
  because tag `v0.7.1` fails pnpm peer resolve (`@deepseek-ai/dsh-type-meta` 404) against `dsh@0.2.0-rc.2`.

### Honesty / non-goals

- `flash.sh` / `rtt-smoke.sh` remain placeholders and may exit non-zero.
- No claim of on-hardware verification; label work without a probe as **未上板**.
- No invented compile/pass-rate metrics.

## 0.1.0 — 2026-09-14

### Added

- Initial public scaffold: `profiles/embedded-firmware`, kit bundle skills,
  Session Gate draft, STM32 smoke script placeholders, L1 eval stub.
