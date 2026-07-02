OWTL_Player = OWTL_Player or {}
OWTL_Player.Data = OWTL_Player.Data or {}

local constants = OWTL_Player.Constants

function OWTL_Player.Data.Ensure(player)
    if not player or not player.getModData then
        return nil
    end

    local modData = player:getModData()
    if not modData then
        return nil
    end

    modData[constants.PLAYER_DATA_KEY] = modData[constants.PLAYER_DATA_KEY] or {}
    local data = modData[constants.PLAYER_DATA_KEY]
    data.schemaVersion = data.schemaVersion or constants.DATA_VERSION
    data.home = data.home or nil
    data.lastDeathDay = data.lastDeathDay or nil
    data.lastRespawnDay = data.lastRespawnDay or nil

    return data
end
