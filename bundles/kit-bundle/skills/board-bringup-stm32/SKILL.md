---
name: board-bringup-stm32
description: >-
  Use when bringing up or debugging the MVP STM32 board (clock, GPIO, UART/RTT,
  debug probe). Do NOT use for non-STM32 targets or pure application feature work
  unrelated to bring-up.
---

# STM32 板级 Bring-up（MVP 默认）

> 将本文 `TODO` 换成你们真实板号、芯片、时钟、引脚。

## 板卡事实（填写）

| 项 | 值 |
|----|-----|
| 板名 | `stm32-smoke`（占位） |
| MCU | TODO e.g. STM32F4xxxx |
| 调试口 | SWD · 探针 TODO |
| 控制台 | RTT（优先）/ UART TODO |
| 期望 smoke 字符串 | `SMOKE_OK` |

## 最小路径

1. 确认 `source toolchains/env.sh` 后 `arm-none-eabi-gcc -v` 可用。
2. 跑 `hardware/boards/stm32-smoke/scripts/build.sh`。
3. 有板时：`flash.sh` → `rtt-smoke.sh` 看到 `SMOKE_OK`。
4. 失败时：查供电、复位、探针连接、时钟源；再查链接地址与启动文件是否被改过。

## Agent 行为

- 没有探针/板时，只做到编译，并明确标注 **未上板**。
- 不主动 mass erase；需擦除时先征得用户确认。
- 改时钟/引脚前先读本 skill 与 `clock-and-boot`。
