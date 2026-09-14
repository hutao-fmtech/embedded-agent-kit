# Embedded Agent Kit — Architecture & Implementation Notes

版本：v0.1 · 日期：2026-09-13 · 状态：可开工草案  
底座：DeepSeek Harness (`dsh`, Developer Preview)  
垂直域：嵌入式固件 / 驱动 / RTOS（以 Cortex-M 为第一阶段）

---

## 0. 目标与非目标

### 目标（成功长什么样）

做一个 **可复现的嵌入式 Coding Agent 产品形态**：

1. 懂固件约束（ISR、并发、NVM、功耗、时序），不是通用 CRUD Agent。
2. 能在真实工程里改代码、编过、（有板时）烧录并做最小验证。
3. 危险操作（擦片、写 option bytes、改启动配置）默认需人工确认。
4. 以 **dsh profile + cord** 交付，可内部分发，不 fork dsh 核心。

### 非目标（第一阶段不做）

- 一统所有 IDE（Keil GUI 自动化、IAR 全链路）
- 全自动「无人工」量产烧录 / 标定
- 覆盖所有 MCU 厂商 SDK
- 承诺替代资深 FAE

---

## 1. 总体架构

```
┌─────────────────────────────────────────────────────────┐
│  入口：dsh web / dsh-code CLI / 项目内 one-shot           │
│  Profile: embedded-firmware                              │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│  dsh Runtime (Cordis)                                    │
│  · agent loop / session / permissions / sandbox          │
│  · tools: bash, fs, grep, plan-mode, subagent            │
│  · skills filesystem provider                            │
└─┬─────────────────┬──────────────────┬──────────────────┘
  │                 │                  │
  ▼                 ▼                  ▼
Bundle A          Bundle B           MCP / Tools
embedded-         your-org-          embedded-debugger
workbench         embedded           (probe-rs | OpenOCD)
(skills+gate)     (私有规范/板级)      flash / RTT / fault
```

### 分层职责

| 层 | 内容 | 谁维护 |
|---|---|---|
| Runtime | dsh 固定版本 pin | 平台组 |
| Community bundle | embedded-workbench（7 skills + session gate） | 上游 + 内部 fork 可选 |
| Org bundle | 芯片族、编码规范、BSP 地图、禁止事项、评审清单 | 你们 |
| Hardware loop | debugger MCP + 工具链 PATH + 板级脚本 | 嵌入式组 |
| Eval harness | 黄金任务集 + 是否编过/上板指标 | 你们 |

---

## 2. 技术选型与依赖

### 2.1 必选

| 组件 | 选择 | 备注 |
|---|---|---|
| Harness | `@deepseek-ai/dsh` **钉死某个 rc 版本** | preview 会破，禁止 floating latest |
| 领域 Skills 基座 | `@amethystluna/embedded-workbench` ≥ 0.7.1 | 官方 dsh.bundle；安装名必须带 scope |
| Plan 纪律增强 | 上游提到的 `logicprobe`（同作者，可选） | 无则 Gate 退化为人工确认 |
| 调试闭环 | `embedded-debugger-mcp` | probe-rs 默认；ESP/Xtensa 走 OpenOCD 后端 |
| 工具链（阶段 1） | `arm-none-eabi-gcc` 或厂商 CLI + CMake/Ninja | 优先 CLI，Keil 作二期 |
| 探针 | ST-Link / J-Link / DAPLink 之一 | 与 probe-rs 兼容优先 |

### 2.2 可选增强

- `dsh-code`：终端编码体验（TUI），与 web UI 共用同一 runtime
- 内部制品库镜像：把 bundle 发到私有 npm/git，离线可装
- CI：无板跑编译 + 静态检查；有板 runner 夜间跑 flash+RTT smoke

### 2.3 明确推迟

- Keil µVision GUI 驱动（可保留 `keil-mdk-build` skill 的 **命令行/工程文件** 路径）
- 多核异构（Cortex-A + M）一阶段不做

---

## 3. 仓库与目录设计

建议新建单仓（或 monorepo 子目录）：

```text
embedded-agent/
├── README.md
├── docs/
│   ├── architecture.md          # 本文精简版
│   ├── threat-model.md          # 擦片/写内存权限
│   └── eval-cases.md            # 黄金任务
├── profiles/
│   └── embedded-firmware/
│       ├── package.json         # dsh.profile.bundles
│       └── cordis.patch.yml     # 覆盖 gate / 权限
├── bundles/
│   └── org-embedded/            # 你们的垂直 bundle
│       ├── package.json         # dsh.bundle
│       ├── cordis.patch.yml
│       ├── lib/                 # 可选：gate 注入插件
│       └── skills/
│           ├── board-bringup-xxx/
│           ├── coding-standard/
│           ├── clock-and-boot/
│           └── hardfault-playbook/
├── toolchains/
│   └── env.sh                   # 导出 ARM GCC / cmake PATH
├── hardware/
│   ├── embedded-debugger.toml   # MCP 安全配置
│   └── boards/
│       └── stm32xxxx-smoke/
│           ├── README.md        # 接线、芯片 id、期望 RTT 输出
│           └── scripts/
│               ├── build.sh
│               ├── flash.sh
│               └── rtt-smoke.sh
├── eval/
│   ├── tasks/                   # 输入 brief + 期望检查脚本
│   └── runner.sh
└── vendor/                      # 可选：pin 的 workbench 子模块
```

---

## 4. Profile 组合（产品入口）

### 4.1 创建 profile

思路：基于 dsh **standard**（或 code）preset，叠加两个 bundle。

伪配置（以实际 `dsh plugin` / profile `package.json` 为准）：

```json
{
  "name": "embedded-firmware",
  "dependencies": {
    "@amethystluna/embedded-workbench": "0.7.1",
    "@your-org/org-embedded": "0.1.0"
  },
  "dsh": {
    "profile": {
      "bundles": [
        "@amethystluna/embedded-workbench",
        "@your-org/org-embedded"
      ]
    }
  }
}
```

安装社区包（文档原文）：

```bash
npx -p @deepseek-ai/dsh dsh plugin --profile web add \
  "github:AmethystLuna/embedded-workbench"
# 依赖键与 bundles 条目都必须是 @amethystluna/embedded-workbench
```

项目级 skills 快速试跑（不注入 gate）：

```bash
mkdir -p .dsh/skills
cp -r vendor/embedded-workbench/skills/* .dsh/skills/
```

验证：

```bash
dsh --profile embedded-firmware --dump-config
# 会话内问：你有哪些 embedded firmware skills？
# cordis_inspect_list / status 见 embedded-workbench enabled
```

### 4.2 Session Gate（必须保留并本地化）

workbench 会在 **每个 session 第一次 model step** 注入：

- 1% Rule（改动最小化）
- Red Flags（危险模式）
- Plan Verification Gate

你们应用 `cordis.patch.yml` **整表替换** `gateContent`（文档写明不 deep-merge），改成存储/嵌入式团队话术，例如：

- 禁止擅自改链接脚本 / 启动文件 / option bytes
- ISR 中禁止调用可能阻塞的 API
- 改并发共享数据必须说明临界区策略
- 无板验证时必须标注「未上板」

---

## 5. Skills 体系

### 5.1 直接复用（embedded-workbench）

| Skill | 用途 |
|---|---|
| `embedded-workbench` | 总工作流 / 多 agent 纪律入口 |
| `embedded-firmware-dev` | 固件开发通识 |
| `c-cpp-dev` | C/C++ 工程实践 |
| `keil-mdk-build` | Keil/ARMClang 构建相关 |
| `hardfault-triage` | HardFault 排查 |
| `state-machine-design` | 状态机设计 |
| `debug-methodology` | 调试方法 |
| `fact-check`（AmethystLuna 树） | 事实核对 |

说明：上游 4 个自定义 agent（steward/reviewer/…）**故意不迁到 dsh**；并行用 dsh 原生 `subagent` / `subagent_fork`，主模型兼 steward。

### 5.2 你们必须自建的 Org Skills（差异化）

| Skill | 触发 | 内容要点 |
|---|---|---|
| `coding-standard` | 改 C 文件前 | MISRA 子集、命名、日志、错误码、禁动态分配策略 |
| `clock-and-boot` | 改时钟/启动 | 板级时钟树、Boot 模式、和存储产品相关的上电时序 |
| `board-bringup-<chip>` | bring-up | 引脚、电源轨、调试口、最小 hello |
| `hardfault-playbook` | fault | 你们历史故障模式 → 检查清单（比通用 triage 更贴） |
| `storage-fw-domain`（可选） | 业务 | FTL/磨损/掉电保护等域知识（若做存储固件） |

Skill 格式遵循 Agent Skills：`skills/<name>/SKILL.md` + kebab-case `name` + `description`（含 Use when / NOT）。

### 5.3 Debugger Skill

把 `embedded-debugger-mcp` 的 `skills/embedded-debugger` 拷到：

- 项目 `.dsh/skills/`，或
- org bundle 的 `skills/`

工作流约定：先 `doctor` / `probes list`，再 MCP `connect`；崩溃：`halt` → `diagnose_fault` → `unwind_exception(elf_path)`。

---

## 6. 硬件闭环（阶段门槛）

### 6.1 MCP 接入

```bash
cargo build --release -C path/to/embedded-debugger-mcp
# 生成并收紧配置
embedded-debugger-mcp config generate > hardware/embedded-debugger.toml
```

安全默认：

- `flash.allow_erase` / `security.allow_flash_erase` = **false**（显式打开）
- `security.allow_memory_write` = false 或白名单区
- `security.allowed_file_paths` 仅工程 `build/` 与签名目录

dsh 侧：按 dsh 当前 MCP 接入方式注册 stdio server（preview 期查钉选版本的 docs；也可用 CLI 模式让 Agent 先跑 `embedded-debugger-mcp` 子命令）。

### 6.2 第一条板的 Smoke（DoD）

选 **一块** 团队最熟的板（建议 STM32 类 Cortex-M）：

1. `build.sh` 产出带 debug info 的 ELF  
2. `flash_program` 或 `run_firmware`  
3. RTT 读到约定字符串（如 `SMOKE_OK`）  
4. 人为制造 SoftFault/除零或断言 → `diagnose_fault` 能出 CFSR 证据包  

未达成前，不宣传「嵌入式 Agent 已可用」。

---

## 7. 权限与威胁模型（摘要）

| 操作 | 默认策略 |
|---|---|
| 读寄存器 / 读内存 / RTT | 允许 |
| 写内存 | 拒绝或白名单 |
| flash erase / program | 需用户确认；CI 板账号可例外 |
| 改 `.sct` / linker / bootloader | Plan mode + 人工 |
| 外网拉取未知 blob 烧录 | 禁止 |
| 生产密钥 / 熔丝 | 永不进入 Agent 可写路径 |

Session 轨迹（dsh Trajectory）保留：便于审计「谁让 Agent 擦了片」。

---

## 8. 实施路线图

### Phase 0 — 环境钉扎（3–5 天）

- [ ] 锁定 dsh 版本；记录安装命令与已知破改
- [ ] 装 workbench（Option D 优先）；验证 gate 注入
- [ ] 工具链 `env.sh`；无板编译通一个最小工程
- [ ] 写 `docs/architecture.md` 内部对齐

**出口**：会话能列出固件 skills，gate 文案已本地化。

### Phase 1 — Org Bundle MVP（1–2 周）

- [ ] 脚手架 `bundles/org-embedded`（package.json + cordis.patch.yml + 3 个 skills）
- [ ] profile `embedded-firmware` 同时挂 workbench + org bundle
- [ ] 选 5 个真实历史 PR/bug 做「仅改代码+编译」试跑，记失败模式
- [ ] 补 Red Flags（针对失败模式）

**出口**：无板场景下，常见驱动/任务改动可编译通过率可量化。

### Phase 2 — 上板闭环（1–2 周）

- [ ] 接入 debugger MCP；收紧 toml
- [ ] 单板 smoke 全绿
- [ ] HardFault 演练任务进 `eval/tasks`
- [ ] 危险工具二次确认话术写进 gate / skill

**出口**：至少一个「编译→烧录→RTT/fault」自动或半自动任务通过。

### Phase 3 — Eval 与产品化（持续）

- [ ] 黄金集 ≥ 20：bring-up、竞态、栈、NVM 掉电、状态机、构建修复
- [ ] 指标：编译通过率、上板 smoke 率、人工接管率、危险操作误触率
- [ ] 内部分发：私有 registry 或 `dsh plugin add git+ssh://...`
- [ ] （可选）dsh-code 作为默认工程师入口

---

## 9. 评测设计（避免自嗨）

每个 eval case 包含：

1. `brief.md`：用户语气任务书  
2. `repo/` 或 patch 基线  
3. `check.sh`：编译 / 单测 /（可选）RTT grep  
4. `rubric.md`：允许的改动范围、禁止触碰路径  

分级：

- L1 静态：只改文件 + 编译  
- L2 逻辑：主机上的单元/模拟（若有）  
- L3 硬件：smoke / fault  

周报只看：**L1 通过率、L3 通过率、平均人工介入次数**。

---

## 10. 团队分工建议

| 角色 | 职责 |
|---|---|
| Agent 平台 | dsh 版本、profile、权限、分发 |
| 资深固件 | Org skills、gate 文案、eval 命题 |
| 工具链/CI | 编译镜像、有板 runner |
| 安全 | 擦写策略、密钥隔离 |

CoS / 你：定成功标准、卡 Phase 出口、防止范围膨胀到「支持所有芯片」。

---

## 11. 风险与缓解

| 风险 | 缓解 |
|---|---|
| dsh preview API 破碎 | 钉版本；bundle 做薄；CI 每周 smoke 装一次 |
| 无板幻觉 | 强制「未验证」标签；L3 任务才算产品完成 |
| 探针/权限事故 | 默认关 erase；allowed_file_paths；双人确认生产板 |
| Skill 太多误触发 | description 写清 NOT；门禁 skill 按任务加载 |
| 与 Cursor/云端 Agent 重复建设 | dsh 负责「本机+板子」；云端负责大仓重构——接口用同一套 skills 文档，不抢同一闭环 |

---

## 12. 第一周执行清单（可直接派活）

1. Pin `dsh` rc 版本，装 web profile。  
2. `dsh plugin add github:AmethystLuna/embedded-workbench`，确认 `@amethystluna/...` 命名。  
3. 覆盖 `gateContent` 为团队红线。  
4. 拉 `embedded-debugger-mcp`，`doctor` + `probes list`。  
5. 选定唯一 MVP 板型，写 `hardware/boards/.../README.md`。  
6. 建 `org-embedded` 空 bundle + `coding-standard` + `board-bringup` 两个 skill。  
7. 跑 3 个内部 bug 的 L1 试写，开会只看「哪条 Red Flag 没挡住」。  

---

## 13. 决策记录（建议确认）

- [ ] MVP 芯片/板型：________  
- [ ] 工具链：GCC / ARMClang / 厂商 SDK CLI：________  
- [ ] 是否 fork workbench 还是 upstream + org bundle：建议 **upstream + org**  
- [ ] 生产板是否允许 Agent 擦写：建议 **否**  
- [ ] 模型路由：DeepSeek 官方 API / 其它：________  

---

## 参考链接

- DeepSeek Harness：https://deepseek.com/harness/en/  
- deepseek-harness 源码：https://github.com/deepseek-ai/deepseek-harness  
- embedded-workbench：https://github.com/AmethystLuna/embedded-workbench  
- 安装说明：仓库内 `.dsh/INSTALL.md`  
- embedded-debugger-mcp：https://github.com/Adancurusul/embedded-debugger-mcp  
- dsh-code（可选 TUI）：https://github.com/UNLINEARITY/dsh-code  
