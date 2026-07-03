OWTL_Player = OWTL_Player or {}
OWTL_Player.Data = OWTL_Player.Data or {}

local constants = OWTL_Player.Constants

-- Runs a function with pcall, Lua's protected-call helper. If a Project
-- Zomboid Java method is missing or throws, this returns nil instead of
-- stopping the whole mod with an error.
local function safeCall(fn)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return nil
end

-- Builds a stable key for saving one player's persistent data. Multiplayer
-- prefers username, then character name, then online id. Single-player stores
-- everything under one simple key.
local function getPlayerKey(player)
    if not player then
        return "unknown"
    end

    if not isClient or not isClient() then
        return "single_player"
    end

    local username = safeCall(function() return player:getUsername() end)
    if username and username ~= "" then
        return tostring(username)
    end

    local descriptor = safeCall(function() return player:getDescriptor() end)
    if descriptor then
        local forename = safeCall(function() return descriptor:getForename() end) or ""
        local surname = safeCall(function() return descriptor:getSurname() end) or ""
        local name = tostring(forename) .. "_" .. tostring(surname)
        if name ~= "_" then
            return name
        end
    end

    local onlineId = safeCall(function() return player:getOnlineID() end)
    if onlineId ~= nil then
        return "online_" .. tostring(onlineId)
    end

    return "local"
end

-- Ensures the current character has an OWTL table inside player:getModData().
-- getModData() is saved with the character. The "or" assignments create fields
-- only when they do not already exist.
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

-- Public wrapper around the local key-building function. Other files call this
-- instead of duplicating the multiplayer/single-player fallback logic.
function OWTL_Player.Data.GetPlayerKey(player)
    return getPlayerKey(player)
end

-- Ensures the world-level OWTL table exists inside getGameTime():getModData().
-- This data is saved with the game world, not with one character.
function OWTL_Player.Data.GetGameRoot()
    local gameTime = safeCall(function() return getGameTime() end)
    if not gameTime or not gameTime.getModData then
        return nil
    end

    local modData = gameTime:getModData()
    if not modData then
        return nil
    end

    modData[constants.GAME_DATA_KEY] = modData[constants.GAME_DATA_KEY] or {}
    local root = modData[constants.GAME_DATA_KEY]
    root.schemaVersion = root.schemaVersion or constants.DATA_VERSION
    root.players = root.players or {}
    return root
end

-- Returns the persistent per-player record stored at the world level. This lets
-- a newly created replacement character recover home, progression, and
-- inventory data saved by a previous character.
function OWTL_Player.Data.GetPersistent(player)
    local root = OWTL_Player.Data.GetGameRoot()
    if not root then
        return nil
    end

    local key = getPlayerKey(player)
    root.players[key] = root.players[key] or {}
    local data = root.players[key]
    data.schemaVersion = data.schemaVersion or constants.DATA_VERSION
    data.home = data.home or nil
    data.progression = data.progression or nil
    data.inventoryRestore = data.inventoryRestore or nil
    data.lastDeathDay = data.lastDeathDay or nil
    data.lastRespawnDay = data.lastRespawnDay or nil
    data.unverified = data.unverified or {}
    return data
end
