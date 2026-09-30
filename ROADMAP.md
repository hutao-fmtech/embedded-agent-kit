# Roadmap

## v0.1 — Kit skeleton

- [x] Profile scaffold (`embedded-firmware`)
- [x] Kit bundle with starter skills (coding-standard, board-bringup-stm32, clock-and-boot, hardfault-playbook)
- [x] Localized Session Gate draft
- [x] STM32 smoke script placeholders
- [x] Eval L1 stub
- [x] Public GitHub repo + CI that only checks skill frontmatter / shell scripts

## v0.2 — Reproducible install + CI/CD/CT boundary (current)

- [x] Documented pin of a known-good `dsh` rc (`docs/dsh-pin.md` → `@deepseek-ai/dsh@0.2.0-rc.2`)
- [x] One-command install script for workbench + kit skills (`scripts/install.sh`)
- [x] `dsh --dump-config` / skill catalog smoke in CI (where runnable; skip-ok if not)
- [x] Replace board TODOs with one **documented reference board** template (`stm32-smoke` + `_template`; still **未上板**)
- [x] CI static gate + bounded L1 CT (toolchain skip-ok)
- [x] Minimal CD: tag `v*` → GitHub Release from `CHANGELOG.md`

## v0.3 — Hardware loop

- [ ] First-class `embedded-debugger-mcp` wiring guide
- [ ] `flash.sh` / `rtt-smoke.sh` green on the reference board
- [ ] L3 eval case: fault → `diagnose_fault` evidence pack
- [ ] Hardware-in-the-loop CT (probe required)

## v0.4 — Multi-board without chaos

- [ ] Board pack layout (`hardware/boards/<id>/`) as a contribution template (seeded by `_template` in v0.2)
- [ ] ESP32 / OpenOCD path as optional pack (not default)
- [ ] Skill trigger quality pass (reduce false activations)

## Explicitly not on the near roadmap

- Claiming a general “vertical coding agent product” that replaces Claude/Cursor
- Auto mass-erase or production fuse programming
- Supporting every IDE GUI (Keil µVision automation, etc.)
- Inventing compile/pass-rate metrics without measurement
