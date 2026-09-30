# PRD：Embedded Agent Kit Roadmap v0.2

| 字段 | 内容 |
|------|------|
| **标题** | Embedded Agent Kit — 可复现安装与 CI/CD/CT 轻量闭环（Roadmap v0.2） |
| **版本** | PRD v0.2.1（相对 v0.2 增补 CI/CD/CT 边界）· 产品目标发布仍为 `0.2.0` |
| **状态** | Draft · Revised（补齐 CI/CD/CT）· Ready for Forge 实施（经 CoS 派发） |
| **仓库** | https://github.com/hutao-fmtech/embedded-agent-kit （MIT · public · default branch `main`） |
| **作者角色** | Product / CoS 规格起草（工程实现由 Forge 执行；本 PRD 不假设 Cursor Pro / Cloud Agents 已可用） |
| **调研基线** | main @ `6959e101`（2026-09-14 CST+8 初始 scaffold 提交）；无 open PR；无 GitHub Actions workflow；`ROADMAP.md` v0.2 条目 + README/architecture 对齐 |

---

## 1. 问题（Problem）

当前仓库是 **v0.1 scaffold**：已有 `profiles/embedded-firmware`、`bundles/kit-bundle` 四套 starter skills、Session Gate 文案草稿、`hardware/boards/stm32-smoke` 占位脚本、`eval/` L1 stub。但对「陌生人能否按 README 复现同一套 dsh + workbench + kit」这件事仍不成立：

1. **`dsh` 未钉死已知可用版本** — README / architecture 均要求 pin；仓库内尚无权威 pin 文件或安装路径记录。preview 期 floating `latest` 会破坏 profile/plugin 行为，属已知风险。
2. **安装路径是多步手工复制** — README 要求 `source toolchains/env.sh`、`dsh plugin add` workbench、`cp` kit skills 到 `.dsh/skills`；根 `package.json` 仅有 `skills:link` / `eval:l1`，无一键安装脚本。
3. **无 CI** — `list_workflows` 为空；`ROADMAP.md` v0.1 未完成项「Public GitHub repo + CI that only checks skill frontmatter / shell scripts」仍开着。skill 破 frontmatter 或脚本语法错误无人挡。
4. **参考板信息仍是 TODO 占位** — `stm32-smoke/README.md` 与 `board-bringup-stm32` skill 中 MCU / Probe / 工程路径均为 TODO；`flash.sh` / `rtt-smoke.sh` **故意 `exit 1`**。若在文档或营销里暗示「能上板验证」，会违反仓库诚实性原则（未上板须标注 **未上板**）。

v0.2 要解决的是：**可复现的安装与文档化的参考板信息模板 + 明确的 CI / CD / CT 边界**，而不是宣称硬件闭环已绿。真板上烟测（flash / RTT 全绿）与硬件-in-loop CT 明确推迟到后续（与 `ROADMAP.md` v0.3 对齐）。

---

## 2. 用户（Users）

| 用户 | 诉求 |
|------|------|
| **嵌入式固件工程师（主用户）** | 在本机用 `dsh` 跑一套可复现的 board-level agent 工作流：skills + Session Gate；无板时能诚实做到编译级协助。 |
| **内部 Agent / 平台维护者** | 钉版本、一键装、CI 拦住破 skill / 破脚本；不 fork `dsh` 核心。 |
| **开源贡献者** | 按模板补 board-info / skills / eval，不需要猜「哪块板才算官方」。 |
| **CoS / 产品负责人** | 用可检查的验收标准卡范围；防止膨胀成「垂直 coding-agent 产品」话术。 |

非用户（本版本不优化）：量产烧录产线、全 IDE GUI 自动化、无探针的「云端代跑真板」叙事。

---

## 3. 目标与非目标（Goals / Non-goals）

### Goals（v0.2）

1. **Pin 已知可用的 `dsh` 版本**（rc / 确切版本号），并在仓库内留下可审计的权威记录与安装命令。
2. **一键安装**：一条命令（或等价单一入口）完成 community `embedded-workbench` + 本仓 kit skills（及文档约定的 profile 挂载路径），可在干净环境复现。
3. **CI（持续集成）**：GitHub Actions 静态门禁（skill frontmatter + 关键 shell `bash -n`）+ 可选 dsh catalog 冒烟；**不要求** runner 接真板。
4. **CD（持续交付，最小）**：打 tag `v0.2.0`（或创建 GitHub Release）时自动生成 Release + 从 `CHANGELOG.md` 拉取说明；**不做** npm 强制 publish、不做硬件部署。
5. **CT（持续测试，有界）**：把现有 L1 eval stub（`npm run eval:l1` / `bash eval/runner.sh l1-compile-fix`）接入 CI：有 toolchain 则跑，无则显式 skip；硬件-in-loop CT 属 v0.3。
6. **文档化参考板信息**：把 `stm32-smoke`（或选定的单一 Cortex-M 参考板 id）从「空 TODO」提升为**可填写的权威 board-info 文档/模板**；诚实标明当前脚本仍为占位、**未上板**。
7. 保持产品定位：**开源可复现的 board-level agent workflow kit**，不是 hype 垂直 Agent 产品。

### Non-goals（v0.2 明确不做）

- **真板上烟测**：`flash.sh` / `rtt-smoke.sh` 在真实硬件上变绿（属 v0.3 / Hardware loop）。
- 接入并宣称 `embedded-debugger-mcp` 全链路可用（wiring guide 可预留链接，但非 v0.2 DoD）。
- L3 eval（fault → `diagnose_fault` evidence pack）。
- 多板 pack 贡献模板定稿（`ROADMAP.md` v0.4）、ESP32 / OpenOCD 默认路径。
- 发明或公布编译通过率、上板率、人工介入率等**未实测指标**。
- 完整 CD 平台（多环境 promote、自动 npm publish kit、镜像仓库、生产烧录流水线）。
- 硬件-in-loop / 探针 CT、L3 eval、定时大规模回归农场。
- 假设 Cursor Pro / Cloud Agents 已开通并用于本仓工程交付（见依赖与待决问题）。
- 声称替代 Claude/Cursor 或资深 FAE；自动 mass-erase / 生产熔丝。

---

## 4. 成功标准（Success criteria）

以下标准均可客观检查；**不含编造数字**。

| ID | 标准 | 如何验证 |
|----|------|----------|
| S1 | 仓库内存在权威 `dsh` pin（版本字符串 + 来源说明 + 安装/校验命令），且 README Quick start 只引导该 pin，不引导 floating latest | 文件存在；README 与 pin 文件一致；按文档在干净机安装后 `dsh --version`（或等价）与 pin 一致 |
| S2 | 存在单一安装入口（如 `scripts/install.sh` 或文档指定的 npm/dsh 命令），执行后 workbench + kit skills 按文档约定落位 | 干净 clone 后只跑该入口；技能目录或 `dsh` skill/catalog 检查可见 kit 四技能名 |
| S3 | CI 在 push/PR 到 `main`（及 PR）上运行且失败会挡合并（至少对 default branch PR） | `.github/workflows/*` 存在；对故意破坏的 frontmatter / `bash -n` 失败用例能红 |
| S4 | 参考板 board-info 文档/模板无「空 TODO 当作已接线板」的误导；明确 **未上板** / 占位脚本行为 | `hardware/boards/<id>/` 文档评审；`flash.sh`/`rtt-smoke.sh` 仍可诚实非零退出直至 v0.3 |
| S5 | `ROADMAP.md` v0.2 清单项与本 PRD 对齐并勾选或指向实现 PR；版本元数据可升至 `0.2.0`（或发布说明标明 0.2） | ROADMAP / CHANGELOG 或 GitHub Release 笔记 |
| S6 | 对外文案（README Status 段）仍诚实：不写「硬件闭环已验证」除非未来真板里程碑完成 | README diff 评审 |
| S7 | CD：存在 Release workflow（或文档化的等价流程），在 tag `vX.Y.Z` 时产出 GitHub Release，正文来自 `CHANGELOG.md`（或约定片段） | 推送测试 tag 或 workflow_dispatch 验证；Release 页可见 |
| S8 | CT：CI 含 L1 eval job；有 `arm-none-eabi-gcc`（或文档约定 toolchain）则执行，否则 job 显式 skip 且不伪装「测试已通过硬件」 | workflow 日志可见 run/skip 原因；故意破坏 L1 fixture 时（在有 toolchain 的 job 上）应变红 |

---

## 5. 范围（In / Out of scope for v0.2）

### In scope

| 项 | 说明（相对当前仓库事实） |
|----|--------------------------|
| dsh pin 文档与安装路径 | 新建权威 pin（建议 `docs/dsh-pin.md` 或 `versions.lock` / 等价）；更新 README Quick start |
| 一键安装脚本 | 封装：workbench 安装（scoped `@amethystluna/embedded-workbench`，当前 profile 钉 `0.7.1`）+ kit skills 链接/复制（可复用/扩展 `npm run skills:link`）+ 可选 profile 提示 |
| 轻量 CI | skill frontmatter（`name` + `description`）；对 `eval/`、`hardware/**/scripts/*.sh`、`toolchains/env.sh`、`scripts/**` 做 `bash -n`；可选 shellcheck（若镜像允许）；**不**跑真板 flash |
| CI 可运行时的 catalog/config 冒烟 | 若 pin 的 `dsh` 能在 GitHub-hosted runner 无交互安装：尝试 `dsh --dump-config` 或 skill 列表冒烟；**若 runner 无法装 dsh，则降级为文档化 skip + 仅静态检查**，并记入 Open Questions 结论 |
| 参考板 board-info | 充实 `hardware/boards/stm32-smoke/`（或更名后的单一参考 id）：模板字段填齐「如何填写」说明、期望 `SMOKE_OK`、脚本语义；可增加 `BOARD.md` / 模板副本供贡献 |
| 文档同步 | `ROADMAP.md`、`README.md` Status、必要时 `docs/architecture.md` 中与「Phase 0 钉扎 / 安装」冲突的过时表述 |
| CD（最小） | `.github/workflows/release.yml`（或等价）：`on: push: tags: ['v*']` → softprops/action-gh-release（或官方）+ `CHANGELOG.md`；可选手动 `workflow_dispatch` |
| CT（有界） | CI 增加 L1 eval job；toolchain 缺失则 `skip`；**禁止**把 `flash.sh`/`rtt-smoke.sh` 成功当作 CT 绿 |
| 诚实性 | Session Gate / skills 继续强调无板须标 **未上板**；不删除该红线 |

### Out of scope

- 将 `flash.sh` / `rtt-smoke.sh` / `build.sh` 接到真实固件树并在硬件上绿。
- `vendor/embedded-debugger-mcp` 作为默认必装依赖。
- 扩展 eval 黄金集规模或宣称 L1/L3 通过率。
- 新增大规模 org skills、多芯片默认支持。
- UI/TUI 产品化（`dsh-code` 可选提及但不交付）。
- 依赖 Cloud Agents 自动开 PR（可作为加速手段，**不是** v0.2 验收前提）。

---

## 6. 用户故事 / Jobs-to-be-done

1. **JTBD — 干净机复现**：作为固件工程师，我 clone 仓库后运行**一条**安装命令，即可在 pin 定的 `dsh` 上看到 workbench + kit skills，而无需拼多段 `npx`/`cp`。
2. **JTBD — 版本可审计**：作为平台维护者，我打开仓库内 pin 文件即可知道「已知可用」的 `dsh` 版本与校验方式，升级时有明确 diff 点。
3. **JTBD — 合并不踩雷**：作为维护者，我依赖 CI 拒绝缺 frontmatter 的 skill 或语法错误的 smoke/install 脚本。
4. **JTBD — 板信息可填**：作为贡献者/内部 FAE，我按参考板模板填写 MCU/探针/工程路径，而不把占位脚本误当成已验证硬件包。
5. **JTBD — 无板诚实**：作为使用者，Agent / 文档在无探针时明确 **未上板**，不会把 toolchain OK 说成 flash/RTT 已通过。

---

## 7. 功能需求（Functional requirements）

### FR-1 · Pin 已知可用 `dsh` 版本（一等公民）

1. 在仓库增加权威 pin 工件（单文件优先），至少包含：`dsh` 版本标识、获取方式（npm 包名 `@deepseek-ai/dsh` 等）、校验命令、已知限制（Developer Preview）、最后验证日期（真实日期，禁止虚构）。
2. README Quick start **仅**引用该 pin；禁止推荐未钉死的 `latest`。
3. `profiles/embedded-firmware` 与安装脚本所使用的 workbench 版本与现网一致处需写明（当前代码钉 `@amethystluna/embedded-workbench` **0.7.1**）；若升级须在同一变更中记录原因。
4. Pin 变更必须走 PR，并更新「已知破改 / 回归说明」小节（可短）。

### FR-2 · 一键安装（workbench + kit skills）

1. 提供 `scripts/install.sh`（或同等单一入口），在 POSIX bash 下可执行；支持从 repo root 调用。
2. 行为至少包括：
   - 检测或安装 pin 定的 `dsh`（策略写清：调用 `npx -p @deepseek-ai/dsh@<pin>` 或要求预装，二选一并在文档固定）；
   - 按 README/architecture 约定添加 `github:AmethystLuna/embedded-workbench`（依赖键必须为 scoped `@amethystluna/embedded-workbench`）；
   - 将 `bundles/kit-bundle/skills/*` 安装到项目 `.dsh/skills/`（可基于现有 `skills:link`）；
   - 打印下一步：如何 `source toolchains/env.sh`、如何开 session、如何跑 `bash eval/runner.sh l1-compile-fix`。
3. 安装脚本失败时非零退出，并给出可行动的错误信息（缺 Node、缺网络、plugin 失败等）。
4. **不**默认启用 flash erase / 拉取 debugger MCP 二进制（保持 SECURITY.md 姿态）。

### FR-3 · 轻量 CI / skill 检查

1. 新增 GitHub Actions workflow（例如 `.github/workflows/ci.yml`），触发：`pull_request`、`push` to `main`。
2. Job A — **静态**：
   - 枚举 `bundles/kit-bundle/skills/*/SKILL.md`，校验 YAML frontmatter 含非空 `name`、`description`；
   - 对约定 shell 脚本执行 `bash -n`（至少：`toolchains/env.sh`、`eval/runner.sh`、`eval/tasks/*/check.sh`、`hardware/boards/*/scripts/*.sh`、`scripts/install.sh`）。
3. Job B — **可选 dsh 冒烟**（best-effort）：若能按 pin 安装 `dsh`，则运行 `--dump-config` 或 skill catalog 类检查；不能则静态 job 仍必须绿，dsh job 可显式 `skip` 并在 workflow 注释 / docs 说明原因（勿假装通过硬件）。
4. CI **不得**要求连接调试探针或执行 `flash.sh` 成功。
5. L1 CT 与 Release CD 详见 **§7A**；本 FR 只定静态/dsh 冒烟底线。

### FR-4 · 参考板 board-info 文档与模板

1. 选定单一参考板目录（默认保留 `hardware/boards/stm32-smoke`，除非 Forge 实施时有已确认的真实板名——无则保持 id，强化模板）。
2. 文档须固定字段表：板名/id、MCU、Probe、调试口、控制台（RTT/UART）、期望 smoke 字符串（现为 `SMOKE_OK`）、固件工程路径约定、脚本说明。
3. 明确标注：`build.sh` 当前仅 toolchain probe；`flash.sh` / `rtt-smoke.sh` 为占位且非零退出；**未上板**。
4. 提供可复制的空模板（如 `hardware/boards/_template/` 或文档内模板区），供后续 board pack 使用；**不**要求本版本合并第二块板。
5. 同步 `board-bringup-stm32` skill 中的板卡事实表：与 board-info 一致，或显式写「以 `hardware/boards/.../README` 为准」。

### FR-5 · 文档与版本元数据

1. 更新 `ROADMAP.md` v0.2 复选框以反映实现状态（完成则勾选）。
2. 更新 README Status：明确 v0.2 = 可复现安装 + 轻量 CI + board-info 模板；硬件闭环仍属后续，标 **未上板**。
3. 可选：`CHANGELOG.md` 或 GitHub Release notes 标明 `0.2.0`；根/package 版本字段与之一致（若项目已有）。
4. 不引入未验证的采用率/通过率数字。

---

---


### FR-7 · CD：tag → GitHub Release（最小）

1. 根 `package.json` 为 `"private": true` 时，v0.2 CD **默认为 GitHub Release only**（git/workspace 安装路径），**不把 npm publish 当作 DoD**。
2. Workflow：`on.push.tags: ['v*']`（可选 `workflow_dispatch`）创建 GitHub Release；Release notes 来自 `CHANGELOG.md` 对应版本段落。
3. **不做**硬件部署、多环境 promote、强制 publish `@embedded-agent-kit/*`（若以后要 publish，另开范围）。

### FR-8 · CT：L1 进 CI（required-if-toolchain-available）

1. CI 必须包含 L1 步骤（`npm run eval:l1` 或 `bash eval/runner.sh l1-compile-fix`）。「L1 是否进 CI」已关闭为 **是**。
2. 策略优先 **required-if-toolchain-available**：检测到 `arm-none-eabi-gcc`（或文档约定等价物）则必须跑且失败挡该 job；缺失则显式 skip，日志说明，**skip ≠ 固件/上板通过**。
3. 待决仅剩：ubuntu-latest 是否 `apt`/action 预装 `gcc-arm-none-eabi` 以提高 L1 实际执行率（推荐实施时尽量预装，仍允许文档化 fallback skip）。
4. HIL / flash / RTT 成功不作为 CT 绿；推迟 v0.3，并在 ROADMAP 标明。

## 7A. CI / CD / CT 边界（本版一等公民）

> 本节回应「CI/CD/CT 都写了吗」：v0.2 **三者都定义**，但深度刻意收窄，避免把未上板仓库写成「已持续交付到硬件」。

### CI — Continuous Integration（必做）

> 建议（非硬 DoD）：`main` 开启 branch protection，要求静态 CI checks 通过后再合并。

| 项 | v0.2 要求 |
|----|-----------|
| 触发 | `pull_request`、`push` to `main` |
| 静态门禁（硬） | skill YAML frontmatter：`name` + `description` 非空；约定 shell 路径 `bash -n` |
| dsh 冒烟（软） | 能装 pin 定 dsh 则 `--dump-config` / skill 列表；否则显式 skip |
| 禁止 | 要求探针在线；要求 `flash.sh`/`rtt-smoke.sh` 退出码 0 |

### CD — Continuous Delivery（最小必做）

| 项 | v0.2 要求 |
|----|-----------|
| 触发 | 推送符合 `v*` 的 git tag（首选 `v0.2.0`）；可选 `workflow_dispatch` |
| 产物 | GitHub Release；Release body 从 `CHANGELOG.md` 对应版本段落提取（或整文件在首版可接受，但须文档约定） |
| 不做 | 自动 npm publish（根包 private；publish 另决策）；多环境 promote；向板卡/量产线部署 |
| 人工 | tag 由维护者在 CI 绿之后打；高风险合并仍人工（与迷你工程组织习惯一致） |

### CT — Continuous Testing（有界必做）

| 项 | v0.2 要求 |
|----|-----------|
| L1 | CI job 调用现有 `eval` L1 入口（`npm run eval:l1` 或 `bash eval/runner.sh l1-compile-fix`） |
| Toolchain | runner 无 `arm-none-eabi-gcc` 时 **skip** 并在日志写明；有则必须执行且失败挡 PR（对该 job） |
| 诚实性 | skip ≠ 宣称硬件验证通过；L1 仅覆盖「编译级 / fixture」能力，不覆盖上板 |
| 推迟到 v0.3 | 探针 HIL、RTT 断言、`embedded-debugger-mcp` 证据包、L3、夜间大规模回归 |

### 三者关系（一句话）

**CI 挡坏文档与坏脚本 → CT 在有工具链时挡 L1 回归 → CD 在版本 tag 时把可审计说明发到 GitHub Release。** 全程不假装未上板已绿。


## 8. 验收标准（Acceptance criteria）

- [ ] AC1：权威 dsh pin 文件合入；README Quick start 仅指向该 pin（S1）。
- [ ] AC2：`scripts/install.sh`（或文档单一入口）在干净环境按文档可完成 workbench + kit skills 落位（S2）；失败路径非零退出。
- [ ] AC3：`.github/workflows/` CI 对 PR/`main` 运行；故意坏 frontmatter 或坏 shell 可使静态检查失败（S3）。
- [ ] AC4：`stm32-smoke`（或选定 id）board-info 字段齐全；脚本语义与 **未上板** 标注正确；可选 `_template`（S4）。
- [ ] AC5：`ROADMAP.md` / README Status 与 v0.2 对齐；无「硬件已验证」误导（S5、S6）。
- [ ] AC6：SECURITY / Session Gate 红线未削弱（无默认 erase、无板须标 **未上板**）。
- [ ] AC7：Release/CD workflow 存在；对测试 tag 或 dispatch 能产出 GitHub Release（S7）。
- [ ] AC8：CI 含 L1 CT job（**required-if-toolchain-available**）；无 `arm-none-eabi-gcc` 则显式 skip（skip ≠ 固件/上板通过）；有则 L1 失败挡 job；HIL 推迟 v0.3（S8 / FR-8）。
- [ ] AC9：`CHANGELOG.md` 含 `0.2.0` 段落，可供 CD 引用。

---

## 9. 风险与依赖（Risks / Dependencies）

| 项 | 说明 | 缓解 |
|----|------|------|
| dsh Developer Preview 行为漂移 | pin 后仍可能因上游破改失效 | pin + 变更说明；CI 可选冒烟尽早暴露 |
| GitHub runner 无法装 dsh | Job B 冒烟不可用 | 静态检查为硬门禁；冒烟可 skip 并文档化 |
| 一键安装依赖 Node/网络 | 离线环境失败 | 文档写清前置条件；错误信息可行动 |
| Cursor Pro / Cloud Agents 未开通 | Forge 原计划用 Cloud Agent 交 PR | **本 PRD 不把 Cloud Agent 当验收前提**；可由 CoS/`gh` 本地路径或用户确认 Pro 后再派 Forge |
| 文档夸大硬件能力 | 违反产品诚实性 | S4/S6 强制评审；占位脚本保持非零退出 |
| workbench 0.7.1 与 dsh pin 不兼容 | 安装绿但 session 挂 | 安装后冒烟 + 已知限制小节 |

---

## 10. 待决问题（Open questions）

1. **权威 pin 的具体 `dsh` 版本字符串是多少？**（需在实施时实测选定，禁止虚构；记入 pin 文件「最后验证日期」。）
2. **安装策略**：强制预装 `dsh`，还是 `install.sh` 内用 `npx -p @deepseek-ai/dsh@<pin>`？
3. **CI Job B**：当前 runner 能否无交互安装 pin 定的 dsh？若否，正式裁定为 skip。
4. **参考板**：继续用 `stm32-smoke` 作为模板 id，还是已有真实板名可替换？（无真实板则保留 id + **未上板**。）
5. **交付路径**：用户确认 Cursor Pro 后由 Forge Cloud Agent 开 PR，还是授权 CoS/`gh` 本地实现并开 PR？
6. **CD 是否附带 npm publish？** 默认否；若要 publish `@embedded-agent-kit/bundle`，需另开一小段范围。
7. **L1 是否进 CI**：已关闭为 **是**（FR-8）。仍开：无 toolchain 时 skip，还是 ubuntu-latest 预装 `gcc-arm-none-eabi` 以提高执行率？（推荐预装 + fallback skip。）
8. **CD dry-run**：合并后是否先打 `v0.2.0-rc.1` 验证 Release workflow，再打 `v0.2.0`？

---

## 11. 建议里程碑（Milestones）

| 里程碑 | 内容 | 出口 |
|--------|------|------|
| M1 | dsh pin 文件 + README Quick start 对齐 | S1 |
| M2 | `scripts/install.sh` + skills 落位验证说明 | S2 |
| M3 | GitHub Actions 静态 CI（frontmatter + `bash -n`） | S3 静态部分 |
| M3b | L1 CT job（有 toolchain 跑 / 无则 skip）+ `CHANGELOG.md` | S8；AC9 |
| M3c | Release CD workflow（tag `v*` → GitHub Release） | S7 |
| M4 | board-info / `_template` + skill 交叉引用 + **未上板** 文案 | S4 |
| M5 | ROADMAP/README/版本元数据收尾；可选 dsh CI 冒烟或文档化 skip | S5、S6；打 `v0.2.0` tag 验证 CD |

建议单一实现 PR（或短 PR 链）覆盖 M1–M5（含 M3b/M3c）；真板 greening 与 HIL CT 不进本 PR。

---

## 12. 派发说明（给 CoS / Forge）

- **产品所有权**：Pulse（规格）；**工程实现**：Forge（经 CoS 派发）。
- **DoD**：满足 §8 验收清单；proof = PR diff + CI 绿（静态）+ 安装命令复述；无板处继续标 **未上板**。
- **禁止**：把 v0.3 硬件闭环塞进本 PR；发明指标；在聊天中索要 PAT。

---

*PRD 起草：Pulse · CoS 修订 v0.2.1 + Pulse delta 并入（FR-7/FR-8、private CD、CT 策略）· 2026-09-30（Asia/Shanghai）*
