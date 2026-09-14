# 威胁模型（摘要）

| 操作 | 默认 |
|------|------|
| 读寄存器 / 内存 / RTT | 允许 |
| 写内存 | 拒绝或地址白名单 |
| flash erase / program | 需确认；生产板默认禁止 Agent 擦写 |
| 改 linker / boot / option bytes | Plan mode + 人工 |
| 未知 blob 烧录 | 禁止 |
| 生产密钥 / 熔丝 | 永不进入 Agent 可写路径 |

配置落点：`hardware/embedded-debugger.toml` 的 `security.*` / `flash.*`。
