require "Items/SuburbsDistributions"

OWTL_Bows = OWTL_Bows or {}
OWTL_Bows.Distributions = OWTL_Bows.Distributions or {}

local bowyerNotesBookstore = {
    "OWTLweapons.OWTL_BowyerNotes", 0.25,
}

local bowyerNotesHome = {
    "OWTLweapons.OWTL_BowyerNotes", 0.08,
}

local bowyerNotesGarage = {
    "OWTLweapons.OWTL_BowyerNotes", 0.12,
}

local function insertItems(target, items)
    if not target or not target.items then
        return
    end
    local offset = #target.items
    for i = 1, #items do
        target.items[offset + i] = items[i]
    end
end

local function addDistribution(room, container, items)
    local roomDef = SuburbsDistributions and SuburbsDistributions[room] or nil
    local target = roomDef and roomDef[container] or nil
    insertItems(target, items)
end

addDistribution("bookstore", "other", bowyerNotesBookstore)
addDistribution("gigamart", "shelvesmag", bowyerNotesBookstore)
addDistribution("all", "shelves", bowyerNotesHome)
addDistribution("all", "shelvesmag", bowyerNotesHome)
addDistribution("all", "sidetable", bowyerNotesHome)
addDistribution("cornerstore", "shelvesmag", bowyerNotesGarage)
addDistribution("garage", "metal_shelves", bowyerNotesGarage)
addDistribution("garagestorage", "other", bowyerNotesGarage)
addDistribution("poststorage", "all", bowyerNotesGarage)
addDistribution("all", "postbox", bowyerNotesGarage)
