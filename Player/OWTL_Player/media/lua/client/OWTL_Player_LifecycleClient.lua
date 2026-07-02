require "OWTL_Player_Constants"
require "OWTL_Player_Data"
require "OWTL_Player_Sandbox"

OWTL_Player = OWTL_Player or {}
OWTL_Player.Lifecycle = OWTL_Player.Lifecycle or {}

local constants = OWTL_Player.Constants
local lastSnapshotTick = 0

local function safeCall(fn)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return nil
end

local function javaListToTable(list)
    local result = {}
    if not list or not list.size or not list.get then
        return result
    end

    for i = 0, list:size() - 1 do
        local value = list:get(i)
        if value ~= nil then
            table.insert(result, tostring(value))
        end
    end
    return result
end

local function captureSkills(player)
    local skills = {}
    local perkList = PerkFactory and PerkFactory.PerkList
    if not player or not perkList or not perkList.size then
        return skills
    end

    local xp = safeCall(function() return player:getXp() end)
    for i = 0, perkList:size() - 1 do
        local perk = perkList:get(i)
        local perkType = safeCall(function() return perk:getType() end)
        if perkType ~= nil then
            local key = tostring(perkType)
            skills[key] = {
                level = safeCall(function() return player:getPerkLevel(perkType) end) or 0,
                xp = xp and safeCall(function() return xp:getXP(perkType) end) or nil,
            }
        end
    end
    return skills
end

local function restoreSkills(player, skills)
    if not player or not skills or not PerkFactory or not PerkFactory.PerkList then
        return
    end

    local xp = safeCall(function() return player:getXp() end)
    local perkList = PerkFactory.PerkList
    for i = 0, perkList:size() - 1 do
        local perk = perkList:get(i)
        local perkType = safeCall(function() return perk:getType() end)
        local saved = perkType and skills[tostring(perkType)] or nil
        if saved then
            safeCall(function() player:level0(perkType) end)
            if xp then
                safeCall(function() xp:setXPToLevel(perkType, 0) end)
            end

            local level = tonumber(saved.level) or 0
            for _ = 1, level do
                safeCall(function() player:LevelPerk(perkType, false) end)
            end
            if xp then
                safeCall(function() xp:setXPToLevel(perkType, level) end)
                if saved.xp then
                    local currentXp = safeCall(function() return xp:getXP(perkType) end) or 0
                    local delta = tonumber(saved.xp) - currentXp
                    if delta and delta > 0 then
                        safeCall(function() xp:AddXP(perkType, delta) end)
                    end
                end
            end
        end
    end
end

local function captureRecipes(player)
    return javaListToTable(safeCall(function() return player:getKnownRecipes() end))
end

local function restoreRecipes(player, recipes)
    local known = safeCall(function() return player:getKnownRecipes() end)
    if not known or not recipes then
        return
    end

    for _, recipe in ipairs(recipes) do
        if recipe and recipe ~= "" then
            local hasRecipe = safeCall(function() return known:contains(recipe) end)
            if not hasRecipe then
                safeCall(function() known:add(recipe) end)
            end
        end
    end
end

local function captureTraits(player)
    return javaListToTable(safeCall(function() return player:getTraits() end))
end

local function restoreTraits(player, traits)
    local target = safeCall(function() return player:getTraits() end)
    if not target or not traits then
        return
    end

    for _, trait in ipairs(traits) do
        local hasTrait = safeCall(function() return target:contains(trait) end)
        if trait and trait ~= "" and not hasTrait then
            safeCall(function() target:add(trait) end)
        end
    end
end

local function captureProfession(player)
    return safeCall(function() return player:getDescriptor():getProfession() end)
end

local function restoreProfession(player, profession)
    if not profession then
        return
    end
    local descriptor = safeCall(function() return player:getDescriptor() end)
    if descriptor then
        safeCall(function() descriptor:setProfession(profession) end)
    end
end

local function captureOptionalProgression(player, data)
    data.mapKnowledgeApiPresent = safeCall(function() return player.getKnownAreas ~= nil end) == true
    data.knownMediaApiPresent = safeCall(function() return player.getKnownMediaLines ~= nil end) == true
    data.unverifiedMapKnowledge = true
    data.unverifiedKnownMedia = true
end

function OWTL_Player.Lifecycle.CaptureProgression(player)
    local persistent = OWTL_Player.Data.GetPersistent(player)
    if not persistent then
        return nil
    end

    local progression = {
        capturedWorldAgeHours = safeCall(function() return getGameTime():getWorldAgeHours() end),
        skills = captureSkills(player),
        recipes = captureRecipes(player),
        traits = captureTraits(player),
        profession = captureProfession(player),
    }
    captureOptionalProgression(player, progression)
    persistent.progression = progression

    local playerData = OWTL_Player.Data.Ensure(player)
    if playerData then
        playerData.progression = progression
    end
    return progression
end

function OWTL_Player.Lifecycle.RestoreProgression(player)
    local persistent = OWTL_Player.Data.GetPersistent(player)
    local progression = persistent and persistent.progression
    if not progression then
        return
    end

    restoreProfession(player, progression.profession)
    restoreTraits(player, progression.traits)
    restoreRecipes(player, progression.recipes)
    restoreSkills(player, progression.skills)
end

local function collectItems(container, out, blockedContainer, blockedByParent)
    if not container or not container.getItems then
        return
    end

    local items = container:getItems()
    if not items then
        return
    end

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item then
            local blocked = blockedByParent == true or (blockedContainer and container == blockedContainer)
            local entry = {
                item = item,
                container = container,
                fullType = safeCall(function() return item:getFullType() end),
                type = safeCall(function() return item:getType() end),
                displayName = safeCall(function() return item:getDisplayName() end),
                blocked = blocked,
            }
            table.insert(out, entry)

            local nested = safeCall(function() return item:getInventory() end)
            if nested then
                collectItems(nested, out, blockedContainer, blocked)
            end
        end
    end
end

local function getBackpack(player)
    return safeCall(function() return player:getClothingItem_Back() end)
        or safeCall(function() return player:getWornItem("Back") end)
end

local function isBackpackEntry(entry, backpack, backpackInventory)
    if not entry or not backpack then
        return false
    end
    if entry.item == backpack then
        return true
    end
    if backpackInventory and entry.container == backpackInventory then
        return true
    end
    return entry.blocked == true
end

local function snapshotInventoryForMode(player, mode)
    if mode == constants.DEATH_DROP_ALL then
        return nil
    end

    local inventory = safeCall(function() return player:getInventory() end)
    if not inventory then
        return nil
    end

    local entries = {}
    local backpack = getBackpack(player)
    local backpackInventory = backpack and safeCall(function() return backpack:getInventory() end) or nil
    collectItems(inventory, entries, backpackInventory, false)

    local snapshot = {}
    for _, entry in ipairs(entries) do
        local keep = mode == constants.DEATH_DROP_KEEP_INVENTORY
        if mode == constants.DEATH_DROP_BACKPACK_ONLY then
            keep = not isBackpackEntry(entry, backpack, backpackInventory)
        end

        if keep and entry.fullType then
            table.insert(snapshot, { fullType = entry.fullType })
            safeCall(function() entry.container:Remove(entry.item) end)
        end
    end
    return snapshot
end

local function restoreInventory(player)
    local persistent = OWTL_Player.Data.GetPersistent(player)
    local snapshot = persistent and persistent.inventoryRestore
    if not snapshot then
        return
    end

    local inventory = safeCall(function() return player:getInventory() end)
    if not inventory then
        return
    end

    for _, itemData in ipairs(snapshot) do
        if itemData.fullType then
            safeCall(function() inventory:AddItem(itemData.fullType) end)
        end
    end
    persistent.inventoryRestore = nil
end

local function resetInfection(player)
    local bodyDamage = safeCall(function() return player:getBodyDamage() end)
    if not bodyDamage then
        return
    end

    safeCall(function() bodyDamage:setInfected(false) end)
    safeCall(function() bodyDamage:setInfectionLevel(0) end)
    safeCall(function() bodyDamage:setFakeInfectionLevel(0) end)
    safeCall(function() bodyDamage:setInfectionTime(-1) end)
    safeCall(function() bodyDamage:setInfectionMortalityDuration(-1) end)
end

local function getBodyPart(bodyDamage, part)
    if not bodyDamage or not BodyPartType or not part then
        return nil
    end
    return safeCall(function() return bodyDamage:getBodyPart(part) end)
end

local function applyDeathPenalty(player)
    if not OWTL_Player.Sandbox.AreDeathPenaltiesEnabled() then
        return
    end

    local roll = ZombRand and ZombRand(4) or math.random(0, 3)
    local bodyDamage = safeCall(function() return player:getBodyDamage() end)
    local stats = safeCall(function() return player:getStats() end)

    if roll == 0 and bodyDamage and BodyPartType then
        local parts = {
            BodyPartType.ForeArm_L,
            BodyPartType.ForeArm_R,
            BodyPartType.UpperArm_L,
            BodyPartType.UpperArm_R,
            BodyPartType.Hand_L,
            BodyPartType.Hand_R,
            BodyPartType.LowerLeg_L,
            BodyPartType.LowerLeg_R,
        }
        local index = ZombRand and ZombRand(#parts) + 1 or math.random(1, #parts)
        local part = getBodyPart(bodyDamage, parts[index])
        if part then
            safeCall(function() part:setFractureTime(80 + (ZombRand and ZombRand(80) or math.random(0, 79))) end)
        end
    elseif roll == 1 and bodyDamage and BodyPartType then
        local part = getBodyPart(bodyDamage, BodyPartType.Torso_Upper) or getBodyPart(bodyDamage, BodyPartType.ForeArm_L)
        if part then
            safeCall(function() part:setBurned() end)
            safeCall(function() part:AddDamage(25) end)
        end
    elseif roll == 2 then
        if stats then
            safeCall(function() stats:setPain(70) end)
        end
    else
        if stats then
            safeCall(function() stats:setFatigue(0.85) end)
            safeCall(function() stats:setEndurance(0.25) end)
        end
    end
end

local function resolvePlayer(first, second)
    if second then
        return second
    end
    if type(first) == "number" and getSpecificPlayer then
        return getSpecificPlayer(first)
    end
    return first or (getPlayer and getPlayer() or nil)
end

local function onPlayerDeath(player)
    player = resolvePlayer(player)
    if not player then
        return
    end

    OWTL_Player.Lifecycle.CaptureProgression(player)
    local persistent = OWTL_Player.Data.GetPersistent(player)
    if persistent then
        persistent.lastDeathDay = safeCall(function() return getGameTime():getNightsSurvived() end)
        persistent.inventoryRestore = snapshotInventoryForMode(player, OWTL_Player.Sandbox.GetDeathDropMode())
    end
end

local function onCreatePlayer(playerIndex, player)
    player = resolvePlayer(playerIndex, player)
    if not player then
        return
    end

    resetInfection(player)
    OWTL_Player.Lifecycle.RestoreProgression(player)
    restoreInventory(player)
    applyDeathPenalty(player)

    local persistent = OWTL_Player.Data.GetPersistent(player)
    if persistent then
        persistent.lastRespawnDay = safeCall(function() return getGameTime():getNightsSurvived() end)
    end
end

local function onPlayerUpdate(player)
    if not player then
        return
    end

    local ticks = safeCall(function() return getTimestampMs() end)
    if ticks == nil then
        local seconds = safeCall(function() return getTimestamp() end)
        if seconds ~= nil then
            ticks = seconds * 1000
        else
            ticks = (safeCall(function() return getGameTime():getWorldAgeHours() end) or 0) * 3600000
        end
    end
    if ticks - lastSnapshotTick < constants.PROGRESSION_SNAPSHOT_TICKS then
        return
    end
    lastSnapshotTick = ticks
    OWTL_Player.Lifecycle.CaptureProgression(player)
end

Events.OnPlayerDeath.Add(onPlayerDeath)
Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnPlayerUpdate.Add(onPlayerUpdate)
