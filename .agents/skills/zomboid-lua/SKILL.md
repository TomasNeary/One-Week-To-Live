---
name: zomboid-lua
description: Use when writing, reviewing, refactoring, or debugging Lua for Project Zomboid mods, including PZ Lua, Kahlua Lua, Zomboid Events, Zomboid mod structure, or Lua code under media/lua/client, media/lua/server, or media/lua/shared.
---

# Project Zomboid Lua

Use this skill for Project Zomboid mod Lua work in the Kahlua-based runtime used by the game.

## Primary Reference

Use the PZwiki Modding page as the primary online reference:

https://pzwiki.net/wiki/Modding

Do not hardcode a stale local copy of the wiki. Browse or fetch current PZwiki pages when exact API names, event signatures, object methods, or build-specific behavior matter.

When needed, pull current details and linked resources from the Modding page for:

- Lua API
- Lua objects
- Lua events
- Java objects
- JavaDocs
- Mod structure
- Game files
- Debug mode
- Startup parameters
- Decompiling game code

Prefer compatibility with the current Project Zomboid build unless the user specifies a target build.

## Kahlua Rules

- Treat the language as Lua 5.1-ish Kahlua, not modern Lua 5.4 or LuaJIT.
- Avoid Lua 5.2+ features unless verified in Project Zomboid/Kahlua.
- Do not assume standard Lua libraries are fully available.
- Add nil checks around game objects, player objects, inventory items, squares, cells, and Java-exposed objects.
- Be careful with Java object methods exposed to Lua; verify unfamiliar methods against current docs, JavaDocs, stubs, or game files.

## Mod Placement

- First inspect the existing mod structure and relevant `mod.info`.
- Inspect nearby files under `media/lua/client`, `media/lua/server`, `media/lua/shared`, and `media/scripts`.
- Identify whether code belongs in client, server, or shared before editing.
- Respect client/server/shared boundaries and multiplayer behavior.
- Prefer event-based integration via Project Zomboid `Events`.
- Make minimal changes consistent with the mod's existing style and naming patterns.

## Review Checklist

Look for:

- Wrong client/server/shared placement.
- Missing or incorrect `Events` registration.
- Global namespace pollution from undeclared or overly broad globals.
- Unsafe assumptions about player index, `getPlayer()`, local player availability, inventory, world objects, squares, cells, and Java object methods.
- Code that works in single-player but may fail in multiplayer, dedicated server, split-screen, or unloaded-world contexts.
- Use of Lua 5.2+ syntax or APIs that Kahlua may not support.

## Workflow

1. Inspect the mod folder, `mod.info`, and nearby Lua/script files.
2. Determine the correct runtime side: client, server, or shared.
3. Check PZwiki docs before using unfamiliar APIs, events, object methods, or build-sensitive behavior.
4. Implement the smallest clear change in the existing style.
5. When possible, suggest in-game verification using debug mode, startup parameters, logs, or targeted reproduction steps from current PZwiki guidance.

## LuaLS

- If the repository has LuaLS configuration, respect it.
- If not, suggest `.luarc.json` only when it would materially improve the task.
- PZ API stubs or definitions are useful when available.
- Do not invent exact stubs or signatures unless generated from verified docs, JavaDocs, current game files, or project-provided definitions.
