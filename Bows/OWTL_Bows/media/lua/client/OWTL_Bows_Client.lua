OWTL_Bows = OWTL_Bows or {}
OWTL_Bows.Client = OWTL_Bows.Client or {}

-- Bow definitions are a Lua table keyed by item type. Each entry tells the
-- sprite updater which model to show when the bow is empty or loaded.
local BOWS = {
    OWTL_BasicBow = {
        emptySprite = "OWTLweapons.OWTL_BasicBow",
        drawnSprite = "OWTLweapons.OWTL_BasicBowDrawn",
    },
    OWTL_ImprovedBow = {
        emptySprite = "OWTLweapons.OWTL_ImprovedBow",
        drawnSprite = "OWTLweapons.OWTL_ImprovedBowDrawn",
    },
}

-- Arrow definitions are keyed by ammo full type. The mod stores hit counts on a
-- zombie, then uses these chances to decide what can be looted from the corpse.
local ARROWS = {
    ["OWTLweapons.OWTL_BasicArrow"] = {
        modDataKey = "OWTL_BasicArrows",
        recoveredType = "OWTLweapons.OWTL_BasicArrow",
        brokenType = "OWTLweapons.OWTL_BasicArrowBroken",
        recoverChance = 65,
        brokenChance = 25,
    },
    ["OWTLweapons.OWTL_ImprovedArrow"] = {
        modDataKey = "OWTL_ImprovedArrows",
        recoveredType = "OWTLweapons.OWTL_ImprovedArrow",
        brokenType = "OWTLweapons.OWTL_ImprovedArrowBroken",
        recoverChance = 80,
        brokenChance = 15,
    },
}

-- Runs a risky call safely. If a game method is unavailable, pcall prevents an
-- error from breaking all weapon event handling.
local function safeCall(fn)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return nil
end

-- Returns the bow definition for an inventory item, or nil when the item is not
-- one of this mod's bows.
local function getBowDef(item)
    local itemType = item and safeCall(function() return item:getType() end) or nil
    return itemType and BOWS[itemType] or nil
end

-- Boolean convenience wrapper around getBowDef().
local function isBow(item)
    return getBowDef(item) ~= nil
end

-- Updates a bow's visible weapon sprite based on current loaded ammo count.
-- The game model is reset by the caller so the new sprite appears in-hand.
local function setBowSprite(item)
    local bowDef = getBowDef(item)
    if not bowDef then
        return false
    end
    local loaded = safeCall(function() return item:getCurrentAmmoCount() end) or 0
    if loaded > 0 then
        safeCall(function() item:setWeaponSprite(bowDef.drawnSprite) end)
    else
        safeCall(function() item:setWeaponSprite(bowDef.emptySprite) end)
    end
    return true
end

-- Checks the player's primary hand item and refreshes it if it is an OWTL bow.
local function refreshPrimaryBow(player)
    local item = player and safeCall(function() return player:getPrimaryHandItem() end) or nil
    if setBowSprite(item) then
        safeCall(function() player:resetEquippedHandsModels() end)
    end
end

-- When a bow hits a zombie, increment a counter on that zombie's modData. The
-- arrow itself is not added to loot yet; recovery happens when the zombie dies.
local function onWeaponHitCharacter(attacker, target, weapon, damage)
    if not weapon or not target or not isBow(weapon) then
        return
    end
    if not instanceof or not instanceof(target, "IsoZombie") then
        return
    end
    local ammoType = safeCall(function() return weapon:getAmmoType() end)
    local arrowDef = ammoType and ARROWS[ammoType] or nil
    if not arrowDef then
        return
    end
    local modData = safeCall(function() return target:getModData() end)
    if not modData then
        return
    end
    modData[arrowDef.modDataKey] = (tonumber(modData[arrowDef.modDataKey]) or 0) + 1
end

-- Converts the stored hit count for one arrow type into corpse inventory items.
-- Each arrow can be recovered intact, recovered broken, or lost.
local function recoverArrows(zombie, arrowDef)
    local modData = zombie and safeCall(function() return zombie:getModData() end) or nil
    local inventory = zombie and safeCall(function() return zombie:getInventory() end) or nil
    if not modData or not inventory then
        return
    end

    local count = tonumber(modData[arrowDef.modDataKey]) or 0
    if count <= 0 then
        return
    end

    for _ = 1, count do
        local roll = ZombRand and ZombRand(100) or 99
        if roll < arrowDef.recoverChance then
            safeCall(function() inventory:AddItem(arrowDef.recoveredType) end)
        elseif roll < arrowDef.recoverChance + arrowDef.brokenChance then
            safeCall(function() inventory:AddItem(arrowDef.brokenType) end)
        end
    end
    modData[arrowDef.modDataKey] = 0
end

-- Death event hook. It runs recovery for each arrow type the mod knows about.
local function onZombieDead(zombie)
    recoverArrows(zombie, ARROWS["OWTLweapons.OWTL_BasicArrow"])
    recoverArrows(zombie, ARROWS["OWTLweapons.OWTL_ImprovedArrow"])
end

-- Swing/hit hook. After firing, the loaded ammo count may have changed, so the
-- bow sprite is refreshed.
local function onWeaponSwingHitPoint(player, weapon)
    if not weapon or not isBow(weapon) then
        return
    end
    setBowSprite(weapon)
    safeCall(function() player:resetEquippedHandsModels() end)
end

-- Equip hook. A newly equipped bow gets the correct loaded/empty sprite
-- immediately.
local function onEquipPrimary(player, item)
    if isBow(item) then
        refreshPrimaryBow(player)
    end
end

-- Periodic fallback. If another mod or game action changes ammo state without
-- firing an event, this keeps the visible bow sprite in sync.
local function onPlayerUpdate(player)
    refreshPrimaryBow(player)
end

Events.OnWeaponHitCharacter.Add(onWeaponHitCharacter)
Events.OnZombieDead.Add(onZombieDead)
Events.OnWeaponSwingHitPoint.Add(onWeaponSwingHitPoint)
Events.OnEquipPrimary.Add(onEquipPrimary)
Events.OnPlayerUpdate.Add(onPlayerUpdate)
