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

This slice initializes, advances, forces, and reports scheduler state only. It does not spawn hordes, apply death persistence, or change trap behavior.

Horde stage advances at event end only when `eventHadHordeGroup` is true, at least one active group exists, `activeHordeCount` is greater than zero, or `queuedHordeCount` is greater than zero.
