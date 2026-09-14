# stm32-smoke（占位板）

填写真实硬件后删除「占位」字样。

| 项 | 值 |
|----|-----|
| MCU | TODO |
| Probe | TODO (ST-Link / J-Link / DAPLink) |
| RTT | 期望输出包含 `SMOKE_OK` |
| 工程路径 | TODO → 指向固件仓或本目录 `firmware/` |

## 脚本

- `scripts/build.sh` — 编译（当前为可运行的占位，检出工具链）
- `scripts/flash.sh` — 烧录（需 debugger MCP 或 probe-rs CLI）
- `scripts/rtt-smoke.sh` — 读 RTT 并检查 `SMOKE_OK`
