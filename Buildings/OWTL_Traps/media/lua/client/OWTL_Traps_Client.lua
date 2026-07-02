require "OWTL_Traps_Definitions"
require "TimedActions/ISBaseTimedAction"

OWTL_Traps = OWTL_Traps or {}
OWTL_Traps.Client = OWTL_Traps.Client or {}

local defs = OWTL_Traps.Definitions
local lastPlayerTrigger = {}
local zombieScanTick = 0

local function safeCall(fn)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return nil
end

local function simpleType(fullType)
    local dot = string.find(fullType, ".", 1, true)
    if dot then
        return string.sub(fullType, dot + 1)
    end
    return fullType
end

local function getSquareFromWorldObjects(worldobjects)
    if not worldobjects then
        return nil
    end
    for _, object in ipairs(worldobjects) do
        local square = safeCall(function() return object:getSquare() end)
        if square then
            return square
        end
    end
    local player = getPlayer and getPlayer() or nil
    return player and safeCall(function() return player:getCurrentSquare() end) or nil
end

local function getItemCount(inventory, fullType)
    if not inventory then
        return 0
    end
    return safeCall(function() return inventory:getItemCountRecurse(fullType) end)
        or safeCall(function() return inventory:getItemCount(simpleType(fullType), true) end)
        or 0
end

local function hasKeepTool(inventory, toolName)
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

local function hasMaterials(player, trapDef, repair)
    if not player or not trapDef then
        return false
    end
    local inventory = player:getInventory()
    local materials = repair and trapDef.repairMaterials or trapDef.materials
    for fullType, count in pairs(materials) do
        if getItemCount(inventory, fullType) < count then
            return false
        end
    end
    if not repair and trapDef.keep then
        for _, toolName in ipairs(trapDef.keep) do
            if not hasKeepTool(inventory, toolName) then
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

local function consumeMaterials(player, materials)
    local inventory = player and player:getInventory()
    if not inventory or not materials then
        return false
    end
    for fullType, count in pairs(materials) do
        for _ = 1, count do
            safeCall(function() inventory:RemoveOneOf(simpleType(fullType)) end)
        end
    end
    return true
end

local function awardBuildXp(player, trapDef)
    if not player or not trapDef or not trapDef.buildXp or trapDef.buildXp <= 0 then
        return
    end
    local xp = safeCall(function() return player:getXp() end)
    if xp and Perks and Perks.Woodwork then
        safeCall(function() xp:AddXP(Perks.Woodwork, trapDef.buildXp) end)
    end
end

local function squareHasTrap(square)
    if not square then
        return false
    end
    if square:getModData().OWTL_TrapPresent == true then
        return true
    end
    local objects = safeCall(function() return square:getWorldObjects() end)
    if not objects then
        return false
    end
    for i = 0, objects:size() - 1 do
        local worldObject = objects:get(i)
        local item = safeCall(function() return worldObject:getItem() end)
        if defs.IsOWTLTrapItem(item) then
            return true
        end
    end
    return false
end

local function findTrapWorldItem(square)
    local objects = square and safeCall(function() return square:getWorldObjects() end) or nil
    if not objects then
        return nil, nil
    end
    for i = 0, objects:size() - 1 do
        local worldItem = objects:get(i)
        local item = safeCall(function() return worldItem:getItem() end)
        if defs.IsOWTLTrapItem(item) then
            return worldItem, item
        end
    end
    return nil, nil
end

local function syncTrapLocal(square, worldItem, item, trapDef, uses)
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
    safeCall(function() square:transmitModdata() end)
end

local function applyZombieDamageLocal(zombie, trapDef)
    local health = zombie and safeCall(function() return zombie:getHealth() end) or nil
    if not health then
        return
    end
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

local function applyPlayerDamageLocal(player, trapDef)
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

local function triggerTrapLocal(square, target)
    local worldItem, item = findTrapWorldItem(square)
    local trapDef = item and defs.Get(item:getModData().owtlTrapId)
    if not worldItem or not item or not trapDef then
        return false
    end
    local uses = tonumber(item:getModData().uses) or trapDef.maxUses
    if uses <= 0 or item:getModData().active == false then
        return false
    end
    if target and instanceof(target, "IsoZombie") then
        applyZombieDamageLocal(target, trapDef)
    elseif target and instanceof(target, "IsoPlayer") then
        applyPlayerDamageLocal(target, trapDef)
    end
    syncTrapLocal(square, worldItem, item, trapDef, uses - 1)
    return true
end

local function placeTrapLocal(player, trapId, square)
    local trapDef = defs.Get(trapId)
    if not player or not trapDef or not square or squareHasTrap(square) then
        return
    end
    if not hasMaterials(player, trapDef, false) then
        return
    end

    consumeMaterials(player, trapDef.materials)
    local item = InventoryItemFactory.CreateItem(trapDef.itemType)
    if not item then
        return
    end
    item:getModData().owtlTrapId = trapId
    item:getModData().uses = trapDef.maxUses
    item:getModData().maxUses = trapDef.maxUses
    item:getModData().condition = trapDef.maxUses
    item:getModData().active = true
    local placed = square:AddWorldInventoryItem(item, 0.5, 0.5, 0)
    local worldItem = safeCall(function() return placed:getWorldItem() end) or placed
    if worldItem then
        worldItem:getModData().owtlTrapId = trapId
        worldItem:getModData().uses = trapDef.maxUses
        worldItem:getModData().maxUses = trapDef.maxUses
        worldItem:getModData().condition = trapDef.maxUses
        worldItem:getModData().active = true
        safeCall(function() worldItem:transmitModData() end)
    end
    square:getModData().OWTL_TrapPresent = true
    square:transmitModdata()
    awardBuildXp(player, trapDef)
end

OWTLBuildTrapAction = ISBaseTimedAction:derive("OWTLBuildTrapAction")

function OWTLBuildTrapAction:isValid()
    return self.character and self.square and hasMaterials(self.character, self.trapDef, false) and not squareHasTrap(self.square)
end

function OWTLBuildTrapAction:perform()
    if isClient and isClient() then
        sendClientCommand(self.character, defs.COMMAND_MODULE, "BuildTrap", {
            trapId = self.trapDef.id,
            x = self.square:getX(),
            y = self.square:getY(),
            z = self.square:getZ(),
        })
    else
        placeTrapLocal(self.character, self.trapDef.id, self.square)
    end
    ISBaseTimedAction.perform(self)
end

function OWTLBuildTrapAction:new(character, square, trapDef)
    local o = ISBaseTimedAction.new(self, character)
    o.character = character
    o.square = square
    o.trapDef = trapDef
    o.maxTime = trapDef.buildTime
    if character and character:isTimedActionInstant() then
        o.maxTime = 1
    end
    return o
end

OWTLRepairTrapAction = ISBaseTimedAction:derive("OWTLRepairTrapAction")

function OWTLRepairTrapAction:isValid()
    return self.character and self.square and self.worldItem and hasMaterials(self.character, self.trapDef, true)
end

function OWTLRepairTrapAction:perform()
    if isClient and isClient() then
        sendClientCommand(self.character, defs.COMMAND_MODULE, "RepairTrap", {
            x = self.square:getX(),
            y = self.square:getY(),
            z = self.square:getZ(),
            keyId = self.worldItem:getKeyId(),
        })
    else
        consumeMaterials(self.character, self.trapDef.repairMaterials)
        local item = self.worldItem:getItem()
        item:getModData().uses = self.trapDef.maxUses
        item:getModData().condition = self.trapDef.maxUses
        item:getModData().active = true
        self.worldItem:getModData().uses = self.trapDef.maxUses
        self.worldItem:getModData().condition = self.trapDef.maxUses
        self.worldItem:getModData().active = true
        self.worldItem:transmitModData()
        self.square:getModData().OWTL_TrapPresent = true
        self.square:transmitModdata()
    end
    ISBaseTimedAction.perform(self)
end

function OWTLRepairTrapAction:new(character, square, worldItem, trapDef)
    local o = ISBaseTimedAction.new(self, character)
    o.character = character
    o.square = square
    o.worldItem = worldItem
    o.trapDef = trapDef
    o.maxTime = trapDef.repairTime
    if character and character:isTimedActionInstant() then
        o.maxTime = 1
    end
    return o
end

local function addTooltip(option, player, trapDef, repair)
    local tooltip = ISToolTip:new()
    tooltip:initialise()
    tooltip:setVisible(false)
    tooltip:setName((repair and "Repair " or "Build ") .. trapDef.displayName)
    tooltip.description = "Needs:"
    local inventory = player:getInventory()
    local materials = repair and trapDef.repairMaterials or trapDef.materials
    for fullType, count in pairs(materials) do
        local have = getItemCount(inventory, fullType)
        local color = have >= count and " <RGB:0,1,0> " or " <RGB:1,0,0> "
        tooltip.description = tooltip.description .. " <LINE>" .. color .. simpleType(fullType) .. " " .. have .. "/" .. count
    end
    if not repair and trapDef.keep then
        for _, toolName in ipairs(trapDef.keep) do
            local color = hasKeepTool(inventory, toolName) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
            tooltip.description = tooltip.description .. " <LINE>" .. color .. toolName
        end
    end
    if not repair and Perks and Perks.Woodwork then
        local level = player:getPerkLevel(Perks.Woodwork)
        local color = level >= trapDef.carpentry and " <RGB:0,1,0> " or " <RGB:1,0,0> "
        tooltip.description = tooltip.description .. " <LINE>" .. color .. "Carpentry " .. level .. "/" .. trapDef.carpentry
    end
    if not repair then
        local known = defs.KnowsRecipe(player, trapDef.recipeName)
        local natural = defs.HasNaturalUnlock(player, trapDef)
        local color = (known or natural) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
        tooltip.description = tooltip.description .. " <LINE>" .. color .. "Recipe: " .. trapDef.recipeName
        if not known and not natural then
            tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> Read " .. simpleType(trapDef.magazineType) .. " or reach Carpentry " .. trapDef.naturalCarpentry
        end
    end
    tooltip.description = tooltip.description .. " <LINE> Uses: " .. trapDef.maxUses .. " Damage: " .. trapDef.damage
    option.toolTip = tooltip
end

local function onBuildTrap(worldobjects, playerIndex, trapId, square)
    local player = getSpecificPlayer(playerIndex)
    local trapDef = defs.Get(trapId)
    if not player or not trapDef or not square then
        return
    end
    ISTimedActionQueue.add(OWTLBuildTrapAction:new(player, square, trapDef))
end

local function findTrapWorldItems(worldobjects)
    local result = {}
    for _, object in ipairs(worldobjects or {}) do
        local square = safeCall(function() return object:getSquare() end)
        local objects = square and safeCall(function() return square:getWorldObjects() end) or nil
        if objects then
            for i = 0, objects:size() - 1 do
                local worldItem = objects:get(i)
                local item = safeCall(function() return worldItem:getItem() end)
                if defs.IsOWTLTrapItem(item) then
                    table.insert(result, { square = square, worldItem = worldItem, item = item })
                end
            end
        end
    end
    return result
end

local function onRepairTrap(worldobjects, playerIndex, trapInfo)
    local player = getSpecificPlayer(playerIndex)
    if not player or not trapInfo then
        return
    end
    local trapId = trapInfo.item:getModData().owtlTrapId
    local trapDef = defs.Get(trapId)
    if not trapDef then
        return
    end
    ISTimedActionQueue.add(OWTLRepairTrapAction:new(player, trapInfo.square, trapInfo.worldItem, trapDef))
end

local function addBuildMenu(playerIndex, context, worldobjects, test)
    if test and ISWorldObjectContextMenu and ISWorldObjectContextMenu.Test then
        return true
    end
    local player = getSpecificPlayer(playerIndex)
    local square = getSquareFromWorldObjects(worldobjects)
    if not player or not square or player:getVehicle() then
        return
    end
    defs.GrantNaturalRecipes(player)

    local defensesOption = context:addOption("Build OWTL Defenses", worldobjects, nil)
    local defensesMenu = ISContextMenu:getNew(context)
    context:addSubMenu(defensesOption, defensesMenu)

    for _, trapId in ipairs(defs.ORDER) do
        local trapDef = defs.Get(trapId)
        local option = defensesMenu:addOption(trapDef.displayName, worldobjects, onBuildTrap, playerIndex, trapId, square)
        if squareHasTrap(square) or not hasMaterials(player, trapDef, false) then
            option.notAvailable = true
        end
        addTooltip(option, player, trapDef, false)
    end

    for _, trapInfo in ipairs(findTrapWorldItems(worldobjects)) do
        local trapId = trapInfo.item:getModData().owtlTrapId
        local trapDef = defs.Get(trapId)
        if trapDef then
            local uses = tonumber(trapInfo.item:getModData().uses) or trapDef.maxUses
            if uses < trapDef.maxUses then
                local option = context:addOption("Repair " .. trapDef.displayName, worldobjects, onRepairTrap, playerIndex, trapInfo)
                if not hasMaterials(player, trapDef, true) then
                    option.notAvailable = true
                end
                addTooltip(option, player, trapDef, true)
            end
        end
    end
end

local function playerTriggerCheck(player)
    if not player or not defs.IsPlayerDamageEnabled() then
        return
    end
    local square = player:getCurrentSquare()
    if not square or square:getModData().OWTL_TrapPresent ~= true then
        return
    end
    local key = tostring(square:getX()) .. "," .. tostring(square:getY()) .. "," .. tostring(square:getZ())
    local now = getTimestampMs and getTimestampMs() or nil
    if now == nil then
        now = getTimestamp and getTimestamp() * 1000 or 0
    end
    if lastPlayerTrigger[key] and now - lastPlayerTrigger[key] < 1200 then
        return
    end
    lastPlayerTrigger[key] = now
    if isClient and isClient() then
        sendClientCommand(player, defs.COMMAND_MODULE, "TriggerPlayerTrap", {
            x = square:getX(),
            y = square:getY(),
            z = square:getZ(),
        })
    else
        triggerTrapLocal(square, player)
    end
end

local function zombieTriggerCheck(player)
    if isClient and isClient() then
        return
    end
    zombieScanTick = zombieScanTick + 1
    if zombieScanTick < 30 then
        return
    end
    zombieScanTick = 0
    if not player or not player.getCell then
        return
    end
    local zlist = safeCall(function() return player:getCell():getZombieList() end)
    if not zlist then
        return
    end
    for i = 0, zlist:size() - 1 do
        local zombie = zlist:get(i)
        local square = zombie and safeCall(function() return zombie:getCurrentSquare() end)
        if square and square:getModData().OWTL_TrapPresent == true then
            triggerTrapLocal(square, zombie)
        end
    end
end

local function onPlayerUpdate(player)
    defs.GrantNaturalRecipes(player)
    playerTriggerCheck(player)
    zombieTriggerCheck(player)
end

Events.OnFillWorldObjectContextMenu.Add(addBuildMenu)
Events.OnPlayerUpdate.Add(onPlayerUpdate)
