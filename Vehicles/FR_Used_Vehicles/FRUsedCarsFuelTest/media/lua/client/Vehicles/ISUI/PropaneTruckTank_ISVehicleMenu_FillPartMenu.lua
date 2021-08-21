require "Vehicles/ISUI/ISVehicleMenu"

local old_ISVehicleMenu_FillPartMenu = ISVehicleMenu.FillPartMenu

function ISVehicleMenu.FillPartMenu(playerIndex, context, slice, vehicle)

	local playerObj = getSpecificPlayer(playerIndex);
	local typeToItem = VehicleUtils.getItems(playerIndex)
	
	for i=1,vehicle:getPartCount() do
		local part = vehicle:getPartByIndex(i-1)		
		if part:isContainer() and part:getContainerContentType() == "Propane Storage" then
			if ISVehiclePartMenu.getPropaneTankNotFull(playerObj, typeToItem)
			and part:getContainerContentAmount() > 0 then
				if slice then
					slice:addSlice(getText("Remove Propane From Propane Storage Tank"), getTexture("Item_PropaneTank"), ISVehiclePartMenu.onTakePropane, playerObj, part)
				else
					context:addOption(getText("Remove Propane From Propane Storage Tank"), playerObj, ISVehiclePartMenu.onTakePropane, part)
				end
			end		
		end			
	end
	old_ISVehicleMenu_FillPartMenu(playerIndex, context, slice, vehicle)
end
