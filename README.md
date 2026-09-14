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
dsh (pinned)
 ├─ @amethystluna/embedded-workbench   # domain skills + first-step gate hook
 ├─ @embedded-agent-kit/bundle         # this repo’s skills + org red lines
 └─ optional: embedded-debugger-mcp    # probe-rs / OpenOCD loop
```

Design notes: [docs/architecture.md](docs/architecture.md) · threat model: [docs/threat-model.md](docs/threat-model.md) · roadmap: [ROADMAP.md](ROADMAP.md)

## Quick start

```bash
git clone <this-repo> && cd embedded-agent-kit
source toolchains/env.sh

# Community workbench (scoped name required; enables Session Gate injection)
npx -p @deepseek-ai/dsh dsh plugin --profile web add \
  "github:AmethystLuna/embedded-workbench"

# Kit skills (project-scoped, highest priority discovery)
mkdir -p .dsh/skills
cp -R bundles/kit-bundle/skills/* .dsh/skills/

# Sanity
bash eval/runner.sh l1-compile-fix
```

Then open a `dsh` session and ask: *What embedded / kit skills do you have?*

### Debugger (Phase 2)

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
| `profiles/embedded-firmware/` | Profile deps + gate override draft |
| `bundles/kit-bundle/skills/` | Kit skills (MIT) |
| `hardware/boards/stm32-smoke/` | Reference board pack **placeholder** |
| `toolchains/env.sh` | Toolchain probe |
| `eval/` | Golden-task stubs |
| `docs/` | Architecture & eval notes |

## Status

**Scaffold / v0.1.** Skills and scripts are real files; the STM32 smoke flash/RTT scripts intentionally exit non-zero until you wire a board. Treat hardware claims as unverified until Phase 0.3 in the roadmap is green.

## License

MIT — see [LICENSE](LICENSE). Upstream projects keep their own licenses — see [NOTICE](NOTICE).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Board packs and eval tasks are the highest-leverage PRs.
