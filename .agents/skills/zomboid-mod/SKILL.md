---
name: zomboid-mod
description: Use when creating, editing, or debugging Project Zomboid mods in this repository.
---

# Project Zomboid Mod Workflow

Before editing:

1. Locate the relevant `mod.info`.
2. Inspect the target mod folder structure.
3. Check nearby files under `media/lua/client`, `media/lua/server`, `media/lua/shared`, and `media/scripts` when present.
4. Preserve existing naming, folder, and load-order conventions.

Implementation rules:

- Keep One Week To Live-specific code in `OWTL_` mod folders unless the user names another target.
- Do not edit third-party mod folders unless the user explicitly requests it.
- Use Project Zomboid's standard Lua and media layout.
- Keep changes narrow to the requested behavior.
- Avoid changing workshop metadata, posters, or vendored assets unless required.

Verification:

- Check `git status --short --branch`.
- If game visibility matters, verify the corresponding symlink in `/Users/tneary/Zomboid/mods`.
- Report any unverified in-game behavior directly.
