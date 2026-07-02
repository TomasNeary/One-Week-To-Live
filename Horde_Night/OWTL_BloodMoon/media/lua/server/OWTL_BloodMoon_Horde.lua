OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.Horde = OWTL_BloodMoon.Horde or {}

local constants = OWTL_BloodMoon.Constants

local registry = {
    groups = {},
    groupOrder = {},
    totalActive = 0,
    totalQueued = 0,
    nextGroupNumber = 0,
    eventStartWorldHour = nil,
}

OWTL_BloodMoon.Horde.Registry = registry

local function debugLog(message)
    if OWTL_BloodMoon.Sandbox and OWTL_BloodMoon.Sandbox.IsDebugLoggingEnabled() then
        print("[OWTL_BloodMoon] " .. tostring(message))
    end
end

local function addEvent(event, handler)
    if event and event.Add then
        event.Add(handler)
    end
end

local function getWorldHour()
    local gameTime = getGameTime()
    if gameTime and gameTime.getWorldAgeHours then
        return gameTime:getWorldAgeHours()
    end
    return 0
end

local function getPlayerName(player)
    if not player then
        return "unknown"
    end
    if player.getUsername then
        return tostring(player:getUsername())
    end
    if player.getDescriptor and player:getDescriptor() and player:getDescriptor().getForename then
        return tostring(player:getDescriptor():getForename())
    end
    return tostring(player)
end

local function playerIsUsable(player)
    if not player then
        return false
    end
    if player.isDead and player:isDead() then
        return false
    end
    if not player.getX or not player.getY or not player.getZ then
        return false
    end
    return true
end

local function distanceSquared(x1, y1, x2, y2)
    local dx = (tonumber(x1) or 0) - (tonumber(x2) or 0)
    local dy = (tonumber(y1) or 0) - (tonumber(y2) or 0)
    return (dx * dx) + (dy * dy)
end

local function getActivePlayers()
    local players = {}

    if getOnlinePlayers then
        local onlinePlayers = getOnlinePlayers()
        if onlinePlayers and onlinePlayers.size and onlinePlayers.get then
            for i = 0, onlinePlayers:size() - 1 do
                local player = onlinePlayers:get(i)
                if playerIsUsable(player) then
                    table.insert(players, player)
                end
            end
        end
    end

    if #players == 0 and getNumActivePlayers and getSpecificPlayer then
        for i = 0, getNumActivePlayers() - 1 do
            local player = getSpecificPlayer(i)
            if playerIsUsable(player) then
                table.insert(players, player)
            end
        end
    end

    if #players == 0 and getPlayer then
        local player = getPlayer()
        if playerIsUsable(player) then
            table.insert(players, player)
        end
    end

    return players
end

local function getPlayerSquareInfo(player)
    local square = nil
    local room = nil
    local building = nil

    if player and player.getSquare then
        square = player:getSquare()
    end
    if square and square.getRoom then
        room = square:getRoom()
    end
    if square and square.getBuilding then
        building = square:getBuilding()
    end

    return square, room, building
end

local function recalculateGroupCenter(group)
    local totalX = 0
    local totalY = 0
    local totalZ = 0
    local count = 0

    for i = 1, #group.players do
        local player = group.players[i]
        if playerIsUsable(player) then
            totalX = totalX + player:getX()
            totalY = totalY + player:getY()
            totalZ = totalZ + player:getZ()
            count = count + 1
        end
    end

    if count > 0 then
        group.targetX = totalX / count
        group.targetY = totalY / count
        group.targetZ = math.floor(totalZ / count)
    end
end

local function playerFitsGroup(player, group, maxDistanceSquared)
    for i = 1, #group.players do
        local other = group.players[i]
        if playerIsUsable(other) and distanceSquared(player:getX(), player:getY(), other:getX(), other:getY()) <= maxDistanceSquared then
            return true
        end
    end
    return false
end

local function groupHasPlayer(group, player)
    if not group or not player then
        return false
    end

    for i = 1, #group.players do
        if group.players[i] == player then
            return true
        end
    end

    return false
end

local function setPlayerGroup(player, groupId)
    if OWTL_BloodMoon.PlayerData and OWTL_BloodMoon.PlayerData.Ensure then
        local playerData = OWTL_BloodMoon.PlayerData.Ensure(player)
        if playerData then
            playerData.activeGroupId = groupId
            playerData.lastKnownEventDay = OWTL_BloodMoon.State and OWTL_BloodMoon.State.GetEventStartDay and OWTL_BloodMoon.State.GetEventStartDay() or nil
        end
    end
end

local function createGroup(player)
    registry.nextGroupNumber = registry.nextGroupNumber + 1
    local groupId = "bm-" .. tostring(registry.nextGroupNumber)
    local square, room, building = getPlayerSquareInfo(player)
    local group = {
        id = groupId,
        players = { player },
        playerNames = { getPlayerName(player) },
        targetX = player:getX(),
        targetY = player:getY(),
        targetZ = math.floor(player:getZ()),
        avoidRoom = room,
        avoidBuilding = building,
        activeCount = 0,
        queuedCount = 0,
        requestedCount = 0,
        spawnedZombies = {},
        allocatedWorldHour = math.floor(getWorldHour()),
    }

    registry.groups[groupId] = group
    table.insert(registry.groupOrder, groupId)
    setPlayerGroup(player, groupId)

    return group
end

local function addPlayerToGroup(player, group)
    if groupHasPlayer(group, player) then
        return
    end

    table.insert(group.players, player)
    table.insert(group.playerNames, getPlayerName(player))
    setPlayerGroup(player, group.id)
    recalculateGroupCenter(group)
end

local function buildGroups(players)
    registry.groups = {}
    registry.groupOrder = {}
    registry.nextGroupNumber = 0

    local maxDistanceSquared = constants.GROUP_DISTANCE_TILES * constants.GROUP_DISTANCE_TILES

    for i = 1, #players do
        local player = players[i]
        local matchedGroup = nil
        for j = 1, #registry.groupOrder do
            local group = registry.groups[registry.groupOrder[j]]
            if group and playerFitsGroup(player, group, maxDistanceSquared) then
                matchedGroup = group
                break
            end
        end

        if matchedGroup then
            addPlayerToGroup(player, matchedGroup)
        else
            createGroup(player)
        end
    end
end

local function squareIsValid(square, avoidRoom, avoidBuilding, requireOutside)
    if not square then
        return false
    end
    if requireOutside and square.isOutside and not square:isOutside() then
        return false
    end
    if square.isSolidFloor and not square:isSolidFloor() then
        return false
    end
    if square.isFree and not square:isFree(false) then
        return false
    end
    if avoidRoom and square.getRoom and square:getRoom() == avoidRoom then
        return false
    end
    if avoidBuilding and square.getBuilding and square:getBuilding() == avoidBuilding then
        return false
    end
    return true
end

local function getCandidateSquare(group, requireOutside)
    local cell = getCell()
    if not cell then
        return nil
    end

    local minTiles = constants.SPAWN_MIN_TILES
    local maxTiles = constants.SPAWN_MAX_TILES
    local attempts = 96

    for _ = 1, attempts do
        local radius = minTiles + ZombRand((maxTiles - minTiles) + 1)
        local angle = ZombRand(6284) / 1000
        local x = math.floor(group.targetX + (math.cos(angle) * radius))
        local y = math.floor(group.targetY + (math.sin(angle) * radius))
        local z = tonumber(group.targetZ) or 0
        local square = cell:getGridSquare(x, y, z)

        if squareIsValid(square, group.avoidRoom, group.avoidBuilding, requireOutside) then
            return square
        end
    end

    return nil
end

local function findSpawnSquare(group)
    return getCandidateSquare(group, true) or getCandidateSquare(group, false)
end

local function tagZombie(zombie, group)
    if not zombie or not zombie.getModData then
        return
    end

    local modData = zombie:getModData()
    if not modData then
        return
    end

    modData.OWTL_BloodMoon = {
        isBloodMoonHorde = true,
        groupId = group.id,
        eventStartWorldHour = registry.eventStartWorldHour,
        spawnedWorldHour = math.floor(getWorldHour()),
    }
end

local function spawnOneZombie(group)
    if not addZombiesInOutfit then
        return false
    end

    local square = findSpawnSquare(group)
    if not square then
        return false
    end

    local spawned = addZombiesInOutfit(square:getX(), square:getY(), square:getZ(), 1, nil, nil)
    if not spawned or not spawned.get then
        return false
    end

    local zombie = spawned:get(0)
    if not zombie then
        return false
    end

    tagZombie(zombie, group)
    table.insert(group.spawnedZombies, zombie)
    return true
end

local function syncState()
    if OWTL_BloodMoon.State and OWTL_BloodMoon.State.ReplaceActiveHordeGroups then
        OWTL_BloodMoon.State.ReplaceActiveHordeGroups(registry.groups, registry.totalActive, registry.totalQueued)
    end
end

local function spawnGroup(group, requestedCount, remainingServerCap)
    local groupCap = OWTL_BloodMoon.Sandbox.GetGroupHordeCap()
    local allowed = math.min(requestedCount, groupCap, remainingServerCap)
    local queued = requestedCount - allowed
    local spawned = 0

    for _ = 1, allowed do
        if spawnOneZombie(group) then
            spawned = spawned + 1
        else
            queued = queued + 1
        end
    end

    group.requestedCount = requestedCount
    group.activeCount = spawned
    group.queuedCount = queued

    registry.totalActive = registry.totalActive + spawned
    registry.totalQueued = registry.totalQueued + queued

    debugLog("group " .. tostring(group.id) .. " requested=" .. tostring(requestedCount) .. " spawned=" .. tostring(spawned) .. " queued=" .. tostring(queued))
end

function OWTL_BloodMoon.Horde.StartEvent(data)
    registry.groups = {}
    registry.groupOrder = {}
    registry.totalActive = 0
    registry.totalQueued = 0
    registry.nextGroupNumber = 0
    registry.eventStartWorldHour = data and data.eventStartWorldHour or math.floor(getWorldHour())

    local players = getActivePlayers()
    if #players == 0 then
        syncState()
        debugLog("Blood Moon horde start found no active players")
        return registry
    end

    buildGroups(players)

    local requestedCount = OWTL_BloodMoon.GetStageZombieCount(data and data.hordeStage or 1)
    local serverCap = OWTL_BloodMoon.Sandbox.GetServerHordeCap()

    for i = 1, #registry.groupOrder do
        local group = registry.groups[registry.groupOrder[i]]
        local remainingServerCap = math.max(0, serverCap - registry.totalActive)
        spawnGroup(group, requestedCount, remainingServerCap)
    end

    syncState()
    return registry
end

function OWTL_BloodMoon.Horde.EndEvent()
    registry.groups = {}
    registry.groupOrder = {}
    registry.totalActive = 0
    registry.totalQueued = 0
    registry.nextGroupNumber = 0
    registry.eventStartWorldHour = nil
end

function OWTL_BloodMoon.Horde.MergePlayer(player)
    local data = OWTL_BloodMoon.State and OWTL_BloodMoon.State.Ensure and OWTL_BloodMoon.State.Ensure() or nil
    if not data or data.isActive ~= true or not playerIsUsable(player) then
        return nil
    end

    local nearestGroup = nil
    local nearestDistance = nil
    local maxDistanceSquared = constants.GROUP_DISTANCE_TILES * constants.GROUP_DISTANCE_TILES

    for i = 1, #registry.groupOrder do
        local group = registry.groups[registry.groupOrder[i]]
        if group then
            if groupHasPlayer(group, player) then
                return group
            end
            local dist = distanceSquared(player:getX(), player:getY(), group.targetX, group.targetY)
            if dist <= maxDistanceSquared and (not nearestDistance or dist < nearestDistance) then
                nearestDistance = dist
                nearestGroup = group
            end
        end
    end

    if nearestGroup then
        addPlayerToGroup(player, nearestGroup)
        syncState()
        debugLog("merged player " .. getPlayerName(player) .. " into " .. tostring(nearestGroup.id))
        return nearestGroup
    end

    return nil
end

function OWTL_BloodMoon.Horde.GetReportLines()
    local lines = {
        "OWTL Blood Moon active horde registry",
        "groups=" .. tostring(#registry.groupOrder) .. " activeCount=" .. tostring(registry.totalActive) .. " queuedCount=" .. tostring(registry.totalQueued),
    }

    for i = 1, #registry.groupOrder do
        local group = registry.groups[registry.groupOrder[i]]
        if group then
            table.insert(lines, tostring(group.id)
                .. " players=" .. tostring(#group.players)
                .. " names=" .. table.concat(group.playerNames, ",")
                .. " target=" .. tostring(math.floor(group.targetX)) .. "," .. tostring(math.floor(group.targetY)) .. "," .. tostring(group.targetZ)
                .. " requested=" .. tostring(group.requestedCount)
                .. " active=" .. tostring(group.activeCount)
                .. " queued=" .. tostring(group.queuedCount))
        end
    end

    return lines
end

local function onClientCommand(module, command, player, args)
    if module ~= "OWTL_BloodMoon" or command ~= "PlayerAvailable" then
        return
    end
    OWTL_BloodMoon.Horde.MergePlayer(player)
end

local function onPeriodicPlayerCheck()
    local data = OWTL_BloodMoon.State and OWTL_BloodMoon.State.Ensure and OWTL_BloodMoon.State.Ensure() or nil
    if not data or data.isActive ~= true then
        return
    end

    local players = getActivePlayers()
    for i = 1, #players do
        OWTL_BloodMoon.Horde.MergePlayer(players[i])
    end
end

addEvent(Events.OnClientCommand, onClientCommand)
addEvent(Events.EveryTenMinutes, onPeriodicPlayerCheck)
