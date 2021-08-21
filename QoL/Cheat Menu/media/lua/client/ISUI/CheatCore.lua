--		 ___________________________________________________________________________
--		|																 			|
--		|	--------------------------------------------------------------------	|
--		|	--------------------------------------------------------------------	|
--		|	----														 	----	|
--		|	----	   ________			      __	______			        ----	|
--		|	----	  / ____/ /_	___	____ _/ /_ / ____/___  _____ ___    ----	|
--		|	----	 / /	/ __ \/ _ \/ __ `/ __// /	/ __ \/ ___// _ \	----	|
--		|	----	/ /___/ / / /	__/ /_/ / /_ / /___/ /_/ / /   /  __/	----	|
--		|	----    \____/_/ /_/\___/\__,_/\__/	 \____/\____/_/	   \___/    ----	|
--		|	----												         	----	|
--		|	----															----	|
--		|	--------------------------------------------------------------------	|
--		|	--------------------------------------------------------------------	|
--		|___________________________________________________________________________|

CheatCoreCM = CheatCoreCM or {}
require "ISUI/CheatMenuTerraformTiles"
print("[CHEAT MENU] CheatCore successfully loaded")
----------------------------------------------
--Needs/stats/whatever they're called toggle--
----------------------------------------------
CheatCoreCM.ToggleAllStats = false
----------------------------------------------
CheatCoreCM.PZVersion = tonumber(string.match(getCore():getVersionNumber(), "%d+")) -- checks game version


----------------------------------------------------------------
---------------------Start of Core Functions--------------------
----------------------------------------------------------------

CheatCoreCM.SyncVariables = function() -- on game start, syncs up the enabled persistent cheats to the normal variables
	if CheatCoreCM.isAdmin() then
		local notifyPlayer = {}
		local stringNotice = "Cheats Enabled: "
		if getPlayer():getModData().IsGhost == true then -- detects a persistent cheat
			CheatCoreCM.IsGhost = true
			table.insert(notifyPlayer, "Ghost Mode, ") -- adds this to the table of enabled cheats
		else
			getPlayer():getModData().IsGhost = false -- if it's not true, it's likely nil
		end
		if getPlayer():getModData().IsGod == true then
			CheatCoreCM.HandleToggle(nil, "CheatCoreCM.IsGod", CheatCoreCM.dragDownDisable)
			table.insert(notifyPlayer, "God Mode, ")
		else
			getPlayer():getModData().IsGod = false
		end
		--[[ depreciated
		if CheatCoreCM.PZVersion >= 40 and CheatCoreCM.IsGod ~= nil then
			getPlayer():setGodMod(CheatCoreCM.IsGod)
		end
		--]]
		if #notifyPlayer > 0 then -- if there are persistent cheats enabled, carries through with notifying the player
			for i = 1,#notifyPlayer do
				if i ~= #notifyPlayer then
					stringNotice = stringNotice..notifyPlayer[i]
				else
					--local subbedString = string.sub(stringNotice, -2) -- extracts last two characters, which are always ", ". just fixes a small grammatical annoyance that it would cause.
					local finishedString = string.gsub(notifyPlayer[i], ", ", "") -- replaces the characters extracted by subbedString with nothing
					stringNotice = stringNotice..finishedString
				end
			end
			print("[CHEAT MENU] "..stringNotice) -- for TIS Support devs/staff/whatever. this is so that, in the event of a player forgetting a cheat was on and reporting it to the Support forum thinking it was a bug, the devs could take one look at the console and easily detect the persons mistake
			getPlayer():Say(stringNotice) -- lets player know which cheats are enabled
		end
	end
end

CheatCoreCM.HandleToggle = function(DisplayName, VariableToToggle, ...) -- I got tired of manually writing toggle functions for each cheat, so I wrote this. All variables used to initiate cheats are defined here via _G. DisplayName is passed to getPlayer():Say() after toggle,, VariableToToggle is the name of the variable to toggle, and Optional is the optional function to call.
	if VariableToToggle ~= nil then
		local VariableToToggle = string.gsub(VariableToToggle, "CheatCoreCM.", "") -- VariableToToggle having "CheatCoreCM." in its string is a leftover from the older version of this function that used loadstring instead of G_ to manipulate metavalues. I'm too lazy to rename stuff in ISUICheatMenu.lua so I just gsub it out.
		_G.CheatCoreCM[VariableToToggle] = not _G.CheatCoreCM[VariableToToggle]
		--print(VariableToToggle)
		
		local gvar = _G.CheatCoreCM[VariableToToggle]
		if VariableToToggle == "IsGod" or "IsGhost" then -- Godmode and Ghostmode's states are meant to be persistent. This is intended to prevent the player from, say, crashing in the middle of a horde with godmode on and dying when they reload their save.
			--print("is " .. VariableToToggle) -- debug stuff
			_G.getPlayer():getModData()[VariableToToggle] = gvar -- To do this, I save the state of the variable to the player's persistent ModData and sync CheatCoreCM.IsGod's value to it with SyncVariables() on game start.
			--print(_G.getPlayer():getModData()[VariableToToggle])
		end
			
		
		if VariableToToggle == "buildCheat" then -- devs have made a bunch of built in cheats like this one so I'm going to have to expand this conditional soon
			ISBuildMenu.cheat = CheatCoreCM.buildCheat
		end
		
		if DisplayName ~= nil then
			getPlayer():Say(DisplayName.. (gvar == true and " enabled." or " disabled.") ) -- I've only recently learned of Lua's trinary operators. Please forgive any discrepancy/spaghetti code that you'll find further in the codebase.
		end
	end
	local args = {...} -- allows for invoking an arbitrary amount of functions
	if #args > 0 then
		for i = 1,#args do
			if type(args[i]) == "string" then
				loadstring(args[i])()
			else
				pcall(args[i])
			end
		end
	end
end

CheatCoreCM.HandleCheck = function(variableToCheck, cheatName, optionalSecondVariable, optionalCheatName) -- used for the "Set value" UI's, for example the one Zombie Brush uses.
	local sayString = {}
	if loadstring("return "..variableToCheck)() ~= true then -- The intended result is a "Set Value" button would set the value and enable the feature if it's disabled, as opposed to HandleToggle which would have disabled the feature if it was enabled and vice versa.
		loadstring(variableToCheck.." = true")()
		table.insert(sayString, cheatName)
	end
	if optionalSecondVariable ~= nil then -- I could have used a table for additional variables, but I don't see myself needing more than two variables to be changed.
		if loadstring("return "..optionalSecondVariable)() ~= true then
			loadstring(optionalSecondVariable.." = true")()
			table.insert(sayString, optionalCheatName)
		end
	end
	if #sayString > 1 then
		getPlayer():Say(cheatName.." And "..optionalCheatName.." Enabled")
	elseif #sayString == 1 then
		getPlayer():Say(cheatName.." Enabled")
	end
end

----------------------------------------------------------------
----------------------End of Core Functions---------------------
----------------------------------------------------------------



------------------------------------------------------------------
---------------------Start of Input Functions---------------------
------------------------------------------------------------------

CheatCoreCM.getMouseCoords = function()
	local x = getMouseXScaled();
	local y = getMouseYScaled();
	local z = getPlayer():getZ();
	local wx, wy = ISCoordConversion.ToWorld(x, y, z);
	wx = math.floor(wx);
	wy = math.floor(wy);
	return x, y, z, wx, wy
end

CheatCoreCM.OnClick = function()
	local mx, my, wz, wx, wy = CheatCoreCM.getMouseCoords()
	if CheatCoreCM.ZombieBrushEnabled == true then
		local player = getPlayer();
		local versionNumber = tonumber(string.match(getCore():getVersionNumber(), "%d+")) -- saves version number to variable, for checking versions
		if string.match(getCore():getVersionNumber(),"Vehicle Test") ~= nil then versionNumber = 32 end
		if versionNumber >= 41 then -- spawnhorde spawns zombies naked on build 41
			addZombiesInOutfit(wx,wy,wz,CheatCoreCM.ZombiesToSpawn, nil, nil)
		elseif versionNumber >= 32 then -- zombie spawn function was changed in build 32
			spawnHorde(wx,wy,wx,wy,wz,CheatCoreCM.ZombiesToSpawn)
		elseif versionNumber <= 31 then
			for i = 1,CheatCoreCM.ZombiesToSpawn do
				getVirtualZombieManager():createRealZombieNow(wx,wy,wz);
			end
		end
	end
	if CheatCoreCM.IsSelect == true then
		local player = getPlayer()
		--local vehicle = getNearVehicle()
		local cell = getWorld():getCell();
		local sq = cell:getGridSquare(wx, wy, wz)
		local vehicle = sq:getVehicleContainer()
		if vehicle ~= nil then
			CheatCoreCM.SelectedVehicle = vehicle
			CheatCoreCM.Parts = {}
			for i = vehicle:getPartCount()-1,0,-1 do
				local part = vehicle:getPartByIndex(i)
				local cat = part:getCategory() or "Other"
				local item = part:getId()
				if type(CheatCoreCM.Parts[cat]) ~= "table" then
					CheatCoreCM.Parts[cat] = {}
				end
				CheatCoreCM.Parts[cat][item] = part
				if i == (vehicle:getPartCount() - 1) then
					CheatCoreCM.IsReady = true -- when this variable is set to true, the Vehicles submenu (defined in ISUICheatMenu.lua) will be generated the next time the context menu is opened
				end
			end
			local name = getText("IGUI_VehicleName" .. vehicle:getScript():getName()) -- only used for debugging
			CheatCoreCM.IsSelect = false -- once a valid vehicle is found the selection mode will be disabled and the Vehicles submenu will be generated
			getPlayer():Say(getText("IGUI_VehicleName" .. vehicle:getScript():getName()) .. " selected")
		end
	end
end




CheatCoreCM.getSqObjs = function()
	local mx, my, wz, wx, wy = CheatCoreCM.getMouseCoords()
	--[[
	local mx = getMouseXScaled();
	local my = getMouseYScaled();
	local wz = getPlayer():getZ();
	local wx, wy = ISCoordConversion.ToWorld(mx, my, wz);
	wx = math.floor(wx);
	wy = math.floor(wy);
	--]]
	local cell = getWorld():getCell();
	local sq = cell:getGridSquare(wx, wy, wz);
	if sq == nil then return false; end
	local sqObjs = sq:getObjects();
	local sqSize = sqObjs:size();
	local tbl = {}
	for i = sqSize-1, 0, -1 do -- enumerate square objects and pack them into a table
		local obj = sqObjs:get(i);
		table.insert(tbl, obj)
	end
	return sq, sqObjs, tbl, cell
end




CheatCoreCM.OnKeyKeepPressed = function(_keyPressed)

	--------------
	--Fire Brush--
	--------------	
	if CheatCoreCM.FireBrushEnabled == true then
		local GridToBurn = CheatCoreCM.getSqObjs()
		if _keyPressed == 49 then
			GridToBurn:StartFire();
		elseif _keyPressed == 33 then
			GridToBurn:stopFire()
			if isClient() then
				GridToBurn:transmitStopFire()
			end
		end
	end
	
	---------------
	--Delete Mode--
	---------------
	if CheatCoreCM.IsDelete == true and _keyPressed == 45 then
		local sq, sqObjs, objTbl, cell = CheatCoreCM.getSqObjs()
		
		if not sq then return end
		
		local z = getPlayer():getZ()
		
		for i = 1, #objTbl do --( (#objTbl > 1 and z == 0) and #objTbl - 1 or z > 0 and #objTbl or 0)
			local obj = objTbl[i]
			local sprite = obj:getSprite()
			
			--[[
			if obj:getSprite() ~= nil then
				
				print(sprite:getProperties():getFlagsList():size())
				print(sprite:getProperties():getPropertyNames():size())
				print("TEST")
				local names = CheatCoreCM.enumJavaArray(sprite:getProperties():getFlagsList())
				for i = 1, #names do
					print(names[i])
				end
			end
			--]]
			
			if sprite and sprite:getProperties():Is(IsoFlagType.solidfloor) ~= true then -- checks for floor on ground, otherwise it'd leave a gaping hole
				local stairObjects = buildUtil.getStairObjects(obj)
				
				if #stairObjects > 0 then
					for i=1,#stairObjects do
						if isClient() then
							sledgeDestroy(stairObjects[i])
						else
							stairObjects[i]:getSquare():RemoveTileObject(stairObjects[i])
						end
					end
				else
					if isClient() then
						sledgeDestroy(obj)
					else
						sq:RemoveTileObject(obj);
						sq:getSpecialObjects():remove(obj);
						sq:getObjects():remove(obj);
					end
				end
				
			end
		end
	end
	
	----------------
	--Terraforming--
	----------------
	if CheatCoreCM.IsTerraforming == true and _keyPressed == 45 then
		local sq, sqObjs, objTbl, cell = CheatCoreCM.getSqObjs()
		
		
		--[[
		if sq == nil then
			sq = cell:createNewGridSquare(wx, wy, wz)
			cell:ConnectNewSquare(sq, false)
		end
		--]]
		if not sq then
			--print("[CHEAT MENU] Attempted to terraform non-existent square")
			return
		end
		
		local obj;
		local sprite;
		for i = 1, #objTbl do
			obj = objTbl[i]
			sprite = obj:getSprite()
			if sprite and sprite:getProperties():Is(IsoFlagType.solidfloor) then
				break
			end
		end
		
		
		local rand;
		if #CheatCoreCM.TerraformRanges > 1 then
			rand = ZombRand(CheatCoreCM.TerraformRanges[1],CheatCoreCM.TerraformRanges[2] + 1)
			if CheatCoreCM.BannedRanges ~= nil then
				for i = 1,#CheatCoreCM.BannedRanges do
					if rand == CheatCoreCM.BannedRanges[i] then
						rand = rand + ZombRand(1,2 + 1) <= CheatCoreCM.TerraformRanges[2] or rand - ZombRand(1,2 + 1)
					end
				end
			end
		else
			rand = CheatCoreCM.TerraformRanges[1]
		end
		
		local generatedTile = CheatCoreCM.Terraform..tostring(rand)
		if not (CheatCoreCM.DoNotFill and not sq:getFloor()) then
			sq:addFloor(generatedTile)
		end
		--end
	end
end

CheatCoreCM.OnKeyPressed = function(_keyPressed, _key2)

	-------------------
	--Barricade Brush--
	-------------------
	if CheatCoreCM.IsBarricade == true and _keyPressed == 44 then
		local mx = getMouseXScaled();
		local my = getMouseYScaled();
		local wz = getPlayer():getZ();
		local wx, wy = ISCoordConversion.ToWorld(mx, my, wz);
		wx = math.floor(wx);
		wy = math.floor(wy);
		local cell = getWorld():getCell();
		local sq = cell:getGridSquare(wx, wy, wz);
		local sqObjs = sq:getObjects();
		local sqSize = sqObjs:size();
		local planks = {}
		local worldobjects = sq:getWorldObjects()

		for i = sqSize-1, 0, -1 do
			local obj = sqObjs:get(i);
			if instanceof(obj, "BarricadeAble") then
				local barricade = IsoBarricade.AddBarricadeToObject(obj, getPlayer())
				local item; -- declared and defined within the local scope of each if statement, so that a single getPlayer():getInventory():Remove(item) call can be used to remove it.
				local numPlanks = barricade:getNumPlanks()
				
				if CheatCoreCM.BarricadeType == "metal" then
					item = getPlayer():getInventory():AddItem("Base.SheetMetal")
				else
					item = getPlayer():getInventory():AddItem("Base.Plank")
				end
				
				if CheatCoreCM.BarricadeLevel > numPlanks and not barricade:isMetal() then
					if CheatCoreCM.BarricadeType == "metal" then
						if not isClient() then
							barricade:addMetal(getPlayer(),item)
						else
							local args = {x=obj:getX(), y=obj:getY(), z=obj:getZ(), index=obj:getObjectIndex(), isMetal=true, itemID=item:getID(), condition=item:getCondition()}
							sendClientCommand(getPlayer(), 'object', 'barricade', args)
						end
					else
						for i = 1,CheatCoreCM.BarricadeLevel - numPlanks do
							if not isClient() then
								barricade:addPlank(getPlayer(),item)
							else
								local args = {x=obj:getX(), y=obj:getY(), z=obj:getZ(), index=obj:getObjectIndex(), isMetal=barricade:isMetal(), itemID=item:getID(), condition=item:getCondition()}
								sendClientCommand(getPlayer(), 'object', 'barricade', args)
							end
						end
					end
				else
					if barricade:isMetal() then
						barricade:removeMetal(getPlayer())
					else
						for i = 1,numPlanks - CheatCoreCM.BarricadeLevel do
							barricade:removePlank(getPlayer())
						end
					end
				end
				getPlayer():getInventory():Remove(item) -- remove the items used to barricade
			end
		end
	end

	------------
	--Fly Mode--
	------------

	if CheatCoreCM.IsFly == true then
		if CheatCoreCM.FlightHeight == nil then CheatCoreCM.FlightHeight = 0 end -- makes sure that it's a number

		if _keyPressed == 200 and getPlayer():getZ() < 5 then -- checks for up arrow and makes sure the players height isn't above the game's limit. note for anyone viewing this code: if this isn't the height limit for your game (either through mods or vanilla updates), feel free to change it
			CheatCoreCM.FlightHeight = CheatCoreCM.FlightHeight + 1
		elseif _keyPressed == 208 and getPlayer():getZ() > 0 then
			CheatCoreCM.FlightHeight = CheatCoreCM.FlightHeight - 1
		end
	end
end

CheatCoreCM.highlightSquare = function()
	if CheatCoreCM.IsBarricade == true or CheatCoreCM.FireBrushEnabled == true or CheatCoreCM.IsDelete == true or CheatCoreCM.IsSelect == true then -- Note to self: clean this up
		local mx = getMouseXScaled();
		local my = getMouseYScaled();
		local player = getPlayer();
		local wz = player:getZ();
		local wx, wy = ISCoordConversion.ToWorld(mx, my, wz);
		wx = math.floor(wx);
		wy = math.floor(wy);
		local cell = getWorld():getCell();
		local sq = cell:getGridSquare(wx, wy, wz);
		if sq ~= nil then
			local sqObjs = sq:getObjects();
			local sqSize = sqObjs:size();
			for i = sqSize - 1, 0, -1 do
				local obj = sqObjs:get(i)
				obj:setHighlighted(true)
			end
		end
	end
end

----------------------------------------------------------------
---------------------End of Input Functions---------------------
----------------------------------------------------------------



----------------------------------------------------------------
--------------------Start of Looped Functions-------------------
----------------------------------------------------------------

CheatCoreCM.DoTickCheats = function()
	--[[
	if getPlayer():getBodyDamage():getHealth() <= 5 and CheatCoreCM.DoPreventDeath == true then
		getPlayer():getBodyDamage():RestoreToFullHealth();
	end
	--]]
	if CheatCoreCM.DoPreventDeath == true then -- credit goes to Slok for providing me with this code
		if getPlayer():getBodyDamage():getHealth() <= 55 then
			getPlayer():getBodyDamage():AddGeneralHealth(2000);
		end
	end

	--[[
	if CheatCoreCM.IsMelee == true and getPlayer():getPrimaryHandItem() ~= nil and CheatCoreCM.doWait ~= os.date("%S") then
		if CheatCoreCM.SavedWeapon ~= getPlayer():getPrimaryHandItem() and not getPlayer():getPrimaryHandItem():isRanged() then
			CheatCoreCM.DoWeaponDamage(true)
		elseif CheatCoreCM.HasSwitchedWeapon ~= getPlayer():getPrimaryHandItem():getName() and getPlayer():getPrimaryHandItem():isRanged() then
			CheatCoreCM.DoWeaponDamage()
		end
	end
	--]]
	--[[
	if CheatCoreCM.doWait ~= nil and os.date("%S") ~= CheatCoreCM.doWait and CheatCoreCM.canSync == true then
		CheatCoreCM.canSync = false
		CheatCoreCM.syncInventory()
		CheatCoreCM.doWait = nil
	end
	--]]

	if CheatCoreCM.IsFly == true and CheatCoreCM.FlightHeight ~= nil then
		getPlayer():setZ(CheatCoreCM.FlightHeight) -- makes sure the player doesn't fall
		getPlayer():setbFalling(false)
		getPlayer():setFallTime(0)
		getPlayer():setLastFallSpeed(0)
		local wz = math.floor(getPlayer():getZ())
		local wx,wy = math.floor(getPlayer():getX()), math.floor(getPlayer():getY())
		local cell = getWorld():getCell()
		local sq = cell:getGridSquare(wx,wy,wz);


		if wz > 0 then
			if sq == nil then
				sq = IsoGridSquare.new(cell, nil, wx, wy, wz)
				cell:ConnectNewSquare(sq, false)
			end

			sq = cell:getGridSquare(wx + 1,wy + 1,wz);

			if sq == nil then
				sq = IsoGridSquare.new(cell, nil, wx + 1, wy + 1, wz)
				cell:ConnectNewSquare(sq, false)
			end
		end
	end
	
	if CheatCoreCM.MadMax == true and CheatCoreCM.SelectedVehicle ~= nil then
		CheatCoreCM.SelectedVehicle:repair()
	end
	
	if CheatCoreCM.IsFreezeTime == true then
		local time = getGameTime()
		if CheatCoreCM.TimeOfDay == nil then
			CheatCoreCM.TimeOfDay = time:getTimeOfDay() -- stores the current time of day
		end
		time:setTimeOfDay(CheatCoreCM.TimeOfDay)
	else
		CheatCoreCM.TimeOfDay = nil
	end
	
	CheatCoreCM.updateCoords()
end


CheatCoreCM.DoCheats = function()

	--if CheatCoreCM.PZVersion <= 39 then -- replaced by setGodMod in build 40 & above
		if CheatCoreCM.IsGod == true or getPlayer():getModData().IsGod == true then
			getPlayer():getBodyDamage():RestoreToFullHealth();
		end
	--end
	
	if CheatCoreCM.IsAmmo == true then
		if getPlayer():getPrimaryHandItem() ~= nil then
			if CheatCoreCM.PZVersion <= 40 then -- legacy
			
				local primaryHandItemData = getPlayer():getPrimaryHandItem():getModData();
				if primaryHandItemData.currentCapacity ~= nil then
					if primaryHandItemData.currentCapacity >= 0 then
						primaryHandItemData.currentCapacity = primaryHandItemData.maxCapacity
					end
				end
				
			else -- build 41 compatible
			
				local gun = getPlayer():getPrimaryHandItem()
				if gun:isRanged() then
					gun:setCurrentAmmoCount(gun:getMaxAmmo())
					gun:setRoundChambered(true)
					if gun:isJammed() then gun:setJammed(false) end
				end
				
			end
		end
	end

	
	CheatCoreCM.DoGhostMode()
	
	
	local statsTable = {"Hunger", "Thirst", "Panic", {"Sanity", 1}, "Stress", {"Fatigue", 0}, "Anger", "Pain", "Sickness", "Drunkenness", {"Endurance", 1}, {"Fitness", 1}}

	
	for i = 1,#statsTable do
		local tbl = statsTable[i]
		if type(tbl) == "string" then
			loadstring("if CheatCoreCM.Is" .. tbl .. " == true then getPlayer():getStats():set" .. tbl .. "(0) end")()
		else
			loadstring("if CheatCoreCM.Is" .. tbl[1] .. " == true then getPlayer():getStats():set" .. tbl[1] .. "(" .. tostring(tbl[2]) .. ") end")()
		end
	end

	

	if CheatCoreCM.IsTemperature == true then
		getPlayer():getBodyDamage():setTemperature(40);
	end

	if CheatCoreCM.IsWet == true then
		getPlayer():getBodyDamage():setWetness(0);
	end

	if CheatCoreCM.IsUnhappy == true then
		getPlayer():getBodyDamage():setUnhappynessLevel(0);
	end

	if getPlayer():getBodyDamage():getHealth() <= 5 and CheatCoreCM.DoPreventDeath == true then
		getPlayer():getBodyDamage():RestoreToFullHealth();
	end
	
	if CheatCoreCM.IsBoredom == true then
		getPlayer():getBodyDamage():setBoredomLevel(0)
	end

	if CheatCoreCM.IsRepair == true and getPlayer():getPrimaryHandItem() ~= nil then
		if getPlayer():getPrimaryHandItem():getCondition() ~= getPlayer():getPrimaryHandItem():getConditionMax() then
			CheatCoreCM.DoRepair()
		end
	end
end

----------------------------------------------------------------
---------------------End of Looped Functions--------------------
----------------------------------------------------------------



----------------------------------------------------------------
-------------------Start of Utility Functions-------------------
----------------------------------------------------------------

CheatCoreCM.readFile = function(modID, fileName)
	local fileTable = {}
	local readFile = getModFileReader(modID, fileName, true)
	local scanLine = readFile:readLine()
	while scanLine do
		fileTable[#fileTable+1] = scanLine
		scanLine = readFile:readLine()
		if not scanLine then break end
	end
	readFile:close()
	return fileTable
end

CheatCoreCM.writeFile = function(tableToWrite, modID, fileName)
	local writeFile = getModFileWriter(modID, fileName, true, false)
	for i = 1,#tableToWrite do
		writeFile:write(tableToWrite[i].."\r\n");
	end
	writeFile:close();
end

CheatCoreCM.doRound = function(number)
	return number % 1 >= 0.5 and math.ceil(number) or math.floor(number)
end

CheatCoreCM.isAdmin = function() -- stops pesky cheaters. good luck trying to modify this, it won't work :^)
	if isClient() == false or isAdmin() or isCoopHost() then
		return true
	else 
		return false
	end
end

CheatCoreCM.RescueFunction = function()
	if getPlayer():getX() == 0 and getPlayer():getY() == 0 then
		getPlayer():setX(10615)
		getPlayer():setY(9696)
		getPlayer():setLx(10615)
		getPlayer():setLy(9696)
		CheatCoreCM.HandleToggle("God Mode", "CheatCoreCM.IsGod")
		CheatCoreCM.HandleToggle("Ghost Mode", "CheatCoreCM.IsGhost")
		getPlayer():Say("For some reason or another, your character was warped to an invalid location (X: 0, Y: 0). To prevent your save from being destroyed, I've added this safety feature to teleport you to safety. If this issue was caused by my mod, I would recommend you report it so I can fix it.")
		print("[CHEAT MENU] Invalid position detected [X: 0 Y: 0]. To prevent a corrupt save, the player has been teleported to a safe location.")
	end
	--[[
	if getPlayer():getInventory():contains("CMInfiniteCarryweight") then
		getPlayer():getInventory():RemoveOneOf("CMInfiniteCarryweight")
	end
	--]]
end

CheatCoreCM.dragDownDisable = function() -- kinda hacky but it works. used to prevent groups of zombies initiating the instakill animation on godmode players.
	if CheatCoreCM.PZVersion >= 41 then -- build 40 & below don't have zombie dragdown
		local sb = SandboxOptions:getInstance()
		if CheatCoreCM.IsGod == true then
			local zomb = sb:getOptionByName("ZombieLore.ZombiesDragDown"):getValueAsObject()
			if zomb == true then
				getPlayer():getModData().CMmodifiedSB = true
				sb:set("ZombieLore.ZombiesDragDown", false);
				print("[CHEAT MENU] ZombiesDragDown set to False to prevent God Mode instadeath")
			end
		elseif getPlayer():getModData().CMmodifiedSB == true then
			getPlayer():getModData().CMmodifiedSB = false
			sb:set("ZombieLore.ZombiesDragDown", true)
			print("[CHEAT MENU] God Mode disabled, ZombiesDragDown value restored to True")
		end
	end
end

CheatCoreCM.enumJavaArray = function(array)
	local tbl = {}
	for i = array:size() - 1, 0, -1 do
		local obj = array:get(i)
		table.insert(tbl, obj)
	end
	return tbl
end

----------------------------------------------------------------
--------------------End of Utility Functions--------------------
----------------------------------------------------------------



----------------------------------------------------------------
-----------------Start of Home/Compass Functions----------------
----------------------------------------------------------------

function CheatCoreCM.setHome( homeNumber )
	loadstring( "CheatCoreCM.Home" .. tostring( homeNumber ) .. "X = "..CheatCoreCM.doRound( getPlayer( ):getX( ) ) )( )
	loadstring( "CheatCoreCM.Home" .. tostring( homeNumber ) .. "Y = "..CheatCoreCM.doRound( getPlayer( ):getY( ) ) )( )
	loadstring( "CheatCoreCM.Home" .. tostring( homeNumber ) .. "Z = "..CheatCoreCM.doRound( getPlayer( ):getZ( ) ) )( )
	local returnX = loadstring( "return CheatCoreCM.Home" .. tostring( homeNumber ) .. "X" )
	local returnY = loadstring( "return CheatCoreCM.Home" .. tostring( homeNumber ) .. "Y" )
	local returnZ = loadstring( "return CheatCoreCM.Home" .. tostring( homeNumber ) .. "Z" )
	CheatCoreCM.fileTable = CheatCoreCM.readFile("cheatmenu", "SavedHomes.txt")
	for i = 1,5 do
		if not CheatCoreCM.fileTable[i] then
			CheatCoreCM.fileTable[i] = " "
		end
	end
	CheatCoreCM.fileTable[ homeNumber ] = "Home" .. tostring( homeNumber ) .. " " .. returnX( ) .. " " .. returnY( ) .. " " .. returnZ( )
	CheatCoreCM.writeFile( CheatCoreCM.fileTable, "cheatmenu", "SavedHomes.txt" )
end

function CheatCoreCM.markHome( homeNumber, optionalDestinationName, optionalX, optionalY, optionalZ, optionalDoTeleport )
	local splitTable = { }
	local tableKey = 0

	if ( homeNumber and type( homeNumber ) == "number" and homeNumber > 0 ) then
		CheatCoreCM.fileTable = CheatCoreCM.readFile("cheatmenu", "SavedHomes.txt")
		for i = 1,5 do
			if not CheatCoreCM.fileTable[i] then
				CheatCoreCM.fileTable[i] = " "
			end
		end
		for i in string.gmatch( CheatCoreCM.fileTable[ homeNumber ], "%S+" ) do
			splitTable[ tableKey ] = i
			tableKey = tableKey + 1
		end

		CheatCoreCM.DisplayName = "Home" .. homeNumber
		CheatCoreCM.MarkedX = splitTable[ 1 ]
		CheatCoreCM.MarkedY = splitTable[ 2 ]
		CheatCoreCM.MarkedZ = splitTable[ 3 ] or 0
	else
		CheatCoreCM.DisplayName = optionalDestinationName
		CheatCoreCM.MarkedX = optionalX
		CheatCoreCM.MarkedY = optionalY
		CheatCoreCM.MarkedZ = ( optionalZ or 0 )
	end

	if not optionalDoTeleport and not ISUICheatWindow:getIsVisible( ) then
		ISUICheatWindow:setVisible(true);
		CheatCoreCM.updateCoords()
	elseif optionalDoTeleport then
		getPlayer( ):setX( tonumber( CheatCoreCM.MarkedX ) );
		getPlayer( ):setY( tonumber( CheatCoreCM.MarkedY ) );
		getPlayer( ):setZ( tonumber( CheatCoreCM.MarkedZ ) );
		getPlayer( ):setLx( getPlayer( ):getX( ) );
		getPlayer( ):setLy( getPlayer( ):getY( ) );
		getPlayer( ):setLz( getPlayer( ):getZ( ) );
	end
end

CheatCoreCM.checkCoords = function(number1, number2)
	local doRound = CheatCoreCM.doRound(number2)
	if doRound >= number1 then
		return doRound - number1
	else
		return number1 - doRound
	end
end

CheatCoreCM.updateCompass = function()
	local newText = "";
	for i,v in ipairs(ISUICheatWindow.compassLines) do
		if i == #ISUICheatWindow.compassLines then
			v = string.gsub(v, " <LINE> $", "")
		end
		newText = newText .. v;
	end
	ISUICheatWindow.HomeWindow.text = newText
	ISUICheatWindow.HomeWindow:paginate()
end

CheatCoreCM.returnDirection = function(X, Y) -- unused
	local wx, wy = getPlayer():getX(), getPlayer():getY()
	wx = math.floor(wx);
	wy = math.floor(wy);
	local cell = getWorld():getCell();
	local sq = cell:getGridSquare(wx, wy, getPlayer():getZ());
	local sqObjs = sq:getObjects();
	local sqSize = sqObjs:size();
	for i = sqSize-1, 0, -1 do
		local obj = sqObjs:get(i);
		local directions = getDirectionTo(getPlayer(), obj)
		local direction = {["N"] = "N", ["NE"] = "North East", ["NW"] = "North West", ["S"] = "South", ["SE"] = "South East", ["SW"] = "South West", ["E"] = "East", ["W"] = "West"}
		return direction[directions]
		--[[
		if direction == "N" then
			return "North"
		elseif direction == "NW" then
			return "North East"
		elseif direction == "NE" then
			return "North West"
		elseif direction == "S" then
			return "South"
		elseif direction == "SW" then
			return "South West"
		elseif direction == "SE" then
			return "South East"
		elseif direction == "W" then
			return "West"
		elseif direction == "E" then
			return "East"
		end
		--]]
	end
end

CheatCoreCM.updateCoords = function()
	if ISUICheatWindow:getIsVisible() then
		ISUICheatWindow.compassLines[2] = "-------------Your Coords-------------".." <LINE> ".."X: "..CheatCoreCM.doRound(getPlayer():getX()).." Y: "..CheatCoreCM.doRound(getPlayer():getY()).." <LINE> "
		if CheatCoreCM.MarkedX ~= nil and CheatCoreCM.MarkedY ~= nil then
			ISUICheatWindow.compassLines[1] = "-----"..CheatCoreCM.DisplayName.." Coords-----".." <LINE> ".."X: "..CheatCoreCM.MarkedX.." Y: "..CheatCoreCM.MarkedY.." <LINE> "
			ISUICheatWindow.compassLines[3] = "-----Distance to Destination-----".." <LINE> ".."X: "..CheatCoreCM.checkCoords(tonumber(CheatCoreCM.MarkedX), getPlayer():getX()).." Y: "..CheatCoreCM.checkCoords(tonumber(CheatCoreCM.MarkedY), getPlayer():getY()).." <LINE> "
			--ISUICheatWindow.compassLines[4] = "-----Direction to Destination-----".." <LINE> "..CheatCoreCM.returnDirection()
		end
		CheatCoreCM.updateCompass()
	end
end

----------------------------------------------------------------
------------------End of Home/Compass Functions-----------------
----------------------------------------------------------------



----------------------------------------------------------------
----------------Start of Player-Related Functions---------------
----------------------------------------------------------------

CheatCoreCM.DoCarryweightCheat = function()
	--[[
	if CheatCoreCM.ItemWeightTable == nil then -- this was a beta. It was scrapped in favor for an item with -99999 weight to prevent issues with dropping, but it's still fully functional (despite there being no trigger, as I do that after the initial testing phase)
		CheatCoreCM.ItemWeightTable = {}
	end
	
	local inv = getPlayer():getInventory()
	local invItems = inv:getItems()
	
	for i = 0, invItems:size() -1 do
		local item = invItems:get(i)

		if CheatCoreCM.ItemWeightTable[item:getDisplayName()] == nil then
			CheatCoreCM.ItemWeightTable[item:getDisplayName()] = item:getActualWeight()
		end
		item:setActualWeight(0)
	end

	local inv = getPlayer():getInventory()
	local invItems = inv:getItems()
	for k,v in pairs(CheatCoreCM.ItemWeightTable) do
		for i = 0, invItems:size() -1 do
			local item = invItems:get(i)
			if item:getDisplayName() == k then
				item:setActualWeight(v)
			end
		end
	end
	--]]
	if not getPlayer():getInventory():contains("CMInfiniteCarryweight") then
		getPlayer():Say("Infinite Carryweight Enabled.")
		getPlayer():getInventory():AddItem("cheatmenu.CMInfiniteCarryweight")
		getPlayer():setMaxWeightBase( 999999 );
	else
		getPlayer():Say("Infinite Carryweight Disabled.")
		getPlayer():getInventory():RemoveOneOf("CMInfiniteCarryweight")
		getPlayer():setMaxWeightBase( 8 );
	end
end

CheatCoreCM.AllStatsToggle = function()
	CheatCoreCM.ToggleAllStats = not CheatCoreCM.ToggleAllStats
	if CheatCoreCM.ToggleAllStats == true then
		getPlayer():Say("Infinite stats enabled.")
	else
		getPlayer():Say("Infinite stats disabled.")
	end
	
	local statsTable = {"Hunger", "Thirst", "Panic", "Sanity", "Stress", "Unhappy", "Fatigue", "Boredom", "Anger", "Pain", "Sickness", "Wet", "Temperature", "Drunkenness", "Endurance", "Fitness"}

	
	for i = 1,#statsTable do -- iterates through statsTable and sets every stat variable to true/false. variables are later handled by CheatCoreCM.DoCheats() per player update
		local tbl = statsTable[i]
		loadstring("CheatCoreCM.Is" .. tbl .. " = " .. tostring(CheatCoreCM.ToggleAllStats))() -- I really need to stop using loadstring for everything
	end
end



CheatCoreCM.ToggleInstantActions = function()

	if CheatCoreCM.IsActionCheat == true then
		ISBaseTimedAction._create = ISBaseTimedAction.create
		function ISBaseTimedAction:create()
			self.maxTime = 0
			self.action = LuaTimedActionNew.new(self, self.character)
		end
		
		if CheatCoreCM.PZVersion >= 41 then -- build 41 compatibility
			ISInventoryTransferAction._new = ISInventoryTransferAction.new
			
			function ISInventoryTransferAction:new (character, item, srcContainer, destContainer)
				local o = {}
				setmetatable(o, self)
				self.__index = self
				o.character = character;
				o.item = item;
				o.srcContainer = srcContainer;
				o.destContainer = destContainer;
				if not srcContainer or not destContainer then
					o.maxTime = 0;
					return o;
				end
				o.stopOnWalk = not o.destContainer:isInCharacterInventory(o.character) or (not o.srcContainer:isInCharacterInventory(o.character))
				if (o.srcContainer == character:getInventory()) and (o.destContainer:getType() == "floor") then
					o.stopOnWalk = false
				end
				o.stopOnRun = true;
				o.maxTime = 0;
				o.jobType = getText("IGUI_JobType_Grabbing", item:getName());
				if srcContainer == destContainer then
					o.queueList = {};
					local queuedItem = {items = {o.item}, time = o.maxTime, type = o.item:getFullType()};
					table.insert(o.queueList, queuedItem);
				else
					o.loopedAction = true;
					o:checkQueueList();
				end
				return o
			end
		end
		
	else
		ISBaseTimedAction.create = ISBaseTimedAction._create
		if CheatCoreCM.PZVersion >= 41 then
			ISInventoryTransferAction.new = ISInventoryTransferAction._new
		end
	end
end

CheatCoreCM.ToggleInstantCrafting = function()
	
	if not ISCraftingUI._render then
		ISCraftingUI._render = ISCraftingUI.render
	end
	
	if CheatCoreCM.IsCraftingCheat == true then
		ISCraftingUI._craft = ISCraftingUI.craft
		function ISCraftingUI:craft()		
			local selectedItem = self.panel.activeView.view.recipes.items[self.panel.activeView.view.recipes.selected].item
			local itemType = selectedItem.recipe:getResult():getFullType()
			
			local inventory = getPlayer():getInventory()
			inventory:AddItem( itemType )
		end
		
		RecipeManager._IsRecipeValid = RecipeManager.IsRecipeValid
		function RecipeManager.IsRecipeValid() return true end
		
		function ISCraftingUI:render()
			ISCraftingUI._render( self )
			
			self.craftOneButton.onclick = ISCraftingUI.craftAll
		end
		
	else
		ISCraftingUI.craft = ISCraftingUI._craft
		RecipeManager.IsRecipeValid = RecipeManager._IsRecipeValid
		
		function ISCraftingUI:render()
			ISCraftingUI._render( self )
			
			self.craftOneButton.onclick = ISCraftingUI.craft
		end
	end
end

CheatCoreCM.DoMaxAllSkills = function()

	getPlayer():Say("All skills maxed!")

	local player = getPlayer():getXp()
	
	local pf = PerkFactory.PerkList
	local pfSize = PerkFactory.PerkList:size()	
	for i = pfSize-1, 0, -1 do -- loop through PerkList and set level to 10
		local obj = pf:get(i)
		local skill = obj:getType()
		
		getPlayer():level0(skill) 
		getPlayer():getXp():setXPToLevel(skill, 0) -- make sure that xp and level is set to 0 first before levelling
		for i = 1,10 do -- then set it
			getPlayer():LevelPerk(skill, false)
		end
	end
end

CheatCoreCM.DoHeal = function()
	getPlayer():Say("Player healed.")
	getPlayer():getBodyDamage():RestoreToFullHealth();
end

CheatCoreCM.DoLearnRecipes = function()
	local recipes = getAllRecipes()
	for i = 0,recipes:size() - 1 do
		local recipe = recipes:get(i)
		if not getPlayer():isRecipeKnown(recipe) and recipe:needToBeLearn() then
			getPlayer():getKnownRecipes():add(recipe:getOriginalname())
			getPlayer():Say("All recipes learned.")
		end
	end
end


CheatCoreCM.DoMaxSkill = function(SkillToSet, ToLevel)


	--[[	
	for i = 1,getPlayer():getPerkLevel(SkillToSet) do -- clear the skill before setting it
		getPlayer():LoseLevel(SkillToSet)
	end
	--]]
	
	getPlayer():level0(SkillToSet)
	getPlayer():getXp():setXPToLevel(SkillToSet, 0)
	
	
	if ToLevel ~= 0 then
		for i = 1,ToLevel do -- then set it
			getPlayer():LevelPerk(SkillToSet, false)
		end
		getPlayer():getXp():setXPToLevel(SkillToSet, ToLevel)
	end
	
	
	--getPlayer():getXp():setXPToLevel(SkillToSet, ToLevel);
	--getPlayer():setNumberOfPerksToPick(getPlayer():getNumberOfPerksToPick() + ToLevel);
end

CheatCoreCM.DoGhostMode = function()
	if not getPlayer():isGhostMode() and CheatCoreCM.IsGhost == true or not getPlayer():isGhostMode() and getPlayer():getModData().IsGhost == true then -- checks if player is already ghostmode
		getPlayer():setGhostMode(true)
	elseif CheatCoreCM.IsGhost == false then
		getPlayer():setGhostMode(false)
	end
end

----------------------------------------------------------------
-----------------End of Player-Related Functions----------------
----------------------------------------------------------------





----------------------------------------------------------------
--------------Start of Equipment-Related Functions--------------
----------------------------------------------------------------

CheatCoreCM.DoNoReload = function()

	if CheatCoreCM.IsMelee == true then -- checks to make sure that IsMelee is enabled, and if it is then it disables it.
		CheatCoreCM.DoWeaponDamage()
	end


	local weapon = getPlayer():getPrimaryHandItem()


	if CheatCoreCM.NoReload == true then
		originalRecoilDelay = weapon:getRecoilDelay() -- saves the normal values into variables

		weapon:setRecoilDelay( 0 ) -- can't set it under 0
	end

	if CheatCoreCM.NoReload == false then
		weapon:setRecoilDelay( originalRecoilDelay ) -- then restores the old values when disabled
	end
end

CheatCoreCM.DoWeaponDamage = function()
	local player = getPlayer()
	local weapon = player:getPrimaryHandItem()
	local sWeapon = player:getSecondaryHandItem() -- unused

	if weapon ~= nil then
		if CheatCoreCM.IsMelee == true and not weapon:isRanged() then
			CheatCoreCM.oldWeapon = {
				weapon:getID(),
				weapon:getMinDamage(),
				weapon:getMaxDamage(),
				weapon:getDoorDamage(),
				weapon:getTreeDamage()
			} -- cache the weapon's ID and stats so that it can be reverted if the player switches weapons
			weapon:setMinDamage( weapon:getMinDamage() + 999 );
			weapon:setMaxDamage( weapon:getMaxDamage() + 999 );
			weapon:setDoorDamage( weapon:getDoorDamage() + 999 );
			weapon:setTreeDamage( weapon:getTreeDamage() + 999 );
			Events.OnEquipPrimary.Add(CheatCoreCM.UndoWeaponDamage) -- calls UndoWeaponDamage on equipment update
		elseif CheatCoreCM.IsMelee == false and not weapon:isRanged() then -- restores original values if cheat is toggled off
			local tbl = CheatCoreCM.oldWeapon
			weapon:setMinDamage( tbl[2] );
			weapon:setMaxDamage( tbl[3] );
			weapon:setDoorDamage( tbl[4] );
			weapon:setTreeDamage( tbl[5] );
		end	
	end
end

CheatCoreCM.UndoWeaponDamage = function() -- if the player unequips or switches his weapon, this function ensures that the original values are restored
	local tbl = CheatCoreCM.oldWeapon
	local weapon = getPlayer():getInventory():getItemById(tbl[1])
	weapon:setMinDamage( tbl[2] );
	weapon:setMaxDamage( tbl[3] );
	weapon:setDoorDamage( tbl[4] );
	weapon:setTreeDamage( tbl[5] );
	--print("Stats reverted")
	Events.OnEquipPrimary.Remove(CheatCoreCM.UndoWeaponDamage)
	if CheatCoreCM.IsMelee == true then
		CheatCoreCM.DoWeaponDamage()
	end
end

CheatCoreCM.DoRepair = function()
	local ToolToRepair = getPlayer():getPrimaryHandItem() -- gets the item in the players hand
	ToolToRepair:setCondition( getPlayer():getPrimaryHandItem():getConditionMax() ) -- gets the maximum condition and sets it to it
end

CheatCoreCM.DoRefillAmmo = function()
	if CheatCoreCM.PZVersion <= 40 then
		local primaryHandItemData = getPlayer():getPrimaryHandItem():getModData();
		primaryHandItemData.currentCapacity = primaryHandItemData.maxCapacity
	else -- build 41 compatible
		local gun = getPlayer():getPrimaryHandItem()
		gun:setCurrentAmmoCount(gun:getMaxAmmo())
		gun:setRoundChambered(true)
	end
end

----------------------------------------------------------------
---------------End of Equipment-Related Functions---------------
----------------------------------------------------------------





----------------------------------------------------------------
----------------Start of Environmental Functions----------------
----------------------------------------------------------------

CheatCoreCM.SetTime = function(TimeToSet, DayOrMonth)
	local time = getGameTime()
	local DayOrMonth = string.gsub(DayOrMonth, "%a", string.upper, 1)
	local success = false

	if DayOrMonth == "Time" and TimeToSet <= 24 then
		time:setTimeOfDay( TimeToSet )
		getPlayer():Say("Time successfully changed to "..TimeToSet..":00.")
	elseif DayOrMonth == "Day" then
		time:setDay( TimeToSet)
	elseif DayOrMonth == "Month" then
		time:setMonth(TimeToSet)
	elseif DayOrMonth == "Year" then
		time:setYear(TimeToSet)
	end -- could probably just replace these three with loadstring("getGameTime():set" .. DayOrMonth .. "(" .. tostring(TimeToSet) .. ")")()
end

CheatCoreCM.SetWeather = function(weather) --old
	local world = getWorld()
	local rm = RainManager
	local gt = getGameTime()
	
	if weather == "rain" then
		world:setWeather(weather)
		rm:startRaining()
	end
	
	if weather == "thunder" then
		if not rm:isRaining() then rm:startRaining(); world:setWeather("rain") end -- must rain first
		if gt:getThunderStorm() == false then
			gt:thunderStart()
		else
			gt:thunderStop()
		end
	end
	
	if weather == "cloud" or weather == "sunny" then
		if rm:isRaining() then
			rm:stopRaining()
		end
		world:setWeather(weather)
	end
	
	if isClient() then
		world:transmitWeather()
	end
end

CheatCoreCM.DoWeather = function(action, val) --doesn't work
	local weather = getWorld():getClimateManager()
	if action == "stop" then
		weather:stopWeatherAndThunder()
		--print("-----------------Done!-----------------")
	end
	
	if action == "snow" then
		local snow = weather:getPrecipitationIsSnow()
		if snow == true then
			getPlayer():Say("Snow toggled off.")
			weather:setPrecipitationIsSnow(false)
		else
			getPlayer():Say("Snow toggled on.")
			weather:setPrecipitationIsSnow(true)
		end
	end
	
	if action == "finalValue" then 
		weather.getClimateFloat:setFinalValue(5555555)
	end
end
----------------------------------------------------------------
-----------------End of Environmental Functions-----------------
----------------------------------------------------------------



----------------------------------------------------------------
-------------------Start of Vehicle Functions-------------------
----------------------------------------------------------------

CheatCoreCM.SpawnVehicle = function(name) -- will be expanded later
	addVehicle(name)
end

----------------------------------------------------------------
--------------------End of Vehicle Functions--------------------
----------------------------------------------------------------


Events.OnGameStart.Add(CheatCoreCM.RescueFunction);
Events.OnLoad.Add(CheatCoreCM.SyncVariables);