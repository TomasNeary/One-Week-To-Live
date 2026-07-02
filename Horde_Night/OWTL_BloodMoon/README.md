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

<<<<<<< HEAD
Phase 3 broadcast/audio behavior:

- `media/lua/server/OWTL_BloodMoon_Broadcast.lua` wraps `WeatherChannel.FillBroadcast`, calls the previous implementation first, then appends Blood Moon warning lines only during the one-day warning window.
- Warning text is diegetic AEBS-style copy but includes clear Blood Moon timing, stage, threat level, and estimated infected count from the current stage.
- Semantic cue names live in `OWTL_BloodMoon.Constants.SOUND_CUES`:
  - `OWTL_BloodMoonStartCue` -> `ZombieSurprisedPlayer`
  - `OWTL_BloodMoonEndCue` -> `Thunder`
- `media/lua/client/OWTL_BloodMoon_AudioClient.lua` exposes `OWTL_BloodMoon.Audio.PlayStartCue()`, `OWTL_BloodMoon.Audio.PlayEndCue()`, and generic `PlayLocalCue(cueName)`.
- Server-side start/end transitions broadcast cue commands to clients in multiplayer and call local cue playback directly in single-player where available.

This slice initializes, advances, forces, reports scheduler state, injects AEBS warning text, and plays local start/end cues only. It does not spawn hordes, apply death persistence, or change trap behavior.
=======
This slice initializes, advances, forces, and reports scheduler state only. It does not spawn hordes, apply death persistence, or change trap behavior.
>>>>>>> c4f761b22ee0330b26c5511191d5c80f5f227f97

Horde stage advances at event end only when `eventHadHordeGroup` is true, at least one active group exists, `activeHordeCount` is greater than zero, or `queuedHordeCount` is greater than zero.
