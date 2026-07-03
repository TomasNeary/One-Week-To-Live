OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.Horde = OWTL_BloodMoon.Horde or {}

local constants = OWTL_BloodMoon.Constants

-- registry is live runtime state. It may contain player and zombie objects, so
-- it is not written directly to modData; State receives summaries instead.
local registry = {
    groups = {},
    groupOrder = {},
    totalActive = 0,
    totalQueued = 0,
    nextGroupNumber = 0,
    eventStartWorldHour = nil,
    lastAwarenessRefreshMs = 0,
    awarenessRefreshCount = 0,
    retargetCount = 0,
}

OWTL_BloodMoon.Horde.Registry = registry

-- Optional debug logger for horde operations.
local function debugLog(message)
    if OWTL_BloodMoon.Sandbox and OWTL_BloodMoon.Sandbox.IsDebugLoggingEnabled() then
        print("[OWTL_BloodMoon] " .. tostring(message))
    end
end

-- Safe event registration helper.
local function addEvent(event, handler)
    if event and event.Add then
        event.Add(handler)
    end
end

-- Returns absolute world age in hours for spawn metadata and reports.
local function getWorldHour()
    local gameTime = getGameTime()
    if gameTime and gameTime.getWorldAgeHours then
        return gameTime:getWorldAgeHours()
    end
    return 0
end

-- Returns a millisecond-ish timestamp. Awareness refresh throttling uses this.
local function getNowMs()
    if getTimestampMs then
        return getTimestampMs()
    end
    if getTimestamp then
        return getTimestamp() * 1000
    end
    return math.floor(getWorldHour() * 3600000)
end

-- Best-effort display name for reports and group summaries.
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

-- Best-effort stable id for target metadata on zombies.
local function getPlayerId(player)
    if not player then
        return nil
    end
    if player.getOnlineID then
        return tostring(player:getOnlineID())
    end
    if player.getUsername then
        return tostring(player:getUsername())
    end
    return tostring(player)
end

-- A usable player must exist, be alive, and expose x/y/z methods.
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

-- A usable zombie must be alive and tagged as an OWTL Blood Moon horde zombie.
local function zombieIsUsable(zombie)
    if not zombie then
        return false
    end
    if zombie.isDead and zombie:isDead() then
        return false
    end
    if zombie.getHealth and zombie:getHealth() <= 0 then
        return false
    end
    if not zombie.getModData then
        return false
    end

    local modData = zombie:getModData()
    return modData and modData.OWTL_BloodMoon and modData.OWTL_BloodMoon.isBloodMoonHorde == true
end

-- Squared distance avoids sqrt and is enough for range comparisons.
local function distanceSquared(x1, y1, x2, y2)
    local dx = (tonumber(x1) or 0) - (tonumber(x2) or 0)
    local dy = (tonumber(y1) or 0) - (tonumber(y2) or 0)
    return (dx * dx) + (dy * dy)
end

-- Collects active players from multiplayer, split-screen, or single-player APIs.
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

-- Reads the player's square, room, and building. Spawn logic avoids spawning
-- inside that room/building.
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

-- Recomputes a group's target center from all usable players in the group.
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

-- Picks the best current player target for a group. If all original group
-- players are gone, it falls back to any active player.
local function resolveGroupTarget(group)
    if not group then
        return nil
    end

    for i = 1, #group.players do
        local player = group.players[i]
        if playerIsUsable(player) then
            return player
        end
    end

    local players = getActivePlayers()
    for i = 1, #players do
        if playerIsUsable(players[i]) then
            return players[i]
        end
    end

    return nil
end

-- Returns true when a player is close enough to any player already in a group.
local function playerFitsGroup(player, group, maxDistanceSquared)
    for i = 1, #group.players do
        local other = group.players[i]
        if playerIsUsable(other) and distanceSquared(player:getX(), player:getY(), other:getX(), other:getY()) <= maxDistanceSquared then
            return true
        end
    end
    return false
end

-- Checks whether a group already contains the exact player object.
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

-- Stores group membership in per-player modData for later inspection.
local function setPlayerGroup(player, groupId)
    if OWTL_BloodMoon.PlayerData and OWTL_BloodMoon.PlayerData.Ensure then
        local playerData = OWTL_BloodMoon.PlayerData.Ensure(player)
        if playerData then
            playerData.activeGroupId = groupId
            playerData.lastKnownEventDay = OWTL_BloodMoon.State and OWTL_BloodMoon.State.GetEventStartDay and OWTL_BloodMoon.State.GetEventStartDay() or nil
        end
    end
end

-- Creates a new horde group around one player.
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

-- Adds a player to an existing group and updates the group's center.
local function addPlayerToGroup(player, group)
    if groupHasPlayer(group, player) then
        return
    end

    table.insert(group.players, player)
    table.insert(group.playerNames, getPlayerName(player))
    setPlayerGroup(player, group.id)
    recalculateGroupCenter(group)
end

-- Removes a player from every live group, used on death/disconnect.
local function removePlayerFromGroups(player)
    if not player then
        return
    end

    for i = 1, #registry.groupOrder do
        local group = registry.groups[registry.groupOrder[i]]
        if group and group.players then
            local keptPlayers = {}
            for j = 1, #group.players do
                if group.players[j] ~= player then
                    table.insert(keptPlayers, group.players[j])
                end
            end
            group.players = keptPlayers
            if group.currentTargetPlayer == player then
                group.currentTargetPlayer = nil
                group.currentTargetPlayerName = nil
            end
            recalculateGroupCenter(group)
        end
    end
end

-- Builds groups from all active players. Nearby players share one horde group;
-- distant players receive separate groups.
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

-- Validates a candidate spawn square. It avoids solid/blocked tiles and can
-- require outside tiles before falling back to less strict placement.
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

-- Attempts random points around the group center until a valid spawn square is
-- found.
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

-- Prefer outside spawn squares; if none are found, allow any valid square.
local function findSpawnSquare(group)
    return getCandidateSquare(group, true) or getCandidateSquare(group, false)
end

-- Writes Blood Moon metadata onto a zombie so later scans know it belongs to
-- this event and group.
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
        targetPlayerId = nil,
        targetPlayerName = nil,
        lastAwarenessRefreshMs = nil,
        forcedTarget = false,
    }
end

-- Calls an object method when it exists. Varargs (...) forward any extra
-- arguments to the method.
local function callIfAvailable(object, methodName, ...)
    if object and object[methodName] then
        if pcall then
            local ok = pcall(object[methodName], object, ...)
            return ok == true
        end

        object[methodName](object, ...)
        return true
    end
    return false
end

-- Clears forced target/pathing metadata from one horde zombie.
local function clearZombieAwareness(zombie)
    if not zombie or not zombie.getModData then
        return
    end

    local modData = zombie:getModData()
    if not modData or not modData.OWTL_BloodMoon then
        return
    end

    callIfAvailable(zombie, "clearAggroList")
    callIfAvailable(zombie, "setTarget", nil)
    callIfAvailable(zombie, "setFollowingTarget", nil)
    callIfAvailable(zombie, "setPath2", nil)
    callIfAvailable(zombie, "setPathing", false)

    modData.OWTL_BloodMoon = nil
end

-- Forces a zombie to notice and path toward a target player, then records that
-- target in zombie modData and group fields.
local function applyZombieAwareness(zombie, targetPlayer, group)
    if not zombieIsUsable(zombie) or not playerIsUsable(targetPlayer) then
        return false
    end

    local modData = zombie:getModData()
    local bloodMoonData = modData and modData.OWTL_BloodMoon
    if not bloodMoonData then
        return false
    end

    callIfAvailable(zombie, "clearAggroList")
    callIfAvailable(zombie, "setTarget", targetPlayer)
    callIfAvailable(zombie, "setFollowingTarget", targetPlayer)
    callIfAvailable(zombie, "addAggro", targetPlayer, 1000)
    callIfAvailable(zombie, "spotted", targetPlayer, true)
    callIfAvailable(zombie, "setTargetSeenTime", 1000000)

    if not callIfAvailable(zombie, "pathToCharacter", targetPlayer) then
        callIfAvailable(zombie, "pathToLocation", math.floor(targetPlayer:getX()), math.floor(targetPlayer:getY()), math.floor(targetPlayer:getZ()))
    end

    bloodMoonData.groupId = group and group.id or bloodMoonData.groupId
    bloodMoonData.targetPlayerId = getPlayerId(targetPlayer)
    bloodMoonData.targetPlayerName = getPlayerName(targetPlayer)
    bloodMoonData.lastAwarenessRefreshMs = getNowMs()
    bloodMoonData.forcedTarget = true

    if group then
        group.currentTargetPlayer = targetPlayer
        group.currentTargetPlayerName = getPlayerName(targetPlayer)
    end

    return true
end

-- Spawns one zombie near the group, tags it, stores it, and gives it a target.
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
    applyZombieAwareness(zombie, resolveGroupTarget(group), group)
    return true
end

-- Sends a summary of the live registry to the scheduler state module.
local function syncState()
    if OWTL_BloodMoon.State and OWTL_BloodMoon.State.ReplaceActiveHordeGroups then
        OWTL_BloodMoon.State.ReplaceActiveHordeGroups(registry.groups, registry.totalActive, registry.totalQueued)
    end
end

-- Spawns as many zombies as allowed by group and server caps. Unspawned zombies
-- are counted as queued for status reporting.
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

-- Starts a horde event: reset registry, group active players, spawn zombies for
-- each group, and sync the result to State.
function OWTL_BloodMoon.Horde.StartEvent(data)
    registry.groups = {}
    registry.groupOrder = {}
    registry.totalActive = 0
    registry.totalQueued = 0
    registry.nextGroupNumber = 0
    registry.eventStartWorldHour = data and data.eventStartWorldHour or math.floor(getWorldHour())
    registry.lastAwarenessRefreshMs = 0
    registry.awarenessRefreshCount = 0
    registry.retargetCount = 0

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

-- Ends a horde event by clearing forced zombie awareness and wiping the live
-- registry.
function OWTL_BloodMoon.Horde.EndEvent()
    for i = 1, #registry.groupOrder do
        local group = registry.groups[registry.groupOrder[i]]
        if group and group.spawnedZombies then
            for j = 1, #group.spawnedZombies do
                clearZombieAwareness(group.spawnedZombies[j])
            end
        end
    end

    registry.groups = {}
    registry.groupOrder = {}
    registry.totalActive = 0
    registry.totalQueued = 0
    registry.nextGroupNumber = 0
    registry.eventStartWorldHour = nil
    registry.lastAwarenessRefreshMs = 0
end

-- During an active event, merge a newly available player into the nearest group
-- when close enough.
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
        OWTL_BloodMoon.Horde.RetargetGroup(nearestGroup)
        syncState()
        debugLog("merged player " .. getPlayerName(player) .. " into " .. tostring(nearestGroup.id))
        return nearestGroup
    end

    return nil
end

-- Retargets every usable zombie in one group toward the group's current target.
function OWTL_BloodMoon.Horde.RetargetGroup(group)
    local targetPlayer = resolveGroupTarget(group)
    if not targetPlayer or not group or not group.spawnedZombies then
        return 0
    end

    local retargeted = 0
    for i = 1, #group.spawnedZombies do
        if applyZombieAwareness(group.spawnedZombies[i], targetPlayer, group) then
            retargeted = retargeted + 1
        end
    end

    if retargeted > 0 then
        registry.retargetCount = registry.retargetCount + retargeted
    end

    return retargeted
end

-- Retargets all groups and returns the total number of zombies updated.
function OWTL_BloodMoon.Horde.RetargetAll()
    local retargeted = 0
    for i = 1, #registry.groupOrder do
        local group = registry.groups[registry.groupOrder[i]]
        retargeted = retargeted + OWTL_BloodMoon.Horde.RetargetGroup(group)
    end
    return retargeted
end

-- Periodically re-applies awareness so horde zombies keep pursuing players even
-- if game AI state drifts.
function OWTL_BloodMoon.Horde.RefreshAwareness(force)
    local data = OWTL_BloodMoon.State and OWTL_BloodMoon.State.Ensure and OWTL_BloodMoon.State.Ensure() or nil
    if not data or data.isActive ~= true then
        return 0
    end

    local now = getNowMs()
    if force ~= true and registry.lastAwarenessRefreshMs and now - registry.lastAwarenessRefreshMs < 3000 then
        return 0
    end

    registry.lastAwarenessRefreshMs = now

    local refreshed = 0
    for i = 1, #registry.groupOrder do
        local group = registry.groups[registry.groupOrder[i]]
        local targetPlayer = resolveGroupTarget(group)
        if group and targetPlayer and group.spawnedZombies then
            for j = 1, #group.spawnedZombies do
                if applyZombieAwareness(group.spawnedZombies[j], targetPlayer, group) then
                    refreshed = refreshed + 1
                end
            end
        end
    end

    if refreshed > 0 then
        registry.awarenessRefreshCount = registry.awarenessRefreshCount + refreshed
    end

    return refreshed
end

-- Builds admin-readable lines about the live horde registry.
function OWTL_BloodMoon.Horde.GetReportLines()
    local lines = {
        "OWTL Blood Moon active horde registry",
        "groups=" .. tostring(#registry.groupOrder) .. " activeCount=" .. tostring(registry.totalActive) .. " queuedCount=" .. tostring(registry.totalQueued),
        "awarenessRefreshCount=" .. tostring(registry.awarenessRefreshCount) .. " retargetCount=" .. tostring(registry.retargetCount),
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
                .. " queued=" .. tostring(group.queuedCount)
                .. " currentTarget=" .. tostring(group.currentTargetPlayerName or "none"))
        end
    end

    return lines
end

-- Handles the client "PlayerAvailable" command and tries to merge that player
-- into an active horde.
local function onClientCommand(module, command, player, args)
    if module ~= "OWTL_BloodMoon" or command ~= "PlayerAvailable" then
        return
    end
    OWTL_BloodMoon.Horde.MergePlayer(player)
end

-- Removes unavailable players and retargets their old zombies.
local function onPlayerUnavailable(player)
    removePlayerFromGroups(player)
    OWTL_BloodMoon.Horde.RetargetAll()
    syncState()
end

-- Periodic safety pass that merges any active players not already in a group.
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

-- Frame tick hook used for awareness refresh throttled inside RefreshAwareness.
local function onTick()
    OWTL_BloodMoon.Horde.RefreshAwareness(false)
end

addEvent(Events.OnClientCommand, onClientCommand)
addEvent(Events.EveryTenMinutes, onPeriodicPlayerCheck)
addEvent(Events.OnTick, onTick)
addEvent(Events.OnPlayerDeath, onPlayerUnavailable)
addEvent(Events.OnDisconnect, onPlayerUnavailable)
