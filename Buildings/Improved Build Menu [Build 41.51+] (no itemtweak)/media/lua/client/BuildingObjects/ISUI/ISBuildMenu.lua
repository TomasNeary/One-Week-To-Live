ISBuildMenu = {};
ISBuildMenu.planks = 0;
ISBuildMenu.nails = 0;
ISBuildMenu.nailsBox = 0;
ISBuildMenu.hinge = 0;
ISBuildMenu.doorknob = 0;
ISBuildMenu.cheat = false;
ISBuildMenu.woodWorkXp = 0;

local function predicateNotBroken(item)
	return not item:isBroken()
end

local function predicateDrainableUsesInt(item, count)
	return item:getDrainableUsesInt() >= count
end

function ISBuildMenu.GetItemInstance(type)
    if not ISBuildMenu.ItemInstances then ISBuildMenu.ItemInstances = {} end
    local item = ISBuildMenu.ItemInstances[type]
    if not item then
        item = InventoryItemFactory.CreateItem(type)
        if item then
            ISBuildMenu.ItemInstances[type] = item
            ISBuildMenu.ItemInstances[item:getFullType()] = item
        end
    end
    return item
end

ISBuildMenu.doBuildMenu = function(player, context, worldobjects, test)

	if test and ISWorldObjectContextMenu.Test then return true end

	if getCore():getGameMode()=="LastStand" then
		return;
	end

    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()

	if playerObj:getVehicle() then return; end

    ISBuildMenu.woodWorkXp = playerObj:getPerkLevel(Perks.Woodwork);
    local thump = nil;

	local square = nil;

	-- destroy item with sledgehammer
	if not isClient() or getServerOptions():getBoolean("AllowDestructionBySledgehammer") then
        local sledgehammer = playerInv:getFirstTypeEvalRecurse("Sledgehammer", predicateNotBroken)
        if not sledgehammer then
            sledgehammer = playerInv:getFirstTypeEvalRecurse("Sledgehammer2", predicateNotBroken)
        end
		if sledgehammer and not sledgehammer:isBroken() then
			if test then return ISWorldObjectContextMenu.setTest() end
            context:addOption(getText("ContextMenu_Destroy"), worldobjects, ISWorldObjectContextMenu.onDestroy, playerObj, sledgehammer)
		end
	end

	-- we get the thumpable item (like wall/door/furniture etc.) if exist on the tile we right clicked
	for i,v in ipairs(worldobjects) do
		square = v:getSquare();
		if instanceof(v, "IsoThumpable") and not v:isDoor() then
			if not MultiStageBuilding.getStages(playerObj, v, ISBuildMenu.cheat):isEmpty() then
				thump = v
			end
		end
	end

	if thump then
        local stages = MultiStageBuilding.getStages(playerObj, thump, ISBuildMenu.cheat);
		if not stages:isEmpty() then
			for i=0,stages:size()-1 do
				local stage = stages:get(i);
				local option = context:addOption(stage:getDisplayName(), worldobjects, ISBuildMenu.onMultiStageBuild, stage, thump, player);
				local items = stage:getItemsLua();
				local perks = stage:getPerksLua();
				local tooltip = ISToolTip:new();
				tooltip:initialise();
				tooltip:setVisible(false);
				tooltip:setName(stage:getDisplayName());
				if ISBuildMenu.cheat then
					tooltip.description = "";
				else
					tooltip.description = getText("Tooltip_craft_Needs") .. ": ";
				end
				tooltip:setTexture(stage:getSprite());
				local notAvailable = false;
				if not ISBuildMenu.cheat then
					for x=0,stage:getItemsToKeep():size()-1 do
						local itemString = stage:getItemsToKeep():get(x);
                        if itemString == "Base.Hammer" then
                            local hammer = playerInv:getFirstTagEvalRecurse("Hammer", predicateNotBroken)
                            if hammer then
                                itemString = hammer:getFullType()
                            end
                        end
                        local item = ISBuildMenu.GetItemInstance(itemString);
                        if item then
                            if playerInv:containsTypeEvalRecurse(itemString, predicateNotBroken) then
                                tooltip.description = tooltip.description .. " <RGB:1,1,1> " .. item:getName() .. " <LINE> ";
                            else
                                tooltip.description = tooltip.description .. " <RGB:1,0,0> " .. item:getName() .. " <LINE> ";
                                notAvailable = true;
                            end
                        end
                    end
					tooltip.description = tooltip.description .. " <LINE> ";
					for x,v in pairs(items) do
                        local item = ISBuildMenu.GetItemInstance(x);
						if item then
							if instanceof(item, "DrainableComboItem") then
                                local drainable = playerInv:getFirstTypeEvalArgRecurse(x, predicateDrainableUsesInt, tonumber(v))
                                if not drainable then
                                    drainable = playerInv:getFirstTypeRecurse(x)
                                end
                                local useLeft = 0;
								if drainable and drainable:getDrainableUsesInt() >= tonumber(v) then
									useLeft = drainable:getDrainableUsesInt()
									tooltip.description = tooltip.description .. " <RGB:0,1,0> " .. item:getName() .. " " .. useLeft .. "/" .. v .. " <LINE> ";
								else
									if drainable then
										useLeft = drainable:getDrainableUsesInt()
									end
									tooltip.description = tooltip.description .. " <RGB:1,0,0> " .. item:getName() .. " " .. useLeft .. "/" .. v .. " <LINE> ";
									notAvailable = true;
								end
							else
								if playerInv:getItemCountRecurse(x) >= tonumber(v) then
									tooltip.description = tooltip.description .. " <RGB:0,1,0> " .. item:getName() .. " " .. playerInv:getItemCount(x) .. "/" .. v .. " <LINE> ";
								else
									tooltip.description = tooltip.description .. " <RGB:1,0,0> " .. item:getName() .. " " .. playerInv:getItemCount(x) .. "/" .. v .. " <LINE> ";
									notAvailable = true;
								end
							end
						end
					end
					tooltip.description = tooltip.description .. " <LINE> ";
					for x,v in pairs(perks) do
						local perk = PerkFactory.getPerk(x);
						if playerObj:getPerkLevel(x) >= tonumber(v) then
							tooltip.description = tooltip.description .. " <RGB:0,1,0> " .. getText("IGUI_perks_" .. perk:getType():toString()) .. " " .. playerObj:getPerkLevel(x) .. "/" ..  v .. " <LINE>";
						else
							tooltip.description = tooltip.description .. " <RGB:1,0,0> " .. getText("IGUI_perks_" .. perk:getType():toString()) .. " " .. playerObj:getPerkLevel(x) .. "/" ..  v .. " <LINE>";
							notAvailable = true;
						end
					end
					local knownRecipe = stage:getKnownRecipe()
					if knownRecipe then
						tooltip.description = tooltip.description .. " <LINE> "
						if playerObj:getKnownRecipes():contains(stage:getKnownRecipe()) then
							tooltip.description = tooltip.description .. " <RGB:0,1,0> " .. getText("Tooltip_vehicle_requireRecipe", getRecipeDisplayName(knownRecipe)) .. " <LINE>"
						else
							tooltip.description = tooltip.description .. " <RGB:1,0,0> " .. getText("Tooltip_vehicle_requireRecipe", getRecipeDisplayName(knownRecipe)) .. " <LINE>"
							notAvailable = true
						end
					end
					option.notAvailable = notAvailable;
				end
				option.toolTip = tooltip;
			end
		end
	end

	-- build menu
	-- if we have any thing to build in our inventory
	if ISBuildMenu.haveSomethingtoBuild(player) then

		if test then return ISWorldObjectContextMenu.setTest() end

		local buildOption = context:addOption(getText("ContextMenu_Build"), worldobjects, nil);
		-- create a brand new context menu wich contain our different material (wood, stone etc.) to build
		local subMenu = ISContextMenu:getNew(context);
		-- We create the different option for this new menu (wood, stone etc.)
		-- check if we can build something in wood material
		if haveSomethingtoBuildWood(player) then
			-- we add the subMenu to our current option (Build)
			context:addSubMenu(buildOption, subMenu);

			------------------ WALL ------------------
			local wallOption = subMenu:addOption(getText("ContextMenu_Wall"), worldobjects, nil);
			local subMenuWall = subMenu:getNew(subMenu);
			context:addSubMenu(wallOption, subMenuWall);
			ISBuildMenu.buildWallMenu(subMenuWall, wallOption, player);
			------------------ FENCE ------------------
			local fenceOption = subMenu:addOption(getText("ContextMenu_Fence"), worldobjects, nil);
			local subMenuFence = subMenu:getNew(subMenu);
			context:addSubMenu(fenceOption, subMenuFence);
			ISBuildMenu.buildFenceMenu(subMenuFence, fenceOption, player);
			------------------ DOOR/GATE ------------------
			local doorOption = subMenu:addOption(getText("ContextMenu_DoorGate"), worldobjects, nil);
			local subMenuDoor = subMenu:getNew(subMenu);
			context:addSubMenu(doorOption, subMenuDoor);
			ISBuildMenu.buildDoorMenu(subMenuDoor, doorOption, player);
			------------------ WINDOW ------------------
--			local windowOption = subMenu:addOption(getText("ContextMenu_Window"), worldobjects, nil);
--			local subMenuWindow = subMenu:getNew(subMenu);
--			context:addSubMenu(windowOption, subMenuWindow);
--			ISBuildMenu.buildWindowMenu(subMenuWindow, windowOption, player);
			------------------ STAIRS ------------------
			local stairsOption = subMenu:addOption(getText("ContextMenu_Stairs"), worldobjects, nil);
			local subMenuStairs = subMenu:getNew(subMenu);
			context:addSubMenu(stairsOption, subMenuStairs);
			ISBuildMenu.buildStairsMenu(subMenuStairs, stairsOption, player);
			------------------ FLOOR ------------------
			local floorOption = subMenu:addOption(getText("ContextMenu_Floor"), worldobjects, nil);
			local subMenuFloor = subMenu:getNew(subMenu);
			context:addSubMenu(floorOption, subMenuFloor);
			ISBuildMenu.buildBetterFloorMenu(subMenuFloor, floorOption, player);
			------------------ FURNITURE ------------------
			local furnitureOption = subMenu:addOption(getText("ContextMenu_Furniture"), worldobjects, nil);
			local subMenuFurniture = subMenu:getNew(subMenu);
			context:addSubMenu(furnitureOption, subMenuFurniture);
			ISBuildMenu.buildFurnitureMenu(subMenuFurniture, context, furnitureOption, player);
			------------------ LIGHT SOURCES ------------------
			local lightOption = subMenu:addOption(getText("ContextMenu_Light_Source"), worldobjects, nil);
			local subMenuLight = subMenu:getNew(subMenu);
			context:addSubMenu(lightOption, subMenuLight);
			ISBuildMenu.buildLightMenu(subMenuLight, lightOption, player);
			------------------ MISC ------------------
			local miscOption = subMenu:addOption(getText("ContextMenu_Misc"), worldobjects, nil);
			local subMenuMisc = subMenu:getNew(subMenu);
			context:addSubMenu(miscOption, subMenuMisc);
			ISBuildMenu.buildMiscMenu(subMenuMisc, miscOption, player);
		end
	end

	-- dismantle stuff
	-- TODO: RJ: removed it for now need to see exactly how it works as now we have a proper right click to dismantle items...
	-- if playerInv:containsTypeRecurse("Saw") and playerInv:containsTypeRecurse("Screwdriver") then
	--  	if test then return ISWorldObjectContextMenu.setTest() end
	--  	context:addOption(getText("ContextMenu_Dismantle"), worldobjects, ISBuildMenu.onDismantle, playerObj);
	-- end



end

function ISBuildMenu.haveSomethingtoBuild(player)
	--~ 	return true;
	return haveSomethingtoBuildWood(player);
end

function haveSomethingtoBuildWood(player)
	local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()
    ISBuildMenu.materialOnGround = buildUtil.checkMaterialOnGround(playerObj:getCurrentSquare())
	if ISBuildMenu.cheat then
		return true;
	end
	ISBuildMenu.planks = 0;
	ISBuildMenu.nails = 0;
	ISBuildMenu.hinge = 0;
	ISBuildMenu.nailsBox = 0;
	ISBuildMenu.doorknob = 0;
	ISBuildMenu.hasHammer = playerInv:containsTagEvalRecurse("Hammer", predicateNotBroken)
	if ISBuildMenu.hasHammer then
		-- most objects require a hammer
	elseif ISBuildMenu.countMaterial(player, "Base.Sandbag") >= 3 or ISBuildMenu.countMaterial(player, "Base.Gravelbag") >= 3 then
		-- no hammer required
	elseif ISBuildMenu.canBuildLogWall(player) then
		-- no hammer required
	else
		return false
	end
	ISBuildMenu.planks = ISBuildMenu.countMaterial(player, "Base.Plank")
	--nails boxes have 100 nails in them, these are added to the nails count to allow for automatic opening of nails boxes when building objects
	ISBuildMenu.nailsBox = ISBuildMenu.countMaterial(player, "Base.NailsBox")
	ISBuildMenu.nails = ISBuildMenu.countMaterial(player, "Base.Nails") + (ISBuildMenu.nailsBox * 100)
	ISBuildMenu.hinge = ISBuildMenu.countMaterial(player, "Base.Hinge")
	ISBuildMenu.doorknob = ISBuildMenu.countMaterial(player, "Base.Doorknob")
	return true;
end

ISBuildMenu.isNailsBoxNeededOpening = function(nailsRequired)
    if ISBuildMenu.nails - (ISBuildMenu.nailsBox * 100) < nailsRequired then
        return true;
    end
end

ISBuildMenu.onMultiStageBuild = function(worldobjects, stage, item, player)
    local playerObj = getSpecificPlayer(player);
    local playerInv = playerObj:getInventory()
    if luautils.walkAdjWall(playerObj, item:getSquare(), item:getNorth(), false) then
        if not ISBuildMenu.cheat then
            local itemsRequired = stage:getItemsLua()
            -- equip required items
            local first = true;
            for i=0,stage:getItemsToKeep():size() - 1 do
                local itemToEquip =  stage:getItemsToKeep():get(i);
                if itemToEquip == "Base.Hammer" then
                    local hammer = playerInv:getFirstTagEvalRecurse("Hammer", predicateNotBroken)
                    if hammer then
                        itemToEquip = hammer:getFullType()
                    end
                end
                local item = nil
                if itemsRequired[itemToEquip] then
                    -- Equip a BlowTorch with the required amount of fuel.
                    local uses = tonumber(itemsRequired[itemToEquip])
                    item = playerInv:getFirstTypeEvalArgRecurse(itemToEquip, predicateDrainableUsesInt, uses)
                else
                    item = playerInv:getFirstTypeEvalRecurse(itemToEquip, predicateNotBroken)
                end
                ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item)
                if not playerObj:hasEquipped(itemToEquip) and item then
                    ISInventoryPaneContextMenu.equipWeapon(item, first, false, player)
                end
                if not first then
                    break;
                end
                first = false;
            end
--[[
            -- Move required items to main inventory.
            -- Not doing this because carpentry code doesn't.
            for x,v in pairs(itemsRequired) do
                local item = ISBuildMenu.GetItemInstance(x);
                if item then
                    if instanceof(item, "DrainableComboItem") then
                        local drainable = playerInv:getFirstTypeEvalArgRecurse(x, predicateDrainableUsesInt, tonumber(v))
                        ISInventoryPaneContextMenu.transferIfNeeded(playerObj, drainable)
                    else
                        local required = playerInv:getSomeTypeRecurse(x, tonumber(v))
                        ISInventoryPaneContextMenu.transferIfNeeded(playerObj, required)
                    end
                end
            end
--]]
        end
        ISTimedActionQueue.add(ISMultiStageBuild:new(playerObj, stage, item, stage:getTimeNeeded(playerObj)));
    end
end

ISBuildMenu.canDoStage = function(player, stage)
    local playerInv = player:getInventory()
    if ISBuildMenu.cheat then return true; end
    if stage:getKnownRecipe() and not player:getKnownRecipes():contains(stage:getKnownRecipe()) then
        return false
    end
    local items = stage:getItemsLua();
	for x=0,stage:getItemsToKeep():size()-1 do
		local itemString = stage:getItemsToKeep():get(x)
		if itemString == "Base.Hammer" then
            local hammer = playerInv:getFirstTagEvalRecurse("Hammer", predicateNotBroken)
			if hammer then
				itemString = hammer:getFullType()
			end
		end
        local item = ISBuildMenu.GetItemInstance(itemString);
        if item then
            if not playerInv:containsTypeEvalRecurse(itemString, predicateNotBroken) then
                return false;
            end
        end
    end
    for x,v in pairs(items) do
        local item = ISBuildMenu.GetItemInstance(x);
        if item then
            if instanceof(item, "DrainableComboItem") then
                local drainable = playerInv:getFirstTypeEvalArgRecurse(x, predicateDrainableUsesInt, tonumber(v))
                local useLeft = 0;
                if (drainable and drainable:getRemainingUses() < tonumber(v)) or not drainable then
                    return false;
                end
            else
                if playerInv:getItemCountRecurse(x) < tonumber(v) then
                    return false;
                end
            end
        end
    end
    return true;
end

-- **********************************************
-- **                   *MISC*                 **
-- **********************************************
ISBuildMenu.buildMiscMenu = function(subMenu, option, player)
    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()
	local signSprite = ISBuildMenu.getSignSprite(player);
	local signOption = subMenu:addOption(getText("ContextMenu_Sign"), worldobjects, ISBuildMenu.onSign, square, signSprite, player);
	local toolTip = ISBuildMenu.canBuild(3, 3, 0, 0, 0, 1, signOption, player);
	toolTip:setName(getText("ContextMenu_Sign"));
	toolTip.description = getText("Tooltip_craft_signDesc") .. toolTip.description;
	toolTip:setTexture(signSprite.sprite);
	ISBuildMenu.requireHammer(signOption)

	local woodenCrossOption = subMenu:addOption(getText("ContextMenu_Wooden_Cross"), worldobjects, ISBuildMenu.onWoodenCross, square, player);
	local toolTip = ISBuildMenu.canBuild(2, 2, 0, 0, 0, 0, woodenCrossOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Cross"));
	toolTip.description = getText("Tooltip_craft_crossDesc") .. toolTip.description;
	toolTip:setTexture("location_community_cemetary_01_23");
	ISBuildMenu.requireHammer(woodenCrossOption);

	local dogHouseSprite = ISBuildMenu.getDogHouseSprite(player);
	local dogHouseOption = subMenu:addOption(getText("ContextMenu_Dog_House"), worldobjects, ISBuildMenu.onDogHouse, square, dogHouseSprite, player);
	local toolTip = ISBuildMenu.canBuild(5, 5, 0, 0, 0, 6, dogHouseOption, player);
	toolTip:setName(getText("ContextMenu_Dog_House"));
	toolTip.description = getText("Tooltip_craft_dogHouseDesc") .. toolTip.description;
	toolTip:setTexture(dogHouseSprite.sprite);
	ISBuildMenu.requireHammer(dogHouseOption);

	local stonePileOption = subMenu:addOption(getText("ContextMenu_Stone_Pile"), worldobjects, ISBuildMenu.onStonePile, square, player);
	local toolTip = ISBuildMenu.canBuild(0,0,0,0,0,0,stonePileOption, player);
	-- we add that we need stone too
	local stones = playerInv:getItemCount("Base.Stone", true);
	if stones < 6 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemText("Stone") .. " " .. stones .. "/6 ";
		stonePileOption.onSelect = nil;
		stonePileOption.notAvailable = true;
	elseif not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemText("Stone") .. " " .. stones .. "/6 ";
	end
	toolTip:setName(getText("ContextMenu_Stone_Pile"));
	toolTip.description = getText("Tooltip_craft_stonePileDesc") .. toolTip.description;
	toolTip:setTexture("location_community_cemetary_01_30");

	local woodenPicketOption = subMenu:addOption(getText("ContextMenu_Wooden_Picket"), worldobjects, ISBuildMenu.onWoodenPicket, square, player);
	local toolTip = ISBuildMenu.canBuild(1,0,0,0,0,0,woodenPicketOption, player);
	local ropes = tonumber(playerInv:getItemCount("Base.SheetRope", true));
	-- we add that we need rope too
	if ropes == 0 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemText("Sheet Rope") .. " " .. ropes .. "/1 ";
		woodenPicketOption.onSelect = nil;
		woodenPicketOption.notAvailable = true;
	elseif not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemText("Sheet Rope") .. " " .. ropes .. "/1 ";
	end
	toolTip:setName(getText("ContextMenu_Wooden_Picket"));
	toolTip.description = getText("Tooltip_craft_woodenPicketDesc") .. toolTip.description;
	toolTip:setTexture("location_community_cemetary_01_31");
	if woodenCrossOption.notAvailable and stonePileOption.notAvailable and woodenPicketOption.notAvailable and signOption.notAvailable then
		option.notAvailable = true;
	end
end

ISBuildMenu.onWoodenCross = function(worldobjects, square, player)
	local cross = ISSimpleFurniture:new("Wooden Cross", "location_community_cemetary_01_22", "location_community_cemetary_01_23", ISBuildMenu.isNailsBoxNeededOpening(2));
	cross.canPassThrough = true;
	cross.canBarricade = false;
	cross.ignoreNorth = true;
	cross.canBeAlwaysPlaced = false;
	cross.isThumpable = false;
	cross.modData["xp:Woodwork"] = 5;
	cross.modData["need:Base.Plank"] = "2";
	cross.modData["need:Base.Nails"] = "2";
	cross.player = player
	cross.maxTime = 80;
	getCell():setDrag(cross, player);
end

ISBuildMenu.onDogHouse = function(worldobjects, square, sprite, player)
	local dogHouse = ISSimpleFurniture:new("Wooden Cross", sprite.sprite, sprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(5));
	dogHouse:setEastSprite(sprite.eastSprite);
	dogHouse:setSouthSprite(sprite.southSprite);
	dogHouse.modData["xp:Woodwork"] = 6;
	dogHouse.modData["need:Base.Plank"] = "5";
	dogHouse.modData["need:Base.Nails"] = "5";
	dogHouse.player = player
	dogHouse.maxTime = 110;
	getCell():setDrag(dogHouse, player);
end

ISBuildMenu.onStonePile = function(worldobjects, square, player)
	-- sprite, northSprite, corner
	local cross = ISSimpleFurniture:new("Stone Pile", "location_community_cemetary_01_30", "location_community_cemetary_01_30");
	cross.canPassThrough = false;
	cross.canBarricade = false;
	cross.ignoreNorth = true;
	cross.canBeAlwaysPlaced = false;
	cross.isThumpable = false;
	cross.modData["need:Base.Stone"] = "6";
	cross.player = player
	cross.maxTime = 50;
	cross.noNeedHammer = true;
	getCell():setDrag(cross, player);
end

ISBuildMenu.onWoodenPicket = function(worldobjects, square, player)
	local cross = ISSimpleFurniture:new("Wooden Picket", "location_community_cemetary_01_31", "location_community_cemetary_01_31");
	cross.canPassThrough = true;
	cross.canBarricade = false;
	cross.ignoreNorth = true;
	cross.canBeAlwaysPlaced = false;
	cross.isThumpable = false;
	cross.modData["xp:Woodwork"] = 5;
	cross.modData["need:Base.Plank"] = "1";
	cross.modData["need:Base.SheetRope"] = "1";
	cross.player = player
	cross.maxTime = 50;
	cross.noNeedHammer = true;
	getCell():setDrag(cross, player);
end

-- **********************************************
-- **                   *BAR*                  **
-- **********************************************

ISBuildMenu.buildBarMenu = function(subMenu, option, player)
	local barElemSprite = ISBuildMenu.getBarElementSprites(player);
	local barElemOption = subMenu:addOption(getText("ContextMenu_Bar_Element"), worldobjects, ISBuildMenu.onBarElement, barElemSprite, player);
	local toolTip = ISBuildMenu.canBuild(4, 4, 0, 0, 0, 7, barElemOption, player);
	toolTip:setName(getText("ContextMenu_Bar_Element"));
	toolTip.description = getText("Tooltip_craft_barElementDesc") .. toolTip.description;
	toolTip:setTexture(barElemSprite.sprite);
	ISBuildMenu.requireHammer(barElemOption)

	local barCornerSprite = ISBuildMenu.getBarCornerSprites(player);
	local barCornerOption = subMenu:addOption(getText("ContextMenu_Bar_Corner"), worldobjects, ISBuildMenu.onBarElement, barCornerSprite, player);
	local toolTip = ISBuildMenu.canBuild(4, 4, 0, 0, 0, 7, barCornerOption, player);
	toolTip:setName(getText("ContextMenu_Bar_Corner"));
	toolTip.description = getText("Tooltip_craft_barElementDesc") .. toolTip.description;
	toolTip:setTexture(barCornerSprite.sprite);
	ISBuildMenu.requireHammer(barCornerOption)

	if barElemOption.notAvailable and barCornerOption.notAvailable then
		option.notAvailable = true;
	end
end

ISBuildMenu.onBarElement = function(worldobjects, sprite, player)
	-- sprite, northSprite
	local bar = ISWoodenContainer:new(sprite.sprite, sprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(4));
	bar.name = "Counter";
	bar:setEastSprite(sprite.eastSprite);
	bar:setSouthSprite(sprite.southSprite);
	bar.modData["xp:Woodwork"] = 5;
	bar.modData["need:Base.Plank"] = "4";
	bar.modData["need:Base.Nails"] = "4";
	bar.player = player
	bar.renderFloorHelper = true
	getCell():setDrag(bar, player);
end

ISBuildMenu.onBar2Element = function(worldobjects, sprite, player)
	-- sprite, northSprite
	local bar = ISWoodenContainer:new(sprite.sprite, sprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(6));
	bar.name = "Bar";
	bar:setEastSprite(sprite.eastSprite);
	bar:setSouthSprite(sprite.southSprite);
	bar.modData["xp:Woodwork"] = 10;
	bar.modData["need:Base.Plank"] = "6";
	bar.modData["need:Base.Nails"] = "6";
	bar.player = player
	bar.renderFloorHelper = true
	getCell():setDrag(bar, player);
end

-- **********************************************
-- **                  *FENCE*                 **
-- **********************************************

ISBuildMenu.buildFenceMenu = function(subMenu, option, player)
    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()
	local stakeOption = subMenu:addOption(getText("ContextMenu_Wooden_Stake"), worldobjects, ISBuildMenu.onWoodenFenceStake, square, player);
	local toolTip = ISBuildMenu.canBuild(1, 2, 0, 0, 0, 5, stakeOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Stake"));
	toolTip.description = getText("Tooltip_craft_woodenStakeDesc") .. toolTip.description;
	toolTip:setTexture("fencing_01_19");
	ISBuildMenu.requireHammer(stakeOption)

	local barbedOption = subMenu:addOption(getText("ContextMenu_Barbed_Fence"), worldobjects, ISBuildMenu.onBarbedFence, square, player);
	local toolTip = ISBuildMenu.canBuild(0, 0, 0, 0, 1, 0, barbedOption, player);
	local carpentrySkill = 5;
	-- we add that we need a Barbed wire too
	local barbedWire = ISBuildMenu.countMaterial(player, "Base.BarbedWire");
	if not playerInv:contains("BarbedWire") and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.BarbedWire") .. " " .. barbedWire .. "/1 ";
		barbedOption.onSelect = nil;
		barbedOption.notAvailable = true;
	elseif not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.BarbedWire") .. " " .. barbedWire .. "/1 ";
	end
	if playerObj:getPerkLevel(Perks.Woodwork) < carpentrySkill and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_Carpentry") .. " " .. playerObj:getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill;
		barbedOption.notAvailable = true;
	elseif carpentrySkill > 0 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_Carpentry") .. " " .. playerObj:getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill;
	end
	toolTip:setName(getText("ContextMenu_Barbed_Fence"));
	toolTip.description = getText("Tooltip_craft_barbedFenceDesc") .. toolTip.description;
	toolTip:setTexture("fencing_01_20");
	ISBuildMenu.requireHammer(barbedOption)

	local woodenFenceSprite = ISBuildMenu.getWoodenFenceSprites(player);
	local fenceOption = subMenu:addOption(getText("ContextMenu_Wooden_Fence"), worldobjects, ISBuildMenu.onWoodenFence, square, woodenFenceSprite, player);
	local toolTip = ISBuildMenu.canBuild(2, 3, 0, 0, 0, 2, fenceOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Fence"));
	toolTip.description = getText("Tooltip_craft_woodenFenceDesc") .. toolTip.description;
	toolTip:setTexture(woodenFenceSprite.sprite);
	ISBuildMenu.requireHammer(fenceOption)

	local postOption = subMenu:addOption(getText("ContextMenu_Wooden_Post"), worldobjects, ISBuildMenu.onWoodenFencePost, square, player);
	local toolTip = ISBuildMenu.canBuild(1, 2, 0, 0, 0, 5, postOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Post"));
	toolTip.description = getText("Tooltip_craft_woodenPostDesc") .. toolTip.description;
	toolTip:setTexture("fencing_01_37");
	ISBuildMenu.requireHammer(postOption)

	local sandBagOption = subMenu:addOption(getText("ContextMenu_Sang_Bag_Wall"), worldobjects, ISBuildMenu.onSangBagWall, square, player);
	local toolTip = ISBuildMenu.canBuild(0, 0, 0, 0, 0, 0, sandBagOption, player);
	-- we add that we need 3 sand bag too
	local sandbag = ISBuildMenu.countMaterial(player, "Base.Sandbag");
	if sandbag < 3 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.Sandbag") .. " " .. sandbag .. "/3 ";
		sandBagOption.onSelect = nil;
		sandBagOption.notAvailable = true;
	elseif not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Sandbag") .. " " .. sandbag .. "/3 ";
	end
	toolTip:setName(getText("ContextMenu_Sang_Bag_Wall"));
	toolTip.description = getText("Tooltip_craft_sandBagDesc") .. toolTip.description;
	toolTip:setTexture("carpentry_02_12");

	local gravelBagOption = subMenu:addOption(getText("ContextMenu_Gravel_Bag_Wall"), worldobjects, ISBuildMenu.onGravelBagWall, square, player);
	local toolTip = ISBuildMenu.canBuild(0,0,0,0,0,0,gravelBagOption, player);
	-- we add that we need 3 gravel bag too
	local gravelbag = ISBuildMenu.countMaterial(player, "Base.Gravelbag");
	if ISBuildMenu.countMaterial(player, "Base.Gravelbag") < 3 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.Gravelbag") .. " " .. gravelbag .. "/3 ";
		gravelBagOption.onSelect = nil;
		gravelBagOption.notAvailable = true;
	elseif not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Gravelbag") .. " " .. gravelbag .. "/3 ";
	end
	toolTip:setName(getText("ContextMenu_Gravel_Bag_Wall"));
	toolTip.description = getText("Tooltip_craft_gravelBagDesc") .. toolTip.description;
	toolTip:setTexture("carpentry_02_12");

	if stakeOption.notAvailable and barbedOption.notAvailable and postOption.notAvailable and fenceOption.notAvailable and sandBagOption.notAvailable and gravelBagOption.notAvailable then
		option.notAvailable = true;
	end
end

ISBuildMenu.onBarbedFence = function(worldobjects, square, player)
	-- sprite, northSprite, corner
	local fence = ISWoodenWall:new("fencing_01_20", "fencing_01_21", nil);
	-- we can place our fence every where
	--	fence.canBeAlwaysPlaced = true;
	fence.hoppable = true;
	fence.canBarricade = false
	fence.modData["xp:Woodwork"] = 5;
	fence.modData["need:Base.BarbedWire"] = "1";
	fence.player = player
	fence.name = "Barbed Fence"
	getCell():setDrag(fence, player);
end

ISBuildMenu.onWoodenFenceStake = function(worldobjects, square, player)
	-- sprite, northSprite, corner
	local fence = ISWoodenWall:new("fencing_01_19", "fencing_01_19", nil, ISBuildMenu.isNailsBoxNeededOpening(2));
	fence.canPassThrough = true;
	fence.isThumpable = false;
	fence.canBarricade = false
	-- we can place our fence every where
	fence.canBeAlwaysPlaced = true;
	fence.modData["xp:Woodwork"] = 5;
	fence.modData["need:Base.Plank"] = "1";
	fence.modData["need:Base.Nails"] = "2";
	fence.player = player
	fence.name = "Wooden Stake"
	getCell():setDrag(fence, player);
end

ISBuildMenu.onSangBagWall = function(worldobjects, square, player)
	-- sprite, northSprite, corner
	local fence = ISWoodenWall:new("carpentry_02_12", "carpentry_02_13", nil);
	fence:setEastSprite("carpentry_02_14");
	fence:setSouthSprite("carpentry_02_15");
	fence.hoppable = true;
	fence.canBarricade = false
	fence.isWallLike = false
	-- but it slow you
	-- fence.crossSpeed = 0.3;
	fence.modData["need:Base.Sandbag"] = "3";
	fence.modData["xp:Woodwork"] = 5;
	fence.player = player
	fence.renderFloorHelper = true
	fence.noNeedHammer = true
	fence.name = "Sand Bag Wall"
	getCell():setDrag(fence, player);
end

ISBuildMenu.onGravelBagWall = function(worldobjects, square, player)
	-- sprite, northSprite, corner
	local fence = ISWoodenWall:new("carpentry_02_12", "carpentry_02_13", nil);
	fence:setEastSprite("carpentry_02_14");
	fence:setSouthSprite("carpentry_02_15");
	fence.hoppable = true;
	fence.canBarricade = false
	fence.isWallLike = false
	-- but it slow you
	-- fence.crossSpeed = 0.3;
	fence.modData["need:Base.Gravelbag"] = "3";
	fence.modData["xp:Woodwork"] = 5;
	fence.player = player
	fence.renderFloorHelper = true
	fence.noNeedHammer = true
	fence.name = "Gravel Bag Wall"
	getCell():setDrag(fence, player);
end

ISBuildMenu.onWoodenFencePost = function(worldobjects, square, player)
	-- sprite, northSprite, corner
	local fence = ISWoodenWall:new("fencing_01_37", "fencing_01_37", nil, ISBuildMenu.isNailsBoxNeededOpening(2));
	fence.canPassThrough = true;
	fence.canBarricade = false
	-- we can place our fence every where
	fence.canBeAlwaysPlaced = true;
	fence.modData["xp:Woodwork"] = 5;
	fence.modData["need:Base.Plank"] = "1";
	fence.modData["need:Base.Nails"] = "2";
	fence.player = player
	fence.name = "Wooden Post"
	getCell():setDrag(fence, player);
end

ISBuildMenu.onWoodenFence = function(worldobjects, square, sprite, player)
	-- sprite, northSprite, corner
	local fence = ISWoodenWall:new(sprite.sprite, sprite.northSprite, sprite.corner, ISBuildMenu.isNailsBoxNeededOpening(3));
	-- you can hopp a fence
	fence.hoppable = true;
	fence.isThumpable = false;
	fence.canBarricade = false
	fence.modData["xp:Woodwork"] = 5;
	fence.modData["need:Base.Plank"] = "2";
	fence.modData["need:Base.Nails"] = "3";
	fence.player = player
	fence.name = "Wooden Fence"
	getCell():setDrag(fence, player);
end

-- **********************************************
-- **          *LIGHT SOURCES*                 **
-- **********************************************
ISBuildMenu.buildLightMenu = function(subMenu, option, player)
    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()
	local sprite = ISBuildMenu.getPillarLampSprite(player);
	local lampOption = subMenu:addOption(getText("ContextMenu_Lamp_on_Pillar"), worldobjects, ISBuildMenu.onPillarLamp, square, sprite, player);
	local toolTip = ISBuildMenu.canBuild(2, 4, 0, 0, 0, 0, lampOption, player);
	local carpentrySkill = 4;
	toolTip:setName(getText("ContextMenu_Lamp_on_Pillar"));
	toolTip.description = getText("Tooltip_craft_pillarLampDesc") .. " " .. toolTip.description;
	toolTip:setTexture("carpentry_02_62");
	local torch = getSpecificPlayer(player):getInventory():getItemCount("Base.Torch", true);
	if not playerInv:containsTypeRecurse("Torch") and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.Torch") .. " " .. torch .. "/1 ";
		lampOption.onSelect = nil;
		lampOption.notAvailable = true;
	elseif not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Torch") .. " " .. torch .. "/1 ";
	end
	local rope = getSpecificPlayer(player):getInventory():getItemCount("Base.Rope", true);
	if not playerInv:containsTypeRecurse("Rope") and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0>" .. getItemNameFromFullType("Base.Rope") .." " .. rope .. "/1 ";
		lampOption.onSelect = nil;
		lampOption.notAvailable = true;
	elseif not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0>" .. getItemNameFromFullType("Base.Rope") .. " " .. rope .. "/1 ";
	end
	if playerObj:getPerkLevel(Perks.Woodwork) < carpentrySkill and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_Carpentry") .. " " .. playerObj:getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill;
		lampOption.notAvailable = true;
	elseif carpentrySkill > 0 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_Carpentry") .. " " .. playerObj:getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill;
	end
	ISBuildMenu.requireHammer(lampOption)

	if lampOption.notAvailable then
		option.notAvailable = true;
	end
end

ISBuildMenu.onPillarLamp = function(worldobjects, square, sprite, player)
	-- sprite, northSprite
	local lamp = ISLightSource:new(sprite.sprite, sprite.northSprite, getSpecificPlayer(player), ISBuildMenu.isNailsBoxNeededOpening(4));
	lamp.offsetX = 5;
	lamp.offsetY = 5;
	lamp.modData["need:Base.Plank"] = "2";
	lamp.modData["need:Base.Rope"] = "1";
	lamp.modData["need:Base.Nails"] = "4";
	lamp.modData["xp:Woodwork"] = 5;
	--    lamp.modData["need:Base.Torch"] = "1";
	lamp:setEastSprite(sprite.eastSprite);
	lamp:setSouthSprite(sprite.southSprite);
	lamp.fuel = "Base.Battery";
	lamp.baseItem = "Base.Torch";
	lamp.radius = 10;
	lamp.player = player
	getCell():setDrag(lamp, player);
end

-- **********************************************
-- **                  *WALL*                  **
-- **********************************************

ISBuildMenu.buildWallMenu = function(subMenu, option, player)
	local sprite = ISBuildMenu.getWoodenWallFrameSprites(player);
	local wallOption = subMenu:addOption(getText("ContextMenu_Wooden_Wall_Frame"), worldobjects, ISBuildMenu.onWoodenWallFrame, sprite, player);
	local toolTip = ISBuildMenu.canBuild(2, 2, 0, 0, 0, 2, wallOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Wall_Frame"));
	toolTip.description = getText("Tooltip_craft_woodenWallFrameDesc") .. toolTip.description;
	toolTip:setTexture(sprite.sprite);
	ISBuildMenu.requireHammer(wallOption)

	local frameSprite = ISBuildMenu.getWoodenDoorFrameSprites(player);
	local doorFrameOption = subMenu:addOption(getText("ContextMenu_Door_Frame"), worldobjects, ISBuildMenu.onWoodenDoorFrame, square, frameSprite, player);
	local toolTip = ISBuildMenu.canBuild(4, 4, 0, 0, 0, 2, doorFrameOption, player);
	toolTip:setName(getText("ContextMenu_Door_Frame"));
	toolTip.description = getText("Tooltip_craft_doorFrameDesc") .. toolTip.description;
	toolTip:setTexture(frameSprite.sprite);
	ISBuildMenu.requireHammer(doorFrameOption)

	--	local sprite = ISBuildMenu.getWoodenWallSprites(player);
	--	local wallOption = subMenu:addOption(getText("ContextMenu_Wooden_Wall"), worldobjects, ISBuildMenu.onWoodenWall, sprite, player);
	--	local tooltip = ISBuildMenu.canBuild(3, 3, 0, 0, 0, 2, wallOption, player);
	--	tooltip:setName(getText("ContextMenu_Wooden_Wall"));
	--	tooltip.description = getText("Tooltip_craft_woodenWallDesc") .. tooltip.description;
	--	tooltip:setTexture(sprite.sprite);
	--	ISBuildMenu.requireHammer(wallOption)

	local cornerOption = subMenu:addOption(getText("ContextMenu_Wooden_Wall_Corner"), worldobjects, ISBuildMenu.onWoodenWallCorner, player);
	local toolTip = ISBuildMenu.canBuild(2, 3, 0, 0, 0, 2, cornerOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Wall_Corner"));
	toolTip.description = getText("Tooltip_craft_woodenCornerDesc") .. toolTip.description;
	toolTip:setTexture("walls_exterior_wooden_01_27");
	ISBuildMenu.requireHammer(cornerOption)

	local pillarOption = subMenu:addOption(getText("ContextMenu_Wooden_Pillar"), worldobjects, ISBuildMenu.onWoodenPillar, player);
	local toolTip = ISBuildMenu.canBuild(2, 3, 0, 0, 0, 2, pillarOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Pillar"));
	toolTip.description = getText("Tooltip_craft_woodenPillarDesc") .. toolTip.description;
	toolTip:setTexture("fixtures_stairs_01_70");
	ISBuildMenu.requireHammer(pillarOption)

	local logOption = subMenu:addOption(getText("ContextMenu_Log_Wall"), worldobjects, ISBuildMenu.onLogWall, player);
	local toolTip = ISBuildMenu.canBuild(0, 0, 0, 0, 0, 0, logOption, player);
	toolTip:setName(getText("ContextMenu_Log_Wall"));
	local numLog = ISBuildMenu.countMaterial(player, "Base.Log")
	if numLog < 4 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.Log") .. " " .. numLog .. "/4 <LINE> ";
		logOption.onSelect = nil;
		logOption.notAvailable = true;
	elseif not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Log") .. " " .. numLog .. "/4 <LINE> ";
	end
	toolTip:setTexture("carpentry_02_80");

	-- log wall require either 4 ripped sheet, 4 twine or 2 ropes
	local numRippedSheets = ISBuildMenu.countMaterial(player, "Base.RippedSheets") + ISBuildMenu.countMaterial(player, "Base.RippedSheetsDirty") + ISBuildMenu.countMaterial(player, "Base.AlcoholRippedSheets")
	local numTwine = ISBuildMenu.countMaterial(player, "Base.Twine")
	local numRope = ISBuildMenu.countMaterial(player, "Base.Rope")
	if not ISBuildMenu.cheat then
		if numRippedSheets >= 4 then
			toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.RippedSheets") .. " " .. numRippedSheets .. "/4 ";
		elseif numTwine >= 4 then
			toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Twine") .. " " .. numTwine .. "/4 ";
		elseif numRope >= 2 then
			toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Rope") .. " " .. numRope .. "/2 ";
		else
			toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.RippedSheets") .. " " .. numRippedSheets .. "/4 <LINE> " .. getText("ContextMenu_or") .. " " .. getItemNameFromFullType("Base.Twine") .. " " .. numTwine .. "/4 <LINE> " .. getText("ContextMenu_or") .. " " ..   getItemNameFromFullType("Base.Rope") .. " " .. numRope .. "/2 ";
			logOption.onSelect = nil;
			logOption.notAvailable = true;
		end
	end
	toolTip.description = getText("Tooltip_craft_wallLogDesc") .. toolTip.description;

	local logPillarOption = subMenu:addOption(getText("ContextMenu_Log_Pillar"), worldobjects, ISBuildMenu.onLogPillar, player);
	local toolTip = ISBuildMenu.canBuild(0, 0, 0, 0, 0, 0, logPillarOption, player);
	toolTip:setName(getText("ContextMenu_Log_Pillar"));
	local numLog = ISBuildMenu.countMaterial(player, "Base.Log")
	if numLog < 1 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemText("Log") .. " " .. numLog .. "/1 <LINE> ";
		logPillarOption.onSelect = nil;
		logPillarOption.notAvailable = true;
	elseif not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemText("Log") .. " " .. ISBuildMenu.countMaterial(player, "Base.Log") .. "/1 <LINE> ";
	end
	toolTip:setTexture("carpentry_02_83");

	-- log wall require either 4 ripped sheet, 4 twine or 2 ropes
	local numRippedSheets = ISBuildMenu.countMaterial(player, "Base.RippedSheets") + ISBuildMenu.countMaterial(player, "Base.RippedSheetsDirty") + ISBuildMenu.countMaterial(player, "Base.AlcoholRippedSheets")
	local numTwine = ISBuildMenu.countMaterial(player, "Base.Twine")
	local numRope = ISBuildMenu.countMaterial(player, "Base.Rope")
	if not ISBuildMenu.cheat then
		if numRippedSheets >= 2 then
			toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemText("Ripped Sheets") .. " " .. numRippedSheets .. "/2 ";
		elseif numTwine >= 2 then
			toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemText("Twine") .. " " .. numTwine .. "/2 ";
		elseif numRope >= 1 then
			toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemText("Rope") .. " " .. numRope .. "/1 ";
		else
			toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemText("Ripped Sheets") .. " " .. numRippedSheets .. "/2 <LINE> " .. getText("ContextMenu_or") .. " " .. getItemText("Twine") .. " " .. numTwine .. "/2 <LINE> " .. getText("ContextMenu_or") .. " " ..   getItemText("Rope") .. " " .. numRope .. "/1 ";
			logPillarOption.onSelect = nil;
			logPillarOption.notAvailable = true;
		end
	end
	toolTip.description = getText("Tooltip_craft_logPillarDesc") .. toolTip.description;

	if wallOption.notAvailable and logOption.notAvailable and logPillarOption.notAvailable and pillarOption.notAvailable and cornerOption.notAvailable and doorFrameOption.notAvailable then
		option.notAvailable = true;
	end
end

ISBuildMenu.onWoodenWallCorner = function(worldobjects, player)
	local wall = ISWoodenWall:new("walls_exterior_wooden_01_27", "walls_exterior_wooden_01_27", nil, ISBuildMenu.isNailsBoxNeededOpening(2));
	wall.modData["need:Base.Plank"] = "1";
	wall.modData["need:Base.Nails"] = "2";
	wall.modData["xp:Woodwork"] = 3;
	wall.modData["wallType"] = "pillar";
	wall.canBePlastered = true;
	wall.canPassThrough = true;
	wall.canBarricade = false
	wall.player = player;
	wall.isCorner = true;
	wall.name = "Wooden Corner"
	getCell():setDrag(wall, player);
end

ISBuildMenu.onWoodenPillar = function(worldobjects, player)
	local wall = ISWoodenWall:new("fixtures_stairs_01_70", "fixtures_stairs_01_71", nil, ISBuildMenu.isNailsBoxNeededOpening(3));
	wall.modData["need:Base.Plank"] = "2";
	wall.modData["need:Base.Nails"] = "3";
	wall.modData["xp:Woodwork"] = 3;
	wall.modData["wallType"] = "pillar";
	wall.canBePlastered = false;
	wall.canPassThrough = true;
	wall.canBarricade = false;
	wall.player = player;
	wall.isCorner = true;
	wall.name = "Wooden Pillar"
	getCell():setDrag(wall, player);
end

ISBuildMenu.canBuildLogWall = function(player)
	local logs = ISBuildMenu.countMaterial(player, "Base.Log")
	local sheets = ISBuildMenu.countMaterial(player, "Base.RippedSheets") + ISBuildMenu.countMaterial(player, "Base.RippedSheetsDirty") + ISBuildMenu.countMaterial(player, "Base.AlcoholRippedSheets")
	local twine = ISBuildMenu.countMaterial(player, "Base.Twine")
	local rope = ISBuildMenu.countMaterial(player, "Base.Rope")
	return logs >= 4 and (sheets >= 4 or twine >= 4 or rope >= 2)
end

ISBuildMenu.onLogWall = function(worldobjects, player)
	local wall = ISWoodenWall:new("carpentry_02_80", "carpentry_02_81", "carpentry_02_82");
	wall.modData["need:Base.Log"] = "4";
	local sheets = ISBuildMenu.countMaterial(player, "Base.RippedSheets");
	local sheetsDirty = ISBuildMenu.countMaterial(player, "Base.RippedSheetsDirty");
	if sheets > 4 then sheets = 4; sheetsDirty = 0 end
	if sheetsDirty > 4 then sheetsDirty = 4; sheets = 0 end
	if sheets < 4 and sheetsDirty > 0 then sheetsDirty = 4 - sheets; end
	if sheets + sheetsDirty >= 4 then
		if sheets > 0 then wall.modData["need:Base.RippedSheets"] = tostring(sheets); end
		if sheetsDirty > 0 then wall.modData["need:Base.RippedSheetsDirty"] = tostring(sheetsDirty); end
	elseif ISBuildMenu.countMaterial(player, "Base.Twine") >= 4 then
		wall.modData["need:Base.Twine"] = "4";
	elseif ISBuildMenu.countMaterial(player, "Base.Rope") >= 2 then
		wall.modData["need:Base.Rope"] = "2";
	end
	wall.modData["xp:Woodwork"] = 5;
	wall.player = player;
	wall.noNeedHammer = true
	wall.canBarricade = false
	wall.name = "Log Wall"
	getCell():setDrag(wall, player);
end

ISBuildMenu.canBuildLogPillar = function(player)
	local logs = ISBuildMenu.countMaterial(player, "Base.Log")
	local sheets = ISBuildMenu.countMaterial(player, "Base.RippedSheets") + ISBuildMenu.countMaterial(player, "Base.RippedSheetsDirty") + ISBuildMenu.countMaterial(player, "Base.AlcoholRippedSheets")
	local twine = ISBuildMenu.countMaterial(player, "Base.Twine")
	local rope = ISBuildMenu.countMaterial(player, "Base.Rope")
	return logs >= 1 and (sheets >= 2 or twine >= 2 or rope >= 1)
end

ISBuildMenu.onLogPillar = function(worldobjects, player)
	local wall = ISWoodenWall:new("carpentry_02_83", "carpentry_02_83", nil);
	wall.modData["need:Base.Log"] = "1";
	local sheets = ISBuildMenu.countMaterial(player, "Base.RippedSheets");
	local sheetsDirty = ISBuildMenu.countMaterial(player, "Base.RippedSheetsDirty");
	if sheets > 2 then sheets = 2; sheetsDirty = 0 end
	if sheetsDirty > 2 then sheetsDirty = 2; sheets = 0 end
	if sheets < 2 and sheetsDirty > 0 then sheetsDirty = 2 - sheets; end
	if sheets + sheetsDirty >= 2 then
		if sheets > 0 then wall.modData["need:Base.RippedSheets"] = tostring(sheets); end
		if sheetsDirty > 0 then wall.modData["need:Base.RippedSheetsDirty"] = tostring(sheetsDirty); end
	elseif ISBuildMenu.countMaterial(player, "Base.Twine") >= 2 then
		wall.modData["need:Base.Twine"] = "2";
	elseif ISBuildMenu.countMaterial(player, "Base.Rope") >= 1 then
		wall.modData["need:Base.Rope"] = "1";
	end
	wall.modData["xp:Woodwork"] = 5;
	wall.player = player;
	wall.noNeedHammer = true
	wall.canBarricade = false
	wall.isCorner = true;
	wall.name = "Log Pillar"
	getCell():setDrag(wall, player);
end

ISBuildMenu.onWoodenWall = function(worldobjects, sprite, player)
	-- sprite, northSprite, corner
	local wall = ISWoodenWall:new(sprite.sprite, sprite.northSprite, sprite.corner, ISBuildMenu.isNailsBoxNeededOpening(3));
	if getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) >= 8 then
		wall.canBePlastered = true;
	end
	wall.canBarricade = false
	-- set up the required material
	wall.modData["wallType"] = "wall";
	wall.modData["xp:Woodwork"] = 5;
	wall.modData["need:Base.Plank"] = "3";
	wall.modData["need:Base.Nails"] = "3";
	wall.player = player;
	getCell():setDrag(wall, player);
end

ISBuildMenu.onWoodenWallFrame = function(worldobjects, sprite, player)
	-- sprite, northSprite, corner
	local wall = ISWoodenWall:new(sprite.sprite, sprite.northSprite, sprite.corner, ISBuildMenu.isNailsBoxNeededOpening(2));
	wall.canBarricade = false
	wall.name = "WoodenWallFrame";
	-- set up the required material
	wall.modData["xp:Woodwork"] = 5;
	wall.modData["need:Base.Plank"] = "2";
	wall.modData["need:Base.Nails"] = "2";
	wall.health = 50;
	wall.player = player;
	getCell():setDrag(wall, player);
end

-- **********************************************
-- **              *WINDOWS FRAME*             **
-- **********************************************
ISBuildMenu.buildWindowsFrameMenu = function(subMenu, player)
	local sprite = ISBuildMenu.getWoodenWindowsFrameSprites(player);
	local wallOption = subMenu:addOption(getText("ContextMenu_Windows_Frame"), worldobjects, ISBuildMenu.onWoodenWindowsFrame, square, sprite, player);
	local toolTip = ISBuildMenu.canBuild(4, 4, 0, 0, 0, 2, wallOption, player);
	toolTip:setName(getText("ContextMenu_Windows_Frame"));
	toolTip.description = getText("Tooltip_craft_woodenFrameDesc") .. toolTip.description;
	toolTip:setTexture(sprite.sprite);
	ISBuildMenu.requireHammer(wallOption)
end

ISBuildMenu.onWoodenWindowsFrame = function(worldobjects, square, sprite, player)
	-- sprite, northSprite, corner
	local frame = ISWoodenWall:new(sprite.sprite, sprite.northSprite, sprite.corner, ISBuildMenu.isNailsBoxNeededOpening(4));
	if getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) >= 8 then
		frame.canBePlastered = true;
	end
	frame.hoppable = true;
	frame.isThumpable = false
	-- set up the required material
	frame.modData["xp:Woodwork"] = 5;
	frame.modData["wallType"] = "windowsframe";
	frame.modData["need:Base.Plank"] = "4";
	frame.modData["need:Base.Nails"] = "4";
	frame.player = player
	frame.name = "Window Frame"
	getCell():setDrag(frame, player);
end

-- **********************************************
-- **                  *FLOOR*                 **
-- **********************************************

ISBuildMenu.buildBetterFloorMenu = function(subMenu, option, player)
	-- simple wooden floor
	local floorSprite = ISBuildMenu.getWoodenFloorSprites(player);
	local floorOption = subMenu:addOption(getText("ContextMenu_Wooden_Floor"), worldobjects, ISBuildMenu.onWoodenFloor, square, floorSprite, player);
	local toolTip = ISBuildMenu.canBuild(1, 1, 0, 0, 0, 1, floorOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Floor"));
	toolTip.description = getText("Tooltip_craft_woodenFloorDesc") .. toolTip.description;
	toolTip:setTexture(floorSprite.sprite);
	ISBuildMenu.requireHammer(floorOption)
	-- brown wooden floor
	local floorBrownOption = subMenu:addOption(getText("ContextMenu_Brown_Wooden_Floor"), worldobjects, ISBuildMenu.onWoodenBrownFloor, square, "floors_interior_tilesandwood_01_52", player);
	local toolTip = ISBuildMenu.canBuild(1, 1, 0, 0, 0, 4, floorBrownOption, player);
	toolTip:setName(getText("ContextMenu_Brown_Wooden_Floor"));
	toolTip.description = getText("Tooltip_craft_woodenBrownFloorDesc") .. toolTip.description;
	toolTip:setTexture("floors_interior_tilesandwood_01_52");
	ISBuildMenu.requireHammer(floorBrownOption)
	-- light brown wooden floor
	local floorLightBrownOption = subMenu:addOption(getText("ContextMenu_Light_Brown_Wooden_Floor"), worldobjects, ISBuildMenu.onWoodenLightBrownFloor, square, "floors_interior_tilesandwood_01_40", player);
	local toolTip = ISBuildMenu.canBuild(1, 1, 0, 0, 0, 4, floorLightBrownOption, player);
	toolTip:setName(getText("ContextMenu_Light_Brown_Wooden_Floor"));
	toolTip.description = getText("Tooltip_craft_woodenLightBrownFloorDesc") .. toolTip.description;
	toolTip:setTexture("floors_interior_tilesandwood_01_40");
	ISBuildMenu.requireHammer(floorLightBrownOption)
	if getActivatedMods():contains("AquatsarYachtClub") then
		ISBuildMenu.buildBridgeMenu(subMenu, option, player)
	end
	if floorOption.notAvailable and floorBrownOption.notAvailable and floorLightBrownOption.notAvailable then
		option.notAvailable = true;
	end
end

ISBuildMenu.onWoodenFloor = function(worldobjects, square, sprite, player)
	-- sprite, northSprite
	local foor = ISWoodenFloor:new(sprite.sprite, sprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(1))
	foor.modData["need:Base.Plank"] = "1";
	foor.modData["xp:Woodwork"] = 3;
	foor.modData["need:Base.Nails"] = "1";
	foor.player = player
	getCell():setDrag(foor, player);
end

ISBuildMenu.onWoodenBrownFloor = function(worldobjects, square, sprite, player)
	-- sprite, northSprite
	local foor = ISWoodenFloor:new("floors_interior_tilesandwood_01_52", "floors_interior_tilesandwood_01_52", ISBuildMenu.isNailsBoxNeededOpening(1))
	foor.modData["need:Base.Plank"] = "1";
	foor.modData["xp:Woodwork"] = 3;
	foor.modData["need:Base.Nails"] = "1";
	getCell():setDrag(foor, player);
end

ISBuildMenu.onWoodenLightBrownFloor = function(worldobjects, square, sprite, player)
	-- sprite, northSprite
	local foor = ISWoodenFloor:new("floors_interior_tilesandwood_01_40", "floors_interior_tilesandwood_01_40", ISBuildMenu.isNailsBoxNeededOpening(1))
	foor.modData["need:Base.Plank"] = "1";
	foor.modData["xp:Woodwork"] = 3;
	foor.modData["need:Base.Nails"] = "1";
	foor.player = player
	getCell():setDrag(foor, player);
end

ISBuildMenu.onConcreteFloor = function(worldobjects, square, sprite, player)
	-- sprite, northSprite, corner
	local cross = ISWoodenFloor:new("blends_street_01_102", "blends_street_01_103");
	cross.modData["use:Base.BucketConcreteFull"] = "1";
	cross.maxTime = 50;
	cross.noNeedHammer = true;
	cross.player = player
	getCell():setDrag(cross, player);
end

ISBuildMenu.onWoodenCrate = function(worldobjects, square, crateSprite, player)
	-- sprite, northSprite
	local crate = ISWoodenContainer:new(crateSprite.sprite, crateSprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(3));
	crate.renderFloorHelper = true
	crate.canBeAlwaysPlaced = true;
	crate.modData["xp:Woodwork"] = 3;
	crate.modData["need:Base.Plank"] = "3";
	crate.modData["need:Base.Nails"] = "3";
	crate:setEastSprite(crateSprite.eastSprite);
	crate.player = player
	getCell():setDrag(crate, player);
end

ISBuildMenu.onWoodenCrateHalf = function(worldobjects, square, crateSprite, player)
	-- sprite, northSprite
	local crate = ISWoodenContainer:new(crateSprite.sprite, crateSprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(2));
	crate.renderFloorHelper = true
	crate.canBeAlwaysPlaced = false;
	crate.modData["xp:Woodwork"] = 5;
	crate.modData["need:Base.Plank"] = "2";
	crate.modData["need:Base.Nails"] = "2";
	crate.player = player
	getCell():setDrag(crate, player);
end

-- **********************************************
-- **                *FURNITURE*               **
-- **********************************************

ISBuildMenu.buildFurnitureMenu = function(subMenu, context, option, player)
    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()
	-- **************** Bedding **************** --
	local beddingOption = subMenu:addOption(getText("ContextMenu_Bedding"), worldobjects, nil);
	local subMenuBedding = subMenu:getNew(subMenu);
	context:addSubMenu(beddingOption, subMenuBedding);
	-- bed
	local bedSprite = ISBuildMenu.getBedSprite(player);
	local bedOption = subMenuBedding:addOption(getText("ContextMenu_Bed"), worldobjects, ISBuildMenu.onBed, square, bedSprite, player);
	local toolTip = ISBuildMenu.canBuild(6, 4, 0, 0, 0, 0, bedOption, player);
	local carpentrySkill = 4;
	-- we add that we need a mattress too
	local mattress = ISBuildMenu.countMaterial(player, "Base.Mattress");
	if ISBuildMenu.countMaterial(player, "Base.Mattress") < 1 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.Mattress") .. " " .. mattress .. "/1 ";
		bedOption.onSelect = nil;
		bedOption.notAvailable = true;
	elseif not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Mattress") .. " " .. mattress .. "/1 ";
	end
	if playerObj:getPerkLevel(Perks.Woodwork) < carpentrySkill and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_Carpentry") .. " " .. playerObj:getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill;
		bedOption.notAvailable = true;
	elseif carpentrySkill > 0 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_Carpentry") .. " " .. playerObj:getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill;
	end
	toolTip:setName(getText("ContextMenu_Bed"));
	toolTip.description = getText("Tooltip_craft_bedDesc") .. toolTip.description;
	toolTip:setTexture(bedSprite.sprite1);
	ISBuildMenu.requireHammer(bedOption)

	if bedOption.notAvailable then
		beddingOption.notAvailable = true;
	end

	-- **************** Chair **************** --
	local chairMenuOption = subMenu:addOption(getText("ContextMenu_Chair"), worldobjects, nil);
	local subMenuChair = subMenu:getNew(subMenu);
	context:addSubMenu(chairMenuOption, subMenuChair);

	local chairSprite = ISBuildMenu.getWoodenChairSprites(player);
	local chairOption = subMenuChair:addOption(getText("ContextMenu_Wooden_Chair"), worldobjects, ISBuildMenu.onWoodChair, square, chairSprite, player);
	local tooltip = ISBuildMenu.canBuild(5, 4, 0, 0, 0, 2, chairOption, player);
	tooltip:setName(getText("ContextMenu_Wooden_Chair"));
	tooltip.description = getText("Tooltip_craft_woodenChairDesc") .. tooltip.description;
	tooltip:setTexture(chairSprite.sprite);
	ISBuildMenu.requireHammer(chairOption)

	local stoolOption = subMenuChair:addOption(getText("ContextMenu_Wooden_Stool"), worldobjects, ISBuildMenu.onWoodStool, square, "location_restaurant_bar_01_26", player);
	local tooltip = ISBuildMenu.canBuild(4, 3, 0, 0, 0, 8, stoolOption, player);
	tooltip:setName(getText("ContextMenu_Wooden_Stool"));
	tooltip.description = getText("Tooltip_craft_woodenStoolDesc") .. tooltip.description;
	tooltip:setTexture("location_restaurant_bar_01_26");
	ISBuildMenu.requireHammer(stoolOption)

	if chairOption.notAvailable and stoolOption.notAvailable then
		chairMenuOption.notAvailable = true;
	end

	-- *************** Container *************** --
	local containerOption = subMenu:addOption(getText("ContextMenu_Container"), worldobjects, nil);
	local subMenuContainer = subMenu:getNew(subMenu);
	context:addSubMenu(containerOption, subMenuContainer);
	-- Compost
	local compostOption = subMenuContainer:addOption(getText("ContextMenu_Compost"), worldobjects, ISBuildMenu.onCompost, player, "camping_01_19");
	local toolTip = ISBuildMenu.canBuild(5, 4, 0, 0, 0, 2, compostOption, player);
	toolTip:setName(getText("ContextMenu_Compost"));
	toolTip.description = getText("Tooltip_craft_compostDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "50" .. toolTip.description;
	toolTip:setTexture("camping_01_19");
	ISBuildMenu.requireHammer(compostOption)
	-- wooden crate
	local crateSprite = ISBuildMenu.getWoodenCrateSprites(player);
	local crateOption = subMenuContainer:addOption(getText("ContextMenu_Wooden_Crate"), worldobjects, ISBuildMenu.onWoodenCrate, square, crateSprite, player);
	local toolTip = ISBuildMenu.canBuild(3, 3, 0, 0, 0, 3, crateOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Crate"));
	toolTip.description = getText("Tooltip_craft_woodenCrateDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "50" .. toolTip.description;
	toolTip:setTexture(crateSprite.sprite);
	ISBuildMenu.requireHammer(crateOption)

	if crateOption.notAvailable and compostOption.notAvailable then
		containerOption.notAvailable = true;
	end

	-- *************** Counter *************** --
	local barOption = subMenu:addOption(getText("ContextMenu_Bar"), worldobjects, nil);
	local subMenuBar = subMenu:getNew(subMenu);
	context:addSubMenu(barOption, subMenuBar);
	-- counter
	local barElemSprite = ISBuildMenu.getBarElementSprites(player);
	local barElemOption = subMenuBar:addOption(getText("ContextMenu_Counter_Element"), worldobjects, ISBuildMenu.onBarElement, barElemSprite, player);
	local toolTip = ISBuildMenu.canBuild(4,4,0,0,0,7,barElemOption, player);
	toolTip:setName(getText("ContextMenu_Counter_Element"));
	toolTip.description = getText("Tooltip_craft_counterElementDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "50" .. toolTip.description;
	toolTip:setTexture(barElemSprite.sprite);
	ISBuildMenu.requireHammer(barElemOption)
	-- corner counter
	local barCornerSprite = ISBuildMenu.getBarCornerSprites(player);
	local barCornerOption = subMenuBar:addOption(getText("ContextMenu_Counter_Corner"), worldobjects, ISBuildMenu.onBarElement, barCornerSprite, player);
	local toolTip = ISBuildMenu.canBuild(4,4,0,0,0,7,barCornerOption, player);
	toolTip:setName(getText("ContextMenu_Counter_Corner"));
	toolTip.description = getText("Tooltip_craft_counterElementDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "50" .. toolTip.description;
	toolTip:setTexture(barCornerSprite.sprite);
	ISBuildMenu.requireHammer(barCornerOption)
	-- bar counter
	local barElem2Sprite = ISBuildMenu.getBarElement2Sprites(player);
	local barElem2Option = subMenuBar:addOption(getText("ContextMenu_Bar_Element"), worldobjects, ISBuildMenu.onBar2Element, barElem2Sprite, player);
	local toolTip = ISBuildMenu.canBuild(6,6,0,0,0,10,barElem2Option, player);
	toolTip:setName(getText("ContextMenu_Bar_Element"));
	toolTip.description = getText("Tooltip_craft_barElementDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "50" .. toolTip.description;
	toolTip:setTexture(barElem2Sprite.sprite);
	ISBuildMenu.requireHammer(barElem2Option)
	-- bar corner
	local barCorner2Sprite = ISBuildMenu.getBarCorner2Sprites(player);
	local barCorner2Option = subMenuBar:addOption(getText("ContextMenu_Bar_Corner"), worldobjects, ISBuildMenu.onBar2Element, barCorner2Sprite, player);
	local toolTip = ISBuildMenu.canBuild(6,6,0,0,0,10,barCorner2Option, player);
	toolTip:setName(getText("ContextMenu_Bar_Corner"));
	toolTip.description = getText("Tooltip_craft_barElementDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "50" .. toolTip.description;
	toolTip:setTexture(barCorner2Sprite.southSprite);
	ISBuildMenu.requireHammer(barCorner2Option)

	if barElemOption.notAvailable and barCornerOption.notAvailable and barElem2Option.notAvailable and barCorner2Option.notAvailable then
		barOption.notAvailable = true;
	end

	-- **************** Plumbing **************** --
	local plumbingOption = subMenu:addOption(getText("ContextMenu_Plumbing"), worldobjects, nil);
	local subMenuPlumbing = subMenu:getNew(subMenu);
	context:addSubMenu(plumbingOption, subMenuPlumbing);
	-- wooden toilet
	local woodenToiletSprite = ISBuildMenu.getWoodenToiletSprites(player);
	local woodenToiletOption = subMenuPlumbing:addOption(getText("ContextMenu_Wooden_Toilet"), worldobjects, ISBuildMenu.onWoodenToilet, square, woodenToiletSprite, player);
	local toolTip = ISBuildMenu.canBuild(5,4,0,0,0,0,woodenToiletOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Toilet"));
	toolTip.description = getText("Tooltip_craft_woodenToiletDesc") .. toolTip.description;
	toolTip:setTexture("fixtures_bathroom_02_24");
	ISBuildMenu.requireHammer(woodenToiletOption);
	-- rain collector barrel (small)
	local smallCollectorOption = subMenuPlumbing:addOption(getText("ContextMenu_Small_Rain_Collector"), worldobjects, ISBuildMenu.onCreateSmallBarrel, player, "carpentry_02_54", RainCollectorBarrel.smallWaterMax);
	local toolTip = ISBuildMenu.canBuild(4,4,0,0,0,0,smallCollectorOption, player);
	local carpentrySkill = 4;
	-- we add that we need 4 garbage bag too
	local garbagebag = ISBuildMenu.countMaterial(player, "Base.Garbagebag");
	if garbagebag < 4 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.Garbagebag") .. " " .. garbagebag .. "/4 ";
		smallCollectorOption.onSelect = nil;
		smallCollectorOption.notAvailable = true;
	elseif not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Garbagebag") .. " " .. garbagebag .. "/4 ";
	end
	if playerObj:getPerkLevel(Perks.Woodwork) < carpentrySkill and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_Carpentry") .. " " .. playerObj:getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill;
		smallCollectorOption.notAvailable = true;
	elseif carpentrySkill > 0 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_Carpentry") .. " " .. playerObj:getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill;
	end
	toolTip:setName(getText("ContextMenu_Small_Rain_Collector"));
	toolTip.description = getText("Tooltip_craft_rainBarrelDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "80 " .. getText("ContextMenu_Uses") .. toolTip.description;
	toolTip:setTexture("carpentry_02_54");
	ISBuildMenu.requireHammer(smallCollectorOption)

	-- rain collector barrel (large)
	local largeCollectorOption = subMenuPlumbing:addOption(getText("ContextMenu_Large_Rain_Collector"), worldobjects, ISBuildMenu.onCreateLargeBarrel, player, "carpentry_02_52", RainCollectorBarrel.largeWaterMax);
	local toolTip = ISBuildMenu.canBuild(8,8,0,0,0,7,largeCollectorOption, player);
	toolTip:setName(getText("ContextMenu_Large_Rain_Collector"));
	toolTip.description = getText("Tooltip_craft_rainBarrelDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "200 " .. getText("ContextMenu_Uses") .. toolTip.description;
	toolTip:setTexture("carpentry_02_52");
	ISBuildMenu.requireHammer(largeCollectorOption)

	if smallCollectorOption.notAvailable and largeCollectorOption.notAvailable and woodenToiletOption.notAvailable then
		plumbingOption.notAvailable = true;
	end

	-- **************** Shelving **************** --
	local shelvingOption = subMenu:addOption(getText("ContextMenu_Shelving"), worldobjects, nil);
	local subMenuShelving = subMenu:getNew(subMenu);
	context:addSubMenu(shelvingOption, subMenuShelving);
	-- bookcase
	local bookSprite = ISBuildMenu.getBookcaseSprite(player);
	local bookOption = subMenuShelving:addOption(getText("ContextMenu_Bookcase"), worldobjects, ISBuildMenu.onBookcase, square, bookSprite, player);
	local tooltip5 = ISBuildMenu.canBuild(5,4,0,0,0,5,bookOption, player);
	tooltip5:setName(getText("ContextMenu_Bookcase"));
	tooltip5.description = getText("Tooltip_craft_bookcaseDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "40" .. tooltip5.description;
	tooltip5:setTexture(bookSprite.sprite);
	ISBuildMenu.requireHammer(bookOption)

	local book2Sprite = ISBuildMenu.getSmallBookcaseSprite(player);
	local book2Option = subMenuShelving:addOption(getText("ContextMenu_SmallBookcase"), worldobjects, ISBuildMenu.onSmallBookcase, square, book2Sprite, player);
	local tooltip7 = ISBuildMenu.canBuild(3,3,0,0,0,3,book2Option, player);
	tooltip7:setName(getText("ContextMenu_SmallBookcase"));
	tooltip7.description = getText("Tooltip_craft_smallBookcaseDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "20" .. tooltip7.description;
	tooltip7:setTexture(book2Sprite.sprite);
	ISBuildMenu.requireHammer(book2Option)

	local shelveSprite = ISBuildMenu.getShelveSprite(player);
	local shelveOption = subMenuShelving:addOption(getText("ContextMenu_Shelves"), worldobjects, ISBuildMenu.onShelve, square, shelveSprite, player);
	local tooltip6 = ISBuildMenu.canBuild(1,2,0,0,0,2,shelveOption, player);
	tooltip6:setName(getText("ContextMenu_Shelves"));
	tooltip6.description = getText("Tooltip_craft_shelvesDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "10" .. tooltip6.description;
	tooltip6:setTexture(shelveSprite.sprite);
	ISBuildMenu.requireHammer(shelveOption)

	local shelve2Sprite = ISBuildMenu.getDoubleShelveSprite(player);
	local shelve2Option = subMenuShelving:addOption(getText("ContextMenu_DoubleShelves"), worldobjects, ISBuildMenu.onDoubleShelve, square, shelve2Sprite, player);
	local tooltip8 = ISBuildMenu.canBuild(2,4,0,0,0,2,shelve2Option, player);
	tooltip8:setName(getText("ContextMenu_DoubleShelves"));
	tooltip8.description = getText("Tooltip_craft_doubleShelvesDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "15" .. tooltip8.description;
	tooltip8:setTexture(shelve2Sprite.sprite);
	ISBuildMenu.requireHammer(shelve2Option)

	if bookOption.notAvailable and book2Option.notAvailable and shelveOption.notAvailable and shelve2Option.notAvailable then
		shelvingOption.notAvailable = true;
	end

	-- **************** Table **************** --
	local tableOption = subMenu:addOption(getText("ContextMenu_Table"), worldobjects, nil);
	local subMenuTable = subMenu:getNew(subMenu);
	context:addSubMenu(tableOption, subMenuTable);

	-- add all our table option
	local tableSprite = ISBuildMenu.getWoodenTableSprites(player);
	local smallTableOption = subMenuTable:addOption(getText("ContextMenu_Small_Table"), worldobjects, ISBuildMenu.onSmallWoodTable, square, tableSprite, player);
	local toolTip = ISBuildMenu.canBuild(5,4,0,0,0,3,smallTableOption, player);
	toolTip:setName(getText("ContextMenu_Small_Table"));
	toolTip.description = getText("Tooltip_craft_smallTableDesc") .. toolTip.description;
	toolTip:setTexture(tableSprite.sprite);
	ISBuildMenu.requireHammer(smallTableOption)

	local largeTableSprite = ISBuildMenu.getLargeWoodTableSprites(player);
	local largeTableOption = subMenuTable:addOption(getText("ContextMenu_Large_Table"), worldobjects, ISBuildMenu.onLargeWoodTable, square, largeTableSprite, player);
	local toolTip = ISBuildMenu.canBuild(6,4,0,0,0,4,largeTableOption, player);
	toolTip:setName(getText("ContextMenu_Large_Table"));
	toolTip.description = getText("Tooltip_craft_largeTableDesc") .. toolTip.description;
	toolTip:setTexture(largeTableSprite.sprite1);
	ISBuildMenu.requireHammer(largeTableOption)

	local drawerSprite = ISBuildMenu.getTableWithDrawerSprites(player);
	local drawerTableOption = subMenuTable:addOption(getText("ContextMenu_Table_with_Drawer"), worldobjects, ISBuildMenu.onSmallWoodTableWithDrawer, square, drawerSprite, player);
	local toolTip = ISBuildMenu.canBuild(5,4,0,0,0,0,drawerTableOption, player);
	local carpentrySkill = 5
	-- we add that we need a Drawer too
	local drawer = ISBuildMenu.countMaterial(player, "Base.Drawer");
	if not playerInv:containsTypeRecurse("Drawer") and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.Drawer") .. " " .. drawer .. "/1 ";
		drawerTableOption.onSelect = nil;
		drawerTableOption.notAvailable = true;
	elseif not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Drawer") .." " .. drawer .. "/1 ";
	end
	if playerObj:getPerkLevel(Perks.Woodwork) < carpentrySkill and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_Carpentry") .. " " .. playerObj:getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill;
		drawerTableOption.notAvailable = true;
	elseif carpentrySkill > 0 and not ISBuildMenu.cheat then
		toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_Carpentry") .. " " .. playerObj:getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill;
	end
	toolTip:setName(getText("ContextMenu_Table_with_Drawer"));
	toolTip.description = getText("Tooltip_craft_tableDrawerDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "10" .. toolTip.description;
	toolTip:setTexture(drawerSprite.sprite);
	ISBuildMenu.requireHammer(drawerTableOption)

	if smallTableOption.notAvailable and largeTableOption.notAvailable and drawerTableOption.notAvailable then
		tableOption.notAvailable = true;
	end

	if  beddingOption.notAvailable and barOption.notAvailable and tableOption.notAvailable and chairOption.notAvailable and bedOption.notAvailable and shelvingOption.notAvailable and plumbingOption.notAvailable then
		option.notAvailable = true;
	end
end

-- create a new barrel to drag a ghost render of the barrel under the mouse
ISBuildMenu.onCreateSmallBarrel = function(worldobjects, player, sprite, waterMax)
	local barrel = RainCollectorBarrel:new(player, sprite, waterMax, ISBuildMenu.isNailsBoxNeededOpening(4));
	-- we now set his the mod data the needed material
	-- by doing this, all will be automatically consummed, drop on the ground if destoryed etc.
	barrel.modData["need:Base.Plank"] = "4";
	barrel.modData["need:Base.Nails"] = "4";
	barrel.modData["need:Base.Garbagebag"] = "4";
	barrel.modData["xp:Woodwork"] = 5;
	-- and now allow the item to be dragged by mouse
	barrel.player = player
	getCell():setDrag(barrel, player);
end

ISBuildMenu.onCreateLargeBarrel = function(worldobjects, player, sprite, waterMax)
	local barrel = RainCollectorBarrel:new(player, sprite, waterMax, ISBuildMenu.isNailsBoxNeededOpening(8));
	-- we now set his the mod data the needed material
	-- by doing this, all will be automatically consummed, drop on the ground if destoryed etc.
	barrel.modData["need:Base.Plank"] = "8";
	barrel.modData["need:Base.Nails"] = "8";
	barrel.modData["xp:Woodwork"] = 10;
	-- and now allow the item to be dragged by mouse
	barrel.player = player
	getCell():setDrag(barrel, player);
end

ISBuildMenu.onCompost = function(worldobjects, player, sprite)
	local compost = ISCompost:new(player, sprite, ISBuildMenu.isNailsBoxNeededOpening(4));
	compost.modData["need:Base.Plank"] = "5";
	compost.modData["need:Base.Nails"] = "4";
	compost.modData["xp:Woodwork"] = 5;
	compost.player = player
	compost.notExterior = true;
	getCell():setDrag(compost, player);
end

ISBuildMenu.onBed = function(worldobjects, square, sprite, player)
	local furniture = ISDoubleTileFurniture:new("Bed", sprite.sprite1, sprite.sprite2, sprite.northSprite1, sprite.northSprite2, ISBuildMenu.isNailsBoxNeededOpening(4));
	furniture.modData["xp:Woodwork"] = 5;
	furniture.modData["need:Base.Plank"] = "6";
	furniture.modData["need:Base.Nails"] = "4";
	furniture.modData["need:Base.Mattress"] = "1";
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenu.onSmallWoodTable = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Small Table", sprite.sprite, sprite.sprite, ISBuildMenu.isNailsBoxNeededOpening(4));
	furniture.modData["xp:Woodwork"] = 3;
	furniture.modData["need:Base.Plank"] = "5";
	furniture.modData["need:Base.Nails"] = "4";
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenu.onSmallWoodTableWithDrawer = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Small Table with Drawer", sprite.sprite, sprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(4));
	furniture.modData["xp:Woodwork"] = 5;
	furniture.modData["need:Base.Plank"] = "5";
	furniture.modData["need:Base.Nails"] = "4";
	furniture.modData["need:Base.Drawer"] = "1";
	furniture:setEastSprite(sprite.eastSprite);
	furniture:setSouthSprite(sprite.southSprite);
	furniture.isContainer = true;
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenu.onLargeWoodTable = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISDoubleTileFurniture:new("Large Table", sprite.sprite1, sprite.sprite2, sprite.northSprite1, sprite.northSprite2, ISBuildMenu.isNailsBoxNeededOpening(4));
	furniture.modData["xp:Woodwork"] = 5;
	furniture.modData["need:Base.Plank"] = "6";
	furniture.modData["need:Base.Nails"] = "4";
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenu.onWoodChair = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Wooden Chair", sprite.sprite, sprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(4));
	furniture.modData["xp:Woodwork"] = 3;
	furniture.modData["need:Base.Plank"] = "5";
	furniture.modData["need:Base.Nails"] = "4";
	-- our chair have 4 tiles (north, east, south and west)
	-- then we define our east and south sprite
	furniture:setEastSprite(sprite.eastSprite);
	furniture:setSouthSprite(sprite.southSprite);
	furniture.canPassThrough = true;
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenu.onWoodStool = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Wooden Stool", "location_restaurant_bar_01_26", "location_restaurant_bar_01_26", ISBuildMenu.isNailsBoxNeededOpening(4));
	furniture.modData["xp:Woodwork"] = 3;
	furniture.modData["need:Base.Plank"] = "5";
	furniture.modData["need:Base.Nails"] = "4";
	-- our chair have 4 tiles (north, east, south and west)
	-- then we define our east and south sprite
	furniture.canPassThrough = true;
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenu.onWoodenToilet = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Wooden Toilet", sprite.sprite, sprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(4));
	furniture:setEastSprite(sprite.eastSprite);
	furniture:setSouthSprite(sprite.southSprite);
	furniture.modData["xp:Woodwork"] = 3;
	furniture.modData["need:Base.Plank"] = "5";
	furniture.modData["need:Base.Nails"] = "4";
	-- our chair have 4 tiles (north, east, south and west)
	-- then we define our east and south sprite
	furniture.canPassThrough = true;
	furniture.canBarricade = false;
	furniture.isThumpable = true;
	furniture.player = player
	furniture.name = "Wooden Toilet"
	furniture.maxTime = 80;
	furniture.renderFloorHelper = true
	getCell():setDrag(furniture, player);
end

ISBuildMenu.onBookcase = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Bookcase", sprite.sprite, sprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(4));
	furniture.canBeAlwaysPlaced = true;
	furniture.isContainer = true;
	furniture.containerType = "shelves";
	furniture.modData["xp:Woodwork"] = 5;
	furniture.modData["need:Base.Plank"] = "5";
	furniture.modData["need:Base.Nails"] = "4";
	-- our chair have 4 tiles (north, east, south and west)
	-- then we define our east and south sprite
	furniture:setEastSprite(sprite.eastSprite);
	furniture:setSouthSprite(sprite.southSprite);
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenu.onSmallBookcase = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Small Bookcase", sprite.sprite, sprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(3));
	furniture.canBeAlwaysPlaced = true;
	furniture.isContainer = true;
	furniture.containerType = "shelves";
	furniture.modData["xp:Woodwork"] = 3;
	furniture.modData["need:Base.Plank"] = "3";
	furniture.modData["need:Base.Nails"] = "3";
	-- our chair have 4 tiles (north, east, south and west)
	-- then we define our east and south sprite
	furniture:setEastSprite(sprite.eastSprite);
	furniture:setSouthSprite(sprite.southSprite);
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenu.onShelve = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Shelves", sprite.sprite, sprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(2));
	furniture.isContainer = true;
	furniture.needToBeAgainstWall = true;
	furniture.blockAllTheSquare = false;
    furniture.isWallLike = true
	furniture.containerType = "shelves";
	furniture.modData["xp:Woodwork"] = 3;
	furniture.modData["need:Base.Plank"] = "1";
	furniture.modData["need:Base.Nails"] = "2";
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenu.onSign = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Wooden Sign", sprite.sprite, sprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(3));
	furniture.blockAllTheSquare = false;
	furniture.isWallLike = true
	furniture.modData["xp:Woodwork"] = 3;
	furniture.modData["need:Base.Plank"] = "3";
	furniture.modData["need:Base.Nails"] = "3";
	furniture.player = player
	getCell():setDrag(furniture, player);
end

ISBuildMenu.onDoubleShelve = function(worldobjects, square, sprite, player)
	-- name, sprite, northSprite
	local furniture = ISSimpleFurniture:new("Double Shelves", sprite.sprite, sprite.northSprite, ISBuildMenu.isNailsBoxNeededOpening(4));
	furniture.isContainer = true;
	furniture.needToBeAgainstWall = true;
	furniture.blockAllTheSquare = false;
	furniture.isWallLike = true
	furniture.containerType = "shelves";
	furniture.modData["xp:Woodwork"] = 5;
	furniture.modData["need:Base.Plank"] = "2";
	furniture.modData["need:Base.Nails"] = "4";
	furniture.player = player
	getCell():setDrag(furniture, player);
end

-- **********************************************
-- **                 *WINDOW*                 **
-- **********************************************

ISBuildMenu.buildWindowMenu = function(subMenu, option, player)

	local windowOption = subMenu:addOption(getText("ContextMenu_Window"), worldobjects, ISBuildMenu.onWindow, square, player);
	local tooltip = ISBuildMenu.canBuild(1,1,0,0,0,1,windowOption, player);
	tooltip:setName(getText("ContextMenu_Wooden_Window"));
	tooltip.description = getText("Tooltip_craft_windowDesc") .. tooltip.description;
	tooltip:setTexture("fixtures_windows_01_6");
	ISBuildMenu.requireHammer(windowOption)

	if windowOption.notAvailable then
		option.notAvailable = true;
	end
end

ISBuildMenu.onWindow = function(worldobjects, square, player)
	local playerObj = getSpecificPlayer(player)
	ISTimedActionQueue.add(ISBuildWindow:new(playerObj, window, 50));
end

-- **********************************************
-- **                 *STAIRS*                 **
-- **********************************************

ISBuildMenu.buildStairsMenu = function(subMenu, option, player)

	local stairsSprite = ISBuildMenu.getStairsSprite(player);
	local stairsOption = subMenu:addOption(getText("ContextMenu_Brown_Wooden_Stairs"), worldobjects, ISBuildMenu.onBrownWoodenStairs, square, player);
	local tooltip = ISBuildMenu.canBuild(15,15,0,0,0,6,stairsOption, player);
	tooltip:setName(getText("ContextMenu_Brown_Wooden_Stairs"));
	tooltip.description = getText("Tooltip_craft_stairsDesc") .. tooltip.description;
	if ISBuildMenu.getStairsSprite(player) == 4 then
		tooltip:setTexture(stairsSprite.sprite1);
	else
		tooltip:setTexture(stairsSprite.northSprite1);
	end
	ISBuildMenu.requireHammer(stairsOption)

	local darkStairsOption = subMenu:addOption(getText("ContextMenu_Dark_Wooden_Stairs"), worldobjects, ISBuildMenu.onDarkWoodenStairs, square, player);
	local tooltip = ISBuildMenu.canBuild(15,15,0,0,0,10,darkStairsOption, player);
	tooltip:setName(getText("ContextMenu_Dark_Wooden_Stairs"));
	tooltip.description = getText("Tooltip_craft_stairsDesc") .. tooltip.description;
	tooltip:setTexture("fixtures_stairs_01_16");
	ISBuildMenu.requireHammer(darkStairsOption)

	local lightStairsOption = subMenu:addOption(getText("ContextMenu_Light_Brown_Wooden_Stairs"), worldobjects, ISBuildMenu.onLightBrownWoodenStairs, square, player);
	local tooltip = ISBuildMenu.canBuild(15,15,0,0,0,10,lightStairsOption, player);
	tooltip:setName(getText("ContextMenu_Light_Brown_Wooden_Stairs"));
	tooltip.description = getText("Tooltip_craft_stairsDesc") .. tooltip.description;
	tooltip:setTexture("fixtures_stairs_01_32");
	ISBuildMenu.requireHammer(lightStairsOption)

	if stairsOption.notAvailable and darkStairsOption.notAvailable and lightStairsOption.notAvailable then
		option.notAvailable = true;
	end
end

ISBuildMenu.onBrownWoodenStairs = function(worldobjects, square, player)
	local stairsSprite = ISBuildMenu.getStairsSprite(player);
	local stairs = ISWoodenStairs:new(stairsSprite.northSprite1, stairsSprite.northSprite2, stairsSprite.northSprite3, stairsSprite.sprite1, stairsSprite.sprite2, stairsSprite.sprite3, stairsSprite.northSprite4, stairsSprite.sprite4, ISBuildMenu.isNailsBoxNeededOpening(15));
	stairs.modData["xp:Woodwork"] = 6;
	stairs.modData["need:Base.Plank"] = "15";
	stairs.modData["need:Base.Nails"] = "15";
	stairs.player = player
	getCell():setDrag(stairs, player);
end

ISBuildMenu.onDarkWoodenStairs = function(worldobjects, square, player)
	local stairs = ISWoodenStairs:new("fixtures_stairs_01_16", "fixtures_stairs_01_17", "fixtures_stairs_01_18", "fixtures_stairs_01_24", "fixtures_stairs_01_25", "fixtures_stairs_01_26", "fixtures_stairs_01_22", "fixtures_stairs_01_23", ISBuildMenu.isNailsBoxNeededOpening(15));
	stairs.modData["xp:Woodwork"] = 10;
	stairs.modData["need:Base.Plank"] = "15";
	stairs.modData["need:Base.Nails"] = "15";
	stairs.player = player
	getCell():setDrag(stairs, player);
end

ISBuildMenu.onLightBrownWoodenStairs = function(worldobjects, square, player)
	local stairs = ISWoodenStairs:new("fixtures_stairs_01_32", "fixtures_stairs_01_33", "fixtures_stairs_01_34", "fixtures_stairs_01_40", "fixtures_stairs_01_41", "fixtures_stairs_01_42", "fixtures_stairs_01_38", "fixtures_stairs_01_39", ISBuildMenu.isNailsBoxNeededOpening(15));
	stairs.modData["xp:Woodwork"] = 10;
	stairs.modData["need:Base.Plank"] = "15";
	stairs.modData["need:Base.Nails"] = "15";
	stairs.player = player
	getCell():setDrag(stairs, player);
end

-- **********************************************
-- **                 *DOOR*                   **
-- **********************************************

ISBuildMenu.buildDoorMenu = function(subMenu, option, player)

	local sprite = ISBuildMenu.getWoodenDoorSprites(player);
	local doorsOption = subMenu:addOption(getText("ContextMenu_Wooden_Door"), worldobjects, ISBuildMenu.onWoodenDoor, square, sprite, player);
	local toolTip = ISBuildMenu.canBuild(4,4,2,1,0,3,doorsOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Door"));
	toolTip.description = getText("Tooltip_craft_woodenDoorDesc") .. toolTip.description;
	toolTip:setTexture(sprite.sprite);
	ISBuildMenu.requireHammer(doorsOption)

	local sprite = {};
	sprite.sprite = "fixtures_bathroom_02_32";
	local doorsOuthouseOption = subMenu:addOption(getText("ContextMenu_Outhouse_Door"), worldobjects, ISBuildMenu.onOuthouseDoor, square, sprite, player);
	local toolTip = ISBuildMenu.canBuild(4,4,2,1,0,3,doorsOuthouseOption, player);
	toolTip:setName(getText("ContextMenu_Outhouse_Door"));
	toolTip.description = getText("Tooltip_craft_outhouseDoorDesc") .. toolTip.description;
	toolTip:setTexture(sprite.sprite);
	ISBuildMenu.requireHammer(doorsOuthouseOption)

	local sprite = {};
	sprite.sprite = "fixtures_doors_fences_01_4";
	local gatesOption = subMenu:addOption(getText("ContextMenu_Wooden_Gate"), worldobjects, ISBuildMenu.onWoodenGate, square, sprite, player);
	local toolTip = ISBuildMenu.canBuild(4,4,2,1,0,3,gatesOption, player);
	toolTip:setName(getText("ContextMenu_Wooden_Gate"));
	toolTip.description = getText("Tooltip_craft_woodenGateDesc") .. toolTip.description;
	toolTip:setTexture(sprite.sprite);
	ISBuildMenu.requireHammer(gatesOption)

	local sprite = {};
	sprite.sprite = "fixtures_doors_fences_01_12";
	local gatesOption2 = subMenu:addOption(getText("ContextMenu_High_Wooden_Gate"), worldobjects, ISBuildMenu.onBigWoodenGate, square, sprite, player);
	local toolTip = ISBuildMenu.canBuild(6,6,2,1,0,5,gatesOption2, player);
	toolTip:setName(getText("ContextMenu_High_Wooden_Gate"));
	toolTip.description = getText("Tooltip_craft_bigWoodenGateDesc") .. toolTip.description;
	toolTip:setTexture(sprite.sprite);
	ISBuildMenu.requireHammer(gatesOption2)

	local sprite = {};
	sprite.sprite = "fixtures_doors_fences_01_";
	local doorsOption2 = subMenu:addOption(getText("ContextMenu_Double_Wooden_Door"), worldobjects, ISBuildMenu.onDoubleWoodenDoor, square, sprite, 104, player);
	local toolTip = ISBuildMenu.canBuild(12,12,4,2,0,6,doorsOption2, player);
	toolTip:setName(getText("ContextMenu_Double_Wooden_Door"));
	toolTip.description = getText("Tooltip_craft_doubleWoodenDoorDesc") .. toolTip.description;
	toolTip:setTexture(sprite.sprite .. "105");
	ISBuildMenu.requireHammer(doorsOption2)

	if doorsOption.notAvailable and gatesOption.notAvailable and doorsOuthouseOption.notAvailable and doorsOption2.notAvailable then
		option.notAvailable = true;
	end
end

ISBuildMenu.onDoubleWoodenDoor = function(worldobjects, square, sprite, spriteIndex, player)
	local door = ISDoubleDoor:new(sprite.sprite, spriteIndex, ISBuildMenu.isNailsBoxNeededOpening(12));
	door.modData["xp:Woodwork"] = 6;
	door.modData["need:Base.Plank"] = "12";
	door.modData["need:Base.Nails"] = "12";
	door.modData["need:Base.Hinge"] = "4";
	door.modData["need:Base.Doorknob"] = "2";
	door.player = player
	getCell():setDrag(door, player);
end

ISBuildMenu.onWoodenDoor = function(worldobjects, square, sprite, player)
	-- sprite, northsprite, openSprite, openNorthSprite
	local door = ISWoodenDoor:new(sprite.sprite, sprite.northSprite, sprite.openSprite, sprite.openNorthSprite, ISBuildMenu.isNailsBoxNeededOpening(4));
	door.modData["xp:Woodwork"] = 3;
	door.modData["need:Base.Plank"] = "4";
	door.modData["need:Base.Nails"] = "4";
	door.modData["need:Base.Hinge"] = "2";
	door.modData["need:Base.Doorknob"] = "1";
	door.player = player
	getCell():setDrag(door, player);
end

ISBuildMenu.onOuthouseDoor = function(worldobjects, square, sprite, player)
	-- sprite, northsprite, openSprite, openNorthSprite
	local door = ISWoodenDoor:new("fixtures_bathroom_02_32", "fixtures_bathroom_02_33", "fixtures_bathroom_02_34", "fixtures_bathroom_02_35", ISBuildMenu.isNailsBoxNeededOpening(4));
	door.modData["xp:Woodwork"] = 3;
	door.modData["need:Base.Plank"] = "4";
	door.modData["need:Base.Nails"] = "4";
	door.modData["need:Base.Hinge"] = "2";
	door.modData["need:Base.Doorknob"] = "1";
	door.player = player
	getCell():setDrag(door, player);
end

ISBuildMenu.onWoodenGate = function(worldobjects, square, sprite, player)
	-- sprite, northsprite, openSprite, openNorthSprite
	local gate = ISWoodenDoor:new("fixtures_doors_fences_01_4", "fixtures_doors_fences_01_5", "fixtures_doors_fences_01_6", "fixtures_doors_fences_01_7", ISBuildMenu.isNailsBoxNeededOpening(4));
	gate.modData["xp:Woodwork"] = 3;
	gate.modData["need:Base.Plank"] = "4";
	gate.modData["need:Base.Nails"] = "4";
	gate.modData["need:Base.Hinge"] = "2";
	gate.modData["need:Base.Doorknob"] = "1";
	gate.dontNeedFrame = true;
	gate.canBarricade = false;
	gate.player = player
	getCell():setDrag(gate, player);
end

ISBuildMenu.onBigWoodenGate = function(worldobjects, square, sprite, player)
	-- sprite, northsprite, openSprite, openNorthSprite
	local gate = ISWoodenDoor:new("fixtures_doors_fences_01_12", "fixtures_doors_fences_01_13", "fixtures_doors_fences_01_14", "fixtures_doors_fences_01_15", ISBuildMenu.isNailsBoxNeededOpening(6));
	gate.modData["xp:Woodwork"] = 5;
	gate.modData["need:Base.Plank"] = "6";
	gate.modData["need:Base.Nails"] = "6";
	gate.modData["need:Base.Hinge"] = "2";
	gate.modData["need:Base.Doorknob"] = "1";
	gate.dontNeedFrame = true;
	gate.canBarricade = false;
	gate.player = player
	getCell():setDrag(gate, player);
end

ISBuildMenu.onFarmDoor = function(worldobjects, square, sprite, player)
	-- sprite, northsprite, openSprite, openNorthSprite
	getCell():setDrag(ISWoodenDoor:new("TileDoors_8", "TileDoors_9", "TileDoors_10", "TileDoors_11"), player);
end

-- **********************************************
-- **              *DOOR FRAME*                **
-- **********************************************

ISBuildMenu.buildDoorFrameMenu = function(subMenu, player)
	local frameSprite = ISBuildMenu.getWoodenDoorFrameSprites(player);
	local doorFrameOption = subMenu:addOption(getText("ContextMenu_Door_Frame"), worldobjects, ISBuildMenu.onWoodenDoorFrame, square, frameSprite, player);
	local toolTip = ISBuildMenu.canBuild(4,4,0,0,0,2,doorFrameOption, player);
	toolTip:setName(getText("ContextMenu_Door_Frame"));
	toolTip.description = getText("Tooltip_craft_doorFrameDesc") .. toolTip.description;
	toolTip:setTexture(frameSprite.sprite);
	ISBuildMenu.requireHammer(doorFrameOption)
end

ISBuildMenu.onWoodenDoorFrame = function(worldobjects, square, sprite, player)
	-- sprite, northSprite, corner
	local doorFrame = ISWoodenDoorFrame:new(sprite.sprite, sprite.northSprite, sprite.corner, ISBuildMenu.isNailsBoxNeededOpening(4))
	if getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) >= 8 then
		doorFrame.canBePlastered = true;
	end
	doorFrame.modData["xp:Woodwork"] = 5;
	doorFrame.modData["wallType"] = "doorframe";
	doorFrame.modData["need:Base.Plank"] = "4";
	doorFrame.modData["need:Base.Nails"] = "4";
	doorFrame.player = player
	doorFrame.name = "WoodenDoorFrameLvl" .. ISBuildMenu.getSpriteLvl(player);
	getCell():setDrag(doorFrame, player);
end

-- **********************************************
-- **            SPRITE FUNCTIONS              **
-- **********************************************

ISBuildMenu.getMattressSprite = function(player)
	local sprite = {};
	sprite.sprite1 = "carpentry_02_77";
	sprite.sprite2 = "carpentry_02_76";
	sprite.northSprite1 = "carpentry_02_78";
	sprite.northSprite2 = "carpentry_02_79";
	return sprite;
end

ISBuildMenu.getBedSprite = function(player)
	local sprite = {};
	sprite.sprite1 = "carpentry_02_73";
	sprite.sprite2 = "carpentry_02_72";
	sprite.northSprite1 = "carpentry_02_74";
	sprite.northSprite2 = "carpentry_02_75";
	return sprite;
end

ISBuildMenu.getLargeWoodTableSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite1 = "carpentry_01_25";
		sprite.sprite2 = "carpentry_01_24";
		sprite.northSprite1 = "carpentry_01_26";
		sprite.northSprite2 = "carpentry_01_27";
	elseif spriteLvl == 2 then
		sprite.sprite1 = "carpentry_01_29";
		sprite.sprite2 = "carpentry_01_28";
		sprite.northSprite1 = "carpentry_01_30";
		sprite.northSprite2 = "carpentry_01_31";
	elseif spriteLvl == 4 then
		sprite.sprite1 = "furniture_tables_high_01_1";
		sprite.sprite2 = "furniture_tables_high_01_0";
		sprite.northSprite1 = "furniture_tables_high_01_2";
		sprite.northSprite2 = "furniture_tables_high_01_3";
	else
		sprite.sprite1 = "carpentry_01_33";
		sprite.sprite2 = "carpentry_01_32";
		sprite.northSprite1 = "carpentry_01_34";
		sprite.northSprite2 = "carpentry_01_35";
	end
	return sprite;
end

ISBuildMenu.getTableWithDrawerSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_02_1";--0
		sprite.northSprite = "carpentry_02_0";--2
		sprite.southSprite = "carpentry_02_2";--1
		sprite.eastSprite = "carpentry_02_3";--3
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_02_5";
		sprite.northSprite = "carpentry_02_8";
		sprite.southSprite = "carpentry_02_6";
		sprite.eastSprite = "carpentry_02_7";
	elseif spriteLvl == 4 then
		sprite.sprite = "furniture_storage_01_53";
		sprite.northSprite = "furniture_storage_01_52";
		sprite.southSprite = "furniture_storage_01_55";
		sprite.eastSprite = "furniture_storage_01_54";
	else
		sprite.sprite = "carpentry_02_9";
		sprite.northSprite = "carpentry_02_8";
		sprite.southSprite = "carpentry_02_10";
		sprite.eastSprite = "carpentry_02_11";
	end
	return sprite;
end

ISBuildMenu.getWoodenFenceSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_02_40";
		sprite.northSprite = "carpentry_02_41";
		sprite.corner = "carpentry_02_43";
	elseif spriteLvl == 2 then
	sprite.sprite = "carpentry_02_44";
	sprite.northSprite = "carpentry_02_45";
	sprite.corner = "carpentry_02_47";
	--	elseif spriteLvl == 4 then
		--		sprite.sprite = "fencing_01_34";
		--		sprite.northSprite = "fencing_01_33";
		--		sprite.corner = "fencing_01_36";
	else
		sprite.sprite = "carpentry_02_48";
		sprite.northSprite = "carpentry_02_49";
		sprite.corner = "carpentry_02_51";
	end
	return sprite;
end

ISBuildMenu.getWoodenFloorSprites = function(player)
    local spriteLvl = ISBuildMenu.getSpriteLvl(player);
    local sprite = {};
    if spriteLvl == 1 then
        sprite.sprite = "carpentry_02_58";
        sprite.northSprite = "carpentry_02_58";
    elseif spriteLvl == 2 then
        sprite.sprite = "carpentry_02_57";
        sprite.northSprite = "carpentry_02_57";
    else
        sprite.sprite = "carpentry_02_56";
        sprite.northSprite = "carpentry_02_56";
    end
    if ISBuildMenu.cheat then
        sprite.sprite = "carpentry_02_56";
        sprite.northSprite = "carpentry_02_56";
    end
    return sprite;
end

ISBuildMenu.getWoodenCrateSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl <= 2 then
		sprite.sprite = "carpentry_01_19";
		sprite.northSprite = "carpentry_01_19";
	else
		sprite.sprite = "carpentry_01_16";
		sprite.northSprite = "carpentry_01_16";
	end
	return sprite;
end

ISBuildMenu.getWoodenCrateHalfSprites = function(player)
	local sprite = {};
	sprite.sprite = "location_shop_greenes_01_35";
	sprite.northSprite = "location_shop_greenes_01_35";
	return sprite;
end

ISBuildMenu.getWoodenChairSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_01_38";
		sprite.northSprite = "carpentry_01_36";
		sprite.southSprite = "carpentry_01_37";
		sprite.eastSprite = "carpentry_01_39";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_01_41";
		sprite.northSprite = "carpentry_01_40";
		sprite.southSprite = "carpentry_01_42";
		sprite.eastSprite = "carpentry_01_43";
	elseif spriteLvl == 4 then
		sprite.sprite = "furniture_seating_indoor_02_1";
		sprite.northSprite = "furniture_seating_indoor_02_0";
		sprite.southSprite = "furniture_seating_indoor_02_2";
		sprite.eastSprite = "furniture_seating_indoor_02_3";
	else
		sprite.sprite = "carpentry_01_45";
		sprite.northSprite = "carpentry_01_44";
		sprite.southSprite = "carpentry_01_46";
		sprite.eastSprite = "carpentry_01_47";
	end
	return sprite;
end

ISBuildMenu.getWoodenDoorSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_01_48";
		sprite.northSprite = "carpentry_01_49";
		sprite.openSprite = "carpentry_01_50";
		sprite.openNorthSprite = "carpentry_01_51";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_01_52";
		sprite.northSprite = "carpentry_01_53";
		sprite.openSprite = "carpentry_01_54";
		sprite.openNorthSprite = "carpentry_01_55";
	elseif spriteLvl == 4 then
		sprite.sprite = "fixtures_doors_01_28";
		sprite.northSprite = "fixtures_doors_01_29";
		sprite.openSprite = "fixtures_doors_01_30";
		sprite.openNorthSprite = "fixtures_doors_01_31";
	else
		sprite.sprite = "carpentry_01_56";
		sprite.northSprite = "carpentry_01_57";
		sprite.openSprite = "carpentry_01_58";
		sprite.openNorthSprite = "carpentry_01_59";
	end
	return sprite;
end

ISBuildMenu.getWoodenTableSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "carpentry_01_60";
	elseif spriteLvl == 2 then
		sprite.sprite = "carpentry_01_61";
	elseif spriteLvl == 4 then
		sprite.sprite = "furniture_tables_high_01_15";
	else
		sprite.sprite = "carpentry_01_62";
	end
	return sprite;
end

ISBuildMenu.getWoodenToiletSprites = function(player)
	local sprite = {};
	sprite.sprite = "fixtures_bathroom_02_24";
	sprite.northSprite = "fixtures_bathroom_02_25";
	sprite.southSprite = "fixtures_bathroom_02_27";
	sprite.eastSprite = "fixtures_bathroom_02_26";
	return sprite;
end

ISBuildMenu.getSmallBookcaseSprite = function(player)
	local sprite = {};
	sprite.sprite = "furniture_shelving_01_23";
	sprite.northSprite = "furniture_shelving_01_19";
	return sprite;
end

ISBuildMenu.getBookcaseSprite = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl <= 2 then
		sprite.northSprite = "carpentry_02_64";
		sprite.sprite = "carpentry_02_65";
		sprite.eastSprite = "carpentry_02_66";
		sprite.southSprite = "carpentry_02_67";
	else
		sprite.northSprite = "furniture_shelving_01_40";
		sprite.sprite = "furniture_shelving_01_41";
		sprite.eastSprite = "furniture_shelving_01_42";
		sprite.southSprite = "furniture_shelving_01_43";
	end
	return sprite;
end

ISBuildMenu.getSignSprite = function(player)
	local sprite = {};
	sprite.sprite = "constructedobjects_signs_01_27";
	sprite.northSprite = "constructedobjects_signs_01_11";
	return sprite;
end

ISBuildMenu.getDogHouseSprite = function(player)
	local sprite = {};
	sprite.sprite = "location_farm_accesories_01_8";
	sprite.northSprite = "location_farm_accesories_01_9";
	sprite.southSprite = "location_farm_accesories_01_11";
	sprite.eastSprite = "location_farm_accesories_01_10";
	return sprite;
end

ISBuildMenu.getDoubleShelveSprite = function(player)
	local sprite = {};
	sprite.sprite = "furniture_shelving_01_2";
	sprite.northSprite = "furniture_shelving_01_1";
	return sprite;
end

ISBuildMenu.getShelveSprite = function(player)
	local sprite = {};
	sprite.sprite = "carpentry_02_68";
	sprite.northSprite = "carpentry_02_69";
	return sprite;
end

ISBuildMenu.getStairsSprite = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 4 then
		sprite.sprite1 = "fixtures_stairs_01_72";
		sprite.sprite2 = "fixtures_stairs_01_73";
		sprite.sprite3 = "fixtures_stairs_01_74";
		sprite.sprite4 = "fixtures_stairs_01_70";
		sprite.northSprite1 = "fixtures_stairs_01_64";
		sprite.northSprite2 = "fixtures_stairs_01_65";
		sprite.northSprite3 = "fixtures_stairs_01_66";
		sprite.northSprite4 = "fixtures_stairs_01_71";
	else
		sprite.sprite1 = "carpentry_02_96";
		sprite.sprite2 = "carpentry_02_97";
		sprite.sprite3 = "carpentry_02_98";
		sprite.sprite4 = "carpentry_02_95";
		sprite.northSprite1 = "carpentry_02_88";
		sprite.northSprite2 = "carpentry_02_89";
		sprite.northSprite3 = "carpentry_02_90";
		sprite.northSprite4 = "carpentry_02_94";
	end
	return sprite;
end

ISBuildMenu.getPillarLampSprite = function(player)
	local sprite = {};
	sprite.sprite = "carpentry_02_61";
	sprite.northSprite = "carpentry_02_60";
	sprite.southSprite = "carpentry_02_59";
	sprite.eastSprite = "carpentry_02_62";
	return sprite;
end

ISBuildMenu.getWoodenWallFrameSprites = function(player)
	local sprite = {};
	sprite.sprite = "carpentry_02_100";
	sprite.northSprite = "carpentry_02_101";
	return sprite;
end

ISBuildMenu.getWoodenWallSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "walls_exterior_wooden_01_44";
		sprite.northSprite = "walls_exterior_wooden_01_45";
	elseif spriteLvl == 2 then
		sprite.sprite = "walls_exterior_wooden_01_40";
		sprite.northSprite = "walls_exterior_wooden_01_41";
	else
		sprite.sprite = "walls_exterior_wooden_01_24";
		sprite.northSprite = "walls_exterior_wooden_01_25";
	end
	if ISBuildMenu.cheat then
		sprite.sprite = "walls_exterior_wooden_01_24";
		sprite.northSprite = "walls_exterior_wooden_01_25";
	end
	sprite.corner = "walls_exterior_wooden_01_27";
	return sprite;
end

ISBuildMenu.getWoodenWindowsFrameSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "walls_exterior_wooden_01_52";
		sprite.northSprite = "walls_exterior_wooden_01_53";
	elseif spriteLvl == 2 then
		sprite.sprite = "walls_exterior_wooden_01_48";
		sprite.northSprite = "walls_exterior_wooden_01_49";
	else
		sprite.sprite = "walls_exterior_wooden_01_32";
		sprite.northSprite = "walls_exterior_wooden_01_33";
	end
	sprite.corner = "walls_exterior_wooden_01_27";
	return sprite;
end

ISBuildMenu.getWoodenDoorFrameSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.sprite = "walls_exterior_wooden_01_54";
		sprite.northSprite = "walls_exterior_wooden_01_55";
	elseif spriteLvl == 2 then
		sprite.sprite = "walls_exterior_wooden_01_50";
		sprite.northSprite = "walls_exterior_wooden_01_51";
	else
		sprite.sprite = "walls_exterior_wooden_01_34";
		sprite.northSprite = "walls_exterior_wooden_01_35";
	end
	sprite.corner = "walls_exterior_wooden_01_27";
	return sprite;
end

ISBuildMenu.getBarCornerSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.southSprite = "carpentry_02_32";
		sprite.sprite = "carpentry_02_34";
		sprite.northSprite = "carpentry_02_36";
		sprite.eastSprite = "carpentry_02_38";
	elseif spriteLvl == 2 then
		sprite.southSprite = "carpentry_02_24";
		sprite.sprite = "carpentry_02_26";
		sprite.northSprite = "carpentry_02_28";
		sprite.eastSprite = "carpentry_02_30";
	elseif spriteLvl == 4 then
		sprite.southSprite = "fixtures_counters_01_8";
		sprite.sprite = "fixtures_counters_01_10";
		sprite.northSprite = "fixtures_counters_01_12";
		sprite.eastSprite = "fixtures_counters_01_14";
	else
		sprite.southSprite = "carpentry_02_16";
		sprite.sprite = "carpentry_02_18";
		sprite.northSprite = "carpentry_02_20";
		sprite.eastSprite = "carpentry_02_22";
	end
	return sprite;
end

ISBuildMenu.getBarElementSprites = function(player)
	local spriteLvl = ISBuildMenu.getSpriteLvl(player);
	local sprite = {};
	if spriteLvl == 1 then
		sprite.southSprite = "carpentry_02_33";
		sprite.sprite = "carpentry_02_35";
		sprite.northSprite = "carpentry_02_37";
		sprite.eastSprite = "carpentry_02_39";
	elseif spriteLvl == 2 then
		sprite.southSprite = "carpentry_02_25";
		sprite.sprite = "carpentry_02_27";
		sprite.northSprite = "carpentry_02_29";
		sprite.eastSprite = "carpentry_02_31";
	elseif spriteLvl == 4 then
		sprite.southSprite = "fixtures_counters_01_9";
		sprite.sprite = "fixtures_counters_01_11";
		sprite.northSprite = "fixtures_counters_01_13";
		sprite.eastSprite = "fixtures_counters_01_15";
	else
		sprite.southSprite = "carpentry_02_17";
		sprite.sprite = "carpentry_02_19";
		sprite.northSprite = "carpentry_02_21";
		sprite.eastSprite = "carpentry_02_23";
	end
	return sprite;
end

ISBuildMenu.getBarCorner2Sprites = function(player)
	local sprite = {};
	sprite.southSprite = "location_restaurant_bar_01_58";
	sprite.sprite = "location_restaurant_bar_01_60";
	sprite.northSprite = "location_restaurant_bar_01_62";
	sprite.eastSprite = "location_restaurant_bar_01_56";
	return sprite;
end

ISBuildMenu.getBarElement2Sprites = function(player)
	local sprite = {};
	sprite.southSprite = "location_restaurant_bar_01_57";
	sprite.sprite = "location_restaurant_bar_01_59";
	sprite.northSprite = "location_restaurant_bar_01_61";
	sprite.eastSprite = "location_restaurant_bar_01_63";
	return sprite;
end

ISBuildMenu.getSpriteLvl = function(player)
	-- 0 to 1 wood work xp mean lvl 1 sprite
	if getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) <= 3 then
		return 1;
	-- 2 to 3 wood work xp mean lvl 2 sprite
	elseif getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) <= 6 then
		return 2;
	-- 4 to 5 wood work xp mean lvl 3 sprite
	else
		return 3;
	end
end

-- **********************************************
-- **                DISMANTLE                 **
-- **********************************************

ISBuildMenu.onDismantle = function(worldobjects, player)
	local bo = ISDestroyCursor:new(player, true)
	getCell():setDrag(bo, bo.player)
end

-- **********************************************
-- **                  OTHER                   **
-- **********************************************

-- Create our toolTip, depending on the required material
ISBuildMenu.canBuild = function(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, carpentrySkill, option, player)
    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()
	-- create a new tooltip
	local tooltip = ISBuildMenu.addToolTip();
	-- add it to our current option
	option.toolTip = tooltip;
	local inv = playerInv;
	local result = true;
	if ISBuildMenu.cheat then
		return tooltip;
	end
	tooltip.description = tooltip.description .. "<LINE> <LINE>" .. getText("Tooltip_craft_Needs") .. ": <LINE>";
	-- now we gonna test all the needed material, if we don't have it, they'll be in red into our toolip
--[[	if nailsNb > 0 then
		if (playerInv:containsWithModule("Base.HammerStone")) then
			hammer = "Base.HammerStone"
		else
			hammer = "Base.Hammer"
		end
		if playerInv:containsTypeRecurse("Base.Hammer") then
			tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.Hammer") .. " 0/1 <LINE>";
			result = false;
		else
			tooltip.description = tooltip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.HammerStone") .. " " .. ISBuildMenu.countMaterial(player, "Base.Hammer") + ISBuildMenu.countMaterial(player, "Base.HammerStone") .. "/1 <LINE>";
		end
	end
]]	if ISBuildMenu.planks < plankNb then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.Plank") .. " " .. ISBuildMenu.planks .. "/" .. plankNb .. " <LINE>";
		result = false;
	elseif plankNb > 0 then
		tooltip.description = tooltip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Plank") .. " " .. ISBuildMenu.planks .. "/"  .. plankNb .. " <LINE>";
	end
	if ISBuildMenu.nails < nailsNb then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.Nails") .. " " .. ISBuildMenu.nails .. "/" .. nailsNb .. " <LINE>";
		result = false;
	elseif nailsNb > 0 then
		tooltip.description = tooltip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Nails") .. " " .. ISBuildMenu.nails .. "/"  .. nailsNb .. " <LINE>";
	end
	if ISBuildMenu.doorknob < doorknobNb then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.Doorknob") .. " " .. ISBuildMenu.doorknob .. "/" .. doorknobNb .. " <LINE>";
		result = false;
	elseif doorknobNb > 0 then
		tooltip.description = tooltip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Doorknob") .. " " .. ISBuildMenu.doorknob .. "/"  .. doorknobNb .. " <LINE>";
	end
	if ISBuildMenu.hinge < hingeNb then
		tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. getItemNameFromFullType("Base.Hinge") .. " " .. ISBuildMenu.hinge .. "/" .. hingeNb .. " <LINE>";
		result = false;
	elseif hingeNb > 0 then
		tooltip.description = tooltip.description .. " <RGB:0,1,0>" .. getItemNameFromFullType("Base.Hinge") .. " " .. ISBuildMenu.hinge .. "/" .. hingeNb .. " <LINE>";
	end
	if getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) < carpentrySkill then
		tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0>" .. getText("IGUI_perks_Carpentry") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill .. " <LINE>";
		result = false;
	elseif carpentrySkill > 0 then
		tooltip.description = tooltip.description .. " <LINE> <RGB:0,1,0>" .. getText("IGUI_perks_Carpentry") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.Woodwork) .. "/" .. carpentrySkill .. " <LINE>";
	end
	if not result then
		option.onSelect = nil;
		option.notAvailable = true;
	end
	tooltip.description = " " .. tooltip.description .. " "
	return tooltip;
end

ISBuildMenu.addToolTip = function()
	local toolTip = ISToolTip:new();
	toolTip:initialise();
	toolTip:setVisible(false);
	toolTip.footNote = getText("Tooltip_craft_pressToRotate", Keyboard.getKeyName(getCore():getKey("Rotate building")))
	return toolTip;
end

ISBuildMenu.countMaterial = function(player, fullType)
    local inv = getSpecificPlayer(player):getInventory()
    local count = 0
    local items = inv:getItemsFromFullType(fullType, true)
    for i=1,items:size() do
        local item = items:get(i-1)
        if not instanceof(item, "InventoryContainer") or item:getInventory():getItems():isEmpty() then
            count = count + 1
        end
    end
    local type = string.split(fullType, "\\.")[2]
    for k,v in pairs(ISBuildMenu.materialOnGround) do
        if k == type then count = count + v end
    end
    return count
end

ISBuildMenu.requireHammer = function(option)
	if not ISBuildMenu.hasHammer and not ISBuildMenu.cheat then
		option.notAvailable = true
		option.onSelect = nil
	end
end

Events.OnFillWorldObjectContextMenu.Add(ISBuildMenu.doBuildMenu);