---
name: clock-and-boot
description: >-
  Use when changing clock tree, PLL, startup files, boot pins, or reset vector
  related code. Do NOT use for ordinary application logic that does not touch
  boot or clocks.
---

# 时钟与启动

## 红线

- 改 `system_*.c`、启动汇编、链接脚本、Boot 引脚逻辑前：**先说明风险与回滚方式，等确认**。
- 禁止在未验证的情况下「顺便」提高主频。
- 存储类产品注意上电时序与外部 Flash/电源轨稳定后再初始化。

## 工作步骤

1. 画出或引用当前时钟源（HSI/HSE/PLL）与总线频率表。
2. 列出将改动的寄存器/Cube 配置/文件。
3. 给出验证：启动是否到 `main`、RTT 是否刷出、看门狗是否误复位。
4. 若用户未确认，停留在计划，不写文件。
