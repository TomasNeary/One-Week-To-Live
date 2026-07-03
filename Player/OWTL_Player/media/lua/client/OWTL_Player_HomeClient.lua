require "OWTL_Player_Constants"
require "OWTL_Player_Data"

OWTL_Player = OWTL_Player or {}
OWTL_Player.Home = OWTL_Player.Home or {}

local constants = OWTL_Player.Constants

-- Protected call helper. PZ exposes many Java objects to Lua, and this keeps a
-- missing method from crashing the event callback.
local function safeCall(fn)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return nil
end

-- Converts an IsoGridSquare into a plain Lua table. Plain tables are easy to
-- save in modData; Java square objects themselves should not be stored.
local function getSquarePosition(square)
    if not square then
        return nil
    end
    return {
        x = safeCall(function() return square:getX() end),
        y = safeCall(function() return square:getY() end),
        z = safeCall(function() return square:getZ() end) or 0,
    }
end

-- Small wrapper for object:getSquare() so the caller does not need its own
-- pcall each time it asks where a world object is.
local function getObjectSquare(object)
    return safeCall(function() return object:getSquare() end)
end

-- Decides whether a right-clicked world object is a reasonable "bed/home"
-- target. It first checks tile properties, then falls back to sprite names.
local function isSleepableObject(object)
    if not object then
        return false
    end

    local properties = safeCall(function() return object:getProperties() end)
    if properties then
        local bedType = safeCall(function() return properties:Val("BedType") end)
        if bedType and bedType ~= "" then
            return true
        end
        local sleepType = safeCall(function() return properties:Val("SleepType") end)
        if sleepType and sleepType ~= "" then
            return true
        end
    end

    local spriteName = safeCall(function() return object:getSprite():getName() end)
    if spriteName then
        spriteName = string.lower(tostring(spriteName))
        if string.find(spriteName, "bed") or string.find(spriteName, "mattress") or string.find(spriteName, "cot") then
            return true
        end
    end

    return false
end

-- Searches the multiplayer safehouse list for one containing the x/y tile.
-- Safehouse rectangles are checked with x/y/w/h bounds.
local function getSafehouseAt(x, y)
    if not SafeHouse or not SafeHouse.getSafehouseList then
        return nil
    end

    local list = SafeHouse.getSafehouseList()
    if not list then
        return nil
    end

    for i = 0, list:size() - 1 do
        local safehouse = list:get(i)
        local sx = safeCall(function() return safehouse:getX() end)
        local sy = safeCall(function() return safehouse:getY() end)
        local sw = safeCall(function() return safehouse:getW() end)
        local sh = safeCall(function() return safehouse:getH() end)
        if sx and sy and sw and sh and x >= sx and x < sx + sw and y >= sy and y < sy + sh then
            return safehouse
        end
    end

    return nil
end

-- In single-player all home positions are allowed. In multiplayer this confirms
-- the player is allowed to use the safehouse that contains the target tile.
local function playerAllowedSafehouse(player, x, y)
    if not isClient or not isClient() then
        return true
    end

    local safehouse = getSafehouseAt(x, y)
    if not safehouse then
        return true
    end

    local allowed = safeCall(function() return safehouse:playerAllowed(player) end)
    if allowed ~= nil then
        return allowed == true
    end

    local username = safeCall(function() return player:getUsername() end)
    if username and safeCall(function() return safehouse:getOwner() end) == username then
        return true
    end

    local players = safeCall(function() return safehouse:getPlayers() end)
    if players then
        for i = 0, players:size() - 1 do
            if tostring(players:get(i)) == tostring(username) then
                return true
            end
        end
    end
    return false
end

-- A respawn square must exist, be in an allowed safehouse area, have solid
-- floor, and not be blocked.
local function isValidRespawnSquare(player, square)
    if not square then
        return false
    end

    local pos = getSquarePosition(square)
    if not pos or pos.x == nil or pos.y == nil then
        return false
    end
    if not playerAllowedSafehouse(player, pos.x, pos.y) then
        return false
    end

    local solidFloor = safeCall(function() return square:isSolidFloor() end)
    if solidFloor == false then
        return false
    end
    local free = safeCall(function() return square:isFree(false) end)
    if free == false then
        return false
    end
    return true
end

-- Looks up an IsoGridSquare from saved numeric coordinates.
local function getSquare(x, y, z)
    local cell = safeCall(function() return getCell() end)
    if not cell then
        return nil
    end
    return safeCall(function() return cell:getGridSquare(tonumber(x), tonumber(y), tonumber(z) or 0) end)
end

-- If the exact bed tile is blocked, scan outward in a square ring until a valid
-- nearby tile is found.
local function findNearbySafeSquare(player, home)
    for radius = 1, constants.HOME_SEARCH_RADIUS do
        for dx = -radius, radius do
            for dy = -radius, radius do
                if math.abs(dx) == radius or math.abs(dy) == radius then
                    local square = getSquare(home.x + dx, home.y + dy, home.z)
                    if isValidRespawnSquare(player, square) then
                        return square, "nearby"
                    end
                end
            end
        end
    end
    return nil, nil
end

-- Moves the player to the center of a square. Project Zomboid tracks current
-- and last x/y/z positions, so both sets are updated.
local function teleportPlayer(player, square)
    local pos = getSquarePosition(square)
    if not pos then
        return false
    end

    safeCall(function() player:setX(pos.x + 0.5) end)
    safeCall(function() player:setY(pos.y + 0.5) end)
    safeCall(function() player:setZ(pos.z) end)
    safeCall(function() player:setLx(pos.x + 0.5) end)
    safeCall(function() player:setLy(pos.y + 0.5) end)
    safeCall(function() player:setLz(pos.z) end)
    return true
end

-- Reads home data from world-level persistent data first, then from the current
-- character's modData as a fallback.
local function getHome(player)
    local persistent = OWTL_Player.Data.GetPersistent(player)
    if persistent and persistent.home then
        return persistent.home
    end

    local playerData = OWTL_Player.Data.Ensure(player)
    return playerData and playerData.home or nil
end

-- Saves a selected sleepable object as the player's home respawn point.
function OWTL_Player.Home.Set(player, object)
    local square = getObjectSquare(object)
    local pos = getSquarePosition(square)
    if not player or not pos or pos.x == nil or pos.y == nil then
        return
    end

    if not playerAllowedSafehouse(player, pos.x, pos.y) then
        safeCall(function() player:Say("You do not have safehouse permission here.") end)
        return
    end

    local home = {
        x = pos.x,
        y = pos.y,
        z = pos.z,
        sprite = safeCall(function() return object:getSprite():getName() end),
        worldAgeHours = safeCall(function() return getGameTime():getWorldAgeHours() end),
    }

    local playerData = OWTL_Player.Data.Ensure(player)
    if playerData then
        playerData.home = home
    end

    local persistent = OWTL_Player.Data.GetPersistent(player)
    if persistent then
        persistent.home = home
    end

    safeCall(function() player:Say("Home set. You will respawn here.") end)
end

-- Attempts home respawn after character creation. It tries the saved square,
-- then nearby safe squares, then the old square if safehouse permission allows.
function OWTL_Player.Home.TryRespawnAtHome(player)
    if not player then
        return false
    end

    local home = getHome(player)
    if not home or not home.x or not home.y then
        return false
    end

    local exact = getSquare(home.x, home.y, home.z)
    if isValidRespawnSquare(player, exact) then
        return teleportPlayer(player, exact)
    end

    local nearby = findNearbySafeSquare(player, home)
    if nearby then
        return teleportPlayer(player, nearby)
    end

    local oldSquare = getSquare(home.x, home.y, home.z)
    if oldSquare and playerAllowedSafehouse(player, home.x, home.y) then
        return teleportPlayer(player, oldSquare)
    end

    return false
end

-- OnCreatePlayer can pass either playerIndex/player or just a player depending
-- on game context. This normalizes the event arguments before trying respawn.
local function onCreatePlayer(playerIndex, player)
    if not player and type(playerIndex) == "number" and getSpecificPlayer then
        player = getSpecificPlayer(playerIndex)
    end
    player = player or playerIndex
    OWTL_Player.Home.TryRespawnAtHome(player)
end

-- Adds "Set as Home" to the right-click menu when any clicked world object
-- looks sleepable.
local function addSetHomeOption(playerIndex, context, worldobjects)
    local player = getSpecificPlayer and getSpecificPlayer(playerIndex) or getPlayer()
    if not player or not context or not worldobjects then
        return
    end

    for _, object in ipairs(worldobjects) do
        if isSleepableObject(object) then
            context:addOption("Set as Home", player, OWTL_Player.Home.Set, object)
            return
        end
    end
end

Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnFillWorldObjectContextMenu.Add(addSetHomeOption)
