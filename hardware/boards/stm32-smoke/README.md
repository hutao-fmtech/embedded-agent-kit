# stm32-smoke — reference board pack (template / **未上板**)

> **Honesty:** This pack is the kit’s single Cortex-M **reference id** for documentation
> and contribution shape. Scripts are wired for a future real board; they are **not**
> a verified hardware bring-up. Until a maintainer replaces TODOs with a measured board
> and greens flash/RTT on hardware (roadmap v0.3), treat all claims as **未上板**.

## Board-info (authoritative fields)

| Field | Value | Notes |
|-------|-------|-------|
| Board id | `stm32-smoke` | Directory name under `hardware/boards/` |
| Board / product name | *fill when known* (placeholder) | e.g. Nucleo-F401RE — leave placeholder until real |
| MCU | *TODO — e.g. STM32F401RE* | Cortex-M family expected for MVP |
| Probe | *TODO — ST-Link / J-Link / DAPLink* | Prefer probe-rs compatible |
| Debug port | SWD (expected) | Confirm on schematic |
| Console | RTT (preferred) / UART *TODO* | |
| Expected smoke string | `SMOKE_OK` | `rtt-smoke.sh` must eventually grep this |
| Firmware project path | *TODO* → firmware repo or `firmware/` under this pack | Not wired in v0.2 |
| Status | **未上板** / placeholder scripts | Do not market as hardware-verified |

Copy this table into PRs that claim a real reference board; delete “placeholder”
wording only after on-hardware smoke is green.

## Scripts (semantics)

| Script | Behavior in v0.2 | Exit |
|--------|------------------|------|
| `scripts/build.sh` | Sources `toolchains/env.sh`; probes for `arm-none-eabi-gcc`. **No firmware tree build yet.** | `0` if toolchain present; `1` if missing |
| `scripts/flash.sh` | Placeholder. Does not program flash. Refuse mass-erase unless user confirms (future). | **`1` (intentional)** |
| `scripts/rtt-smoke.sh` | Placeholder. Does not attach RTT. | **`1` (intentional)** |

CI and CT **must not** treat flash/RTT exit `0` as a gate in v0.2.

## How to fill this pack (contributors)

1. Replace MCU / Probe / console / firmware path with facts from your schematic.
2. Point `build.sh` at your CMake/Make project; keep `SMOKE_OK` (or document a change).
3. Wire `flash.sh` / `rtt-smoke.sh` via probe-rs CLI or optional `embedded-debugger-mcp`
   (not a default install — see SECURITY.md).
4. Mark README status **未上板** until flash + RTT smoke pass on desk hardware.
5. For a new board id, start from `hardware/boards/_template/` instead of forking names silently.

## Cross-reference

Skill `board-bringup-stm32` should follow **this README** as the board-info source of truth.
