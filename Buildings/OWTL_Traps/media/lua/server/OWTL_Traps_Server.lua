require "OWTL_Traps_Definitions"

OWTL_Traps = OWTL_Traps or {}
OWTL_Traps.Server = OWTL_Traps.Server or {}

local defs = OWTL_Traps.Definitions
local tickCounter = 0

-- Protected-call helper. Server code touches Java-backed objects, so pcall
-- prevents one missing method from stopping the tick handler.
local function safeCall(fn)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return nil
end

-- Converts "Module.Type" to "Type" for inventory APIs that remove by simple
-- item type.
local function simpleType(fullType)
    local dot = string.find(fullType, ".", 1, true)
    if dot then
        return string.sub(fullType, dot + 1)
    end
    return fullType
end

-- Ensures the world-level trap registry exists. The registry stores simple
-- coordinates/key ids, not live world objects.
local function getRoot()
    local gameTime = getGameTime()
    local modData = gameTime and gameTime:getModData()
    if not modData then
        return nil
    end
    modData[defs.MOD_DATA_KEY] = modData[defs.MOD_DATA_KEY] or {}
    local root = modData[defs.MOD_DATA_KEY]
    root.traps = root.traps or {}
    return root
end

-- Creates a stable string key from x/y/z coordinates.
local function trapKey(x, y, z)
    return tostring(math.floor(tonumber(x) or 0)) .. "," .. tostring(math.floor(tonumber(y) or 0)) .. "," .. tostring(math.floor(tonumber(z) or 0))
end

-- Converts command args with x/y/z fields into an IsoGridSquare.
local function getSquare(args)
    local cell = getCell and getCell() or safeCall(function() return getWorld():getCell() end)
    if not cell or not args then
        return nil
    end
    return safeCall(function() return cell:getGridSquare(tonumber(args.x), tonumber(args.y), tonumber(args.z) or 0) end)
end

-- Finds a server cell. Dedicated server contexts may not have getCell(), so it
-- can fall back through online players.
local function getServerCell()
    local cell = getCell and getCell() or nil
    if cell then
        return cell
    end
    if getOnlinePlayers then
        local players = getOnlinePlayers()
        if players and players.size and players.get then
            for i = 0, players:size() - 1 do
                local player = players:get(i)
                cell = player and safeCall(function() return player:getCell() end) or nil
                if cell then
                    return cell
                end
            end
        end
    end
    return nil
end

-- Counts an item type in the player's inventory, including nested containers.
local function getItemCount(inventory, fullType)
    if not inventory then
        return 0
    end
    return safeCall(function() return inventory:getItemCountRecurse(fullType) end)
        or safeCall(function() return inventory:getItemCount(simpleType(fullType), true) end)
        or 0
end

-- Checks for a required kept tool, accepting equivalent item types for common
-- tools.
local function hasTool(inventory, toolName)
    if not inventory then
        return false
    end
    if toolName == "Hammer" then
        return safeCall(function() return inventory:getFirstTagEvalRecurse("Hammer", function(item) return not item:isBroken() end) end) ~= nil
            or safeCall(function() return inventory:containsTypeRecurse("Hammer") end) == true
            or safeCall(function() return inventory:containsTypeRecurse("HammerStone") end) == true
    end
    if toolName == "Saw" then
        return safeCall(function() return inventory:containsTypeRecurse("Saw") end) == true
            or safeCall(function() return inventory:containsTypeRecurse("GardenSaw") end) == true
    end
    if toolName == "Shovel" then
        return safeCall(function() return inventory:containsTypeRecurse("Shovel") end) == true
            or safeCall(function() return inventory:containsTypeRecurse("Shovel2") end) == true
            or safeCall(function() return inventory:containsTypeRecurse("HandShovel") end) == true
    end
    return safeCall(function() return inventory:containsTypeRecurse(toolName) end) == true
end

-- Server-side validation for build/repair requirements. This mirrors the
-- client menu checks so clients cannot bypass requirements.
local function hasMaterials(player, trapDef, repair)
    local inventory = player and player:getInventory()
    if not inventory or not trapDef then
        return false
    end
    local materials = repair and trapDef.repairMaterials or trapDef.materials
    for fullType, count in pairs(materials) do
        if getItemCount(inventory, fullType) < count then
            return false
        end
    end
    if not repair and trapDef.keep then
        for _, toolName in ipairs(trapDef.keep) do
            if not hasTool(inventory, toolName) then
                return false
            end
        end
    end
    if not repair and Perks and Perks.Woodwork and player:getPerkLevel(Perks.Woodwork) < trapDef.carpentry then
        return false
    end
    if not repair and not defs.HasProgressionUnlock(player, trapDef) then
        return false
    end
    return true
end

-- Removes consumed material items from inventory.
local function consumeMaterials(player, materials)
    local inventory = player and player:getInventory()
    if not inventory then
        return false
    end
    for fullType, count in pairs(materials) do
        for _ = 1, count do
            safeCall(function() inventory:RemoveOneOf(simpleType(fullType)) end)
        end
    end
    return true
end

-- Awards Carpentry XP for a completed trap build.
local function awardBuildXp(player, trapDef)
    if not player or not trapDef or not trapDef.buildXp or trapDef.buildXp <= 0 then
        return
    end
    local xp = safeCall(function() return player:getXp() end)
    if xp and Perks and Perks.Woodwork then
        safeCall(function() xp:AddXP(Perks.Woodwork, trapDef.buildXp) end)
    end
end

-- Finds an OWTL trap world item on a square, optionally matching a key id sent
-- by the client.
local function findTrapWorldItem(square, keyId)
    local objects = square and safeCall(function() return square:getWorldObjects() end) or nil
    if not objects then
        return nil, nil
    end
    for i = 0, objects:size() - 1 do
        local worldItem = objects:get(i)
        if not keyId or safeCall(function() return worldItem:getKeyId() end) == keyId then
            local item = safeCall(function() return worldItem:getItem() end)
            if defs.IsOWTLTrapItem(item) then
                return worldItem, item
            end
        end
    end
    return nil, nil
end

-- True when a square already contains an OWTL trap.
local function squareHasTrap(square)
    local worldItem = findTrapWorldItem(square)
    return worldItem ~= nil
end

-- Adds or updates the trap in the world-level registry used by zombie scans.
local function registerTrap(square, worldItem, trapId)
    local root = getRoot()
    if not root or not square or not worldItem then
        return
    end
    local key = trapKey(square:getX(), square:getY(), square:getZ())
    root.traps[key] = {
        x = square:getX(),
        y = square:getY(),
        z = square:getZ(),
        keyId = worldItem:getKeyId(),
        trapId = trapId,
    }
end

-- Synchronizes uses/condition/active state to item modData, world item modData,
-- and square modData.
local function syncTrap(square, worldItem, item, trapDef, uses)
    local active = uses > 0
    item:getModData().uses = uses
    item:getModData().condition = uses
    item:getModData().maxUses = trapDef.maxUses
    item:getModData().active = active
    worldItem:getModData().uses = uses
    worldItem:getModData().condition = uses
    worldItem:getModData().maxUses = trapDef.maxUses
    worldItem:getModData().active = active
    safeCall(function() worldItem:transmitModData() end)
    square:getModData().OWTL_TrapPresent = active
    square:transmitModdata()
end

-- Authoritative multiplayer build command. It validates the request, consumes
-- materials, creates the trap item, registers it, and awards XP.
function OWTL_Traps.Server.BuildTrap(player, args)
    local trapDef = args and defs.Get(args.trapId)
    local square = getSquare(args)
    defs.GrantNaturalRecipes(player)
    if not player or not trapDef or not square or squareHasTrap(square) or not hasMaterials(player, trapDef, false) then
        return
    end

    consumeMaterials(player, trapDef.materials)
    local item = InventoryItemFactory.CreateItem(trapDef.itemType)
    if not item then
        return
    end
    item:getModData().owtlTrapId = trapDef.id
    item:getModData().uses = trapDef.maxUses
    item:getModData().maxUses = trapDef.maxUses
    item:getModData().condition = trapDef.maxUses
    item:getModData().active = true
    local placed = square:AddWorldInventoryItem(item, 0.5, 0.5, 0)
    local worldItem = safeCall(function() return placed:getWorldItem() end) or placed
    if worldItem then
        worldItem:getModData().owtlTrapId = trapDef.id
        syncTrap(square, worldItem, item, trapDef, trapDef.maxUses)
        registerTrap(square, worldItem, trapDef.id)
        awardBuildXp(player, trapDef)
    end
end

-- Applies damage to a zombie that stepped on a trap.
local function applyZombieDamage(zombie, trapDef)
    if not zombie or not trapDef then
        return
    end
    local health = safeCall(function() return zombie:getHealth() end)
    if health then
        local nextHealth = health - trapDef.damage
        if nextHealth <= 0 then
            safeCall(function() zombie:Kill(nil) end)
            safeCall(function() zombie:setHealth(0) end)
        else
            safeCall(function() zombie:setHealth(nextHealth) end)
            if trapDef.id ~= "SpikedLogBarricade" and ZombRand and ZombRand(3) == 0 then
                safeCall(function() zombie:toggleCrawling() end)
            end
        end
    end
end

-- Applies player foot damage when player trap damage is enabled.
local function applyPlayerDamage(player, trapDef)
    if not player or not trapDef or not defs.IsPlayerDamageEnabled() then
        return
    end
    local bodyDamage = player:getBodyDamage()
    if not bodyDamage or not BodyPartType then
        return
    end
    local part = bodyDamage:getBodyPart(BodyPartType.Foot_L)
    if ZombRand and ZombRand(2) == 0 then
        part = bodyDamage:getBodyPart(BodyPartType.Foot_R)
    end
    if part then
        safeCall(function() part:generateDeepWound() end)
        safeCall(function() part:AddDamage(trapDef.playerDamage) end)
    end
end

-- Triggers one trap, applies target damage, reduces uses, and synchronizes the
-- changed trap state.
local function triggerTrap(square, worldItem, item, trapDef, target)
    if not square or not worldItem or not item or not trapDef then
        return false
    end
    local uses = tonumber(item:getModData().uses) or trapDef.maxUses
    if uses <= 0 or item:getModData().active == false then
        return false
    end

    if target and instanceof(target, "IsoZombie") then
        applyZombieDamage(target, trapDef)
    elseif target and instanceof(target, "IsoPlayer") then
        applyPlayerDamage(target, trapDef)
    end

    uses = uses - 1
    syncTrap(square, worldItem, item, trapDef, uses)
    return true
end

-- Authoritative repair command. It validates materials, consumes them, and
-- restores the trap to max uses.
function OWTL_Traps.Server.RepairTrap(player, args)
    local square = getSquare(args)
    local worldItem, item = findTrapWorldItem(square, args and args.keyId)
    local trapDef = item and defs.Get(item:getModData().owtlTrapId)
    if not player or not square or not worldItem or not item or not trapDef or not hasMaterials(player, trapDef, true) then
        return
    end
    consumeMaterials(player, trapDef.repairMaterials)
    syncTrap(square, worldItem, item, trapDef, trapDef.maxUses)
    registerTrap(square, worldItem, trapDef.id)
end

-- Multiplayer player-trigger command. The client notices the player standing on
-- a trap, but the server applies the actual damage and use reduction.
function OWTL_Traps.Server.TriggerPlayerTrap(player, args)
    if not defs.IsPlayerDamageEnabled() then
        return
    end
    local square = getSquare(args)
    local worldItem, item = findTrapWorldItem(square)
    local trapDef = item and defs.Get(item:getModData().owtlTrapId)
    if square and worldItem and item and trapDef then
        triggerTrap(square, worldItem, item, trapDef, player)
    end
end

-- Server zombie scan. It checks registered trap coordinates against live zombie
-- positions and triggers the matching trap when a zombie stands on it.
local function scanZombieTriggers()
    local root = getRoot()
    if not root or not root.traps then
        return
    end
    local cell = getServerCell()
    local zlist = cell and safeCall(function() return cell:getZombieList() end) or nil
    if not zlist then
        return
    end

    for key, trapInfo in pairs(root.traps) do
        local square = getSquare(trapInfo)
        local worldItem, item = findTrapWorldItem(square, trapInfo.keyId)
        local trapDef = item and defs.Get(item:getModData().owtlTrapId)
        if not square or not worldItem or not item or not trapDef then
            root.traps[key] = nil
        else
            for i = 0, zlist:size() - 1 do
                local zombie = zlist:get(i)
                if zombie and math.floor(zombie:getX()) == trapInfo.x and math.floor(zombie:getY()) == trapInfo.y and math.floor(zombie:getZ()) == trapInfo.z then
                    triggerTrap(square, worldItem, item, trapDef, zombie)
                    break
                end
            end
        end
    end
end

-- Tick hook throttled to every 30 ticks so zombie scans are not run every frame.
local function onTick()
    if not isServer() then
        return
    end
    tickCounter = tickCounter + 1
    if tickCounter < 30 then
        return
    end
    tickCounter = 0
    scanZombieTriggers()
end

-- Dispatches client commands from OWTL_Traps_Client.lua to server functions.
local function onClientCommand(module, command, player, args)
    if not isServer() or module ~= defs.COMMAND_MODULE then
        return
    end
    if command == "BuildTrap" then
        OWTL_Traps.Server.BuildTrap(player, args)
    elseif command == "RepairTrap" then
        OWTL_Traps.Server.RepairTrap(player, args)
    elseif command == "TriggerPlayerTrap" then
        OWTL_Traps.Server.TriggerPlayerTrap(player, args)
    end
end

Events.OnClientCommand.Add(onClientCommand)
Events.OnTick.Add(onTick)
