# One Week To Live Gameplay Plan

## Purpose

One Week To Live is intended to provide a 7 Days to Die-style survival rhythm inside Project Zomboid while keeping Zomboid's core survival loops intact.

The core player fantasy is:

> Build a base, gather resources and weapons, and survive escalating hordes of zombies that attack every 7 days.

The mod should create a repeating preparation-and-siege structure without replacing the baseline Project Zomboid experience. Food, water, injury, infection, fatigue, scavenging, vehicles, skills, stealth, long-term base maintenance, and normal zombie behavior remain important.

## Intended Gameplay Experience

Players spend the days between Blood Moon events scouting, scavenging, building, training, repairing, and preparing. The Blood Moon is a survival test: a horde spawns nearby, knows where the player is, and pressures the player's base, escape plan, and combat readiness until sunrise.

Surviving is the only required objective. Fighting, hiding, fleeing, driving, abandoning a base, or holding a fortified position are all valid strategies. The core intended experience, however, is building and maintaining a base capable of surviving increasingly dangerous Blood Moon events.

## Blood Moon Cycle

The Blood Moon schedule is configurable.

Default behavior:

- Blood Moon occurs randomly every 5-7 in-game days.
- The warning is broadcast one day before the event.
- The event starts at 21:00 and ends at 06:00 in version 1.
- Days before the event are used for scavenging, building, weapons, resources, and skill training.
- The final preparation day is used to repair, arm traps, organize supplies, and commit to a defense or escape plan.

Setup options:

- Blood Moon system enabled or disabled.
- Random interval or fixed interval.
- Minimum and maximum random interval.
- Fixed interval length.

Fixed behavior:

- Warning lead time is always one day.
- Horde duration is fixed at 21:00 to 06:00 for version 1.

Scheduling implementation:

- Use world age/time for scheduling.
- Persist the next Blood Moon day/time in OWTL mod data.
- Persist current horde stage in OWTL mod data.
- Global Blood Moon schedule/event state lives under an `OWTL_BloodMoon` namespace in game-time mod data.
- Player-specific Blood Moon state lives under an `OWTL_BloodMoonPlayer` namespace in player mod data.
- Player lifecycle state lives under an `OWTL_Player` namespace in player mod data.
- If a Blood Moon night has no active player target, escalation does not advance.
- If a Blood Moon allocates at least one horde group, whether spawned or queued, escalation advances at dawn.

## Blood Moon Forecasting

Blood Moon forecasting should follow the same design pattern as the base game's helicopter event forecasting.

The player must:

- Find the emergency broadcast channel.
- Maintain a working radio setup.
- Monitor the broadcast to hear the Blood Moon warning.

The Blood Moon warning should be diegetic radio text on the emergency broadcast channel. There should be no general player-facing countdown UI for the first version.

Version 1 warning cadence:

- One day before Blood Moon, warning text enters the emergency broadcast cycle.
- The warning can repeat as part of that cycle.
- Warning text should vary by escalation stage.
- Warning text should be diegetic but clear enough that players understand a major night threat is expected tomorrow.
- Future work should create a pool of potential warning lines per stage band and select from them randomly.

## Horde Night Behavior

During a Blood Moon:

- A fixed number of zombies spawn nearby for each horde event.
- Only Blood Moon-spawned zombies receive special awareness.
- Blood Moon-spawned zombies know the exact player location.
- Awareness updates continuously until dawn.
- Implementation should first verify whether Build 41 zombie awareness/target state automatically follows the player once assigned.
- If it does not, update horde target/pathing every 3 real-time seconds by default.
- Hiding, entering vehicles, changing floors, moving indoors, or relocating does not break awareness.
- Blood Moon-spawned zombies otherwise behave as normal Project Zomboid zombies.
- Existing non-Blood Moon zombies continue to behave normally.
- At dawn, Blood Moon-spawned zombies revert to normal behavior.
- At dawn, clear OWTL tracking and modData from Blood Moon zombies.
- If Build 41 provides a safe API to clear forced target/path state, use it at dawn.
- Do not despawn remaining Blood Moon zombies at dawn.
- Blood Moon zombies have no visual distinction from normal zombies.

The horde does not need special structure-targeting behavior in version 1. Zombies should attack structures according to normal Project Zomboid behavior, primarily when structures block their path.

## Difficulty Escalation

Difficulty escalates by horde stage.

Version 1 escalation:

- More zombies per Blood Moon.
- Fixed zombies-per-stage table.
- Fixed escalation table.
- Final defined stage repeats indefinitely.

Version 1 default horde stages:

| Stage | Zombies |
|---:|---:|
| 1 | 20 |
| 2 | 35 |
| 3 | 55 |
| 4 | 80 |
| 5 | 110 |
| 6 | 150 |
| Final repeat | 150 |

Later escalation:

- Special zombie types.
- Special horde composition.
- Additional pressure types after playtesting.

## Base Defense

Base defense is a core pillar of the mod.

Players should be encouraged to build:

- Fortified walls.
- Gates.
- Fallback positions.
- Traps.
- Kill zones.
- Escape routes.

Initial rules:

- New wall durability remains equivalent to vanilla walls until playtesting shows a need to adjust it.
- Defenses require manual repair after Blood Moon events.
- There is no automatic repair.
- Any survival approach is valid, including mobile fallback strategies, but the central concept is a static base strong enough to survive escalating Blood Moons.

Upgrade tiers are desired:

- Wood.
- Reinforced wood.
- Metal.
- Advanced.

Resolved post-version 1 item:

- Vehicle-access fortified gates are post-version 1. They are a documented base-defense expansion requirement, not part of the first playable release.

## Traps And Buildable Defenses

Traps can damage, slow, redirect, or kill zombies. Traps also damage players.

Trap lifecycle depends on the trap:

- Consumable, such as a propane tank trap.
- Repairable, such as a spiked log trap.
- Reusable, where appropriate.
- Single-use, where appropriate.

Trap requirements may include:

- Fuel.
- Power.
- Ammo.
- Batteries.
- Manual reset.
- Repair materials.

Version 1 uses vanilla materials only.

Version 1 trap placement:

- Both build-menu defenses and crafted placeable items are allowed.
- Spiked pits and spiked log barricades are build-menu defenses.
- Future smaller traps can be crafted placeable items where appropriate.

Version 1 trap effects:

- Damage targets.
- Lose durability or uses when triggered.
- Player damage is supported and configurable.
- Slow, redirect, and stronger crowd-control effects are planned later.
- Trap gameplay is server-authoritative in multiplayer.
- Clients handle placement preview, UI, animations, and sounds only.
- Trap and defense repairs use timed context actions that consume materials.
- Repair amount is defined per defense/trap.
- Version 1 repairs restore full durability/uses; tune repair amounts later.

First traps and defenses:

- Simple spiked pit: faster and cheaper, built directly from materials, repairable.
- Dug spiked pit: preferably a multistage build where the player digs a pit first and then adds spikes; fallback is a single shovel-required build action if Build 41 multistage support is unreliable.
- Spiked log barricade: repairable, upgradeable wall/barricade defense that damages zombies when they attack or collide with it.

Relative balance targets:

- Simple spiked pit: low damage, low durability, cheap materials.
- Dug spiked pit: higher damage and durability than simple spiked pit, higher labor/material cost.
- Spiked log barricade: repeated low-to-moderate contact/attack damage, repairable defensive object.

Relevant existing OWTL folder:

- `Buildings/OWTL_Traps`

Relevant reference mods:

- `Buildings/PlayerTraps`
- `Buildings/Nolan's Traps Updates`
- `Buildings/Improved Build Menu [Build 41.51+] (basic)`
- `Buildings/Improved Build Menu [Build 41.51+] (no itemtweak)`

## Crafting And Progression

New defenses and traps should integrate into existing Project Zomboid progression.

Relevant skills:

- Carpentry.
- Metalworking.
- Electrical.
- Mechanics.

Unlock model:

- Every trap has a natural skill-level unlock.
- Magazines can teach the trap before the natural skill unlock.
- Building the trap still requires a minimum skill level.
- The minimum build skill is lower than the natural unlock skill.

Example:

- A trap may naturally unlock at Carpentry 6.
- A magazine may teach it earlier.
- Building it may still require Carpentry 3.

Version 1 progression table:

| Defense | Natural unlock | Magazine | Build minimum |
|---|---:|---|---:|
| Simple spiked pit | Carpentry 2 | Basic Pit Traps | Carpentry 1 |
| Dug spiked pit | Carpentry 3 | Advanced Pit Traps | Carpentry 2 |
| Spiked log barricade | Carpentry 4 | Spiked Barricades | Carpentry 2 |

Version 1 schematic/magazine items should use vanilla magazine/book icons. No new icon art is required for V1.

## Scavenging And Loot

Loot remains unchanged for version 1 except for possible literature/schematic items needed for recipe progression.

No version 1 changes:

- No loot table rebalance.
- No horde rewards.
- No special Blood Moon loot.
- No forced ammo or tool abundance changes.
- No deliberate loot scarcity changes.
- No direct weapon or ammo loot distribution changes.
- No zombie-attached bow or arrow spawns.
- Bow skill interactions use Aiming and Reloading in version 1.
- A custom Archery skill can be considered later, but is out of scope for version 1.
- Arrow recovery from zombie corpses is included in version 1.
- Missed-shot or ground arrow recovery is planned later.

Bow balance target:

- Bows should be viable early horde weapons when the player prepares enough arrows.
- Firearms remain superior for burst killing and emergency defense.
- Basic Bow should be accessible but limited.
- Improved Bow should be meaningfully better while still below firearms for burst damage.

The existing Zomboid scavenging loop should provide the resources needed for early versions, with later tuning based on playtesting.

## Early Game Combat Scaling

Version 1 must review early-game player/zombie scaling.

The first Blood Moons must be threatening but not impossible before the player has firearms, large stockpiles, or advanced defenses. Accessible early-game ranged weapons are expected to help solve this.

Likely version 1 direction:

- Basic bows and basic arrows are craftable from the beginning.
- Improved bows are version 1 progression items.
- Improved arrows are version 1 progression items.
- Fire, explosive, and other special arrows are post-version 1.
- Crossbows are deferred from version 1 unless implementation proves trivial.
- Crossbow/Kitsune work is reference material only.
- Low-barrier ammunition crafting.
- Early-game ranged options that do not require firearm loot.
- No zombie-attached bow or arrow spawns.

Relevant existing OWTL folder:

- `Bows/OWTL_Bows`

Relevant reference mod:

- `Bows/Remastered Kitsune's Crossbow Mod`

Reference-mod workflow:

- Use the currently bundled reference mods only.
- Do not fetch newer copies for version 1 planning or implementation unless explicitly requested later.
- Do not vendor updated external mods into the repository.

## Persistent Character

The player character should persist through death.

On death:

- Learned skills are retained.
- The player can respawn as the same character.
- Death is a setback, not a Blood Moon failure state.
- All death causes are treated the same, including Knox infection.
- Infection state resets to zero on every respawn.

Configurable death drop modes:

- Drop all.
- Drop backpack only. This is the default.
- Keep inventory.

Death drop details:

- Drop All should preserve the items the vanilla corpse would have, then respawn the persistent character without duplicating those items.
- If full vanilla corpse preservation is unreliable, fallback to dropping carried items, bags, primary/secondary weapons, belt/attached items, and other equipped non-clothing gear while clothing remains.
- Drop Backpack Only drops the equipped backpack and its contents; all other inventory is retained without duplication.
- Keep Inventory respawns with inventory retained and prevents duplicate corpse items.

Death penalties:

- Disabled by default.
- Configurable through an injury table.
- Version 1 default table uses physical setbacks that do not immediately drain health.
- Version 1 default table: broken limb, burn, severe pain, exhaustion/fatigue.
- Excluded from the default table: lacerations, deep wounds, open bleeding wounds, or any penalty likely to cause repeated death after respawn.
- Broken limb is the default/example penalty.
- Broken-limb selection is weighted random: mostly arms, sometimes legs.

Persistent data target:

- Broad persistence: skills, recipes, traits, profession, map knowledge, known media, and partial XP where technically feasible.
- Inventory is excluded from persistence because death drop handling controls items.
- Infection is excluded from persistence and is always cleared on respawn.
- Fallback if Build 41 APIs are unreliable: skills, recipes, traits, and profession.

Current planning assumption:

- Horde stage progress continues after death.
- The corpse remains lootable.

## Bed And Home Respawn

Players respawn at their assigned bed or home location.

This likely requires a new bed assignment feature:

- A player can assign a bed as home.
- Home assignment is per player.
- If no bed is assigned, the player respawns at a random location.
- Bed/home respawn is always enabled.
- Valid home objects use sleepable-object detection first.
- If sleepable-object detection is unreliable, fall back to known vanilla bed checks.
- If the bed object is gone but the stored square/location is still valid, respawn near the old home location.
- If the exact home square is unsafe or occupied, try a nearby safe square.
- If no safe nearby square is found, use random respawn.
- Single-player ignores safehouse rules for home assignment.
- Multiplayer respects safehouse ownership/permissions by default.

Required feedback:

- Bed/home context action text: `Set as Home`.
- Success confirmation: `Home set. You will respawn here.`

## Multiplayer

Multiplayer design is pure PvE.

Blood Moon behavior:

- Hordes are assigned per player group where practical.
- Players more than 100 tiles apart may receive separate horde pressure.
- Player groups are clustered by distance at Blood Moon start.
- During the event, joiners and respawned players can merge into the nearest active horde group if within 100 tiles.
- Active horde groups are not continuously recalculated for all players during the event.
- Horde pressure scales by active player hordes.
- Default server-wide Blood Moon horde cap: 300 zombies.
- Default per-group Blood Moon horde cap: 120 zombies.
- Caps are configurable.
- If caps prevent a full spawn, remaining zombies are queued and may spawn later as cap space frees.
- Queued horde spawns expire at dawn.
- Spawn ring defaults to 60-100 tiles from the target, with 60 tiles as the minimum safe distance.
- Spawn selection prefers outdoor valid squares.
- If insufficient outdoor squares are available, spawn selection may use any valid square in the spawn band.
- Do not spawn inside the player's current room/building if Build 41 APIs can detect it.

Retargeting:

- On player death or logout, horde zombies retarget to another valid player, preferably in the same group/base.
- On respawn during Blood Moon, horde pressure can retarget back to the respawned player.
- New joiners during active Blood Moon join a nearby active group horde.
- Isolated new joiners do not receive a new horde until the next Blood Moon.

Settings:

- Server-level/admin configurable.
- Bed/home respawn is per player.

PvP:

- Not an explicit design goal.
- Best-effort compatibility only.

## Player Feedback

Version 1 feedback:

- Emergency broadcast radio text for Blood Moon warnings.
- Blood Moon start audio cue.
- Blood Moon end audio cue.
- Bed/home assignment prompt.
- Blood Moon start/end cues are player-local in version 1.
- Version 1 defines semantic hooks `OWTL_BloodMoonStartCue` and `OWTL_BloodMoonEndCue`.
- Exact base-game sound IDs are selected during implementation after inspecting available Build 41 sounds.
- Server-wide/global broadcast audio is planned later.

Not planned for version 1:

- General on-screen Blood Moon warning.
- Player-facing horde stage UI.
- Visual Blood Moon sky/weather changes.

Admin/debug feedback is required for development and server administration, but not as a normal player-facing feature.

## Special Zombies

Special zombies are planned for later, not version 1.

Candidate roles:

- Tank: absorbs damage and threatens defenses.
- Runner: pressures fleeing players.
- Screamer: attracts or increases horde pressure.
- Spitter: punishes static defensive positions.
- Exploder: damages structures and traps.
- Armored: resists specific damage types.

Special zombies should appear only during Blood Moon events initially.

Reference observations from bundled mods:

- `Zombies/Night Sprinters` changes zombie speed by time, season, and rain.
- `Zombies/nocturnal zombies` and `Zombies/NocturnalZombiesFixed` apply night speed pressure.
- `Zombies/dynamic zombies` varies speed and scatter behavior.
- `Zombies/RestlessZombiesFixed` and `Horde_Night/OWTL_Horde_Night` contain examples of redirecting nearby zombies toward players.
- `Horde_Night/Expanded Helicopter Events` includes event scheduling, emergency broadcast-style content, spawned zombie handling, crawler spawning, and event audio assets.

These are inspiration sources only. Bundled third-party mods should not be edited unless explicitly requested.

## NPCs, Traders, Factions, And Quests

No NPC systems are planned for version 1.

Out of scope:

- NPC survivors.
- Traders.
- Factions.
- Quests.
- Physical NPC worldbuilding.

## Version 1 Settings

Configurable:

- Enable or disable Blood Moon system.
- Random or fixed interval.
- Minimum random interval.
- Maximum random interval.
- Fixed interval length.
- Maximum simultaneous player hordes.
- Server-wide horde cap.
- Per-group horde cap.
- Death drop mode.
- Death penalties enabled or disabled.
- Trap player damage enabled or disabled.

Fixed in version 1:

- Warning lead time: one day prior.
- Horde start/end: 21:00 to 06:00.
- Zombies per horde stage.
- Escalation stage table.
- Spawn radius/minimum safe distance.
- Horde zombies revert at dawn.
- Bed/home respawn enabled.
- Configuration uses native Project Zomboid sandbox options only.
- English-only text is acceptable for version 1.

Later:

- Special zombies enabled or disabled.
- Special zombie composition and scaling.

## Required Version 1 Systems

Version 1 requires the following systems:

- Blood Moon scheduler.
- Emergency broadcast integration.
- Horde spawning and tracking.
- Horde zombie awareness behavior.
- Horde escalation table.
- Multiplayer horde allocation and cap handling.
- Persistent character and skill retention.
- Death drop handling.
- Death penalty handling.
- Bed/home respawn system.
- Buildable defense objects.
- Trap behavior, damage, repair, and reset handling.
- Recipe and progression integration.
- Sandbox/server settings.
- Blood Moon start/end audio cue integration.
- Admin/debug tools.
- Compatibility review against bundled mods.
- Early-game ranged weapon support review.

## Minimum Viable Version

The minimum viable version is playable when it includes:

- Configurable Blood Moon schedule.
- Emergency broadcast warning.
- Spawned horde near player at 21:00.
- Horde zombies track player until 06:00.
- Horde zombies revert at dawn.
- Basic escalation table.
- Persistent character skill retention.
- Bed/home respawn.
- Death drop setting.
- Three buildable defenses:
  - Simple spiked pit.
  - Dug spiked pit.
  - Spiked log barricade.
- Basic admin/debug commands.
- Basic bow and improved bow support.

## Explicitly Out Of Scope For Version 1

Not included in version 1:

- Special zombies.
- NPCs, traders, factions, or quests.
- Loot rebalance.
- New maps or map locations.
- Major zombie AI changes beyond Blood Moon awareness.
- Visual Blood Moon sky/weather changes.
- Horde rewards.
- Story campaign.
- PvP-specific balancing.
- Full 7 Days to Die clone mechanics.

## Implementation Areas

Likely implementation areas:

- A clean new `Horde_Night/OWTL_BloodMoon` module for Blood Moon scheduling, horde spawning, tracking, and zombie awareness.
  - Module id/display name target: `OWTL_BloodMoon` / `OWTL Blood Moon`, pending `mod.info` conflict check.
- `Horde_Night/OWTL_Horde_Night` remains reference material unless explicitly migrated later.
- A clean new `Player/OWTL_Player` support module for persistent character data, death drops, death penalties, and bed/home respawn.
- `Buildings/OWTL_Traps` for traps and buildable defenses.
- `Bows/OWTL_Bows` for early ranged weapon support.

Before editing any mod folder, inspect its `mod.info` and nearby `media/lua/client`, `media/lua/server`, `media/lua/shared`, and `media/scripts` files.

## Remaining Ambiguities

The remaining ambiguities are implementation-level checks rather than core gameplay decisions:

- Exact Project Zomboid Build 41 APIs for emergency broadcast injection.
- Exact Build 41 APIs for reliable pre-death capture and post-respawn restoration.
- Exact Build 41 APIs for sleepable-object detection.
- Exact Build 41 APIs for player respawn position override.
- Exact implementation hook for zombie trap triggering.
- Exact damage values, durability values, material costs, and bow balance numbers.
- Exact base-game sound identifiers for temporary Blood Moon start/end cues.
- Exact OWTL module dependency metadata after folder inspection.
