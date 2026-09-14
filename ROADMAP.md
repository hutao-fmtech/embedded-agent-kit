# Roadmap

## v0.1 — Kit skeleton (current)

- [x] Profile scaffold (`embedded-firmware`)
- [x] Kit bundle with starter skills (coding-standard, board-bringup-stm32, clock-and-boot, hardfault-playbook)
- [x] Localized Session Gate draft
- [x] STM32 smoke script placeholders
- [x] Eval L1 stub
- [ ] Public GitHub repo + CI that only checks skill frontmatter / shell scripts

## v0.2 — Reproducible install

- [ ] Documented pin of a known-good `dsh` rc
- [ ] One-command install script for workbench + kit skills
- [ ] `dsh --dump-config` / skill catalog smoke in CI (where runnable)
- [ ] Replace board TODOs with one **documented reference board** (still Cortex-M)

## v0.3 — Hardware loop

- [ ] First-class `embedded-debugger-mcp` wiring guide
- [ ] `flash.sh` / `rtt-smoke.sh` green on the reference board
- [ ] L3 eval case: fault → `diagnose_fault` evidence pack

## v0.4 — Multi-board without chaos

- [ ] Board pack layout (`hardware/boards/<id>/`) as a contribution template
- [ ] ESP32 / OpenOCD path as optional pack (not default)
- [ ] Skill trigger quality pass (reduce false activations)

## Explicitly not on the near roadmap

- Claiming a general “vertical coding agent product” that replaces Claude/Cursor
- Auto mass-erase or production fuse programming
- Supporting every IDE GUI (Keil µVision automation, etc.)
