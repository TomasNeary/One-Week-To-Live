# Repository Explanation

## Overview

This repository is a Project Zomboid mod workspace for **One Week To Live**.

The root `README.md` describes the project as:

> One Week To Live - Zomboid mod - 7DTD

The repository is organized as a collection of Project Zomboid mod folders grouped by gameplay area. Most folders are bundled third-party mods or source mods used as references. The One Week To Live-specific work is currently concentrated in folders prefixed with `OWTL_`.

## Top-Level Layout

- `Buildings/` contains trap, crafting, and build-menu related mods.
- `Bows/` contains crossbow and bow-related mods.
- `Horde_Night/` contains horde and helicopter-event related mods.
- `Zombies/` contains zombie behavior mods.
- `Guns/` contains firearm-related mods.
- `Weapons/` contains melee/scrap weapon mods.
- `Vehicles/` contains vehicle mods and vehicle sound/maintenance changes.
- `QoL/` contains quality-of-life mods such as minimap, sorting, display bars, coordinate display, and recycling recipes.
- `.agents/` contains repository-local Codex skills.
- `.codex/` contains repository-local Codex rules.

## One Week To Live-Specific Mods

### `Buildings/OWTL_Traps`

`Buildings/OWTL_Traps/mod.info` defines:

- `name=OWTL Zombie Traps`
- `id=OWTL Zombie Traps`
- `description=Adds traps you can set on the ground that will injure zombies, based on the mod and fix by X and Y.`

Observed files:

- `media/scripts/traps.txt`
- `media/lua/client/traps.lua`
- `media/lua/client/Window.lua`
- `media/lua/server/TrapServer.lua`
- `media/lua/server/Loading.lua`
- trap textures under `media/textures/`
- trap sounds under `media/sound/`

Observed behavior:

- Defines trap items: `PropaneTrap`, `BearTrap`, `BearTrapClosed`, `SpikeTrap`, `SpikeTrapClosed`, and `Nothing`.
- Defines recipes for setting traps, opening bear traps, making spike traps, adding nails to spike traps, and crafting propane bomb traps.
- Client logic checks player squares for trap mod data and applies trap effects.
- Server logic receives `Trap` client commands and synchronizes trap state on world squares and world items.

Notable observation:

- `media/scripts/traps.txt` contains two recipes named `Add Nails to Spike Trap`. They are nearly duplicated, but one includes `Sound:PZ_Hammer`.

### `Bows/OWTL_Bows`

`Bows/OWTL_Bows/mod.info` defines:

- `name=OWTL Crossbow Mod`
- `id=OWTL Crossbow Mod`
- `description=This is a Modified version of Kitsune's Crossbow Mod and Tweaked Kitsune's Crossbow Mod for the OWTL Mod`

Observed files:

- bow and crossbow textures under `media/textures/`
- bow and crossbow models under `media/models_x/`
- weapon sounds under `media/sound/`
- client Lua file `media/lua/client/Zed_Back_Spawn.lua`

Observed behavior:

- Adds attached weapon definitions for bows and crossbows on zombie backs.
- Uses `AttachedWeaponDefinitions`.
- Adds staged spawn chances based on `daySurvived`, including day 7, day 14, and day 21 entries.

Notable observation:

- `Zed_Back_Spawn.lua` references `OWTLweapons.OWTL_Compound03`, but the inspected file list did not show the corresponding weapon script in `Bows/OWTL_Bows` within the shallow file scan. This may be defined elsewhere or may need verification before relying on it in-game.

### `Horde_Night/OWTL_Horde_Night`

Observed files:

- `NocturnalZombiesServer.lua`

Observed behavior:

- Provides server-side zombie movement logic based on nearby players and time of day.
- Pulls or redirects zombies within configured distance bands.
- Applies additional zombie speed during deep night through `zombie:setSpeedMod`.
- Registers an `Events.OnClientCommand` handler for module `NocturnalZombies` and command `ScatterZombies`.

Notable observation:

- This folder does not currently contain a `mod.info` file in the inspected repository state. As-is, it does not appear to be a complete standalone Project Zomboid mod folder.

## Bundled Or Reference Mods

The repository includes many non-OWTL mod folders, including:

- `Bows/Remastered Kitsune's Crossbow Mod`
- `Buildings/PlayerTraps`
- `Buildings/Nolan's Traps Updates`
- `Buildings/CraftHelper41`
- `Buildings/Improved Build Menu [Build 41.51+] (basic)`
- `Buildings/Improved Build Menu [Build 41.51+] (no itemtweak)`
- `Horde_Night/Expanded Helicopter Events`
- `Zombies/nocturnal zombies`
- `Zombies/NocturnalZombiesFixed`
- `Zombies/RestlessZombiesFixed`
- `Zombies/dynamic zombies`
- `Zombies/Night Sprinters`
- `Guns/Scrap Guns`
- `Guns/Silencer`
- `Weapons/Scrap Weapons`
- `Vehicles/FR_Used_Vehicles/*`
- `Vehicles/New Car Sounds`
- `Vehicles/EasyEngineRebuild`
- `QoL/*`

These should be treated as bundled third-party or reference mods unless a task explicitly names one for editing.

## Project Zomboid Conventions Used

The repository follows standard Project Zomboid mod layout patterns:

- `mod.info` at the mod folder root.
- `poster.png` at the mod folder root when present.
- `media/lua/client/` for client Lua.
- `media/lua/server/` for server Lua.
- `media/lua/shared/` for shared Lua or translations when present.
- `media/scripts/` for item and recipe scripts.
- `media/textures/` for item and UI textures.
- `media/sound/` for audio assets.
- `media/models_x/` for model assets.

## Maintenance Notes

- Prefer new One Week To Live work under an `OWTL_` folder.
- Inspect the relevant `mod.info` before editing any mod folder.
- Inspect nearby `media/lua/client`, `media/lua/server`, `media/lua/shared`, and `media/scripts` files before adding or changing code.
- Do not edit bundled third-party mods unless the task explicitly names them.
- Verify local game behavior against symlinked mod paths under `/Users/tneary/Zomboid/mods` when game visibility matters.

## Current Git Observation

At inspection time, `git status --short --branch` reported:

```text
## main...origin/main
?? .agents/
?? .codex/
?? AGENTS.md
```

This explanation file is new and was created after that status check.
