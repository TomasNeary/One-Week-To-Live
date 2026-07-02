# One Week To Live Build TODO

This document breaks the gameplay plan into implementation tasks that Codex can pick up one at a time.

Rules for all tasks:

- Keep One Week To Live code in OWTL-prefixed mod folders.
- Before editing a mod folder, inspect its `mod.info` and nearby `media/lua/client`, `media/lua/server`, `media/lua/shared`, and `media/scripts` files.
- Do not edit bundled third-party mods unless explicitly requested.
- Treat external mods as references only.
- Record unresolved design questions instead of filling gaps with guesses.

Primary planning references:

- `docs/GAMEPLAY_PLAN.md`
- `docs/EXTERNAL_MODS.txt`
- `docs/IMPLEMENTATION_PLAN.md`

Resolved planning decisions:

- Target Project Zomboid version is Build 41.
- Create a clean new `Horde_Night/OWTL_BloodMoon` module for core Blood Moon systems.
- Blood Moon module id/display name target is `OWTL_BloodMoon` / `OWTL Blood Moon`, pending conflict check.
- Create a clean new `Player/OWTL_Player` support module for persistent character, death drops, death penalties, and bed/home respawn.
- Keep `Horde_Night/OWTL_Horde_Night` as reference material unless explicitly migrated later.
- Use a hybrid OWTL module structure: Blood Moon core, with `OWTL_Traps` and `OWTL_Bows` as support modules.
- Core Blood Moon functionality should work without support modules, but intended balance assumes they are enabled.
- Use native Project Zomboid sandbox options for version 1.
- Default random Blood Moon interval is 5-7 days.
- Scheduling uses world age/time and persists next Blood Moon day/time in OWTL mod data.
- Global Blood Moon schedule/event state uses an `OWTL_BloodMoon` namespace in game-time mod data.
- Player-specific Blood Moon state uses an `OWTL_BloodMoonPlayer` namespace in player mod data.
- Player lifecycle state uses an `OWTL_Player` namespace in player mod data.
- Blood Moon warning enters the emergency broadcast cycle one day before the event and can repeat in that cycle.
- Blood Moon runs from 21:00 to 06:00 in version 1.
- Stage advances at dawn only if the event had at least one active player target.
- More specifically, stage advances if at least one horde group was allocated, spawned, or queued during the event.
- Horde stages: 20, 35, 55, 80, 110, 150, then 150 repeating.
- Spawn band is 60-100 tiles from target, with 60 tiles minimum safe distance.
- Spawn selection prefers outdoor valid squares, falls back to any valid square in band, and avoids the player's current room/building when detectable.
- Players more than 100 tiles apart may receive separate horde pressure.
- Player groups are clustered by distance at Blood Moon start.
- Joiners and respawned players can merge into the nearest active horde group if within 100 tiles.
- Active horde groups are not continuously recalculated for all players during the event.
- Default server-wide horde cap is 300 Blood Moon zombies.
- Default per-group horde cap is 120 Blood Moon zombies.
- If caps prevent full spawn, queue remaining zombies and retry while the event is active; discard queue at dawn.
- Track Blood Moon zombies with zombie mod data plus a server-side active horde registry.
- Verify whether Build 41 zombie awareness/target state automatically tracks the player's updated location once assigned.
- If manual refresh is required, update horde targeting every 3 real-time seconds by default.
- On death or logout, horde retargets to another valid player; on respawn, horde can retarget to the respawned player.
- New joiners during active Blood Moon join a nearby active horde group; isolated joiners wait until the next Blood Moon.
- Blood Moon zombies use normal zombie appearance and have no visible gameplay marker.
- Debug visibility is admin count/list commands plus optional debug logging; no in-world markers.
- Start/end sounds are player-local in version 1, using base-game sounds through centralized hooks.
- Define semantic sound hooks `OWTL_BloodMoonStartCue` and `OWTL_BloodMoonEndCue`; choose exact base-game sound IDs during implementation.
- Third-party mods are reference material only. Do not copy assets or large code. Credit referenced mods in the final mod.
- Use the currently bundled reference mods only. Do not fetch or vendor newer external mod copies unless explicitly requested later.
- Admin/debug interface is chat commands in version 1, with UI later.
- Admin/debug command set includes status/schedule, force warning, force start, force end, spawn test horde, set stage, reset scheduler, and active horde counts.
- Death drop modes are `Drop All`, `Drop Backpack Only`, and `Keep Inventory`.
- Default death drop mode is `Drop Backpack Only`.
- Drop All preserves vanilla corpse inventory behavior if possible; fallback drops carried items, bags, primary/secondary weapons, belt/attached items, and equipped non-clothing gear.
- Drop Backpack Only drops the equipped backpack and contents; all other inventory is retained without duplication.
- Death penalties are disabled by default; when enabled, use a configurable injury table. Broken limb is the default/example penalty.
- Version 1 death penalty table excludes lacerations, deep wounds, open bleeding wounds, or any penalty likely to cause repeated death after respawn.
- Persistent character target is broad persistence: skills, recipes, traits, profession, map knowledge, known media, and partial XP where feasible. Fallback is skills, recipes, traits, and profession.
- All death causes are treated the same. Infection state resets to zero on every respawn.
- Corpse remains lootable.
- Bed/home detection tries sleepable-object detection first, then known vanilla bed checks.
- If home object is gone but square/location is valid, respawn near the prior home location.
- Home respawn tries the exact home first, then a nearby safe square, then random respawn if no safe nearby square exists.
- Single-player ignores safehouse restrictions for bed/home assignment.
- Multiplayer respects safehouse ownership/permissions by default.
- Trap placement supports both build-menu defenses and crafted placeable items. Version 1 traps are build-menu defenses.
- Version 1 trap effects are damage plus durability/use loss. Slow, redirect, and kill/crowd-control variants are later goals.
- Trap gameplay is server-authoritative. Clients handle placement preview, UI, animations, and sounds.
- Trap and defense repairs use timed context actions that consume materials.
- Repair amount is defined per defense/trap. Version 1 repairs restore full durability/uses.
- Version 1 defenses are Simple Spiked Pit, Dug Spiked Pit, and Spiked Log Barricade.
- Simple Spiked Pit and Dug Spiked Pit are separate repairable items.
- Dug Spiked Pit should use a multistage build first; fallback is a single shovel-required build action.
- Spiked Log Barricade is a repairable, upgradeable wall/barricade defense that damages zombies on attack or collision.
- Relative trap balance: Simple Spiked Pit is low damage/low durability/cheap; Dug Spiked Pit is higher damage and durability with higher cost; Spiked Log Barricade deals repeated low-to-moderate contact/attack damage.
- Trap progression uses natural skill unlock plus magazine early learning plus lower build minimum skill.
- Version 1 trap progression:
  - Simple Spiked Pit: Carpentry 2 natural unlock, `Basic Pit Traps` magazine, Carpentry 1 build minimum.
  - Dug Spiked Pit: Carpentry 3 natural unlock, `Advanced Pit Traps` magazine, Carpentry 2 build minimum.
  - Spiked Log Barricade: Carpentry 4 natural unlock, `Spiked Barricades` magazine, Carpentry 2 build minimum.
- Vehicle-access gates are post-version 1.
- Basic bows and arrows are craftable from the beginning.
- Version 1 ranged scope is Basic Bow and Improved Bow. Crossbows are reference/deferred.
- Version 1 ammo scope is Basic Arrows and Improved Arrows. Special arrows are post-version 1.
- Weapon/ammo loot distributions remain unchanged; literature/schematic loot may be added for progression.
- Zombie-attached bow or arrow spawns are out of scope for version 1.
- Bow skill interactions use Aiming and Reloading in version 1. Custom Archery skill is a later possibility.
- Arrow recovery from zombie corpses is included in version 1; missed-shot/ground recovery is later.
- Bow balance target: viable early horde weapon with preparation, but inferior to firearms for burst killing.
- Schematic/magazine items use vanilla magazine/book icons in version 1.
- Version 1 text can be English only.


Phase 0 - Repository And Mod Structure
--------------------------------------

1. Audit existing OWTL mod folders.

   Tasks:

   - Inspect `Bows/OWTL_Bows/mod.info`.
   - Inspect `Buildings/OWTL_Traps/mod.info`.
   - Inspect `Horde_Night/OWTL_Horde_Night` as reference material.
   - Confirm whether `Horde_Night/OWTL_Horde_Night` has no `mod.info`.
   - List all existing OWTL files and their current responsibilities.
   - Create core Blood Moon work in a clean new `Horde_Night/OWTL_BloodMoon` folder.
   - Create player lifecycle work in a clean new `Player/OWTL_Player` folder.

   Relevant existing folders:

   - `Bows/OWTL_Bows`
   - `Buildings/OWTL_Traps`
   - `Horde_Night/OWTL_Horde_Night`

   Resolved decisions:

   - Persistent character and bed/home systems belong in `Player/OWTL_Player`.

2. Create the OWTL Blood Moon module.

   Tasks:

   - Add `Horde_Night/OWTL_BloodMoon/mod.info`.
   - Use target id/display name `OWTL_BloodMoon` / `OWTL Blood Moon` unless conflict check finds a collision.
   - Add standard Project Zomboid folder structure:
     - `media/lua/client`
     - `media/lua/server`
     - `media/lua/shared`
     - `media/scripts`
     - `media/sound`, only if audio assets are added here.
   - Define stable module naming, such as `OWTL_BloodMoon`.
   - Ensure file names use `OWTL_` prefixes where practical.

   References:

   - `Horde_Night/Expanded Helicopter Events/mod.info`
   - `Buildings/OWTL_Traps/mod.info`
   - `Bows/OWTL_Bows/mod.info`

   Resolved decisions:

   - Target id/display name: `OWTL_BloodMoon` / `OWTL Blood Moon`.

   Remaining implementation checks:

   - Exact module description.
   - Exact dependency metadata after inspecting existing OWTL module ids.

3. Confirm local game visibility.

   Tasks:

   - Check symlinked mod paths under `/Users/tneary/Zomboid/mods` when game behavior becomes relevant.
   - Record which OWTL modules are visible to Project Zomboid.
   - Do not modify symlinks unless explicitly requested.

   Remaining implementation checks:

   - Which OWTL folders should be symlinked for the user's local test setup.


Phase 1 - Blood Moon Scheduler
------------------------------

4. Define Blood Moon save data schema.

   Tasks:

   - Decide and document the exact `getGameTime():getModData()` keys.
   - Store whether the Blood Moon system is enabled.
   - Store next Blood Moon day.
   - Store next Blood Moon warning day.
   - Store current horde stage.
   - Store whether an event is currently active.
   - Store active horde metadata.
   - Store per-player horde metadata for multiplayer.
   - Include a save-data version value for future migrations.

   References:

   - `Horde_Night/Expanded Helicopter Events/media/lua/client/ExpandedHelicopter06_EventScheduler.lua`

   Resolved decisions:

   - Global Blood Moon schedule/event state lives under `OWTL_BloodMoon` in game-time mod data.
   - Player-specific Blood Moon state lives under `OWTL_BloodMoonPlayer` in player mod data.
   - Player lifecycle state lives under `OWTL_Player` in player mod data.

   Remaining implementation checks:

   - Exact child key names inside each namespace.

5. Implement scheduler initialization.

   Tasks:

   - On game start, initialize missing scheduler data.
   - If Blood Moon is disabled, leave data intact but do not schedule new events.
   - Generate first Blood Moon according to settings:
     - Random mode: default random 5-7 days.
     - Fixed mode: every X days.
   - Calculate the warning day as one day before the event.
   - Persist the generated schedule.

   References:

   - `Horde_Night/Expanded Helicopter Events/media/lua/client/ExpandedHelicopter06_EventScheduler.lua`

   Resolved decisions:

   - Use world age/time rather than `getNightsSurvived()` labels.
   - In default random mode, the first Blood Moon can occur in the 5-7 day interval.

6. Implement scheduler tick.

   Tasks:

   - Add periodic checks for warning and event start/end.
   - Use an event granularity appropriate for day/night transitions.
   - Detect fixed version 1 start time: 21:00.
   - Detect fixed version 1 end time: 06:00.
   - Start Blood Moon at 21:00 on event day.
   - End Blood Moon at 06:00.
   - Advance horde stage at dawn only if the event had at least one active target.
   - Schedule the next Blood Moon.

   References:

   - `Horde_Night/Expanded Helicopter Events/media/lua/client/ExpandedHelicopter06_EventScheduler.lua`
   - `Horde_Night/Expanded Helicopter Events/media/lua/client/ExpandedHelicopter01e_MainUpdate.lua`

   Remaining implementation checks:

   - Exact time comparison implementation for crossing 21:00 and 06:00 safely at different time speeds.
   - Track whether at least one horde group was allocated, spawned, or queued during the event.


Phase 2 - Sandbox And Server Settings
-------------------------------------

7. Add V1 configurable settings.

   Tasks:

   - Add enable/disable Blood Moon system.
   - Add random vs fixed interval.
   - Add minimum random interval.
   - Add maximum random interval.
   - Add fixed interval length.
   - Add maximum simultaneous player hordes if still distinct from group allocation.
   - Add server-wide horde cap.
   - Add per-group horde cap.
   - Add death drop mode.
   - Add death penalties enabled/disabled.
   - Add trap player damage enabled/disabled.
   - Make these available at server/admin level.

   References:

   - `Horde_Night/Expanded Helicopter Events/media/lua/client/ExpandedHelicopter09_SandboxOptions.lua`
   - `Zombies/Night Sprinters/media/lua/client/NS_Config.lua`

   Resolved decisions:

   - Use native Project Zomboid sandbox options only for version 1.
   - Default server-wide horde cap is 300.
   - Default per-group horde cap is 120.

8. Encode fixed V1 settings as constants.

   Tasks:

   - Warning lead time: one day.
   - Horde start: 21:00.
   - Horde end: 06:00.
   - Zombies per horde stage.
   - Escalation stage table.
   - Spawn radius and minimum safe distance.
   - Horde zombies revert at dawn.
   - Bed/home respawn enabled.

   Resolved decisions:

   - Stage counts are 20, 35, 55, 80, 110, 150, then 150 repeating.
   - Spawn band is 60-100 tiles.
   - Minimum safe distance is 60 tiles.


Phase 3 - Emergency Broadcast Forecasting
-----------------------------------------

9. Add Blood Moon warning to emergency broadcast.

   Tasks:

   - Hook into the emergency broadcast/weather channel.
   - Preserve vanilla broadcast behavior.
   - Add Blood Moon warning text only on the warning day.
   - Add fuzz/static formatting if appropriate.
   - Ensure the warning is only discoverable through the emergency broadcast channel.

   References:

   - `Horde_Night/Expanded Helicopter Events/media/lua/server/ExpandedHelicopter_AEBS.lua`
   - `Horde_Night/Expanded Helicopter Events/media/lua/shared/Translate/EN/DynamicRadio_EN.txt`

   Resolved decisions:

   - Warning text should vary by escalation stage.
   - Warning text enters the emergency broadcast cycle and can repeat throughout the warning day.
   - Warning text should be diegetic but clear.
   - Future work should create a pool of possible warning lines per stage band and select randomly.

   Remaining implementation checks:

   - Exact final V1 warning lines or stage-band templates.
   - Exact radio API hook for injecting OWTL warning text without breaking vanilla broadcast behavior.

10. Add English text entries.

   Tasks:

   - Add English radio text.
   - Add any needed UI text for settings and debug tools.
   - Keep strings OWTL-prefixed where possible.

   References:

   - `Horde_Night/Expanded Helicopter Events/media/lua/shared/Translate/EN/DynamicRadio_EN.txt`
   - `Buildings/Improved Build Menu [Build 41.51+] (no itemtweak)/media/lua/shared/Translate/EN/*`

   Resolved decisions:

   - Non-English translations are out of scope for version 1.


Phase 4 - Blood Moon Horde Spawning
-----------------------------------

11. Define horde stage table.

   Tasks:

   - Create data table for horde stages.
   - Include zombie count per player horde.
   - Include final repeat stage.
   - Keep special zombie slots absent or disabled for V1.
   - Add comments marking future special-zombie expansion points.

   Resolved decisions:

   - Stages are 20, 35, 55, 80, 110, 150, then 150 repeating.
   - Apply counts per active horde group, bounded by server and group caps.

12. Implement spawn point selection.

   Tasks:

   - Spawn zombies nearby each targeted player/group.
   - Respect 60-100 tile spawn band and 60 tile minimum safe distance.
   - Avoid spawning directly inside the player's room if possible.
   - Avoid invalid squares.
   - Avoid spawning on top of the player.
   - Support multiple active player hordes.
   - Respect max simultaneous horde cap.

   References:

   - `Horde_Night/Expanded Helicopter Events/media/lua/client/ExpandedHelicopter01d_MainEvents.lua`
   - `QoL/Cheat Menu/media/lua/client/ISUI/CheatCore.lua`

   Resolved decisions:

   - Spawned zombies use normal spawned zombie appearance.
   - Retry nearby valid tiles first.
   - Failed spawn counts go into the active horde queue.
   - Spawn queue expires at dawn.
   - Prefer outdoor valid squares.
   - Fall back to any valid square in the 60-100 tile spawn band.
   - Avoid the player's current room/building if detectable.

13. Implement horde spawn execution.

   Tasks:

   - Spawn fixed stage count for each active horde group, bounded by caps.
   - Tag spawned zombies as Blood Moon horde zombies using zombie mod data.
   - Associate each horde zombie with a target player or horde id.
   - Store spawned zombie identifiers where possible.
   - Track spawned count and live tracked count.
   - Add server-safe handling for multiplayer.

   References:

   - `Horde_Night/Expanded Helicopter Events/media/lua/client/ExpandedHelicopter01d_MainEvents.lua`
   - `QoL/Cheat Menu/media/lua/client/ISUI/CheatCore.lua`

   Resolved decisions:

   - Mark zombies with modData and maintain a server-side active horde registry.
   - Horde zombies retarget if their target dies or logs out.

   Remaining implementation checks:

   - Best Build 41-safe reference or identifier for tracking individual zombies.


Phase 5 - Horde Awareness
-------------------------

14. Implement continuous target awareness.

   Tasks:

   - On a recurring update, find Blood Moon-spawned zombies.
   - For each horde zombie, resolve current target player location.
   - Path horde zombie toward exact target player location.
   - Keep normal zombie behavior otherwise.
   - Do not affect non-Blood Moon zombies.
   - Avoid changing speed, strength, vision, hearing, or visuals in V1.

   References:

   - `Zombies/NocturnalZombiesFixed/media/lua/server/NocturnalZombiesServer.lua`
   - `Zombies/RestlessZombiesFixed/media/lua/server/restlesszombiesServer.lua`
   - `Horde_Night/OWTL_Horde_Night/NocturnalZombiesServer.lua`

   Resolved decisions:

   - Update awareness on a throttled interval, not every tick.
   - Verify first whether Build 41 zombie awareness/target state automatically tracks the player after assignment.
   - If manual refresh is required, use a 3 real-time second default interval.

   Remaining implementation checks:

   - Whether manual refresh is required at all after setting zombie awareness/target state.
   - Whether to call `pathToLocation` every interval or only when target location changes meaningfully if manual refresh is needed.
   - Performance limit per update.

15. Revert horde zombies at dawn.

   Tasks:

   - Clear Blood Moon horde mod-data markers.
   - Stop active horde tracking.
   - If a safe Build 41 API exists, clear forced target/path state.
   - Let remaining zombies behave normally.
   - Never despawn remaining Blood Moon zombies at dawn.

   Resolved decisions:

   - No normal gameplay visual distinction.
   - Admin/debug gets count/list commands and optional logging, not in-world markers.
   - Clear OWTL tracking and modData at dawn.
   - If safe, clear forced target/path state at dawn.
   - Do not despawn remaining Blood Moon zombies at dawn.

   Remaining implementation checks:

   - Whether Build 41 has a safe API to clear forced target/path state.


Phase 6 - Multiplayer Horde Allocation
--------------------------------------

16. Implement per-player horde allocation.

   Tasks:

   - Determine online active players at Blood Moon start.
   - Assign horde slots per player group where practical.
   - If players are more than 100 tiles apart, each can receive separate horde pressure.
   - Respect server-wide and per-group horde caps.
   - Store horde id, target player id/name, start time, and stage.

   Resolved decisions:

   - 100 tiles counts as far apart.
   - Groups at one base should receive shared horde pressure, bounded by per-group cap.
   - Caps queue remaining spawn count rather than dropping it immediately.
   - Use distance clustering at Blood Moon start.
   - During the event, allow joiners/respawns to merge into nearest active group within 100 tiles.
   - Do not continuously recalculate all active groups during the event.

17. Handle multiplayer edge cases.

   Tasks:

   - Target player dies during Blood Moon.
   - Target player respawns during Blood Moon.
   - Target player logs out during Blood Moon.
   - New player logs in during active Blood Moon.
   - Player drives far away after horde spawn.

   Resolved decisions:

   - On death or logout, horde retargets to another valid player, preferably same group/base.
   - On respawn, horde can retarget to the respawned player.
   - New joiners join nearby active horde groups.
   - Isolated new joiners do not receive a new horde until the next Blood Moon.


Phase 7 - Audio And Player Feedback
-----------------------------------

18. Add Blood Moon start/end audio cues.

   Tasks:

   - Add scripted sound hooks.
   - Use base-game sounds for version 1.
   - Play start cue at 21:00 when Blood Moon begins.
   - Play end cue at 06:00 when Blood Moon ends.
   - Ensure multiplayer players hear appropriate cues.

   References:

   - `Horde_Night/Expanded Helicopter Events/media/scripts/sounds_EHE.txt`
   - `Horde_Night/Expanded Helicopter Events/media/lua/client/ExpandedHelicopter01b_MainSounds.lua`
   - `Horde_Night/Expanded Helicopter Events/media/sound/*`

   Resolved decisions:

   - Sounds are player-local in version 1.
   - Add server/global broadcast-style sounds later.
   - Do not reuse third-party sound assets.
   - Define semantic sound hooks `OWTL_BloodMoonStartCue` and `OWTL_BloodMoonEndCue`.

   Remaining implementation checks:

   - Exact base-game sound identifiers to map to the semantic hooks.

19. Add bed/home assignment prompt.

   Tasks:

   - Add context action on beds or sleeping objects.
   - Prompt player to assign bed as home.
   - Store assigned home location in player mod data.
   - Display success/failure message.
   - Support multiplayer per-player homes.

   References:

   - `QoL/Cheat Menu/media/lua/client/ISUI/CheatCore.lua`

   Resolved decisions:

   - Detect sleepable objects first.
   - Fallback to known vanilla bed checks.
   - Context action text: `Set as Home`.
   - Success confirmation: `Home set. You will respawn here.`

   Remaining implementation checks:

   - Exact Build 41 safehouse ownership/permission API for enforcing multiplayer restrictions.


Phase 8 - Persistent Character And Death
----------------------------------------

20. Define persistent character data.

   Tasks:

   - Persist broad character data where feasible:
     - skills
     - recipes
     - traits
     - profession
     - map knowledge
     - known media
     - partial XP
   - Document each field included or excluded.
   - Store persistent data before death.
   - Restore persistent data after respawn.

   Resolved decisions:

   - Use broad persistence as the target.
   - Fall back to skills, recipes, traits, and profession if Build 41 APIs block broader persistence.
   - Inventory is controlled by death drop handling, not persistence.
   - Infection is excluded from persistence and always reset to zero on respawn.

21. Implement skill retention.

   Tasks:

   - Capture perk levels before character death.
   - Restore perk levels on respawn.
   - Preserve partial XP where feasible.
   - Treat infection death the same as any other death.
   - Reset infection state to zero on every respawn.
   - Test single-player.
   - Test multiplayer.

   Remaining implementation checks:

   - Exact Project Zomboid event hook for reliable pre-death capture.
   - Exact Build 41 API for clearing infection state on respawn.

22. Implement death drop mode.

   Tasks:

   - Add setting for:
     - Drop All
     - Drop Backpack Only
     - Keep Inventory
   - On death, apply configured drop mode.
   - Ensure dropped items remain recoverable.
   - Avoid duplicating items on respawn.

   Resolved decisions:

   - The earlier backpack/tool belt/both model is superseded.
   - Corpse remains lootable.
   - Drop All preserves vanilla corpse inventory behavior if possible.
   - Drop All fallback drops carried items, bags, primary/secondary weapons, belt/attached items, and equipped non-clothing gear.
   - Drop Backpack Only drops the equipped backpack and contents; all other inventory is retained without duplication.
   - Keep Inventory respawns with inventory retained and prevents duplicate corpse items.

   Remaining implementation checks:

   - Exact Build 41 inventory handling needed to implement Drop All without duplication.
   - Exact definition of backpack slot in Build 41 equipment data.

23. Implement death penalties.

   Tasks:

   - Add disabled-by-default penalty path.
   - If enabled, apply configured penalty after respawn.
   - Implement configurable injury table.
   - Include broken limb as the default/example penalty.
   - Include default V1 penalties:
     - broken limb
     - burn
     - severe pain
     - exhaustion/fatigue
   - Exclude lacerations, deep wounds, open wounds, and other immediate-health-drain penalties from the default table.
   - Use weighted random limb selection for broken limbs: mostly arms, sometimes legs.

   Resolved decisions:

   - Default injury table is broken limb, burn, severe pain, and exhaustion/fatigue.

24. Implement bed/home respawn.

   Tasks:

   - On respawn, check assigned home location.
   - If valid, respawn player at home.
   - If object is missing but square/location is valid, respawn near previous home.
   - If the exact home square is unsafe or occupied, try a nearby safe square.
   - If missing, invalid, or no safe nearby square exists, respawn at random location.
   - Keep home per player.
   - Keep bed/home respawn always enabled.

   Remaining implementation checks:

   - How to validate a bed/home after it is destroyed.
   - Exact Build 41 safehouse ownership/permission API.


Phase 9 - Buildable Defenses
----------------------------

25. Define V1 defense catalog.

   Tasks:

   - Create data entries for:
     - Simple spiked pit.
     - Dug spiked pit.
     - Spiked log barricade.
   - Define lifecycle:
     - Simple spiked pit: repairable.
     - Dug spiked pit: repairable.
     - Spiked log barricade: repairable, upgradeable.
   - Define damage plus durability/use loss behavior.
   - Define player damage behavior.
   - Define repair materials.
   - Define build materials from vanilla items.

   References:

   - `Buildings/PlayerTraps/media/scripts/traps.txt`
   - `Buildings/Nolan's Traps Updates/media/scripts/traps.txt`
   - `Buildings/Nolan's Traps Updates/media/scripts/Nolans_Landmines.txt`

   Resolved decisions:

   - Simple spiked pit is built directly from materials.
   - Dug spiked pit should use a multistage build where the player digs first, then adds spikes.
   - If multistage build support is unreliable in Build 41, use a single shovel-required build action.
   - Spiked log barricade is a buildable wall/barricade defense.
   - Version 1 traps damage and lose durability/use count.
   - Slow, redirect, and stronger kill behavior are later goals.

   Remaining implementation checks:

   - Exact damage values based on relative balance targets.
   - Exact durability values based on relative balance targets.
   - Exact repair material costs based on relative balance targets.

26. Implement build menu integration.

   Tasks:

   - Add defenses to an OWTL build menu category.
   - Gate build options by required skill and known recipe.
   - Show required materials.
   - Support placement preview if using buildable objects.
   - Keep vanilla build menu behavior intact.

   References:

   - `Buildings/Improved Build Menu [Build 41.51+] (no itemtweak)/media/lua/client/BuildingObjects/ISUI/ISNewBuildMenu_Patch.lua`
   - `Buildings/Improved Build Menu [Build 41.51+] (no itemtweak)/media/scripts/ibm_multistagebuild.txt`
   - `Buildings/Improved Build Menu [Build 41.51+] (no itemtweak)/media/scripts/ibm_recipes.txt`

   Resolved decisions:

   - Support both build-menu defenses and crafted placeable items as a general pattern.
   - Version 1 defenses are build-menu objects.
   - Vehicle-access gates are post-version 1.

   Resolved decisions:

   - Try multistage builds for dug pits/upgrades first.
   - Fall back to a simpler shovel-required build action if needed.

27. Implement trap triggering for zombies and players.

   Tasks:

   - Detect when a zombie enters a trap square or interacts with a trap object.
   - Detect when a player enters a trap square if trap player damage is enabled.
   - Apply damage/effect.
   - Update trap state.
   - Sync state in multiplayer.
   - Replace or mark worn-out trap where appropriate.

   References:

   - `Buildings/PlayerTraps/media/lua/client/traps.lua`
   - `Buildings/PlayerTraps/media/lua/server/TrapServer.lua`

   Remaining implementation checks:

   - Best hook for zombie entering trap area.
   - Whether trap effects can directly damage zombies reliably.

28. Implement trap repair/reset.

   Tasks:

   - Add timed context action to repair or reset damaged traps.
   - Consume vanilla materials.
   - Require appropriate skill/tool.
   - Restore trap state.
   - Sync state in multiplayer.

   References:

   - `Buildings/PlayerTraps/media/scripts/traps.txt`
   - `QoL/Recycle Everything - Main Recipes/media/scripts/POETRecycleEverything.txt`

   Resolved decisions:

   - Repair is a timed context action that consumes materials.
   - Repair amount is data-driven per defense/trap.
   - Version 1 repairs restore full durability/uses.

   Remaining implementation checks:

   - Exact repair materials.


Phase 10 - Crafting, Magazines, And Progression
-----------------------------------------------

29. Define trap recipe progression.

   Tasks:

   - For each defense/trap, define:
     - Natural skill unlock level.
     - Magazine/manual item that teaches it early.
     - Minimum skill required to build after reading magazine.
     - Required tools.
     - Required materials.
     - XP awarded.

   References:

   - `Weapons/Scrap Weapons/media/scripts/SWeapons_Magazines.txt`
   - `Weapons/Scrap Weapons/media/scripts/module_SWeapons.txt`
   - `QoL/Recycle Everything - Main Recipes/media/lua/server/items/POETExperienceFunctions.lua`
   - `Buildings/CraftHelper41/media/lua/client/crafthelper41.lua`

   Resolved decisions:

   - Simple Spiked Pit: Carpentry 2 natural unlock, `Basic Pit Traps` magazine, Carpentry 1 build minimum.
   - Dug Spiked Pit: Carpentry 3 natural unlock, `Advanced Pit Traps` magazine, Carpentry 2 build minimum.
   - Spiked Log Barricade: Carpentry 4 natural unlock, `Spiked Barricades` magazine, Carpentry 2 build minimum.

   Remaining implementation checks:

   - Exact material costs.
   - XP awarded.

30. Implement magazine/manual items.

   Tasks:

   - Add OWTL magazine items.
   - Add translation/display names.
   - Add recipe teaching metadata.
   - Add icons or reuse appropriate existing OWTL-compatible assets only if permitted.

   References:

   - `Weapons/Scrap Weapons/media/scripts/SWeapons_Magazines.txt`
   - `QoL/LitSortOGSN/media/textures/Item_magazine_*.png`

   Resolved decisions:

   - Literature/schematic loot may be added for progression.
   - Direct weapon/ammo loot distributions remain unchanged.
   - Use vanilla magazine/book icons for version 1.


31. Implement recipe validation and XP.

   Tasks:

   - Add recipes with `SkillRequired`.
   - Add `OnGiveXP` handlers if default XP is insufficient.
   - Ensure learned-via-magazine recipes still require minimum skill.
   - Verify recipes appear in crafting/build UI correctly.

   References:

   - `QoL/Recycle Everything - Main Recipes/media/scripts/POETRecycleEverything.txt`
   - `QoL/Recycle Everything - Main Recipes/media/lua/server/items/POETExperienceFunctions.lua`
   - `Buildings/CraftHelper41/media/lua/client/UI/craftHelper41RecipePanel.lua`

   Remaining implementation checks:

   - Whether Project Zomboid supports "natural skill unlock" for recipes without custom Lua.
   - Whether custom recipe-known checks are needed.


Phase 11 - Early Ranged Weapon Support
--------------------------------------

32. Audit current `Bows/OWTL_Bows`.

   Tasks:

   - Inspect `Bows/OWTL_Bows/mod.info`.
   - Inspect current scripts, Lua, models, textures, sounds.
   - Determine whether item scripts are missing.
   - Check `Zed_Back_Spawn.lua` references against actual item ids.
   - Compare with `Bows/Remastered Kitsune's Crossbow Mod`.

   References:

   - `Bows/Remastered Kitsune's Crossbow Mod/media/scripts/module_KCMweapons_Items.txt`
   - `Bows/Remastered Kitsune's Crossbow Mod/media/scripts/module_KCMweapons_Recipe.txt`
   - `Bows/Remastered Kitsune's Crossbow Mod/media/lua/client/KCMCrossbowClient.lua`
   - `Bows/Remastered Kitsune's Crossbow Mod/media/lua/client/TimedActions/ISKCMReloadCrossbowAction.lua`

   Resolved decisions:

   - Version 1 includes Basic Bow and Improved Bow.
   - Crossbow/Kitsune work is reference only for V1.
   - Basic bows and arrows are craftable from the beginning.

   Remaining implementation checks:

   - Whether `OWTL_Bows` is currently complete.

33. Define V1 ranged weapon catalog.

   Tasks:

   - Define Basic Bow and Improved Bow items.
   - Define ammo types.
   - Define ammo crafting.
   - Define sound radius/noise.
   - Define damage and durability.
   - Define reload behavior.
   - Define corpse-based arrow recovery chance.

   Resolved decisions:

   - Basic bow and arrows are craftable at game start.
   - Improved bow uses progression.
   - Ammo should use vanilla materials for version 1.
   - Aiming affects bow accuracy/damage.
   - Reloading affects bow draw/reload speed.
   - Custom Archery skill is out of scope for version 1.
   - Arrows can be recovered from zombie corpses in version 1.
   - Missed-shot or ground recovery is out of scope for version 1.
   - Bows should be viable early horde weapons with enough prepared arrows.
   - Firearms remain superior for burst killing.

   Remaining implementation checks:

   - Exact damage, range, noise, durability, reload, and corpse recovery values.

34. Implement ranged weapon scripts and Lua.

   Tasks:

   - Add or repair item scripts.
   - Add reload timed actions if required.
   - Add projectile hit behavior.
   - Add sound definitions.
   - Add recipes.
   - Add distributions only if explicitly accepted despite "loot unchanged for V1."

   References:

   - `Bows/Remastered Kitsune's Crossbow Mod`
   - `Guns/Scrap Guns/media/scripts/module_SGuns_air.txt`
   - `Guns/Scrap Guns/media/scripts/module_SGuns_recipes.txt`

   Resolved decisions:

   - Weapon/ammo loot distributions are out of scope for version 1.
   - Zombie-attached bow or arrow spawns are out of scope for version 1.


Phase 12 - Admin And Debug Tools
--------------------------------

35. Define admin commands.

   Tasks:

   - List required debug/admin commands.
   - Minimum likely commands:
     - Show Blood Moon schedule.
     - Force warning.
     - Force Blood Moon start.
     - Force Blood Moon end.
     - Spawn test horde.
     - Set horde stage.
     - Reset scheduler.
     - Show active horde count.
   - Ensure commands are admin/server-only where appropriate.

   References:

   - `Horde_Night/Expanded Helicopter Events/media/lua/client/zDebugTests.lua`
   - `QoL/Cheat Menu/media/lua/client/ISUI/CheatCore.lua`

   Resolved decisions:

   - Version 1 admin/debug interface is chat commands.
   - UI/context menu can be added later.
   - Required commands: status/schedule, force warning, force start, force end, spawn test horde, set stage, reset scheduler, active horde count/list.

36. Implement debug logging.

   Tasks:

   - Log scheduler initialization.
   - Log warning broadcasts.
   - Log event start/end.
   - Log horde spawns and failures.
   - Log per-player horde assignment.
   - Log death persistence and respawn decisions.
   - Keep logs concise and OWTL-prefixed.

   Resolved decisions:

   - Debug logging is controlled by a debug setting.


Phase 13 - Compatibility And Modernization
------------------------------------------

37. Review bundled external references before heavy implementation.

   Tasks:

   - Review the bundled copies of these external mods:
     - `Horde_Night/Expanded Helicopter Events`
     - `Buildings/Improved Build Menu [Build 41.51+] (no itemtweak)`
     - `Bows/Remastered Kitsune's Crossbow Mod`
     - `Buildings/PlayerTraps`
     - `Buildings/Nolan's Traps Updates`
     - `Zombies/NocturnalZombiesFixed`
     - `Zombies/RestlessZombiesFixed`
     - `QoL/Cheat Menu`
   - Treat these as old-but-useful examples.
   - Verify any API patterns against Build 41 behavior during implementation.
   - Update `docs/EXTERNAL_MODS.txt` if bundled references change implementation guidance.

   Resolved decisions:

   - External assets/code are reference only unless later explicitly approved.
   - Credit referenced mods in final mod documentation.
   - Do not fetch newer copies for version 1.
   - Do not vendor updated external mods into this repository.

38. Check Project Zomboid version assumptions.

   Tasks:

   - Identify target Project Zomboid build.
   - Verify Lua API availability for:
     - radio broadcast hooks
     - zombie spawning
     - zombie pathing
     - player death/respawn events
     - build menu APIs
     - sandbox/server options
   - Document incompatible old-reference patterns.

   Resolved decisions:

   - Target is Build 41.
   - Build 42 compatibility is out of scope unless requested later.


Phase 14 - Verification Tasks
-----------------------------

39. Static repository checks.

   Tasks:

   - Check all edited Lua files for syntax issues.
   - Check item script files for obvious malformed blocks.
   - Check mod folder layout.
   - Check `mod.info` exists for every enabled OWTL module.
   - Check translations referenced by code exist.
   - Check sound names referenced by code exist.

40. Single-player manual test checklist.

   Tasks:

   - New game starts without Lua errors.
   - Blood Moon schedule initializes.
   - Emergency broadcast warning appears one day before event.
   - Blood Moon starts at 21:00.
   - Start audio cue plays.
   - Horde spawns near player.
   - Horde zombies pursue player through movement, interiors, floors, and vehicles.
   - Non-horde zombies remain normal.
   - Blood Moon ends at 06:00.
   - End audio cue plays.
   - Horde zombies revert to normal.
   - Next event is scheduled.
   - Stage advances.

41. Multiplayer manual test checklist.

   Tasks:

   - Server starts with OWTL modules.
   - Server settings apply.
   - Multiple players receive per-player hordes where appropriate.
   - Horde cap is respected.
   - Players far apart behave according to defined allocation rules.
   - Player death during Blood Moon is handled.
   - Player respawn/home behavior works.
   - Disconnect/reconnect behavior is observed and documented.

42. Trap and defense test checklist.

   Tasks:

   - Spiked pit can be built or placed.
   - Spiked log barricade can be built or placed.
   - Required skill gates work.
   - Magazine early-learn path works.
   - Build minimum skill still applies after magazine learning.
   - Zombies trigger traps.
   - Players trigger traps when player trap damage is enabled.
   - Players do not trigger traps when player trap damage is disabled.
   - Trap state syncs in multiplayer.
   - Trap repair/reset works.
   - No auto-repair occurs after Blood Moon.

43. Persistent character test checklist.

   Tasks:

   - Skills are captured before death.
   - Player respawns as same character.
   - Skills are restored.
   - Death drop mode works for Drop All.
   - Death drop mode works for Drop Backpack Only.
   - Death drop mode works for Keep Inventory.
   - Bed/home respawn works.
   - Random respawn works when no bed/home is set.
   - Death penalties are disabled by default.
   - Enabled death penalty applies correctly.

44. Early ranged weapon test checklist.

   Tasks:

- Basic Bow is craftable at game start.
- Improved Bow is craftable through progression.
- Basic Arrows are craftable at game start.
- Improved Arrows are craftable through progression.
   - Reload works.
   - Firing works.
   - Sound radius is appropriate.
   - Damage is useful but not dominant.
   - Ammo recovery works if included.
   - First Blood Moon is survivable with intended preparation.


Remaining Ambiguities And Implementation Risks
----------------------------------------------

The major gameplay decisions are now resolved. The remaining items are implementation checks, tuning values, or data-entry details.

API and architecture checks:

- Exact OWTL module dependency metadata after inspecting current `mod.info` ids.
- Exact Build 41 API for emergency broadcast injection.
- Exact Build 41 API for zombie spawning and reliable zombie reference tracking.
- Exact Build 41 API for zombie awareness/targeting, including whether manual path refresh is required.
- Exact Build 41 event hook for reliable pre-death capture.
- Exact Build 41 API for respawn position override.
- Exact Build 41 API for sleepable-object detection.
- Exact Build 41 hook for zombie/player trap triggering.
- Exact trap state sync mechanism for client presentation.

Content and tuning values:

- Final emergency broadcast text variants per horde stage.
- Exact base-game sound identifiers for Blood Moon start/end cues.
- Exact trap damage, durability, and repair/material costs.
- Whether Build 41 multistage build support is reliable enough for dug pits.
- Exact bow damage, range, noise, reload timing, durability, ammo recovery, and skill interactions.

Policy or workflow checks:

- None currently blocking. Treat bundled third-party mods as references only.
