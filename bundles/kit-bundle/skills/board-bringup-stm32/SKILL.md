---
name: board-bringup-stm32
description: >-
  Use when bringing up or debugging the MVP STM32 board (clock, GPIO, UART/RTT,
  debug probe). Do NOT use for non-STM32 targets or pure application feature work
  unrelated to bring-up.
---

# STM32 板级 Bring-up（MVP 默认）

> **Board-info 以仓库文档为准：**
> [`hardware/boards/stm32-smoke/README.md`](../../../../hardware/boards/stm32-smoke/README.md)
> 下表为摘要；字段冲突时以该 README 为准。当前参考板为模板 id，**未上板**。

## 板卡事实（摘要）

| 项 | 值 |
|----|-----|
| 板名 / id | `stm32-smoke`（参考模板 id） |
| MCU | 见 board README（仍为待填 / TODO，直至真实板写入） |
| 调试口 | SWD · 探针见 board README |
| 控制台 | RTT（优先）/ UART — 见 board README |
| 期望 smoke 字符串 | `SMOKE_OK` |
| 状态 | **未上板**（`flash.sh` / `rtt-smoke.sh` 可为非零退出） |

## 最小路径

1. 确认 `source toolchains/env.sh` 后 `arm-none-eabi-gcc -v` 可用。
2. 跑 `hardware/boards/stm32-smoke/scripts/build.sh`（当前多为工具链探测）。
3. 有板且已接线时：`flash.sh` → `rtt-smoke.sh` 看到 `SMOKE_OK`。
4. 失败时：查供电、复位、探针连接、时钟源；再查链接地址与启动文件是否被改过。

## Agent 行为

- 没有探针/板时，只做到编译，并明确标注 **未上板**。
- 不主动 mass erase；需擦除时先征得用户确认。
- 改时钟/引脚前先读本 skill 与 `clock-and-boot`。
- 勿把 toolchain OK 或 L1 eval 说成 flash/RTT 已通过。
