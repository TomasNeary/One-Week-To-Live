# One Week To Live Implementation Plan

This plan converts the gameplay plan and build TODO into an implementation order that can be executed incrementally.

Primary references:

- `docs/GAMEPLAY_PLAN.md`
- `docs/BUILD_TODO.md`
- `docs/EXTERNAL_MODS.txt`

Project rules:

- Target Project Zomboid Build 41.
- Use the repository-local `zomboid-mod` skill for Project Zomboid mod structure, folder layout, and `mod.info` work.
- Use the repository-local `zomboid-lua` skill when writing, reviewing, refactoring, or debugging Lua under `media/lua/client`, `media/lua/server`, or `media/lua/shared`.
- For Build 41 API names, event signatures, object methods, or Kahlua behavior that are not already verified locally, follow `zomboid-lua`: check current PZwiki/Javadocs/game-file references before coding.
- Keep One Week To Live code in OWTL-prefixed mod folders.
- Inspect the relevant `mod.info` before editing a mod folder.
- Do not edit bundled third-party mods.
- Use bundled external mods as reference only.
- Prefer small playable increments over broad incomplete systems.

Lua implementation rules:

- Treat Project Zomboid Lua as Lua 5.1-ish Kahlua.
- Avoid Lua 5.2+ syntax and APIs unless verified in Project Zomboid.
- Add nil checks around game objects, players, inventory items, squares, cells, and Java-exposed objects.
- Decide client/server/shared placement before adding Lua.
- Prefer Project Zomboid `Events` integration.
- Avoid broad globals and keep OWTL namespaces explicit.

## Phase 0 - Repository Audit And Module Skeletons

Goal:

- Establish clean OWTL module boundaries and confirm existing folder state.

Tasks:

- Inspect `Bows/OWTL_Bows/mod.info`.
- Inspect `Buildings/OWTL_Traps/mod.info`.
- Inspect `Horde_Night/OWTL_Horde_Night` as reference material.
- Confirm whether `Horde_Night/OWTL_Horde_Night` has no `mod.info`.
- Create `Horde_Night/OWTL_BloodMoon` with target id/display name `OWTL_BloodMoon` / `OWTL Blood Moon`.
- Create `Player/OWTL_Player` for persistent character, death drops, death penalties, and bed/home respawn.
- Add standard PZ folder layout for new modules:
  - `media/lua/client`
  - `media/lua/server`
  - `media/lua/shared`
  - `media/scripts`

Deliverables:

- New module skeletons with valid `mod.info`.
- Initial notes on dependency metadata and any id conflicts.

Verification:

- PZ mod folder structure is valid.
- `git status --short --branch` reviewed.

## Phase 1 - Shared Constants, Sandbox Settings, And State

Goal:

- Establish configuration and persistent state before behavior is implemented.

Required skills:

- `zomboid-mod`
- `zomboid-lua`

Tasks:

- Add native Project Zomboid sandbox options:
  - Blood Moon enabled.
  - Random/fixed interval.
  - Minimum random interval.
  - Maximum random interval.
  - Fixed interval length.
  - Server-wide horde cap, default 300.
  - Per-group horde cap, default 120.
  - Death drop mode, default `Drop Backpack Only`.
  - Death penalties enabled/disabled.
  - Trap player damage enabled/disabled.
- Add shared constants:
  - Blood Moon start: 21:00.
  - Blood Moon end: 06:00.
  - Warning lead time: 1 day.
  - Spawn band: 60-100 tiles.
  - Group distance: 100 tiles.
  - Horde stages: 20, 35, 55, 80, 110, 150, then 150 repeating.
- Define mod-data namespaces:
  - `OWTL_BloodMoon` in game-time mod data.
  - `OWTL_BloodMoonPlayer` in player mod data.
  - `OWTL_Player` in player mod data.
- Add save-data version fields for future migrations.

Deliverables:

- Settings readable from Lua.
- Shared constants available to server/client code as appropriate.
- State schema documented in code comments or a small internal README.

Verification:

- New game initializes state without Lua errors.
- Disabled Blood Moon setting prevents scheduling while preserving data.

## Phase 2 - Scheduler And Admin Debug Commands

Goal:

- Make Blood Moon schedule observable and controllable before spawning zombies.

Required skills:

- `zomboid-lua`

Tasks:

- Initialize first Blood Moon using world age/time.
- Support random default interval of 5-7 days.
- Support fixed interval.
- Persist next Blood Moon day/time and warning day/time.
- Detect 21:00 start and 06:00 end robustly across time speeds.
- Track whether at least one horde group was allocated/spawned/queued during the event.
- Advance stage at dawn only when a horde group existed.
- Add admin chat commands:
  - Show status/schedule.
  - Force warning.
  - Force Blood Moon start.
  - Force Blood Moon end.
  - Spawn test horde.
  - Set horde stage.
  - Reset scheduler.
  - Show active horde counts/groups.
- Add debug logging behind a debug setting.

Deliverables:

- Scheduler runs without horde spawning.
- Admin can force and inspect event state.

Verification:

- New schedule persists across save/load.
- Forced start/end transitions update state correctly.
- Stage advancement follows the allocated-horde rule.

## Phase 3 - Emergency Broadcast And Audio Hooks

Goal:

- Make the Blood Moon discoverable through the emergency broadcast channel and provide basic event cues.

Required skills:

- `zomboid-lua`

Tasks:

- Inspect bundled Expanded Helicopter Events broadcast implementation.
- Identify Build 41 emergency broadcast injection point.
- Add warning text to the emergency broadcast cycle one day before Blood Moon.
- Use diegetic but clear stage-scaled warning text.
- Add semantic sound hooks:
  - `OWTL_BloodMoonStartCue`
  - `OWTL_BloodMoonEndCue`
- Map semantic hooks to available base-game sound IDs during implementation.
- Play start/end cues locally for affected players.

Deliverables:

- Radio warning appears through emergency broadcast.
- Start/end sound hooks are callable.

Verification:

- Vanilla broadcast behavior remains intact.
- Warning repeats in the broadcast cycle on warning day.
- Start/end cues play for local affected player.

## Phase 4 - Horde Allocation, Spawning, And Tracking

Goal:

- Spawn bounded Blood Moon horde groups and track them safely.

Required skills:

- `zomboid-lua`

Tasks:

- Cluster online players by distance at Blood Moon start.
- Use 100 tiles as group threshold.
- Allow joiners/respawns to merge into nearest active group within 100 tiles.
- Do not continuously recalculate all active groups during event.
- Apply server-wide and per-group horde caps.
- Queue spawn counts blocked by caps or failed spawn searches.
- Discard queue at dawn.
- Select spawn squares:
  - Prefer outdoor valid squares.
  - Fall back to any valid square in the 60-100 tile band.
  - Avoid the player's current room/building when detectable.
- Spawn normal-appearance zombies.
- Mark horde zombies with modData.
- Maintain server-side active horde registry.

Deliverables:

- Blood Moon allocates horde groups and spawns capped horde zombies.
- Spawn failures become queue entries.
- Admin command shows active horde counts/groups.

Verification:

- Single-player horde spawns near player, outside safe distance.
- Multiplayer clustered players share a group.
- Far-apart players receive separate pressure.
- Caps are respected.

## Phase 5 - Horde Awareness And Dawn Reversion

Goal:

- Make Blood Moon-spawned zombies pressure their assigned player/group until 06:00.

Required skills:

- `zomboid-lua`

Tasks:

- Verify Build 41 zombie awareness/target behavior:
  - If setting target/awareness follows the player automatically, use native behavior.
  - If not, refresh target/path every 3 real-time seconds by default.
- Retarget horde on player death/logout to another valid player, preferably same group/base.
- Retarget to respawned player when appropriate.
- Keep non-Blood Moon zombies unchanged.
- At dawn:
  - Clear OWTL tracking and modData.
  - Safely clear forced target/path state if Build 41 supports it.
  - Never despawn remaining horde zombies.

Deliverables:

- Horde zombies continue pursuing valid targets until event end.
- Dawn reverts horde zombies to normal behavior.

Verification:

- Moving, hiding, entering vehicles, and changing floors does not break pressure.
- Target death/logout does not stall half a horde.
- Remaining zombies persist but act normally after dawn.

## Phase 6 - Persistent Character, Death Drops, And Home Respawn

Goal:

- Make death a setback while preserving character progression.

Required skills:

- `zomboid-lua`

Tasks:

- Capture and restore broad persistent data where feasible:
  - skills
  - recipes
  - traits
  - profession
  - map knowledge
  - known media
  - partial XP
- Fallback persistence if APIs are unreliable:
  - skills
  - recipes
  - traits
  - profession
- Reset infection state to zero on every respawn.
- Treat all death causes the same.
- Implement death drop modes:
  - `Drop All`
  - `Drop Backpack Only`
  - `Keep Inventory`
- `Drop All` preserves vanilla corpse inventory behavior if possible; fallback drops carried items, bags, primary/secondary weapons, belt/attached items, and equipped non-clothing gear.
- `Drop Backpack Only` drops equipped backpack and contents; all other inventory is retained without duplication.
- `Keep Inventory` respawns with inventory retained and prevents duplicate corpse items.
- Implement disabled-by-default death penalties.
- Default penalty table when enabled:
  - broken limb
  - burn
  - severe pain
  - exhaustion/fatigue
- Exclude bleeding/open-wound penalties from default table.
- Broken limb selection is weighted random: mostly arms, sometimes legs.
- Add bed/home assignment:
  - Context action: `Set as Home`.
  - Success text: `Home set. You will respawn here.`
- Use sleepable-object detection first; fallback to known vanilla beds.
- Home respawn order:
  - exact home
  - nearby safe square
  - old home square fallback if object gone but location valid
  - random respawn
- Single-player ignores safehouse restrictions.
- Multiplayer respects safehouse ownership/permissions by default.

Deliverables:

- `OWTL_Player` handles persistence, death drops, penalties, and home respawn.
- Death settings work independently of Blood Moon event state.

Verification:

- Skills and selected progression data survive death.
- Infection does not carry over.
- Each death drop mode avoids duplication.
- Bed/home respawn works, including destroyed/unsafe home fallback.

## Phase 7 - Buildable Defenses And Traps

Goal:

- Add first base-defense tools needed for Blood Moon gameplay.

Required skills:

- `zomboid-mod`
- `zomboid-lua`

Tasks:

- Inspect `Buildings/OWTL_Traps/mod.info`.
- Inspect current trap/build-menu files in `Buildings/OWTL_Traps`.
- Use bundled PlayerTraps, Nolan's Traps Updates, and Improved Build Menu as references only.
- Implement build-menu defenses:
  - Simple Spiked Pit.
  - Dug Spiked Pit.
  - Spiked Log Barricade.
- Dug Spiked Pit uses multistage build first; fallback to single shovel-required build action.
- Implement server-authoritative trap gameplay.
- Clients handle placement preview, UI, animations, and sounds.
- V1 trap effects:
  - damage
  - durability/use loss
  - player damage if setting enabled
- Implement timed context repair actions consuming materials.
- V1 repairs restore full durability/uses.
- Use relative balance targets:
  - Simple Spiked Pit: low damage, low durability, cheap.
  - Dug Spiked Pit: higher damage/durability/cost.
  - Spiked Log Barricade: repeated low-to-moderate contact/attack damage.

Deliverables:

- Three buildable defenses with damage, degradation, player damage toggle, and repair.

Verification:

- Skill gates and known-recipe gates work.
- Zombies and players trigger traps.
- Trap state syncs in multiplayer.
- Repairs consume materials and restore full condition.

## Phase 8 - Crafting, Magazines, And Progression

Goal:

- Integrate traps and defenses into Zomboid progression.

Required skills:

- `zomboid-mod`
- `zomboid-lua`

Tasks:

- Add progression definitions:
  - Simple Spiked Pit: Carpentry 2 natural unlock, `Basic Pit Traps` magazine, Carpentry 1 build minimum.
  - Dug Spiked Pit: Carpentry 3 natural unlock, `Advanced Pit Traps` magazine, Carpentry 2 build minimum.
  - Spiked Log Barricade: Carpentry 4 natural unlock, `Spiked Barricades` magazine, Carpentry 2 build minimum.
- Add magazine/schematic items using vanilla magazine/book icons.
- Add literature/schematic loot only as needed for progression.
- Do not add direct weapon/ammo loot distributions.
- Verify whether natural skill unlock requires custom Lua.
- Add XP awards if default recipe/build XP is insufficient.

Deliverables:

- Trap recipes and magazines work as designed.
- Players can learn early via magazine but still need lower build minimum skill.

Verification:

- Recipes appear correctly.
- Skill unlock path works.
- Magazine path works.
- Build minimum remains enforced.

## Phase 9 - Bows, Arrows, And Early Horde Combat

Goal:

- Provide viable early-game ranged support without changing weapon/ammo loot.

Required skills:

- `zomboid-mod`
- `zomboid-lua`

Tasks:

- Inspect `Bows/OWTL_Bows/mod.info`.
- Inspect existing scripts, Lua, textures, sounds, and `Zed_Back_Spawn.lua`.
- Use bundled Kitsune Crossbow work as reference only.
- Implement V1 weapon scope:
  - Basic Bow.
  - Improved Bow.
- Implement V1 ammo scope:
  - Basic Arrows.
  - Improved Arrows.
- Basic Bow and Basic Arrows are craftable from the beginning.
- Improved Bow and Improved Arrows use progression.
- No crossbows in V1 unless trivial later.
- No zombie-attached bow or arrow spawns.
- Use Aiming and Reloading:
  - Aiming affects accuracy/damage.
  - Reloading affects draw/reload speed.
- Include arrow recovery from zombie corpses.
- Exclude missed-shot/ground recovery from V1.
- Balance target:
  - bows are viable for early horde defense with preparation
  - firearms remain superior for burst killing

Deliverables:

- Craftable bows and arrows with working reload/fire behavior.
- Corpse-based arrow recovery.

Verification:

- Bow firing works.
- Ammo consumption and recovery work.
- Noise is lower than firearms.
- First Blood Moon is survivable with reasonable preparation.

## Phase 10 - Integration And Compatibility Pass

Goal:

- Make V1 systems work together without requiring third-party edits.

Required skills:

- `zomboid-mod`
- `zomboid-lua`

Tasks:

- Run a full single-player loop:
  - schedule
  - warning
  - start cue
  - horde spawn
  - horde pursuit
  - traps
  - bows
  - death/respawn if needed
  - dawn reversion
  - stage advance
- Run a multiplayer loop:
  - grouped players
  - far-apart players
  - horde caps
  - death/logout/respawn retargeting
  - new joiner behavior
- Check interactions between `OWTL_BloodMoon`, `OWTL_Player`, `OWTL_Traps`, and `OWTL_Bows`.
- Verify no bundled third-party folders were edited.
- Verify symlinked mod paths under `/Users/tneary/Zomboid/mods` only if local game behavior needs it.

Deliverables:

- Playable V1 integration build.
- Known-issues list for playtesting.

Verification:

- No startup Lua errors.
- Core loop completes at least once in single-player.
- Core multiplayer allocation behavior is validated or documented as unverified.

## First Implementation Slice

Start here:

1. Audit existing OWTL module folders and `mod.info` files.
2. Create `Horde_Night/OWTL_BloodMoon`.
3. Create `Player/OWTL_Player`.
4. Add native sandbox options and shared constants.
5. Add scheduler state schema and admin status command.

Exit criteria:

- A new save can load with both new modules enabled.
- Blood Moon settings exist.
- Scheduler initializes and can be inspected by admin/debug command.
- No horde spawning or player death behavior is required in this first slice.
