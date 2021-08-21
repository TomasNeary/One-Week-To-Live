--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************
require "Vehicle/ISVehiclePartMenu"


--Hydrocraft.HCPropanetankempty
function ISVehiclePartMenu.getPropaneTankNotFull(playerObj, typeToItem)
	-- Prefer an equipped EmptyPetrolCan/PetrolCan, then the fullest PetrolCan, then any EmptyPetrolCan.
	local equipped = playerObj:getPrimaryHandItem()
	if equipped and equipped:getType() == "PropaneTank" and equipped:getUsedDelta() < 1 then
		return equipped
	elseif equipped and equipped:getType() == "HCPropanetankempty" then
		return equipped
	end
	if typeToItem["Base.PropaneTank"] then
		local gasCan = nil
		local usedDelta = -1
		for _,item in ipairs(typeToItem["Base.PropaneTank"]) do
			if item:getUsedDelta() < 1 and item:getUsedDelta() > usedDelta then
				gasCan = item
				usedDelta = gasCan:getUsedDelta()
			end
		end
		if gasCan then return gasCan end
	end
	if typeToItem["Hydrocraft.HCPropanetankempty"] then
		return typeToItem["Hydrocraft.HCPropanetankempty"][1]
	end
	return nil
end

local function isMod(mod_Name)
	local mods = getActivatedMods();
	for i=0, mods:size()-1, 1 do
		if mods:get(i) == mod_Name then
			return true;
		end
	end
	return false;
end
if not isMod("Hydrocraft") then
	local tank = ScriptManager.instance:getItem("Base.PropaneTank")
	tank:DoParam("KeepOnDeplete = TRUE")
	tank:DoParam("StaticModel = PropaneTank")
end


function ISVehiclePartMenu.onTakePropane(playerObj, part)
	if playerObj:getVehicle() then
		ISVehicleMenu.onExit(playerObj)
	end
	local typeToItem = VehicleUtils.getItems(playerObj:getPlayerNum())
	local item = ISVehiclePartMenu.getPropaneTankNotFull(playerObj, typeToItem)
	if item:getType()=="Hydrocraft.HCPropanetankempty" then
		playeObj:getInventory():Remove(item)
		item = player:getInventory():AddItem("Base.PropaneTank")
		item:setUsedDelta(0)
	end
	if item then
		ISVehiclePartMenu.toPlayerInventory(playerObj, item)
		ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea()))
		ISInventoryPaneContextMenu.equipWeapon(item, false, false, playerObj:getPlayerNum())
		--ISTimedActionQueue.add(FuelTruck_TakePropaneFromVehicle:new(playerObj, part, item, 50))
		ISTimedActionQueue.add(ISTakeGasolineFromVehicle:new(playerObj, part, item, 50))
	end
end


