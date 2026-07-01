OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.PlayerData = OWTL_BloodMoon.PlayerData or {}

local constants = OWTL_BloodMoon.Constants

function OWTL_BloodMoon.PlayerData.Ensure(player)
    if not player or not player.getModData then
        return nil
    end

    local modData = player:getModData()
    if not modData then
        return nil
    end

    modData[constants.PLAYER_BLOOD_MOON_DATA_KEY] = modData[constants.PLAYER_BLOOD_MOON_DATA_KEY] or {}
    local data = modData[constants.PLAYER_BLOOD_MOON_DATA_KEY]
    data.schemaVersion = data.schemaVersion or constants.DATA_VERSION
    data.activeGroupId = data.activeGroupId or nil
    data.lastKnownEventDay = data.lastKnownEventDay or nil
    data.lastWarningDay = data.lastWarningDay or nil

    return data
end
