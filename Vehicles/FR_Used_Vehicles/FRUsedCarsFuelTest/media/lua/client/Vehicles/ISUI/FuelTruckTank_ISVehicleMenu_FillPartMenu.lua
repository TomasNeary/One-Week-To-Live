require "Vehicles/ISUI/ISVehicleMenu"

local function isMod(mod_Name)
	local mods = getActivatedMods();
	for i=0, mods:size()-1, 1 do
		if mods:get(i) == mod_Name then
			return true;
		end
	end
	return false;
end

if isMod("Siphoning Needs Hoses") then
	require "Vehicles/ISUI/SiphonHose_ISVehicleMenu"
end


local old_ISVehicleMenu_FillPartMenu = ISVehicleMenu.FillPartMenu

function ISVehicleMenu.FillPartMenu(playerIndex, context, slice, vehicle)
	--local what = IsoObjectPicker():PickVehicle(2,2)
	
	-- print("Player Index: ".. tostring(playerIndex))
	-- print("Context: ".. tostring(context))
	-- print("Slice: " ..tostring(slice))
	-- print("Vehicle: " ..tostring(vehicle))
	
	
	local playerObj = getSpecificPlayer(playerIndex);
	local typeToItem = VehicleUtils.getItems(playerIndex)
	
	local fuel_truck_source = FindVehicleGas(playerObj, vehicle)
	
	
	for i=1,vehicle:getPartCount() do
		local part = vehicle:getPartByIndex(i-1)		
		if part:isContainer() and part:getContainerContentType() == "Gasoline Storage" then
			if typeToItem["Base.PetrolCan"] and part:getContainerContentAmount() < part:getContainerCapacity() then
				if slice then
					slice:addSlice(getText("Add Gasoline To Gasoline Storage Tank"), getTexture("Item_Petrol"), ISVehiclePartMenu.onAddGasoline, playerObj, part)
				else
					context:addOption(getText("Add Gasoline To Gasoline Storage Tank"), playerObj,ISVehiclePartMenu.onAddGasoline, part)
				end
			end
			if ISVehiclePartMenu.getGasCanNotFull(playerObj, typeToItem) and part:getContainerContentAmount() > 0 then
				if slice then
					slice:addSlice(getText("Remove Gasoline From Gasoline Storage Tank"), getTexture("Item_Petrol"), ISVehiclePartMenu.onTakeGasoline, playerObj, part)
				else
					context:addOption(getText("Remove Gasoline From Gasoline Storage Tank"), playerObj, ISVehiclePartMenu.onTakeGasoline, part)
				end
			end
			local square = ISVehiclePartMenu.getNearbyFuelPump(vehicle)
			if square and ((SandboxVars.AllowExteriorGenerator and square:haveElectricity()) or (SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier)) then
				if square and part:getContainerContentAmount() < part:getContainerCapacity() then
					if slice then
						slice:addSlice(getText("Fill Gasoline Storage Tank From Pump"), getTexture("Item_Petrol"), ISVehiclePartMenu.onPumpGasoline, playerObj, part)
					else
						context:addOption(getText("Fill Gasoline Storage Tank From Pump"), playerObj, ISVehiclePartMenu.onPumpGasoline, part)
					end
				end
			end
			
			--local square = ISVehiclePartMenu.getNearbyFuelPump(vehicle)
			if fuel_truck_source and fuel_truck_source:getContainerContentAmount() > 0 and part:getContainerContentAmount() < part:getContainerCapacity() then
				--if square and part:getContainerContentAmount() < part:getContainerCapacity() then
					if slice then
						slice:addSlice(getText("Fill Gasoline Storage Tank From Fuel Truck"), getTexture("Item_Petrol"), ISVehiclePartMenu.onPumpGasolineFromTruck, playerObj, part, fuel_truck_source)
					else
						context:addOption(getText("Fill Gasoline Storage Tank From Fuel Truck"), playerObj, ISVehiclePartMenu.onPumpGasolineFromTruck, part, fuel_truck_source)
					end
				--end
			end			
		end	

		if not vehicle:isEngineStarted() and part:isContainer() and part:getContainerContentType() == "Gasoline" then
			print("Room")
			
			
			--local square = ISVehiclePartMenu.getNearbyFuelPump(vehicle)
			if fuel_truck_source and fuel_truck_source:getContainerContentAmount() > 0 and part:getContainerContentAmount() < part:getContainerCapacity() then
				--if square and part:getContainerContentAmount() < part:getContainerCapacity() then
					if slice then
						slice:addSlice(getText("Add Gasoline From Fuel Truck"), getTexture("Item_Petrol"), ISVehiclePartMenu.onPumpGasolineFromTruck, playerObj, part, fuel_truck_source)
					else
						context:addOption(getText("Add Gasoline From Fuel Truck"), playerObj, ISVehiclePartMenu.onPumpGasolineFromTruck, part, fuel_truck_source)
					end
				--end
			end			
		end


		
	end
	old_ISVehicleMenu_FillPartMenu(playerIndex, context, slice, vehicle)
end

function FindVehicleGas(playerObj, playerVehicle)
	print("TEST")
	local radius = 10
	local player = getPlayer()
	local cell = playerObj:getCell()
	local vehicleList = cell:getVehicles()
	--for b,vehicle in pairs(vehicleList) do
	for index=0, vehicleList:size()-1 do
		local vehicle = vehicleList:get(index)
		for i=1,vehicle:getPartCount() do
			local part = vehicle:getPartByIndex(i-1)	
			if part:isContainer() and part:getContainerContentType() == "Gasoline Storage" and part:getContainerContentAmount() > 0 and vehicle ~= playerVehicle then
				print("FUEL")
				local square = vehicle:getSquare()
					x = math.abs(vehicle:getX()-playerObj:getX())
					y = math.abs(vehicle:getY()-playerObj:getY())
					if x <radius and y<radius then
					--if playerObj:distTo(vehicle) < 10 then
						-- We've found fuel storage
						print("FUEL")
						print(tostring(vehicle:getX()))
						print(tostring(vehicle:getY()))
						--return true
						return part
					end
			end
		end
	end
	return false
end

function ISVehiclePartMenu.onPumpGasolineFromTruck(playerObj, part, source_Tank)
	if playerObj:getVehicle() then
		ISVehicleMenu.onExit(playerObj)
	end
	local square = source_Tank:getVehicle():getSquare()
	if square then
		local action = ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea())
		action:setOnFail(ISVehiclePartMenu.onPumpGasolinePathFail, playerObj)
		ISTimedActionQueue.add(action)
		ISTimedActionQueue.add(ISRefuelFromFuelTruck:new(playerObj, part, square, 100, source_Tank))
	end
end

-- function ISVehiclePartMenu.onPumpGasoline(playerObj, part)
	-- if playerObj:getVehicle() then
		-- ISVehicleMenu.onExit(playerObj)
	-- end
	-- local square = ISVehiclePartMenu.getNearbyFuelPump(part:getVehicle())
	-- if square then
		-- local action = ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea())
		-- action:setOnFail(ISVehiclePartMenu.onPumpGasolinePathFail, playerObj)
		-- ISTimedActionQueue.add(action)
		-- ISTimedActionQueue.add(ISRefuelFromGasPump:new(playerObj, part, square, 100))
	-- end
-- end
