require "Items/SuburbsDistributions"
require "Items/ItemPicker"

OWTL_Traps = OWTL_Traps or {}
OWTL_Traps.Loading = OWTL_Traps.Loading or {}

local function insertItems(target, items)
    if not target or not target.items then
        return
    end
    local offset = #target.items
    for i = 1, #items do
        target.items[offset + i] = items[i]
    end
end

local magazinesBookstore = {
    "Trap.OWTL_BasicPitTrapsMagazine", 0.4,
    "Trap.OWTL_AdvancedPitTrapsMagazine", 0.25,
    "Trap.OWTL_SpikedBarricadesMagazine", 0.25,
}

local magazinesHome = {
    "Trap.OWTL_BasicPitTrapsMagazine", 0.15,
    "Trap.OWTL_AdvancedPitTrapsMagazine", 0.08,
    "Trap.OWTL_SpikedBarricadesMagazine", 0.08,
}

local magazinesGarage = {
    "Trap.OWTL_BasicPitTrapsMagazine", 0.25,
    "Trap.OWTL_AdvancedPitTrapsMagazine", 0.15,
    "Trap.OWTL_SpikedBarricadesMagazine", 0.15,
}

local function addDistribution(room, container, items)
    local roomDef = SuburbsDistributions and SuburbsDistributions[room] or nil
    local target = roomDef and roomDef[container] or nil
    insertItems(target, items)
end

OWTL_Traps.Loading.getSprites = function()
	getTexture("Item_BicycleHelmet.png");
	print("OWTL trap textures and sprites loaded.");
end

addDistribution("bookstore", "other", magazinesBookstore)
addDistribution("gigamart", "shelvesmag", magazinesBookstore)
addDistribution("all", "shelves", magazinesHome)
addDistribution("all", "shelvesmag", magazinesHome)
addDistribution("all", "sidetable", magazinesHome)
addDistribution("cornerstore", "shelvesmag", magazinesGarage)
addDistribution("garage", "metal_shelves", magazinesGarage)
addDistribution("garagestorage", "other", magazinesGarage)
addDistribution("poststorage", "all", magazinesGarage)
addDistribution("all", "postbox", magazinesGarage)

print("OWTL trap literature distributions added.");
Events.OnPreMapLoad.Add(OWTL_Traps.Loading.getSprites);
