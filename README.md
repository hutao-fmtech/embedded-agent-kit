# Embedded Agent Kit

**Open-source kit to run a reproducible embedded firmware coding agent on [DeepSeek Harness (`dsh`)](https://github.com/deepseek-ai/deepseek-harness).**

Not another “vertical Agent” pitch deck. This repo ships the **boring parts that make board work real**:

- a pin-able `dsh` profile composition  
- installable **Agent Skills** + a Session Gate (red lines for ISR / flash / linker)  
- wiring notes for a debug MCP  
- a **single-board smoke** path (build → flash → RTT / fault) you can actually fail CI on  

Default MVP target: **Cortex-M / STM32 + `arm-none-eabi-gcc`**. Other boards belong in `hardware/boards/<id>/` packs.

## Why this exists

Generic coding agents write C. Embedded work dies on **verification** and **discipline** (startup files, flash erase, “I didn’t run it on hardware”).  

Embedded Agent Kit optimizes for:

1. **Reproducibility** — a stranger can follow the README  
2. **Honesty** — skills must say 未上板 when there is no probe  
3. **Composability** — community [`embedded-workbench`](https://github.com/AmethystLuna/embedded-workbench) + this kit bundle + optional [`embedded-debugger-mcp`](https://github.com/Adancurusul/embedded-debugger-mcp)

## Architecture

```text
dsh (pinned — see docs/dsh-pin.md)
 ├─ dsh-embedded-workbench (@v0.9.1)   # domain skills + first-step gate hook
 ├─ @embedded-agent-kit/bundle         # this repo’s skills + org red lines
 └─ optional: embedded-debugger-mcp    # probe-rs / OpenOCD loop
```

Design notes: [docs/architecture.md](docs/architecture.md) · threat model: [docs/threat-model.md](docs/threat-model.md) · roadmap: [ROADMAP.md](ROADMAP.md) · **dsh pin**: [docs/dsh-pin.md](docs/dsh-pin.md)

## Quick start

Requires **Node.js ≥ 22.19** (see pin doc). Do **not** install a floating `dsh@latest`.

```bash
git clone https://github.com/hutao-fmtech/embedded-agent-kit.git
cd embedded-agent-kit

# One-shot: check pinned dsh + add workbench + link kit skills
bash scripts/install.sh

source toolchains/env.sh

# Sanity (needs arm-none-eabi-gcc on PATH)
bash eval/runner.sh l1-compile-fix
```

Authoritative pin (version string, verify commands, known limits): **[docs/dsh-pin.md](docs/dsh-pin.md)**.  
Current pin: `@deepseek-ai/dsh@0.2.0-rc.2`. Companion workbench: `dsh-embedded-workbench@0.9.1` via `github:AmethystLuna/embedded-workbench#v0.9.1`.

Manual equivalent (if you skip the script):

```bash
# Exact pin only — never recommend unpinned @latest here
npx -y -p @deepseek-ai/dsh@0.2.0-rc.2 dsh --version

npx -y -p @deepseek-ai/dsh@0.2.0-rc.2 dsh plugin --profile web add \
  "github:AmethystLuna/embedded-workbench#v0.9.1"

npm run skills:link   # or: mkdir -p .dsh/skills && cp -R bundles/kit-bundle/skills/* .dsh/skills/
```

Then open a `dsh` session and ask: *What embedded / kit skills do you have?*

### Debugger (optional / later)

Not part of the default install. Flash erase stays off — see [SECURITY.md](SECURITY.md).

```bash
git clone https://github.com/Adancurusul/embedded-debugger-mcp.git vendor/embedded-debugger-mcp
(cd vendor/embedded-debugger-mcp && cargo build --release)
./vendor/embedded-debugger-mcp/target/release/embedded-debugger-mcp doctor
./vendor/embedded-debugger-mcp/target/release/embedded-debugger-mcp config generate \
  > hardware/embedded-debugger.toml
# Keep allow_flash_erase / allow_memory_write false until you mean it.
```

## Repository layout

| Path | Role |
|------|------|
| `docs/dsh-pin.md` | Authoritative `dsh` version pin |
| `scripts/install.sh` | One-shot workbench + kit skills install |
| `profiles/embedded-firmware/` | Profile deps + gate override draft |
| `bundles/kit-bundle/skills/` | Kit skills (MIT) |
| `hardware/boards/stm32-smoke/` | Reference board pack (**未上板** template) |
| `hardware/boards/_template/` | Empty board pack template for contributors |
| `toolchains/env.sh` | Toolchain probe |
| `eval/` | Golden-task stubs (L1 CT in CI when toolchain present) |
| `.github/workflows/` | CI (static + optional dsh/L1) · CD (tag → Release) |
| `docs/` | Architecture, eval notes, PRD |

## Status

**v0.2.0 — reproducible install + lightweight CI/CD/CT.**  

- Pin + `scripts/install.sh` + static CI + Release-on-tag + L1 CT (skip if no `arm-none-eabi-gcc`).  
- Reference board-info is documented; **STM32 smoke flash/RTT scripts intentionally exit non-zero**.  
- **Hardware loop is not verified.** Label any work without a probe as **未上板**.  
- No invented pass-rate metrics.

See [CHANGELOG.md](CHANGELOG.md) and [ROADMAP.md](ROADMAP.md).

## License

MIT — see [LICENSE](LICENSE). Upstream projects keep their own licenses — see [NOTICE](NOTICE).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Board packs and eval tasks are the highest-leverage PRs.
