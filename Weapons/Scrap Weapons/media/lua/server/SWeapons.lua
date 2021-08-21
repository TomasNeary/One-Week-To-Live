function DeconstructSmallTool_OnCreate(items, result, player)
    player:getInventory():AddItem("MetalParts")
	player:getInventory():AddItem("Base.Screws")
end

function DeconstructTool_OnCreate(items, result, player)
    player:getInventory():AddItem("Base.UnusableWood")
    player:getInventory():AddItem("Base.Screws")
end

function DeconstructMetalTool_OnCreate(items, result, player)
    player:getInventory():AddItem("MetalBar")
	player:getInventory():AddItem("Base.Screws")
end