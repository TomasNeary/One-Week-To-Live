# OWTL Debug Test Plan

## Purpose

This document lists practical Project Zomboid debug/admin commands and manual test cases for the One Week To Live modules in this repository:

- `Horde_Night/OWTL_BloodMoon`
- `Player/OWTL_Player`
- `Buildings/OWTL_Traps`
- `Bows/OWTL_Bows`

OWTL command names in this document are verified from local source. Vanilla Project Zomboid admin command availability and exact argument order can vary by build and server context; confirm in-game with `/help` before treating a command as authoritative.

## Test Setup

1. Launch a new disposable sandbox save with debug mode enabled.
   - Steam launch option: `-debug`
   - Dedicated/server tests: use an admin account and verify commands with `/help`.
2. Enable these mods:
   - `OWTL_BloodMoon`
   - `OWTL_Player`
   - `OWTL Zombie Traps`
   - `OWTL Crossbow Mod`
3. Verify local game mod visibility before testing:
   - `ls -la /Users/tneary/Zomboid/mods | rg 'OWTL|BloodMoon|Player|Traps|Bows'`
   - Current observation: `/Users/tneary/Zomboid/mods` contains `OWTL_Bows` and `OWTL_Traps`; `OWTL_BloodMoon` and `OWTL_Player` were not visible in the quick listing and should be linked or installed before in-game testing.
4. Recommended sandbox settings:
   - `OWTL_BloodMoon.Enabled = true`
   - `OWTL_BloodMoon.IntervalMode = Fixed`
   - `OWTL_BloodMoon.FixedInterval = 1`
   - `OWTL_BloodMoon.ServerHordeCap = 30` for smoke tests, then higher for stress tests
   - `OWTL_BloodMoon.GroupHordeCap = 20` for smoke tests
   - `OWTL_BloodMoon.DebugLogging = true`
   - `OWTL_Traps.PlayerDamageEnabled = true`
   - Test each `OWTL_Player.DeathDropMode`: Drop All, Drop Backpack Only, Keep Inventory
   - Test `OWTL_Player.DeathPenaltiesEnabled` both false and true
5. Keep logs open:
   - macOS game log directory is usually `~/Zomboid/console.txt` and `~/Zomboid/Logs/`.
   - Search logs for `[OWTL_BloodMoon]`, `OWTL_BloodMoon`, `OWTL_Player`, `OWTL_Traps`, and `OWTL_Bows`.

## Useful Debug And Admin Commands

### OWTL Blood Moon Commands

Enter these in chat as an admin or in single player. `/owtlbloodmoon` is also accepted as the command prefix.

| Command | Use |
| --- | --- |
| `/owtl help` | Print OWTL Blood Moon command help. |
| `/owtl status` | Print scheduler status, stage, next event, caps, and active horde counts. |
| `/owtl schedule` | Alias for status. |
| `/owtl active` | Print persisted active horde summaries and live registry report lines. |
| `/owtl hordes` | Alias for active horde status. |
| `/owtl force warning` | Force the one-day warning state. |
| `/owtl force start` | Start a Blood Moon immediately. |
| `/owtl force end` | End the current Blood Moon immediately. |
| `/owtl setstage <number>` | Set horde stage. Example: `/owtl setstage 3`. |
| `/owtl stage <number>` | Alias for setstage. |
| `/owtl reset` | Reset scheduler state and schedule the next event. |

### Vanilla Debug/Admin Aids

Use these to accelerate test setup. If a chat command fails, open the debug UI and perform the same action through the cheats/debug panels.

| Command or Tool | Use |
| --- | --- |
| `/help` | List server/admin commands available in the current build/context. |
| `-debug` launch option | Enables Project Zomboid debug tools and cheat panels. |
| Debug UI: time controls | Advance to warning/start/end windows without waiting. |
| Debug UI: item list | Spawn materials, weapons, arrows, magazines, food, medical items, and backpacks. |
| Debug UI: player stats/traits/skills | Set Carpentry, Aiming, Reloading, injuries, infection, fatigue, and XP for lifecycle tests. |
| Debug UI: god mode/invisible/no clip | Keep tester alive while validating hordes and trap behavior. |
| Debug UI: zombie population tools | Spawn or remove zombies near trap and horde test areas. |
| `/additem <user> <module.item> <count>` | Common admin form for adding test items. Confirm syntax with `/help`. |
| `/addxp <user> <perk>=<amount>` | Common admin form for granting skill XP. Confirm syntax with `/help`. |
| `/teleportto <x>,<y>,<z>` or debug teleport | Move to controlled test locations. Confirm syntax with `/help`. |
| `/godmod <user>` | Toggle invulnerability where available. Confirm exact spelling with `/help`. |
| `/invisible <user>` | Toggle zombie targeting where available. Useful for horde observation. |
| `/noclip <user>` | Toggle collision bypass where available. Useful for trapped/surrounded states. |
| `/createhorde <count>` | Spawn zombies where available. Useful for trap tests. |

Useful OWTL item full types:

| Item | Full Type |
| --- | --- |
| Basic Bow | `OWTLweapons.OWTL_BasicBow` |
| Improved Bow | `OWTLweapons.OWTL_ImprovedBow` |
| Basic Arrow | `OWTLweapons.OWTL_BasicArrow` |
| Improved Arrow | `OWTLweapons.OWTL_ImprovedArrow` |
| Broken Basic Arrow | `OWTLweapons.OWTL_BasicArrowBroken` |
| Broken Improved Arrow | `OWTLweapons.OWTL_ImprovedArrowBroken` |
| Bowyer Notes | `OWTLweapons.OWTL_BowyerNotes` |
| Simple Spiked Pit item | `Trap.OWTL_SimpleSpikedPit` |
| Dug Spiked Pit item | `Trap.OWTL_DugSpikedPit` |
| Spiked Log Barricade item | `Trap.OWTL_SpikedLogBarricade` |

## Acceptance Criteria

The mod passes manual debug validation when all criteria below are true:

- All enabled OWTL mods load without Lua errors on world start.
- `/owtl help`, `/owtl status`, `/owtl active`, `/owtl force warning`, `/owtl force start`, `/owtl force end`, `/owtl setstage <number>`, and `/owtl reset` work for admin/single-player testers.
- Non-admin multiplayer users cannot execute privileged OWTL Blood Moon commands and receive an admin access denial.
- Blood Moon warning, start, horde allocation, active reporting, end, and scheduler reset states are observable in-game and in logs when debug logging is enabled.
- Blood Moon stage advances after an event only when a horde group was allocated, spawned, or queued.
- Blood Moon horde zombies are capped by server/group settings, tagged as Blood Moon horde zombies, pursue valid players during the event, retarget when needed, and stop receiving OWTL tracking at dawn without despawning unrelated zombies.
- AEBS warning text appears only in the warning window, and start/end audio cues play without client errors.
- Player progression persists across death/respawn for skills, recipes, traits, and profession within Build 41 API limits.
- Infection is cleared on respawn.
- Each death drop mode behaves as configured.
- Optional death penalties apply only when enabled.
- `Set as Home` appears on sleepable objects, saves the home, and respawns the player at exact/nearby/fallback squares without violating safehouse permissions.
- Trap build menu entries appear with correct material, tool, recipe, and Carpentry requirements.
- Each OWTL trap can be built, consumes materials, awards intended Carpentry XP, records uses/condition modData, triggers on zombies, optionally triggers on players, decrements uses, deactivates at zero uses, and repairs to full uses.
- Basic bows/arrows are craftable from game start. Improved bow/arrows require `Bowyer Notes` and required Woodwork levels.
- Bows equip, render, load, fire, damage zombies, use quiet sound radii, degrade condition, and recover arrows from zombie corpses at plausible rates.
- No OWTL test produces recurring Lua stack traces in `console.txt`.

## Test Cases

### 1. Mod Loading And Baseline

Steps:

1. Start a fresh debug sandbox with all OWTL mods enabled.
2. Open the mod list and confirm the four OWTL mods are enabled.
3. Enter `/owtl help`.
4. Enter `/owtl status`.
5. Inspect `console.txt`.

Acceptance criteria:

- World loads to playable state.
- `/owtl help` prints the command list.
- `/owtl status` prints enabled state, active state, stage, next Blood Moon timing, caps, and horde counts.
- No OWTL Lua errors appear in the log.

### 2. Blood Moon Scheduler And Admin Commands

Steps:

1. Enter `/owtl reset`.
2. Enter `/owtl status` and record stage and next event values.
3. Enter `/owtl setstage 3`.
4. Enter `/owtl status`.
5. Enter `/owtl force warning`.
6. Enter `/owtl force start`.
7. Enter `/owtl active`.
8. Enter `/owtl force end`.
9. Enter `/owtl status`.

Acceptance criteria:

- Reset schedules a future event.
- Stage changes to `3`.
- Warning state is observable in status and/or AEBS test.
- Force start sets `isActive=true`, plays the start cue, and attempts horde allocation.
- Active report includes group/count lines or clear zero-count output if no valid player/spawn square exists.
- Force end sets `isActive=false`, plays the end cue, clears active registry, and schedules the next event.

### 3. Blood Moon Horde Spawn, Cap, And Pursuit

Steps:

1. Set server cap to `30` and group cap to `20`.
2. Move to an open outdoor area.
3. Enable god mode or invisible mode if needed for observation.
4. Enter `/owtl setstage 1`.
5. Enter `/owtl force start`.
6. Wait 30-60 seconds.
7. Enter `/owtl active`.
8. Move 40-80 tiles away and observe whether Blood Moon zombies continue to pursue or retarget.
9. Enter `/owtl force end`.
10. Observe remaining zombies after dawn/end.

Acceptance criteria:

- Spawned horde size does not exceed configured caps.
- Zombies spawn in plausible 60-100 tile bands where valid squares exist.
- Active report shows group summaries and active/queued counts.
- Horde zombies continue to pursue the target during the active event.
- End clears OWTL tracking/registry but does not delete unrelated zombies.

### 4. Blood Moon Warning Broadcast And Audio

Steps:

1. Enter `/owtl force warning`.
2. Use a radio tuned to AEBS/weather broadcast or advance broadcast timing through debug tools.
3. Verify warning copy mentions Blood Moon timing/stage/threat.
4. Enter `/owtl force start`.
5. Enter `/owtl force end`.

Acceptance criteria:

- Warning text appears during the warning window.
- Warning text does not appear outside the warning window after reset/end.
- Start cue maps to `OWTL_BloodMoonStartCue`; end cue maps to `OWTL_BloodMoonEndCue`.
- No client audio errors appear.

### 5. Multiplayer Admin Access And Player Grouping

Steps:

1. Start a local multiplayer or dedicated test server.
2. Log in as one admin and one non-admin.
3. As non-admin, enter `/owtl force start`.
4. As admin, enter `/owtl force start`.
5. Position two players within 100 tiles and repeat start.
6. Position two players more than 100 tiles apart and repeat start.
7. Have one player disconnect, die, or respawn during an active event.
8. Enter `/owtl active` after each transition.

Acceptance criteria:

- Non-admin command is denied.
- Admin command succeeds.
- Nearby players share a group; distant players form separate groups.
- Joiner/respawn notification can merge a player into the nearest active group within range.
- Death/disconnect causes retargeting to another valid player when one exists.

### 6. Player Progression Persistence

Steps:

1. Use debug tools to set non-default skills, XP, traits, known recipes, and profession.
2. Wait for at least one player update snapshot interval or force a controlled death after several seconds.
3. Kill the player using debug tools or a controlled zombie encounter.
4. Respawn.
5. Inspect skills, recipes, traits, profession, infection state, and logs.

Acceptance criteria:

- Skills and available partial XP are restored.
- Known recipes are restored.
- Traits and profession are restored where Build 41 runtime permits.
- Infection is reset to uninfected with zero infection level.
- No lifecycle stack traces occur.

### 7. Death Drop Modes

Run this case once for each `OWTL_Player.DeathDropMode`.

Steps:

1. Prepare a controlled inventory with a backpack, items inside the backpack, and items outside the backpack.
2. Set mode to Drop All.
3. Die and inspect corpse/respawn inventory.
4. Repeat with Drop Backpack Only.
5. Repeat with Keep Inventory.

Acceptance criteria:

- Drop All leaves vanilla corpse inventory behavior untouched.
- Drop Backpack Only preserves non-backpack item types on respawn and leaves backpack contents dropped.
- Keep Inventory restores retained item types on respawn.
- Known limitation is accepted: condition, nested contents, modData, and attachments may not survive because current code restores item full types only.

### 8. Death Penalties

Steps:

1. Set `OWTL_Player.DeathPenaltiesEnabled=false`.
2. Die and respawn.
3. Confirm no OWTL penalty is applied.
4. Set `OWTL_Player.DeathPenaltiesEnabled=true`.
5. Die and respawn several times.
6. Inspect body damage and stats after each respawn.

Acceptance criteria:

- Disabled setting applies no OWTL death penalty.
- Enabled setting applies one of: fracture, burn plus damage, severe pain, or fatigue/endurance penalty.
- Infection reset still occurs even when penalties are enabled.

### 9. Home Respawn

Steps:

1. Right-click a bed, cot, mattress, or sleepable object.
2. Select `Set as Home`.
3. Confirm player says `Home set. You will respawn here.`
4. Move away, die, and respawn.
5. Repeat with the exact square blocked if practical.
6. In multiplayer, repeat inside a safehouse where the player is allowed and not allowed.

Acceptance criteria:

- Context action appears only on sleepable objects.
- Home coordinates persist into player/global mod data.
- Respawn teleports to exact home square if valid.
- If exact square is invalid, nearby safe square is used.
- If safehouse permissions deny access, home set or respawn is blocked/falls back safely.

### 10. Trap Build Menu And Requirements

Steps:

1. Start with Carpentry 0 and no materials.
2. Right-click ground and inspect `Build OWTL Defenses`.
3. Use debug item tools or `/additem` to add required materials and tools.
4. Use debug skill tools or `/addxp` to reach required Carpentry.
5. Test each trap:
   - Simple Spiked Pit: `Base.Plank` x2, `Base.Nails` x4, hammer, saw, Carpentry 1.
   - Dug Spiked Pit: `Base.Plank` x4, `Base.Nails` x8, hammer, saw, shovel, Carpentry 2.
   - Spiked Log Barricade: `Base.Log` x2, `Base.Nails` x4, hammer, saw, Carpentry 2.
6. Verify natural unlock thresholds by setting Carpentry to 2, 3, and 4.

Acceptance criteria:

- Options appear in `Build OWTL Defenses`.
- Tooltips show missing/present materials, tools, Carpentry, recipe, uses, and damage.
- Options are disabled until requirements are met.
- Natural recipe grants occur at configured Carpentry thresholds.
- Built traps consume materials but keep tools.
- Built traps place a world item with `owtlTrapId`, uses, max uses, condition, active state, and square `OWTL_TrapPresent`.

### 11. Trap Trigger, Deactivation, Repair, And Player Damage

Steps:

1. Build one of each trap in a flat outdoor area.
2. Spawn or lure zombies across each trap.
3. Enter `/createhorde <count>` if available, or use debug zombie spawn tools.
4. Inspect trap uses after each trigger.
5. Walk the player across a trap with `OWTL_Traps.PlayerDamageEnabled=true`.
6. Repeat with `OWTL_Traps.PlayerDamageEnabled=false`.
7. Use repair materials:
   - Simple Spiked Pit: `Base.Plank` x1, `Base.Nails` x2.
   - Dug Spiked Pit: `Base.Plank` x2, `Base.Nails` x4.
   - Spiked Log Barricade: `Base.Log` x1, `Base.Nails` x2.
8. Repair a partially used trap.

Acceptance criteria:

- Zombie trigger reduces zombie health or kills zombie according to trap damage.
- Uses decrement exactly once per trigger window.
- Trap becomes inactive at zero uses and square trap presence clears.
- Player damage applies only when enabled.
- Repair consumes repair materials and restores full uses/active state.
- Multiplayer route through server commands works without duplicate triggers.

### 12. Bows: Crafting, Notes, And Item Availability

Steps:

1. Open crafting UI at game start.
2. Verify Basic Bow and Basic Arrows are visible/craftable once materials are present.
3. Verify Improved Bow and Improved Arrows are hidden or unavailable until learned.
4. Spawn or find `OWTLweapons.OWTL_BowyerNotes`.
5. Read Bowyer Notes.
6. Set Woodwork to required levels.
7. Craft Improved Bow and Improved Arrows.

Acceptance criteria:

- Basic recipes work without magazine unlock.
- Bowyer Notes teaches `Craft Improved Bow` and `Craft Improved Arrows (x5)`.
- Improved recipes enforce learned recipe and Woodwork requirements.
- Crafted item full types match OWTL item definitions.

### 13. Bows: Combat, Recovery, And Balance Smoke Test

Steps:

1. Spawn:
   - `OWTLweapons.OWTL_BasicBow`
   - `OWTLweapons.OWTL_BasicArrow` x20
   - `OWTLweapons.OWTL_ImprovedBow`
   - `OWTLweapons.OWTL_ImprovedArrow` x20
2. Test at Aiming 0, then at a higher Aiming level.
3. Fire at individual zombies and a small group.
4. Kill hit zombies and inspect corpse inventories.
5. Observe bow condition after repeated firing.
6. Compare noise response against a firearm if desired.

Acceptance criteria:

- Bows equip two-handed and use correct empty/drawn sprites.
- Firing consumes one arrow.
- Hits damage zombies and record recoverable arrow modData.
- Corpse inventory receives intact or broken arrows at plausible rates.
- Misses do not create ground recovery items.
- Bow sound attracts fewer zombies than firearms in practical observation.
- Improved bow performs better than Basic Bow without eclipsing firearms.

### 14. Integrated Blood Moon Defense Trial

Steps:

1. Build a small defended position with at least three OWTL traps.
2. Craft or spawn a Basic Bow and arrows.
3. Set `/owtl setstage 1`.
4. Enter `/owtl force start`.
5. Fight through the event using traps and bows.
6. Enter `/owtl active` during the event.
7. Enter `/owtl force end`.
8. Inspect logs, trap states, inventory, corpse arrow recovery, and scheduler status.

Acceptance criteria:

- Blood Moon starts and produces a manageable horde at smoke-test caps.
- Traps affect Blood Moon zombies and degrade predictably.
- Bow combat remains usable during the horde.
- Active report is coherent during combat.
- Force end cleans Blood Moon tracking and schedules the next event.
- No cross-module Lua errors occur.

## Regression Notes

- Keep this document aligned with source when OWTL command names or item full types change.
- Re-run tests after any changes to event registration, `sendClientCommand` modules, sandbox option names, or item script module names.
- Preserve third-party bundled mods during OWTL testing unless a specific compatibility issue is being tested.
