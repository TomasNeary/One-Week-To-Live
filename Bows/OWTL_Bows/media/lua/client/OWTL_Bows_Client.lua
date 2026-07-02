OWTL_Bows = OWTL_Bows or {}
OWTL_Bows.Client = OWTL_Bows.Client or {}

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

local function safeCall(fn)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return nil
end

local function getBowDef(item)
    local itemType = item and safeCall(function() return item:getType() end) or nil
    return itemType and BOWS[itemType] or nil
end

local function isBow(item)
    return getBowDef(item) ~= nil
end

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

local function refreshPrimaryBow(player)
    local item = player and safeCall(function() return player:getPrimaryHandItem() end) or nil
    if setBowSprite(item) then
        safeCall(function() player:resetEquippedHandsModels() end)
    end
end

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

local function onZombieDead(zombie)
    recoverArrows(zombie, ARROWS["OWTLweapons.OWTL_BasicArrow"])
    recoverArrows(zombie, ARROWS["OWTLweapons.OWTL_ImprovedArrow"])
end

local function onWeaponSwingHitPoint(player, weapon)
    if not weapon or not isBow(weapon) then
        return
    end
    setBowSprite(weapon)
    safeCall(function() player:resetEquippedHandsModels() end)
end

local function onEquipPrimary(player, item)
    if isBow(item) then
        refreshPrimaryBow(player)
    end
end

local function onPlayerUpdate(player)
    refreshPrimaryBow(player)
end

Events.OnWeaponHitCharacter.Add(onWeaponHitCharacter)
Events.OnZombieDead.Add(onZombieDead)
Events.OnWeaponSwingHitPoint.Add(onWeaponSwingHitPoint)
Events.OnEquipPrimary.Add(onEquipPrimary)
Events.OnPlayerUpdate.Add(onPlayerUpdate)
