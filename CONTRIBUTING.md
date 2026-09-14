# Contributing

Thanks for helping make board-level agent workflows reproducible.

## What we want

- Skills with clear `description` (include **Use when** and **Do NOT**)
- Board packs that a stranger can follow: chip, probe, build, expected RTT string
- Eval tasks with `brief.md` + `check.sh` + `rubric.md`
- Fixes that shrink “未上板却声称已验证” failure modes

## What we will reject

- Undocumented flash-erase defaults
- Skills that scrape opaque third-party “爆款” APIs or disable TLS verification
- Huge unrelated refactors
- Marketing claims (“10x agent”, “replaces FAE”) without a runnable check

## Dev loop

1. Fork and branch from `main`.
2. Edit skills under `bundles/kit-bundle/skills/`.
3. Run `bash eval/runner.sh l1-compile-fix` (toolchain may be required).
4. Open a PR with: what changed, how you verified, whether hardware was involved.

## Skill format

Agent Skills layout: `skills/<kebab-name>/SKILL.md` with YAML frontmatter `name` + `description`.
