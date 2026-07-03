OWTL_Traps = OWTL_Traps or {}
OWTL_Traps.Definitions = OWTL_Traps.Definitions or {}

OWTL_Traps.Definitions.MOD_DATA_KEY = "OWTL_Traps"
OWTL_Traps.Definitions.MODULE = "OWTL_Traps"
OWTL_Traps.Definitions.COMMAND_MODULE = "OWTL_Traps"

-- V1 balance values. Tune after Blood Moon playtests.
-- TRAPS is the central data table for every OWTL trap. Each nested table
-- describes one trap's item id, damage, uses, build requirements, and repair
-- requirements. Other files read this instead of hardcoding those values.
OWTL_Traps.Definitions.TRAPS = {
    SimpleSpikedPit = {
        id = "SimpleSpikedPit",
        displayName = "Simple Spiked Pit",
        itemType = "Trap.OWTL_SimpleSpikedPit",
        icon = "Spiketrap",
        damage = 0.35,
        playerDamage = 18,
        maxUses = 3,
        buildTime = 180,
        repairTime = 110,
        carpentry = 1,
        naturalCarpentry = 2,
        recipeName = "Build Simple Spiked Pit",
        magazineType = "Trap.OWTL_BasicPitTrapsMagazine",
        buildXp = 5,
        materials = {
            ["Base.Plank"] = 2,
            ["Base.Nails"] = 4,
        },
        keep = {
            "Hammer",
            "Saw",
        },
        repairMaterials = {
            ["Base.Plank"] = 1,
            ["Base.Nails"] = 2,
        },
    },
    DugSpikedPit = {
        id = "DugSpikedPit",
        displayName = "Dug Spiked Pit",
        itemType = "Trap.OWTL_DugSpikedPit",
        icon = "Spiketrap",
        damage = 0.65,
        playerDamage = 32,
        maxUses = 6,
        buildTime = 320,
        repairTime = 180,
        carpentry = 2,
        naturalCarpentry = 3,
        recipeName = "Build Dug Spiked Pit",
        magazineType = "Trap.OWTL_AdvancedPitTrapsMagazine",
        buildXp = 5,
        materials = {
            ["Base.Plank"] = 4,
            ["Base.Nails"] = 8,
        },
        keep = {
            "Hammer",
            "Saw",
            "Shovel",
        },
        repairMaterials = {
            ["Base.Plank"] = 2,
            ["Base.Nails"] = 4,
        },
    },
    SpikedLogBarricade = {
        id = "SpikedLogBarricade",
        displayName = "Spiked Log Barricade",
        itemType = "Trap.OWTL_SpikedLogBarricade",
        icon = "Spiketrap",
        damage = 0.25,
        playerDamage = 12,
        maxUses = 10,
        buildTime = 260,
        repairTime = 150,
        carpentry = 2,
        naturalCarpentry = 4,
        recipeName = "Build Spiked Log Barricade",
        magazineType = "Trap.OWTL_SpikedBarricadesMagazine",
        buildXp = 5,
        materials = {
            ["Base.Log"] = 2,
            ["Base.Nails"] = 4,
        },
        keep = {
            "Hammer",
            "Saw",
        },
        repairMaterials = {
            ["Base.Log"] = 1,
            ["Base.Nails"] = 2,
        },
    },
}

-- ORDER controls menu display order and natural recipe unlock order.
OWTL_Traps.Definitions.ORDER = {
    "SimpleSpikedPit",
    "DugSpikedPit",
    "SpikedLogBarricade",
}

-- Returns one trap definition by id. Missing ids return nil.
function OWTL_Traps.Definitions.Get(id)
    return OWTL_Traps.Definitions.TRAPS[id]
end

-- Reads the player's Carpentry/Woodwork level. If the PZ perk table is missing,
-- it safely returns 0.
function OWTL_Traps.Definitions.GetCarpentryLevel(player)
    if player and Perks and Perks.Woodwork then
        return player:getPerkLevel(Perks.Woodwork)
    end
    return 0
end

-- Checks whether the player knows a named recipe.
function OWTL_Traps.Definitions.KnowsRecipe(player, recipeName)
    if not player or not recipeName then
        return false
    end
    local known = player:getKnownRecipes()
    return known and known:contains(recipeName) == true
end

-- Adds a recipe to the player's known recipe list if it is not already present.
function OWTL_Traps.Definitions.LearnRecipe(player, recipeName)
    if not player or not recipeName then
        return false
    end
    local known = player:getKnownRecipes()
    if not known then
        return false
    end
    if known:contains(recipeName) then
        return true
    end
    known:add(recipeName)
    return true
end

-- Natural unlock means a high enough Carpentry level can unlock the trap even
-- without reading its magazine.
function OWTL_Traps.Definitions.HasNaturalUnlock(player, trapDef)
    if not trapDef or not trapDef.naturalCarpentry then
        return false
    end
    return OWTL_Traps.Definitions.GetCarpentryLevel(player) >= trapDef.naturalCarpentry
end

-- Progression unlock is true when the player either knows the recipe or has the
-- natural Carpentry unlock.
function OWTL_Traps.Definitions.HasProgressionUnlock(player, trapDef)
    if not trapDef then
        return false
    end
    return OWTL_Traps.Definitions.KnowsRecipe(player, trapDef.recipeName)
        or OWTL_Traps.Definitions.HasNaturalUnlock(player, trapDef)
end

-- Grants any recipes the player has naturally unlocked by Carpentry level.
-- Client and server both call this so menus and server validation agree.
function OWTL_Traps.Definitions.GrantNaturalRecipes(player)
    if not player then
        return
    end
    for _, trapId in ipairs(OWTL_Traps.Definitions.ORDER) do
        local trapDef = OWTL_Traps.Definitions.Get(trapId)
        if OWTL_Traps.Definitions.HasNaturalUnlock(player, trapDef) then
            OWTL_Traps.Definitions.LearnRecipe(player, trapDef.recipeName)
        end
    end
end

-- Returns true when an inventory item is one of this mod's placed trap items.
-- The owtlTrapId field links the item back to TRAPS.
function OWTL_Traps.Definitions.IsOWTLTrapItem(item)
    if not item or not item.getModData then
        return false
    end
    local data = item:getModData()
    return data and data.owtlTrapId ~= nil
end

-- Sandbox helper for whether traps can hurt players. Defaults to enabled.
function OWTL_Traps.Definitions.IsPlayerDamageEnabled()
    if SandboxVars and SandboxVars.OWTL_Traps and SandboxVars.OWTL_Traps.PlayerDamageEnabled ~= nil then
        return SandboxVars.OWTL_Traps.PlayerDamageEnabled == true
    end
    return true
end
