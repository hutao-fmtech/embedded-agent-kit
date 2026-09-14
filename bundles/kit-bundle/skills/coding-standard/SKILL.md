---
name: coding-standard
description: >-
  Use when writing or reviewing embedded C/C++ firmware for Embedded Agent Kit users.
  Applies coding rules, logging, error codes, and concurrency constraints.
  Do NOT use for pure documentation edits or non-firmware host tools.
---

# Kit 嵌入式编码规范

## 强制

1. 优先静态分配；若必须动态分配，在 PR 说明里写明生命周期与失败路径。
2. ISR / 故障处理函数：禁止阻塞、禁止重活；只做置标志 / 环形缓冲投递。
3. 跨任务或 ISR↔任务共享数据：写明临界区（关中断 / 原子 / 队列），禁止「先写着再说」。
4. 公开 API 返回明确错误码；禁止吞掉 `HAL_*` / 驱动错误。
5. 日志带模块前缀；默认级别不刷屏；禁止在热路径 `printf` 大包。

## 命名（可按团队改）

- 文件：`module_subsystem.c` / `.h`
- 全局：`g_` 前缀慎用；优先文件静态 + 显式 accessor
- 宏：`MODULE_FOO`

## 改动检查清单

- [ ] 未擅自改启动文件 / 链接脚本
- [ ] 新中断处理符合 ISR 约束
- [ ] 有失败路径与超时（若涉及外设等待）
- [ ] 本地能 `build` 通过（或说明缺工具链）

## 输出

指出违规处 → 给最小补丁建议 → 列出建议验证方式（编译 / RTT / 上板）。
