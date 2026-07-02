OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.Constants = OWTL_BloodMoon.Constants or {}

local constants = OWTL_BloodMoon.Constants

constants.MOD_ID = "OWTL_BloodMoon"
constants.MOD_NAME = "OWTL Blood Moon"
constants.DATA_VERSION = 1

constants.GAME_TIME_DATA_KEY = "OWTL_BloodMoon"
constants.PLAYER_BLOOD_MOON_DATA_KEY = "OWTL_BloodMoonPlayer"
constants.PLAYER_LIFECYCLE_DATA_KEY = "OWTL_Player"

constants.START_HOUR = 21
constants.END_HOUR = 6
constants.WARNING_LEAD_DAYS = 1

constants.SPAWN_MIN_TILES = 60
constants.SPAWN_MAX_TILES = 100
constants.GROUP_DISTANCE_TILES = 100

constants.HORDE_STAGES = { 20, 35, 55, 80, 110, 150 }
constants.FINAL_STAGE_ZOMBIES = 150

constants.SOUND_CUES = {
    OWTL_BloodMoonStartCue = "ZombieSurprisedPlayer",
    OWTL_BloodMoonEndCue = "Thunder",
}

function OWTL_BloodMoon.GetStageZombieCount(stage)
    if not stage or stage < 1 then
        return constants.HORDE_STAGES[1]
    end

    return constants.HORDE_STAGES[stage] or constants.FINAL_STAGE_ZOMBIES
end
