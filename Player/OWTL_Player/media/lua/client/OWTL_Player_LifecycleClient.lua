require "OWTL_Player_Constants"
require "OWTL_Player_Data"
require "OWTL_Player_Sandbox"

OWTL_Player = OWTL_Player or {}
OWTL_Player.Lifecycle = OWTL_Player.Lifecycle or {}

local constants = OWTL_Player.Constants
local lastSnapshotTick = 0

-- Protected-call helper used around Java-backed PZ methods. Returning nil is
-- safer than letting one missing method stop death/respawn handling.
local function safeCall(fn)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return nil
end

-- Converts a Java list-like object into a normal Lua array table. Java lists are
-- zero-indexed; Lua arrays conventionally start at 1, so table.insert is used.
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

-- Captures every perk's level and XP into a table keyed by perk type string.
-- This is called repeatedly so a recent progression snapshot survives death.
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

-- Restores saved perk levels by clearing the perk then applying levels and XP.
-- The loop walks the live PerkFactory list so it only restores perks the game
-- currently knows about.
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

-- Reads known recipe names from the player and stores them as strings.
local function captureRecipes(player)
    return javaListToTable(safeCall(function() return player:getKnownRecipes() end))
end

-- Adds saved recipes back only when the new character does not already know
-- them.
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

-- Reads the character's trait list into a plain Lua table.
local function captureTraits(player)
    return javaListToTable(safeCall(function() return player:getTraits() end))
end

-- Adds saved traits back to the replacement character without duplicating
-- traits that are already present.
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

-- Saves the profession id from the player descriptor.
local function captureProfession(player)
    return safeCall(function() return player:getDescriptor():getProfession() end)
end

-- Writes the saved profession id back to the descriptor if one was captured.
local function restoreProfession(player, profession)
    if not profession then
        return
    end
    local descriptor = safeCall(function() return player:getDescriptor() end)
    if descriptor then
        safeCall(function() descriptor:setProfession(profession) end)
    end
end

-- Records that optional map/media APIs were not actually restored. The flags
-- make that limitation visible in saved data instead of implying full support.
local function captureOptionalProgression(player, data)
    data.mapKnowledgeApiPresent = safeCall(function() return player.getKnownAreas ~= nil end) == true
    data.knownMediaApiPresent = safeCall(function() return player.getKnownMediaLines ~= nil end) == true
    data.unverifiedMapKnowledge = true
    data.unverifiedKnownMedia = true
end

-- Public entry point for saving character progression. It writes both the
-- world-level persistent record and the current character's modData.
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

-- Public entry point for restoring progression after a replacement character is
-- created.
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

-- Recursively walks an inventory container and any nested bags. Each found item
-- is recorded with the container that owns it so it can be removed later.
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

-- Returns the item worn on the player's back using whichever PZ API is
-- available in this runtime.
local function getBackpack(player)
    return safeCall(function() return player:getClothingItem_Back() end)
        or safeCall(function() return player:getWornItem("Back") end)
end

-- Decides whether an inventory entry is the backpack or inside the backpack.
-- In backpack-only death-drop mode those entries are not preserved.
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

-- Creates a list of item full types to restore after respawn, then removes those
-- kept items from the dying character so the normal death drop will not also
-- leave duplicates.
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

-- Adds each saved item full type into the new character's inventory, then clears
-- the restore list so it only happens once.
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

-- Clears zombie infection state on respawn. This prevents the new character
-- from inheriting the old character's fatal infection.
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

-- Safely fetches one body part object from BodyDamage.
local function getBodyPart(bodyDamage, part)
    if not bodyDamage or not BodyPartType or not part then
        return nil
    end
    return safeCall(function() return bodyDamage:getBodyPart(part) end)
end

-- Applies one random optional death penalty: fracture, burn, pain, or fatigue.
-- The sandbox setting gates the whole function.
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

-- Normalizes PZ event callback arguments into an IsoPlayer object.
local function resolvePlayer(first, second)
    if second then
        return second
    end
    if type(first) == "number" and getSpecificPlayer then
        return getSpecificPlayer(first)
    end
    return first or (getPlayer and getPlayer() or nil)
end

-- On death, capture progression and decide what inventory should be restored
-- according to the sandbox death-drop mode.
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

-- On character creation, clear infection, restore saved progression/inventory,
-- then apply optional death penalties.
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

-- Periodically snapshots progression while the player is alive. The tick check
-- keeps this from running on every frame.
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
