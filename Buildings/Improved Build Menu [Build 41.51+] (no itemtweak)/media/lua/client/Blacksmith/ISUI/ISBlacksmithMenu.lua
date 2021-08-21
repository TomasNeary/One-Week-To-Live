ISBlacksmithMenu = {};
ISBlacksmithMenu.canDoSomething = false

local function predicateDrainableUsesInt(item, count)
    return item:getDrainableUsesInt() >= count
end

function ISBlacksmithMenu.weldingRodUses(torchUses)
    return math.floor((torchUses + 0.1) / 2)
end

ISBlacksmithMenu.doBuildMenu = function(player, context, worldobjects, test)

    if test and ISWorldObjectContextMenu.Test then return true end

    if getCore():getGameMode()=="LastStand" then
        return;
    end

    if test then return ISWorldObjectContextMenu.setTest() end
    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()

    if playerObj:getVehicle() then return; end

    local itemMap = buildUtil.getMaterialOnGround(playerObj:getCurrentSquare())
    ISBlacksmithMenu.groundItems = itemMap
    ISBlacksmithMenu.groundItemCounts = buildUtil.getMaterialOnGroundCounts(itemMap)
    ISBlacksmithMenu.groundItemUses = buildUtil.getMaterialOnGroundUses(itemMap)


    local disableFurnaceAnvil = true;
    if not disableFurnaceAnvil then
        local buildOption = context:addOption(getText("ContextMenu_Blacksmith"), worldobjects, nil);
        local subMenu = ISContextMenu:getNew(context);
        context:addSubMenu(buildOption, subMenu);

        local furnaceOption = subMenu:addOption(getText("ContextMenu_Stone_Furnace"), worldobjects, ISBlacksmithMenu.onStoneFurnace, player);
        local toolTip = ISToolTip:new();
        toolTip:initialise();
        toolTip:setVisible(false);
        -- add it to our current option
        furnaceOption.toolTip = toolTip;
        toolTip:setName(getText("ContextMenu_Stone_Furnace"));
        toolTip.description = getText("Tooltip_craft_stoneFurnaceDesc") .. " <LINE> ";
        toolTip:setTexture("crafted_01_16");
        if playerInv:getItemCount("Base.Stone") < 1 then
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.Stone") .. " " .. playerInv:getItemCount("Base.Stone") .. "/50" ;
            furnaceOption.notAvailable = true;
        else
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,1,1> " .. getItemNameFromFullType("Base.Stone") .. " " .. playerInv:getItemCount("Base.Stone") .. "/50" ;
        end

        local anvilOption = subMenu:addOption(getText("ContextMenu_Anvil"), worldobjects, ISBlacksmithMenu.onAnvil, player);
        local toolTip = ISToolTip:new();
        toolTip:initialise();
        toolTip:setVisible(false);
        -- add it to our current option
        anvilOption.toolTip = toolTip;
        toolTip:setName(getText("ContextMenu_Anvil"));
        toolTip.description = getText("Tooltip_craft_anvilDesc") .. " <LINE> ";
        toolTip:setTexture("crafted_01_19");
        -- check if the player have enough metal to make the anvil
        local canBeCrafted = playerInv:contains("Hammer") and playerInv:contains("Log");
        if not playerInv:contains("Hammer") then
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.Hammer") .. " 0/1" ;
            anvilOption.notAvailable = true;
        else
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,1,1> " .. getItemNameFromFullType("Base.Hammer") .. " 1/1" ;
        end
        if not playerInv:contains("Log") then
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.Log") .. " 0/1" ;
            anvilOption.notAvailable = true;
        else
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,1,1> " .. getItemNameFromFullType("Base.Log") .. " 1/1" ;
        end
        local ingots = nil;
        local metalAmount = nil;
        if canBeCrafted then
            ingots, metalAmount = ISBlacksmithMenu.getMetal(playerObj, ISBlacksmithMenu.metalForAnvil);
            if not ingots then
                toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.IronIngot") .. " " .. (metalAmount/100) .. " / " .. (ISBlacksmithMenu.metalForAnvil/100);
                anvilOption.notAvailable = true;
            else
                toolTip.description = toolTip.description .. " <LINE> <RGB:1,1,1> " .. getItemNameFromFullType("Base.IronIngot") .. " " .. (metalAmount/100) .. " / " .. (ISBlacksmithMenu.metalForAnvil/100);
            end
        else
            anvilOption.notAvailable = true;
        end


        local drumOption = subMenu:addOption(getText("ContextMenu_Metal_Drum"), worldobjects, ISBlacksmithMenu.onMetalDrum, player, "crafted_01_24");
        local toolTip = ISToolTip:new();
        toolTip:initialise();
        toolTip:setVisible(false);
        -- add it to our current option
        drumOption.toolTip = toolTip;
        toolTip:setName(getText("ContextMenu_Metal_Drum"));
        toolTip.description = getText("Tooltip_craft_metalDrumDesc") .. " <LINE> ";
        toolTip:setTexture("crafted_01_24");
        if not playerInv:contains("MetalDrum") then
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.MetalDrum") .. " 0/1" ;
            drumOption.notAvailable = true;
        else
            toolTip.description = toolTip.description .. " <LINE> <RGB:1,1,1> " .. getItemNameFromFullType("Base.MetalDrum") .. " 1/1" ;
        end

        if anvilOption.notAvailable and furnaceOption.notAvailable and drumOption.notAvailable then
--        if drumOption.notAvailable then
            context:removeLastOption();
        end
    end

    local lighter = nil
    local matches = nil
    local petrol = nil
    local percedWood = nil
    local branch = nil
    local stick = nil
    local lightFireList = {}
    local lightFromPetrol = nil;
    local lightFromKindle = nil
    local lightFromLiterature = nil
    local lightDrumFromPetrol = nil;
    local lightDrumFromKindle = nil
    local lightDrumFromLiterature = nil
    local metalFence;
    local bellows;
    local coal = nil;
    local containers = ISInventoryPaneContextMenu.getContainers(playerObj)
    for i=1,containers:size() do
        local container = containers:get(i-1)
        for j=1,container:getItems():size() do
            local item = container:getItems():get(j-1)
            local type = item:getType()
            if type == "Lighter" then
                lighter = item
            elseif type == "Matches" then
                matches = item
            elseif type == "PetrolCan" then
                petrol = item
            elseif type == "PercedWood" then
                percedWood = item
            elseif type == "TreeBranch" then
                branch = item
            elseif type == "WoodenStick" then
                stick = item
            elseif type == "MetalFence" then
                metalFence = item
            elseif type == "Coal" or type == "Charcoal" then
                coal = item
            elseif type == "Bellows" then
                bellows = item
            end

            if campingLightFireType[type] then
                if campingLightFireType[type] > 0 then
                    table.insert(lightFireList, item)
                end
            elseif campingLightFireCategory[item:getCategory()] then
                table.insert(lightFireList, item)
            end
        end
    end

    local furnace;
    local metalDrumIsoObj = nil
    local metalDrumLuaObj = nil
    local sq;
    for i,v in ipairs(worldobjects) do
        sq = v:getSquare();
        if instanceof(v, "BSFurnace") then
            furnace = v;
        end
        if CMetalDrumSystem.instance:isValidIsoObject(v) then
            metalDrumIsoObj = v
            metalDrumLuaObj = CMetalDrumSystem.instance:getLuaObjectOnSquare(v:getSquare())
        end

        if (lighter or matches) and petrol and furnace and furnace:getFuelAmount() > 0 and not furnace:isFireStarted() then
            lightFromPetrol = furnace;
        end

        if (lighter or matches) and petrol and metalDrumLuaObj and metalDrumLuaObj.haveLogs and not metalDrumLuaObj.isLit and not metalDrumLuaObj.haveCharcoal then
            lightDrumFromPetrol = metalDrumLuaObj;
        end

        if percedWood and (stick or branch) and furnace and furnace:getFuelAmount() > 0 and not furnace:isFireStarted() and playerObj:getStats():getEndurance() > 0 then
            lightFromKindle = furnace
        end
        if percedWood and (stick or branch) and metalDrumLuaObj and metalDrumLuaObj.haveLogs and not metalDrumLuaObj.isLit and not metalDrumLuaObj.haveCharcoal and playerObj:getStats():getEndurance() > 0 then
            lightDrumFromKindle = metalDrumLuaObj
        end
        if (lighter or matches) and furnace ~= nil and furnace:getFuelAmount() > 0 and not furnace:isFireStarted() then
            lightFromLiterature = furnace
        end
        if (lighter or matches) and metalDrumLuaObj and metalDrumLuaObj.haveLogs and not metalDrumLuaObj.isLit and not metalDrumLuaObj.haveCharcoal then
            lightDrumFromLiterature = metalDrumLuaObj
        end
    end

    if lightFromPetrol or lightFromKindle or (lightFromLiterature and #lightFireList > 0) then
        if test then return ISWorldObjectContextMenu.setTest() end
        local lightOption = context:addOption("Lit Stone Furnace", worldobjects, nil);
        local subMenuLight = ISContextMenu:getNew(context);
        context:addSubMenu(lightOption, subMenuLight);
        if lightFromPetrol then
            if lighter then
                subMenuLight:addOption(petrol:getName()..' + '..lighter:getName(), worldobjects, ISBlacksmithMenu.onLightFromPetrol, player, lighter, petrol, lightFromPetrol)
            end
            if matches then
                subMenuLight:addOption(petrol:getName()..' + '..matches:getName(), worldobjects, ISBlacksmithMenu.onLightFromPetrol, player, matches, petrol, lightFromPetrol)
            end
        end
        for i,v in pairs(lightFireList) do
            local label = v:getName()
            if lighter then
                subMenuLight:addOption(label..' + '..lighter:getName(), worldobjects, ISBlacksmithMenu.onLightFromLiterature, player, v, lighter, lightFromLiterature, coal)
            end
            if matches then
                subMenuLight:addOption(label..' + '..matches:getName(), worldobjects, ISBlacksmithMenu.onLightFromLiterature, player, v, matches, lightFromLiterature, coal)
            end
        end
        if lightFromKindle then
            if stick then
                subMenuLight:addOption(percedWood:getName()..' + '..stick:getName(), worldobjects, ISBlacksmithMenu.onLightFromKindle, player, percedWood, stick, lightFromKindle);
            elseif branch then
                subMenuLight:addOption(percedWood:getName()..' + '..branch:getName(), worldobjects, ISBlacksmithMenu.onLightFromKindle, player, percedWood, branch, lightFromKindle);
            end
        end
    end

    if lightDrumFromPetrol or lightDrumFromKindle or (lightDrumFromLiterature and #lightFireList > 0) then
        if test then return ISWorldObjectContextMenu.setTest() end
        local lightOption = context:addOption(getText("ContextMenu_LitDrum"), worldobjects, nil);
        local subMenuLight = ISContextMenu:getNew(context);
        context:addSubMenu(lightOption, subMenuLight);
        if lightDrumFromPetrol then
            if lighter then
                local LitOption = subMenuLight:addOption(petrol:getName()..' + '..lighter:getName(), worldobjects, ISBlacksmithMenu.onLightDrumFromPetrol, player, lighter, petrol, lightDrumFromPetrol)
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip:setName(getText("ContextMenu_LitDrum"))
                tooltip.description = getText("Tooltip_Charcoal");
                LitOption.toolTip = tooltip
            end
            if matches then
                local LitOption = subMenuLight:addOption(petrol:getName()..' + '..matches:getName(), worldobjects, ISBlacksmithMenu.onLightDrumFromPetrol, player, matches, petrol, lightDrumFromPetrol)
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip:setName(getText("ContextMenu_LitDrum"))
                tooltip.description = getText("Tooltip_Charcoal");
                LitOption.toolTip = tooltip
            end
        end
        for i,v in pairs(lightFireList) do
            local label = v:getName()
            if lighter then
                local LitOption = subMenuLight:addOption(label..' + '..lighter:getName(), worldobjects, ISBlacksmithMenu.onLightDrumFromLiterature, player, v, lighter, lightDrumFromLiterature, coal)
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip:setName(getText("ContextMenu_LitDrum"))
                tooltip.description = getText("Tooltip_Charcoal");
                LitOption.toolTip = tooltip
            end
            if matches then
                local LitOption = subMenuLight:addOption(label..' + '..matches:getName(), worldobjects, ISBlacksmithMenu.onLightDrumFromLiterature, player, v, matches, lightDrumFromLiterature, coal)
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip:setName(getText("ContextMenu_LitDrum"))
                tooltip.description = getText("Tooltip_Charcoal");
                LitOption.toolTip = tooltip
            end
        end
        if lightDrumFromKindle then
            if stick then
                local LitOption = subMenuLight:addOption(percedWood:getName()..' + '..stick:getName(), worldobjects, ISBlacksmithMenu.onLightDrumFromKindle, player, percedWood, stick, lightDrumFromKindle);
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip:setName(getText("ContextMenu_LitDrum"))
                tooltip.description = getText("Tooltip_Charcoal");
                LitOption.toolTip = tooltip
            elseif branch then
                local LitOption = subMenuLight:addOption(percedWood:getName()..' + '..branch:getName(), worldobjects, ISBlacksmithMenu.onLightDrumFromKindle, player, percedWood, branch, lightDrumFromKindle);
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip:setName(getText("ContextMenu_LitDrum"))
                tooltip.description = getText("Tooltip_Charcoal");
                LitOption.toolTip = tooltip
            end
        end
    end

    if furnace then
        context:addOption("Furnace info", worldobjects, ISBlacksmithMenu.onInfo, furnace, playerObj);
       if coal and furnace:getFuelAmount() < 100 then
           context:addOption(getText("ContextMenu_Add_fuel_to_fire"), worldobjects, ISBlacksmithMenu.onAddFuel, furnace, coal, playerObj);
       end
       if furnace:isFireStarted() then
           if furnace:getHeat() < 100 and bellows then
               context:addOption(getText("ContextMenu_UseBellows"), worldobjects, ISBlacksmithMenu.onUseBellows, furnace, bellows, playerObj);
           end
           context:addOption("Stop fire", worldobjects, ISBlacksmithMenu.onStopFire, furnace);
       end
    end

    if metalDrumLuaObj and playerObj:DistToSquared(metalDrumIsoObj:getX() + 0.5, metalDrumIsoObj:getY() + 0.5) < 2 * 2 then
        local option = context:addOption(getText("ContextMenu_Metal_Drum"), worldobjects, nil)
        local subMenuDrum = ISContextMenu:getNew(context);
        context:addSubMenu(option, subMenuDrum);
        local tooltip = ISWorldObjectContextMenu.addToolTip()
        tooltip:setName(getText("ContextMenu_Metal_Drum"))
        if metalDrumIsoObj:getWaterAmount() > 0 then
            tooltip.description = getText("Water Percent ", round((metalDrumIsoObj:getWaterAmount() / metalDrumLuaObj.waterMax) * 100))
        elseif metalDrumLuaObj.haveLogs and metalDrumLuaObj.isLit then
            if not metalDrumLuaObj.charcoalTick then
                tooltip.description = "Charcoal Progression 0%";
            else
                tooltip.description = "Charcoal Progression " .. (round((metalDrumLuaObj.charcoalTick / 12) * 100)) .. "%";
            end
        end
        if metalDrumIsoObj:getWaterAmount() > 0 or (metalDrumLuaObj.haveLogs and metalDrumLuaObj.isLit) then
            option.toolTip = tooltip
        end
        if metalDrumIsoObj:getWaterAmount() > 0 then
            subMenuDrum:addOption("Empty", worldobjects, ISBlacksmithMenu.onEmptyDrum, metalDrumLuaObj, playerObj);
        else
            if not metalDrumLuaObj.haveLogs and not metalDrumLuaObj.haveCharcoal then
                subMenuDrum:addOption("Remove", worldobjects, ISBlacksmithMenu.onRemoveDrum, metalDrumLuaObj, playerObj);
                local addWoodOption = subMenuDrum:addOption("Add Logs", worldobjects, ISBlacksmithMenu.onAddLogs, metalDrumLuaObj, playerObj);
                local tooltip = ISWorldObjectContextMenu.addToolTip()
                tooltip:setName("Add Logs")
                tooltip.description = "Add 5 logs to do charcoal, once done, lit up the barrel with a lighter and wait";
                addWoodOption.toolTip = tooltip
                if playerInv:getItemCount("Base.Log") < 5 then
                   addWoodOption.notAvailable = true;
                end
            else
                if metalDrumLuaObj.isLit then
                    subMenuDrum:addOption(getText("ContextMenu_Put_out_fire"), worldobjects, ISBlacksmithMenu.onPutOutFireDrum, metalDrumLuaObj, playerObj);
                elseif not metalDrumLuaObj.isLit and not metalDrumLuaObj.haveCharcoal then
                    subMenuDrum:addOption("Remove", worldobjects, ISBlacksmithMenu.onRemoveDrum, metalDrumLuaObj, playerObj);
                    subMenuDrum:addOption("Remove Logs", worldobjects, ISBlacksmithMenu.onRemoveLogs, metalDrumLuaObj, playerObj);
                end
            end
            if metalDrumLuaObj.haveCharcoal then
                subMenuDrum:addOption(getText("ContextMenu_RemoveCharcoal"), worldobjects, ISBlacksmithMenu.onRemoveCharcoal, metalDrumLuaObj, playerObj);
            end
        end
    end
end

ISBlacksmithMenu.onRemoveCharcoal = function(worldobjects, metalDrum, player)
    if luautils.walkAdj(player, metalDrum:getSquare()) then
        ISTimedActionQueue.add(ISRemoveCharcoal:new(player, metalDrum))
    end
end

ISBlacksmithMenu.onPutOutFireDrum = function(worldobjects, metalDrum, player)
    if luautils.walkAdj(player, metalDrum:getSquare()) then
        ISTimedActionQueue.add(ISPutOutFireDrum:new(player, metalDrum))
    end
end

ISBlacksmithMenu.onRemoveLogs = function(worldobjects, metalDrum, player)
    if luautils.walkAdj(player, metalDrum:getSquare()) then
        ISTimedActionQueue.add(ISAddLogsInDrum:new(player, metalDrum, false))
    end
end

ISBlacksmithMenu.onAddLogs = function(worldobjects, metalDrum, player)
    if luautils.walkAdj(player, metalDrum:getSquare()) then
        ISTimedActionQueue.add(ISAddLogsInDrum:new(player, metalDrum, true))
    end
end

ISBlacksmithMenu.onRemoveDrum = function(worldobjects, metalDrum, player)
    if luautils.walkAdj(player, metalDrum:getSquare()) then
        ISTimedActionQueue.add(ISRemoveDrum:new(player, metalDrum))
    end
end

ISBlacksmithMenu.onEmptyDrum = function(worldobjects, metalDrum, playerObj)
    if luautils.walkAdj(playerObj, metalDrum:getSquare()) then
        ISTimedActionQueue.add(ISEmptyDrum:new(playerObj, metalDrum))
    end
end

ISBlacksmithMenu.addToolTip = function(option, name, texture)
    local toolTip = ISWorldObjectContextMenu.addToolTip();
    option.toolTip = toolTip;
    toolTip:setName(name);
    toolTip.description = getText("Tooltip_craft_Needs") .. ": ";
    toolTip:setTexture(texture);
    toolTip.footNote = getText("Tooltip_craft_pressToRotate", Keyboard.getKeyName(getCore():getKey("Rotate building")))
    return toolTip;
end

ISBlacksmithMenu.getMetal = function(player, amount)
    local totalMetal = 0;
    local ingots = {};
    local containers = ISInventoryPaneContextMenu.getContainers(player)
    for i=1,containers:size() do
        local container = containers:get(i-1)
        for j=1,container:getItems():size() do
            local item = container:getItems():get(j-1);
            if item:getType() == "IronIngot" then
                totalMetal = totalMetal + item:getUsedDelta() / item:getUseDelta();
                table.insert(ingots, item);
                if totalMetal >= amount then
                    return ingots, round(amount,0);
                end
            end
        end
    end
    return nil, round(totalMetal,0);
end

ISBlacksmithMenu.onInfo = function(worldobjects, furnace, player)
    if luautils.walkAdj(player, furnace:getSquare()) then
        ISTimedActionQueue.add(ISFurnaceInfoAction:new(player, furnace))
    end
end

ISBlacksmithMenu.onUseBellows = function(worldobjects, furnace, bellows, player)
    if luautils.walkAdj(player, furnace:getSquare()) then
        ISTimedActionQueue.add(ISUseBellows:new(furnace, bellows, player))
    end
end

ISBlacksmithMenu.onStopFire = function(worldobjects, furnace, player)
    if luautils.walkAdj(player, furnace:getSquare()) then
        ISTimedActionQueue.add(ISStopFurnaceFire:new(furnace, player))
    end
end

ISBlacksmithMenu.onAddFuel = function(worldobjects, furnace, coal, player)
    if luautils.walkAdj(player, furnace:getSquare()) then
        ISTimedActionQueue.add(ISAddCoalInFurnace:new(furnace, coal, player))
    end
end

ISBlacksmithMenu.onStoneFurnace = function(worldobjects, player)
    local furniture = ISBSFurnace:new("Stone Furnace", "crafted_01_42", "crafted_01_43");
--    furniture.modData["need:Base.Stone"] = "5";
    furniture.player = player
    getCell():setDrag(furniture, player);
end

ISBlacksmithMenu.onAnvil = function(worldobjects, player)
    local furniture = ISAnvil:new("Anvil", getSpecificPlayer(player), "crafted_01_19", "crafted_01_19");
    furniture.player = player
    getCell():setDrag(furniture, player);
end

ISBlacksmithMenu.onMetalDrum = function(worldobjects, player, sprite)
    local barrel = ISMetalDrum:new(player, sprite);
--    barrel.modData["need:Base.MetalDrum"] = "1";
    barrel.player = player
    getCell():setDrag(barrel, player);
end

ISBlacksmithMenu.onLightFromPetrol = function(worldobjects, player, lighter, petrol, furnace)
    local playerObj = getSpecificPlayer(player)
    ISCampingMenu.toPlayerInventory(playerObj, lighter)
    ISCampingMenu.toPlayerInventory(playerObj, petrol)
    if luautils.walkAdj(playerObj, furnace:getSquare(), true) then
        ISTimedActionQueue.add(ISFurnaceLightFromPetrol:new(playerObj, furnace, lighter, petrol, 20));
    end
end

ISBlacksmithMenu.onLightFromLiterature = function(worldobjects, player, literature, lighter, furnace, fuelAmt)
    local playerObj = getSpecificPlayer(player)
    ISCampingMenu.toPlayerInventory(playerObj, literature)
    ISCampingMenu.toPlayerInventory(playerObj, lighter)
    if luautils.walkAdj(playerObj, furnace:getSquare(), true) then
        if playerObj:isEquipped(literature) then
            ISTimedActionQueue.add(ISUnequipAction:new(playerObj, literature, 50));
        end
        ISTimedActionQueue.add(ISFurnaceLightFromLiterature:new(playerObj, literature, lighter, furnace, fuelAmt, 100));
    end
end

ISBlacksmithMenu.onLightFromKindle = function(worldobjects, player, percedWood, stickOrBranch, furnace)
    local playerObj = getSpecificPlayer(player)
    ISCampingMenu.toPlayerInventory(playerObj, percedWood)
    ISCampingMenu.toPlayerInventory(playerObj, stickOrBranch)
    if luautils.walkAdj(playerObj, furnace:getSquare(), true) then
        ISTimedActionQueue.add(ISFurnaceLightFromKindle:new(playerObj, percedWood, stickOrBranch, furnace, 1500));
    end
end

ISBlacksmithMenu.onLightDrumFromPetrol = function(worldobjects, player, lighter, petrol, metalDrum)
    local playerObj = getSpecificPlayer(player)
    ISCampingMenu.toPlayerInventory(playerObj, lighter)
    ISCampingMenu.toPlayerInventory(playerObj, petrol)
    if luautils.walkAdj(playerObj, metalDrum:getSquare(), true) then
        ISTimedActionQueue.add(ISDrumLightFromPetrol:new(playerObj, metalDrum, lighter, petrol, 20));
    end
end

ISBlacksmithMenu.onLightDrumFromLiterature = function(worldobjects, player, literature, lighter, metalDrum, fuelAmt)
    local playerObj = getSpecificPlayer(player)
    ISCampingMenu.toPlayerInventory(playerObj, literature)
    ISCampingMenu.toPlayerInventory(playerObj, lighter)
    if luautils.walkAdj(playerObj, metalDrum:getSquare(), true) then
        if playerObj:isEquipped(literature) then
            ISTimedActionQueue.add(ISUnequipAction:new(playerObj, literature, 50));
        end
        ISTimedActionQueue.add(ISDrumLightFromLiterature:new(playerObj, literature, lighter, metalDrum, fuelAmt, 100));
    end
end

ISBlacksmithMenu.onLightDrumFromKindle = function(worldobjects, player, percedWood, stickOrBranch, metalDrum)
    local playerObj = getSpecificPlayer(player)
    ISCampingMenu.toPlayerInventory(playerObj, percedWood)
    ISCampingMenu.toPlayerInventory(playerObj, stickOrBranch)
    if luautils.walkAdj(playerObj, metalDrum:getSquare(), true) then
        ISTimedActionQueue.add(ISDrumLightFromKindle:new(playerObj, percedWood, stickOrBranch, metalDrum, 1500));
    end
end

local function comparatorDrainableUsesInt(item1, item2)
    return item1:getDrainableUsesInt() - item2:getDrainableUsesInt()
end

function ISBlacksmithMenu.getBlowTorchWithMostUses(container)
    return container:getBestTypeEvalRecurse("Base.BlowTorch", comparatorDrainableUsesInt)
end

function ISBlacksmithMenu.getFirstBlowTorchWithUses(container, uses)
    return container:getFirstTypeEvalArgRecurse("Base.BlowTorch", predicateDrainableUsesInt, uses)
end

function ISBlacksmithMenu.getMaterialCount(playerObj, type)
    local playerInv = playerObj:getInventory()
    local count = playerInv:getCountTypeRecurse(type)
    if ISBlacksmithMenu.groundItemCounts[type] then
        count = count + ISBlacksmithMenu.groundItemCounts[type]
    end
    return count
end

function ISBlacksmithMenu.getMaterialUses(playerObj, type)
    local playerInv = playerObj:getInventory()
    local count = playerInv:getUsesTypeRecurse(type)
    if ISBlacksmithMenu.groundItemUses[type] then
        count = count + ISBlacksmithMenu.groundItemUses[type]
    end
    return count
end

Events.OnFillWorldObjectContextMenu.Add(ISBlacksmithMenu.doBuildMenu);
ISBlacksmithMenu.metalForAnvil = 500;
