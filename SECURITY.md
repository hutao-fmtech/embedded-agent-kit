# Security

## Hardware risk

This kit can drive debug probes and flash programming when you wire
`embedded-debugger-mcp` or similar tools. Defaults in this repo keep erase and
arbitrary memory write **off**.

Never point an agent with flash permissions at production devices or key
material.

## Reporting

If you find a safety issue in scripts, skill instructions, or suggested
configs (e.g. a path that enables mass erase by default), open a GitHub issue
with title prefix `[security]` or email the maintainers listed in the README
once the public repo is live.

Do not file public issues that include production keys, fuse maps, or customer
firmware blobs.
