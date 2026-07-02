# OWTL Blood Moon Internal Notes

Save data lives in `getGameTime():getModData().OWTL_BloodMoon`.

Current schema version: `1`.

Initial state keys:

- `schemaVersion`
- `enabled`
- `nextBloodMoonDay`
- `nextBloodMoonStartHour`
- `nextBloodMoonStartWorldHour`
- `nextBloodMoonEndDay`
- `nextBloodMoonEndHour`
- `nextBloodMoonEndWorldHour`
- `warningDay`
- `warningHour`
- `warningWorldHour`
- `hordeStage`
- `isActive`
- `warningIssued`
- `eventHadHordeGroup`
- `activeHordeGroups`
- `activeHordeCount`
- `queuedHordeCount`
- `eventStartDay`
- `eventStartWorldHour`
- `eventEndWorldHour`
- `lastWarningWorldHour`
- `lastStartedWorldHour`
- `lastEndedWorldHour`
- `lastEventAdvancedStage`
- `lastCheckedDay`
- `lastCheckedHour`
- `lastCheckedWorldHour`
- `lastScheduledInterval`
- `lastTransition`

Phase 4 horde group summaries add these per `activeHordeGroups[id]`:

- `playerCount`
- `playerNames`
- `targetX`
- `targetY`
- `targetZ`
- `requestedCount`
- `activeCount`
- `queuedCount`
- `allocatedWorldHour`

Player Blood Moon data is reserved under player mod data key `OWTL_BloodMoonPlayer`.
Player lifecycle data is reserved under player mod data key `OWTL_Player`.

Implemented admin commands:

- `/owtl status`
- `/owtl schedule`
- `/owtl active`
- `/owtl force warning`
- `/owtl force start`
- `/owtl force end`
- `/owtl setstage <number>`
- `/owtl reset`
- `/owtl help`

Phase 4 horde behavior:

- `media/lua/server/OWTL_BloodMoon_Horde.lua` owns the server-side active horde registry.
- Blood Moon start clusters currently active players by 100-tile distance without continuously recalculating all groups during the event.
- Client `OnGameStart` and `OnCreatePlayer` notifications let joiners/respawns merge into the nearest active group within 100 tiles.
- Server-wide and per-group caps are read from sandbox options, defaulting to 300 and 120.
- Spawn attempts use normal `addZombiesInOutfit` zombies in the 60-100 tile band, prefer outdoor valid squares, and fall back to valid non-outdoor squares.
- Spawned zombies receive `zombie:getModData().OWTL_BloodMoon` with `isBloodMoonHorde`, `groupId`, `eventStartWorldHour`, and `spawnedWorldHour`.
- Counts blocked by caps or failed spawn searches are queued in group and server summaries. Queues are cleared at dawn with the active registry.
- `/owtl active` reports persisted horde summaries and the live server registry.

Phase 4 verification notes:

- Repository-local static checks confirmed Phase 4 wiring points, default caps, spawn band constants, Blood Moon zombie modData tagging, joiner notification, and admin active-report paths.
- Lua syntax could not be checked with `lua` or `luac`; neither command is installed in this environment.
- Local `/Users/tneary/Zomboid/mods` symlink visibility and game logs were not inspected; external filesystem verification was skipped.
- Single-player spawning is expected to run through `OWTL_BloodMoon.State.StartBloodMoon()` -> `OWTL_BloodMoon.Horde.StartEvent()` -> `addZombiesInOutfit(...)`. This is static/log-path verification only, not an in-game spawn confirmation.
- Multiplayer grouping, joiner/respawn merging, server-side `getOnlinePlayers()` enumeration, and dedicated-server availability of `addZombiesInOutfit` remain unverified in-game.

Phase 3 broadcast/audio behavior:

- `media/lua/server/OWTL_BloodMoon_Broadcast.lua` wraps `WeatherChannel.FillBroadcast`, calls the previous implementation first, then appends Blood Moon warning lines only during the one-day warning window.
- Warning text is diegetic AEBS-style copy but includes clear Blood Moon timing, stage, threat level, and estimated infected count from the current stage.
- Semantic cue names live in `OWTL_BloodMoon.Constants.SOUND_CUES`:
  - `OWTL_BloodMoonStartCue` -> `ZombieSurprisedPlayer`
  - `OWTL_BloodMoonEndCue` -> `Thunder`
- `media/lua/client/OWTL_BloodMoon_AudioClient.lua` exposes `OWTL_BloodMoon.Audio.PlayStartCue()`, `OWTL_BloodMoon.Audio.PlayEndCue()`, and generic `PlayLocalCue(cueName)`.
- Server-side start/end transitions broadcast cue commands to clients in multiplayer and call local cue playback directly in single-player where available.

This slice initializes, advances, forces, reports scheduler state, injects AEBS warning text, plays local start/end cues, and spawns bounded Blood Moon hordes. It does not apply death persistence, traps, bows, or Phase 5 horde awareness behavior.

Horde stage advances at event end only when `eventHadHordeGroup` is true, at least one active group exists, `activeHordeCount` is greater than zero, or `queuedHordeCount` is greater than zero.
