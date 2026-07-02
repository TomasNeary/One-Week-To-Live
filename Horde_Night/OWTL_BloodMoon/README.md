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
- `currentTargetPlayerName`
- `allocatedWorldHour`

Blood Moon zombie modData also records Phase 5 awareness fields:

- `targetPlayerId`
- `targetPlayerName`
- `lastAwarenessRefreshMs`
- `forcedTarget`

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

Phase 5 horde awareness behavior:

- Build 41 JavaDocs confirm `IsoZombie` has awareness helpers including `clearAggroList`, `addAggro`, and `spotted`; `IsoGameCharacter` exposes `setFollowingTarget`. The docs do not confirm that one target assignment automatically follows later player movement.
- Because automatic movement-follow behavior could not be verified without runtime testing, OWTL uses a defensive 3 real-time second `Events.OnTick` refresh.
- Refresh affects only tracked zombies whose `zombie:getModData().OWTL_BloodMoon.isBloodMoonHorde` is true.
- Each refresh reapplies target/following target, aggro, spotted state, and optional pathing toward the current group target where those methods are available at runtime.
- Player death/logout triggers a registry-wide retarget to another valid player, preferring another live player already in the same group before falling back to any active player.
- Respawned players send the same `PlayerAvailable` client command used by joiners; if they are within 100 tiles of an active group, they merge into that group and that group is retargeted.
- Dawn cleanup calls safe target/path cleanup methods when available, clears `zombie:getModData().OWTL_BloodMoon`, and clears the server registry. It does not despawn or kill remaining zombies.
- Non-Blood-Moon zombies are not enumerated or modified by the awareness refresh.

Phase 4 verification notes:

- Repository-local static checks confirmed Phase 4 wiring points, default caps, spawn band constants, Blood Moon zombie modData tagging, joiner notification, and admin active-report paths.
- Lua syntax could not be checked with `lua` or `luac`; neither command is installed in this environment.
- Local `/Users/tneary/Zomboid/mods` symlink visibility and game logs were not inspected; external filesystem verification was skipped.
- Single-player spawning is expected to run through `OWTL_BloodMoon.State.StartBloodMoon()` -> `OWTL_BloodMoon.Horde.StartEvent()` -> `addZombiesInOutfit(...)`. This is static/log-path verification only, not an in-game spawn confirmation.
- Multiplayer grouping, joiner/respawn merging, server-side `getOnlinePlayers()` enumeration, and dedicated-server availability of `addZombiesInOutfit` remain unverified in-game.

Phase 5 verification notes:

- Verified by documentation/static inspection: Build 41 JavaDocs list the aggro/awareness/following-target methods used by the defensive wrappers; PZwiki documents standard `Events` registration.
- Verified by repository-local static checks: awareness refresh is gated by active Blood Moon state and Blood Moon zombie modData; dawn cleanup clears tracking and modData but never calls despawn/remove/kill APIs.
- Not verified without in-game testing: whether native zombie target state follows player movement automatically, whether every Java method is Lua-callable on server in Build 41, exact `OnPlayerDeath`/`OnDisconnect` callback argument shape on dedicated servers, and vehicle/floor/path behavior during live pursuit.

Phase 3 broadcast/audio behavior:

- `media/lua/server/OWTL_BloodMoon_Broadcast.lua` wraps `WeatherChannel.FillBroadcast`, calls the previous implementation first, then appends Blood Moon warning lines only during the one-day warning window.
- Warning text is diegetic AEBS-style copy but includes clear Blood Moon timing, stage, threat level, and estimated infected count from the current stage.
- Semantic cue names live in `OWTL_BloodMoon.Constants.SOUND_CUES`:
  - `OWTL_BloodMoonStartCue` -> `ZombieSurprisedPlayer`
  - `OWTL_BloodMoonEndCue` -> `Thunder`
- `media/lua/client/OWTL_BloodMoon_AudioClient.lua` exposes `OWTL_BloodMoon.Audio.PlayStartCue()`, `OWTL_BloodMoon.Audio.PlayEndCue()`, and generic `PlayLocalCue(cueName)`.
- Server-side start/end transitions broadcast cue commands to clients in multiplayer and call local cue playback directly in single-player where available.

This slice initializes, advances, forces, reports scheduler state, injects AEBS warning text, plays local start/end cues, spawns bounded Blood Moon hordes, and maintains horde awareness until dawn. It does not apply death persistence, traps, or bows.

Horde stage advances at event end only when `eventHadHordeGroup` is true, at least one active group exists, `activeHordeCount` is greater than zero, or `queuedHordeCount` is greater than zero.
