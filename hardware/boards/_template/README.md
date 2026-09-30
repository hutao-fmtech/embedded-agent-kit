# Board pack template

Copy this directory to `hardware/boards/<your-board-id>/` and fill every field.
Until hardware smoke is green, keep status **未上板**.

## Board-info

| Field | Value |
|-------|-------|
| Board id | `<your-board-id>` |
| Board / product name | |
| MCU | |
| Probe | ST-Link / J-Link / DAPLink / other: |
| Debug port | SWD / JTAG / other: |
| Console | RTT / UART (port, baud): |
| Expected smoke string | `SMOKE_OK` (or document replacement) |
| Firmware project path | |
| Status | **未上板** |

## Scripts

Provide `scripts/build.sh`, `scripts/flash.sh`, `scripts/rtt-smoke.sh`.

- `build.sh` — compile firmware (or clearly document toolchain-only probe).
- `flash.sh` — program device; default **no** mass-erase; non-zero until wired.
- `rtt-smoke.sh` — assert expected smoke string; non-zero until wired.

See `hardware/boards/stm32-smoke/README.md` for the kit reference example.
