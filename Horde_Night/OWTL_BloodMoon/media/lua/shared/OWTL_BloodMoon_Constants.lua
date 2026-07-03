OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.Constants = OWTL_BloodMoon.Constants or {}

local constants = OWTL_BloodMoon.Constants

-- This shared constants file defines the cross-file contract for the Blood Moon
-- module. Client, server, and shared files all read these same table fields.
constants.MOD_ID = "OWTL_BloodMoon"
constants.MOD_NAME = "OWTL Blood Moon"
constants.DATA_VERSION = 1

constants.GAME_TIME_DATA_KEY = "OWTL_BloodMoon"
constants.PLAYER_BLOOD_MOON_DATA_KEY = "OWTL_BloodMoonPlayer"
constants.PLAYER_LIFECYCLE_DATA_KEY = "OWTL_Player"

constants.START_HOUR = 21
constants.END_HOUR = 6
constants.WARNING_LEAD_DAYS = 1

-- Spawn/group settings are measured in world tiles. The horde code uses these
-- to place zombies away from players and to group nearby players together.
constants.SPAWN_MIN_TILES = 60
constants.SPAWN_MAX_TILES = 100
constants.GROUP_DISTANCE_TILES = 100

constants.HORDE_STAGES = { 20, 35, 55, 80, 110, 150 }
constants.FINAL_STAGE_ZOMBIES = 150

-- Sound cue names are local keys; values are Project Zomboid sound ids.
constants.SOUND_CUES = {
    OWTL_BloodMoonStartCue = "ZombieSurprisedPlayer",
    OWTL_BloodMoonEndCue = "Thunder",
}

-- Returns the zombie count for a horde stage. If the stage is beyond the table,
-- the final-stage value is used so late-game scaling remains defined.
function OWTL_BloodMoon.GetStageZombieCount(stage)
    if not stage or stage < 1 then
        return constants.HORDE_STAGES[1]
    end

    return constants.HORDE_STAGES[stage] or constants.FINAL_STAGE_ZOMBIES
end
