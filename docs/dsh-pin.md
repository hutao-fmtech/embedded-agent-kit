# Authoritative `dsh` pin

| Field | Value |
|-------|-------|
| **Package** | `@deepseek-ai/dsh` |
| **Pinned version** | `0.2.0-rc.2` |
| **npm dist-tag at pin time** | `latest` / `next` both pointed at `0.2.0-rc.2` (do **not** install via floating `@latest` in docs or scripts) |
| **Registry** | https://www.npmjs.com/package/@deepseek-ai/dsh |
| **Source** | https://github.com/deepseek-ai/deepseek-harness |
| **Status** | Developer Preview — APIs may break between rc tags |
| **Last verified** | 2026-09-30 (Asia/Shanghai) |
| **Verified how** | `npx -y -p @deepseek-ai/dsh@0.2.0-rc.2 dsh --version` → `0.2.0-rc.2` on Node.js `v22.19.0` (linux-x64). Also confirmed `dsh --profile web --dump-config` exits 0 and prints the composed profile tree. |
| **Node requirement** | Runtime deps of this rc expect modern Node (observed `EBADENGINE` warnings under Node 20; use **Node ≥ 22.19** for install / CI smoke). |

## Install / check commands

```bash
# Prefer an exact pin — never recommend unpinned @latest in this kit.
npx -y -p @deepseek-ai/dsh@0.2.0-rc.2 dsh --version
# expect: 0.2.0-rc.2

npx -y -p @deepseek-ai/dsh@0.2.0-rc.2 dsh --profile web --dump-config >/dev/null
```

Or install globally / into a profile once Node ≥ 22.19 is available:

```bash
npm install -g @deepseek-ai/dsh@0.2.0-rc.2
dsh --version
```

## Companion pins (this kit)

| Component | Pin | Notes |
|-----------|-----|-------|
| Workbench | GitHub tag `v0.9.1` → package **`dsh-embedded-workbench@0.9.1`** | Install: `dsh plugin --profile web add "github:AmethystLuna/embedded-workbench#v0.9.1"`. Dependency key and `dsh.profile.bundles` entry must be `dsh-embedded-workbench` (not a floating main branch; main may be newer e.g. 0.9.x). Older kit docs mentioned `@amethystluna/embedded-workbench` — that scoped name is **not** on the public npm registry; use the GitHub package name above. |
| Kit bundle | this repo `@embedded-agent-kit/bundle` | Linked via `scripts/install.sh` / `npm run skills:link` into `.dsh/skills/`. |
| pnpm | required for `dsh plugin` | `scripts/install.sh` seeds profile `.npmrc` with `ignore-workspace-root-check=true` so pnpm can add into the profile workspace. |

| **Workbench upgrade note (v0.2)** | Profile previously declared `0.7.1` / scoped `@amethystluna/...`. Against `@deepseek-ai/dsh@0.2.0-rc.2`, GitHub tag `v0.7.1` fails pnpm resolve (`@deepseek-ai/dsh-type-meta` 404). Tag **`v0.9.1`** installs successfully as `dsh-embedded-workbench@0.9.1`. Version bump recorded here deliberately — not a silent float. |

## Known limitations / regression notes

- Harness is **Developer Preview**; bumping the pin requires a PR that updates this file, README Quick start, `scripts/install.sh`, and CI env.
- Node 20 runners may download the package but hit engine warnings; CI dsh smoke uses Node 22.
- Full interactive web/TUI sessions and workbench gate injection are **not** claimed verified in this pin entry — only CLI `--version` and `--dump-config` on the web profile template. Workbench plugin add was exercised with pnpm + `.npmrc` workaround against tag `v0.9.1`.
- `dsh plugin` may print success-looking exit codes while logging `plugin command failed` — `scripts/install.sh` treats those markers as failure.
- Changing this pin: open a PR, note prior version → new version, what broke / what was re-checked.

## How to re-verify

1. Use Node ≥ 22.19 and ensure `pnpm` is on `PATH`.
2. Run the install/check commands above; confirm stdout version equals the table.
3. Optionally: `bash scripts/install.sh` then ask a `dsh` session which embedded / kit skills are visible.
4. Update **Last verified** date only when steps actually ran (never invent dates or versions).
