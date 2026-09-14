---
name: hardfault-playbook
description: >-
  Use when investigating HardFault, MemManage, BusFault, UsageFault, stack
  overflow, or sudden reset on Cortex-M. Prefer with embedded-debugger diagnose_fault.
  Do NOT use for unrelated application bugs with a clean running target.
---

# HardFault 组织手册（Cortex-M）

## 标准动作

1. 停住目标（`halt`）。
2. 取证：`diagnose_fault`（CFSR/HFSR/MMFAR/BFAR + PC/SP/LR）——**只报告证据，不臆造根因**。
3. 有 ELF（带 debug）时：`unwind_exception`。
4. 对照本手册「常见模式」给出**假说排序**与下一次实验。

## 常见模式（按你们历史继续追加）

| 证据倾向 | 假说 | 下一步 |
|----------|------|--------|
| INVSTATE / 未对齐 Thumb | 函数指针/中断向量糟了 | 查向量表与编译选项 |
| PRECISERR + BFAR 有效 | 野指针写外设/空指针 | 查 BFAR 映射外设 |
| 栈指针近水位 | 栈溢出 / 深调用在 ISR | 加栈染色/加大栈并复现 |
| 仅任务上下文出错 | 竞态 / 未保护共享 | 查临界区 |

## 输出模板

- 原始寄存器摘要  
- Top 3 假说（标注置信度）  
- 建议的最小代码或实验  
- 是否已上板验证  
