ISMetalWeldingMenu = {};
ISMetalWeldingMenu.canDoSomething = false

local function predicateDrainableUsesInt(item, count)
    return item:getDrainableUsesInt() >= count
end

function ISMetalWeldingMenu.weldingRodUses(torchUses)
    return math.floor((torchUses + 0.1) / 2)
end

ISMetalWeldingMenu.doBuildMenu = function(player, context, worldobjects, test)

  if test and ISWorldObjectContextMenu.Test then return true end

  if getCore():getGameMode()=="LastStand" then
    return;
  end

    if test then return ISWorldObjectContextMenu.setTest() end
    local playerObj = getSpecificPlayer(player)
    local playerInv = playerObj:getInventory()

  if playerObj:getVehicle() then return; end

  local itemMap = buildUtil.getMaterialOnGround(playerObj:getCurrentSquare())
  ISMetalWeldingMenu.groundItems = itemMap
  ISMetalWeldingMenu.groundItemCounts = buildUtil.getMaterialOnGroundCounts(itemMap)
  ISMetalWeldingMenu.groundItemUses = buildUtil.getMaterialOnGroundUses(itemMap)

  -- *********************************************** --
  -- **************** METAL WELDING **************** --
  -- *********************************************** --

  -- show menu if we have a blowtorch and welding mask
    if (playerInv:containsTypeRecurse("BlowTorch") and playerInv:containsTypeRecurse("WeldingMask")) or ISBuildMenu.cheat then

      local buildMWOption = context:addOption(getText("ContextMenu_MetalWelding"), worldobjects, nil);
      local subMenuMW = ISContextMenu:getNew(context);
      context:addSubMenu(buildMWOption, subMenuMW);
      local keepMenu = false;

      -- **************** CONTEXT MENUS **************** --
      -- Wall
      local wallOption = subMenuMW:addOption(getText("ContextMenu_Wall"), worldobjects, nil);
      local subMenuWall = subMenuMW:getNew(subMenuMW);
      context:addSubMenu(wallOption, subMenuWall);
      if not ISBuildMenu.cheat and not playerObj:getKnownRecipes():contains("Make Metal Walls") then
        subMenuMW:removeLastOption();
      end
      -- Fence
      local fenceOption = subMenuMW:addOption(getText("ContextMenu_Fence"), worldobjects, nil);
      local subMenuFence = subMenuMW:getNew(subMenuMW);
      context:addSubMenu(fenceOption, subMenuFence);
      if not ISBuildMenu.cheat and not playerObj:getKnownRecipes():contains("Make Metal Fences") then
        subMenuMW:removeLastOption();
      end
      -- Door/Gate
      local doorOption = subMenuMW:addOption(getText("ContextMenu_DoorGate"), worldobjects, nil);
      local subMenuDoor = subMenuMW:getNew(subMenuMW);
      context:addSubMenu(doorOption, subMenuDoor);
      if not ISBuildMenu.cheat and not (playerObj:getKnownRecipes():contains("Make Metal Walls") or  playerObj:getKnownRecipes():contains("Make Metal Fences")) then
        subMenuMW:removeLastOption();
      end
      -- Stairs
      local stairsOption = subMenuMW:addOption(getText("ContextMenu_Stairs"), worldobjects, nil);
      local subMenuStairs = subMenuMW:getNew(subMenuMW);
      context:addSubMenu(stairsOption, subMenuStairs);
      if not ISBuildMenu.cheat and not playerObj:getKnownRecipes():contains("Make Metal Roof") then
        subMenuMW:removeLastOption();
      end
      -- Floor
      local floorOption = subMenuMW:addOption(getText("ContextMenu_Floor"), worldobjects, nil);
      local subMenuFloor = subMenuMW:getNew(subMenuMW);
      context:addSubMenu(floorOption, subMenuFloor);
      if not ISBuildMenu.cheat and not playerObj:getKnownRecipes():contains("Make Metal Roof") then
        subMenuMW:removeLastOption();
      end
      -- Furniture
      local furnitureOption = subMenuMW:addOption(getText("ContextMenu_Furniture"), worldobjects, nil);
      local subMenuFurniture = subMenuMW:getNew(subMenuMW);
      context:addSubMenu(furnitureOption, subMenuFurniture);
      if not ISBuildMenu.cheat and not playerObj:getKnownRecipes():contains("Make Metal Containers") then
        subMenuMW:removeLastOption();
      end
      -- Light sources
      --local lightOption = subMenuMW:addOption(getText("ContextMenu_Light_Source"), worldobjects, nil);
      --local subMenuLight = subMenuMW:getNew(subMenuMW);
      --context:addSubMenu(lightOption, subMenuLight);
      --if not ISBuildMenu.cheat and not playerObj:getKnownRecipes():contains("Make Metal Containers") then
      --  subMenuMW:removeLastOption();
      --endend

    -- **************** Wall **************** --
    if playerObj:getKnownRecipes():contains("Make Metal Walls") or ISBuildMenu.cheat then
      keepMenu = true;
      local frame = subMenuWall:addOption(getText("ContextMenu_MetalWallFrame"), worldobjects, ISMetalWeldingMenu.onMetalWallFrame, player,"8");
      local toolTip = ISMetalWeldingMenu.addToolTip(frame, getText("ContextMenu_MetalWallFrame"), "constructedobjects_01_68");
      toolTip.description = getText("Tooltip_craft_metalWallFrameDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(0,0,0,0,0,8,3,playerObj,toolTip, 3);
      if not canDo then frame.notAvailable = true; end

      local doorFrameSprite = ISMetalWeldingMenu.getMetalDoorFrameSprites(player);
      local doorFrameOption = subMenuWall:addOption(getText("ContextMenu_MetalDoorFrame"), worldobjects, ISMetalWeldingMenu.onMetalDoorFrame, doorFrameSprite, player,"8");
      local toolTip = ISMetalWeldingMenu.addToolTip(doorFrameOption, getText("ContextMenu_MetalDoorFrame"), doorFrameSprite.sprite);
      toolTip.description = getText("Tooltip_craft_metalDoorFrameDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(0,0,3,0,0,10,3,playerObj,toolTip, 3);
      if not canDo then doorFrameOption.notAvailable = true; end

      local cornerOption = subMenuWall:addOption(getText("ContextMenu_MetalWallCorner"), worldobjects, ISMetalWeldingMenu.onMetalWallCorner, player,"4");
      local toolTip = ISMetalWeldingMenu.addToolTip(cornerOption, getText("ContextMenu_MetalWallCorner"), "constructedobjects_01_67");
      toolTip.description = getText("Tooltip_craft_metalWallCornerDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(0,0,0,0,0,4,3,playerObj,toolTip, 2);
      if not canDo then cornerOption.notAvailable = true; end

      local wallJailOption = subMenuWall:addOption(getText("ContextMenu_MetalJailWall"), worldobjects, ISMetalWeldingMenu.onMetalJailWall, player,"8");
      local toolTip = ISMetalWeldingMenu.addToolTip(wallJailOption, getText("ContextMenu_MetalJailWall"), "location_community_police_01_0");
      toolTip.description = getText("Tooltip_craft_metalJailWallDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(8,0,0,0,5,16,8,playerObj,toolTip, 3);
      if not canDo then wallJailOption.notAvailable = true; end

      --            local windowJailOption = subMenuWall:addOption(getText("ContextMenu_MetalJailWindow"), worldobjects, ISMetalWeldingMenu.onMetalJailWindow, player,"8");
      --            local toolTip = ISMetalWeldingMenu.addToolTip(windowJailOption, getText("ContextMenu_MetalJailWindow"), "location_community_police_01_40");
      --            toolTip.description = getText("Tooltip_craft_metalJailWindowDesc") .. toolTip.description;
      --            local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(8,0,0,0,5,10,8,playerObj,toolTip, 3);
      --            if not canDo then windowJailOption.notAvailable = true; end

      local doorFrameJailOption = subMenuWall:addOption(getText("ContextMenu_MetalJailDoorFrame"), worldobjects, ISMetalWeldingMenu.onMetalJailDoorFrame, player,"8");
      local toolTip = ISMetalWeldingMenu.addToolTip(doorFrameJailOption, getText("ContextMenu_MetalJailDoorFrame"), "location_community_police_01_10");
      toolTip.description = getText("Tooltip_craft_metalJailDoorFrameDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(5,0,0,0,3,12,8,playerObj,toolTip, 3);
      if not canDo then doorFrameJailOption.notAvailable = true; end

      local jailCornerOption = subMenuWall:addOption(getText("ContextMenu_JailWallCorner"), worldobjects, ISMetalWeldingMenu.onJailWallCorner, player,"2");
      local toolTip = ISMetalWeldingMenu.addToolTip(jailCornerOption, getText("ContextMenu_JailWallCorner"), "location_community_police_01_3");
      toolTip.description = getText("Tooltip_craft_metalJailWallCornerDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(0,0,0,0,0,2,8,playerObj,toolTip, 1);
      if not canDo then jailCornerOption.notAvailable = true; end

      if frame.notAvailable and doorFrameOption.notAvailable and wallJailOption.notAvailable and doorFrameJailOption.notAvailable and cornerOption.notAvailable and jailCornerOption.notAvailable then
        wallOption.notAvailable = true;
      end
    end

    -- **************** Fences **************** --
    if playerObj:getKnownRecipes():contains("Make Metal Fences") or ISBuildMenu.cheat then
      keepMenu = true;
      -- **************** Low **************** --
      local fenceSprite = ISMetalWeldingMenu.getFenceSprite(playerObj);
      local fenceMetalOption = subMenuFence:addOption(getText("ContextMenu_MetalFence"), worldobjects, ISMetalWeldingMenu.onMetalFence, player,"5",fenceSprite);
      local toolTip = ISMetalWeldingMenu.addToolTip(fenceMetalOption, getText("ContextMenu_MetalFence"), fenceSprite.sprite);
      toolTip.description = getText("Tooltip_craft_metalFenceDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(1,2,0,0,3,5,3,playerObj,toolTip);
      if not canDo then fenceMetalOption.notAvailable = true; end

      local fencePoleOption = subMenuFence:addOption(getText("ContextMenu_MetalPoleFence"), worldobjects, ISMetalWeldingMenu.onMetalPoleFence, player,"4");
      local toolTip = ISMetalWeldingMenu.addToolTip(fencePoleOption, getText("ContextMenu_MetalPoleFence"), "constructedobjects_01_62");
      toolTip.description = getText("Tooltip_craft_metalPoleFenceDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(3,0,0,0,0,4,3,playerObj,toolTip);
      if not canDo then fencePoleOption.notAvailable = true; end

      local wiredFenceOption = subMenuFence:addOption(getText("ContextMenu_WiredFence"), worldobjects, ISMetalWeldingMenu.onWiredFence, player,"4");
      local toolTip = ISMetalWeldingMenu.addToolTip(wiredFenceOption, getText("ContextMenu_WiredFence"), "fencing_01_26");
      toolTip.description = getText("Tooltip_craft_metalWiredFenceDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(2,0,0,0,1,4,0,playerObj,toolTip);
      local metalWeldingSkill = 4;
      local canDo2, toolTip = ISMetalWeldingMenu.checkWire(1,playerObj,toolTip);
      if getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) < metalWeldingSkill and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_MetalWelding") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) .. "/" .. metalWeldingSkill;
        wiredFenceOption.notAvailable = true;
      elseif metalWeldingSkill > 0 and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_MetalWelding") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) .. "/" .. metalWeldingSkill;
      end
      if not canDo or not canDo2 then wiredFenceOption.notAvailable = true; end

      local wiredPostOption = subMenuFence:addOption(getText("ContextMenu_WiredFencePost"), worldobjects, ISMetalWeldingMenu.onWiredFencePost, player,"2");
      local toolTip = ISMetalWeldingMenu.addToolTip(wiredPostOption, getText("ContextMenu_WiredFencePost"), "fencing_01_29");
      toolTip.description = getText("Tooltip_craft_fencePostDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(1,0,0,0,0,2,4,playerObj,toolTip);
      if not canDo then wiredPostOption.notAvailable = true; end

      -- **************** High **************** --
      local bigFenceOption = subMenuFence:addOption(getText("ContextMenu_BigMetalFence"), worldobjects, ISMetalWeldingMenu.onBigMetalFence, player,"8");
      local toolTip = ISMetalWeldingMenu.addToolTip(bigFenceOption, getText("ContextMenu_BigMetalFence"), "constructedobjects_01_78");
      toolTip.description = getText("Tooltip_craft_bigMetalFenceDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(5,0,0,0,2,8,6,playerObj,toolTip);
      if not canDo then bigFenceOption.notAvailable = true; end

      local bigWiredFenceOption = subMenuFence:addOption(getText("ContextMenu_BigWiredFence"), worldobjects, ISMetalWeldingMenu.onBigWiredFence, player,"6");
      local toolTip = ISMetalWeldingMenu.addToolTip(bigWiredFenceOption, getText("ContextMenu_BigWiredFence"), "fencing_01_58");
      toolTip.description = getText("Tooltip_craft_bigWiredFenceDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(3,0,0,0,4,7,0,playerObj,toolTip);
      local metalWeldingSkill = 7;
      local canDo2, toolTip = ISMetalWeldingMenu.checkWire(3,playerObj,toolTip);
      if getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) < metalWeldingSkill and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_MetalWelding") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) .. "/" .. metalWeldingSkill;
        bigWiredFenceOption.notAvailable = true;
      elseif metalWeldingSkill > 0 and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_MetalWelding") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) .. "/" .. metalWeldingSkill;
      end
      if not canDo or not canDo2 then bigWiredFenceOption.notAvailable = true; end

      local bigWiredPostOption = subMenuFence:addOption(getText("ContextMenu_BigWiredFencePost"), worldobjects, ISMetalWeldingMenu.onBigWiredFencePost, player,"4");
      local toolTip = ISMetalWeldingMenu.addToolTip(bigWiredPostOption, getText("ContextMenu_BigWiredFencePost"), "fencing_01_61");
      toolTip.description = getText("Tooltip_craft_bigFencePostDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(2,0,0,0,0,4,7,playerObj,toolTip);
      if not canDo then bigWiredPostOption.notAvailable = true; end

      if fenceMetalOption.notAvailable and fencePoleOption.notAvailable and wiredFenceOption.notAvailable and bigWiredFenceOption.notAvailable and bigFenceOption.notAvailable and bigWiredPostOption.notAvailable and wiredPostOption.notAvailable then
        fenceOption.notAvailable = true;
      end
    end


    -- **************** Doors **************** --
    if playerObj:getKnownRecipes():contains("Make Metal Walls") or ISBuildMenu.cheat then
      local metalDoorOption = subMenuDoor:addOption(getText("ContextMenu_MetalDoor"), worldobjects, ISMetalWeldingMenu.onMetalDoor, player,"8");
      local toolTip = ISMetalWeldingMenu.addToolTip(metalDoorOption, getText("ContextMenu_MetalDoor"), "fixtures_doors_01_52");
      toolTip.description = getText("Tooltip_craft_metalDoorDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(0,0,4,2,2,8,0,playerObj,toolTip, 2);
      local metalWeldingSkill = 5
      local canDo2, toolTip = ISMetalWeldingMenu.checkDoorknob(playerObj,toolTip);
      if getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) < metalWeldingSkill and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_MetalWelding") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) .. "/" .. metalWeldingSkill;
        metalDoorOption.notAvailable = true;
      elseif metalWeldingSkill > 0 and not ISBuildMenu.cheat then
          toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_MetalWelding") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) .. "/" .. metalWeldingSkill;
      end
      if not canDo or not canDo2 then metalDoorOption.notAvailable = true; end

      local metalJailDoorOption = subMenuDoor:addOption(getText("ContextMenu_MetalJailDoor"), worldobjects, ISMetalWeldingMenu.onMetalJailDoor, player,"8");
      local toolTip = ISMetalWeldingMenu.addToolTip(metalJailDoorOption, getText("ContextMenu_MetalJailDoor"), "location_community_police_01_4");
      toolTip.description = getText("Tooltip_craft_metalJailDoorDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(5,0,0,2,3,10,0,playerObj,toolTip);
      local metalWeldingSkill = 8
      local canDo2, toolTip = ISMetalWeldingMenu.checkDoorknob(playerObj,toolTip);
      if getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) < metalWeldingSkill and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_MetalWelding") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) .. "/" .. metalWeldingSkill;
        metalJailDoorOption.notAvailable = true;
      elseif metalWeldingSkill > 0 and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_MetalWelding") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) .. "/" .. metalWeldingSkill;
      end
      if not canDo or not canDo2 then metalJailDoorOption.notAvailable = true; end
      if metalDoorOption.notAvailable and metalJailDoorOption.notAvailable then
        doorOption.notAvailable = true;
      end
    end
    -- **************** Gates **************** --
    if playerObj:getKnownRecipes():contains("Make Metal Fences") or ISBuildMenu.cheat then
      local fenceGateOption = subMenuDoor:addOption(getText("ContextMenu_MetalFenceGate"), worldobjects, ISMetalWeldingMenu.onFenceGate, player,"7");
      local toolTip = ISMetalWeldingMenu.addToolTip(fenceGateOption, getText("ContextMenu_MetalFenceGate"), "fixtures_doors_fences_01_28");
      toolTip.description = getText("Tooltip_craft_metalFenceGateDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(3,0,0,2,2,7,4,playerObj,toolTip);
      if not canDo then fenceGateOption.notAvailable = true; end

      local wiredGateOption = subMenuDoor:addOption(getText("ContextMenu_WiredGate"), worldobjects, ISMetalWeldingMenu.onWiredGate, player,"7");
      local toolTip = ISMetalWeldingMenu.addToolTip(wiredGateOption, getText("ContextMenu_WiredGate"), "fixtures_doors_fences_01_16");
      toolTip.description = getText("Tooltip_craft_metalWiredGateDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(2,0,0,2,1,4,0,playerObj,toolTip);
      local metalWeldingSkill = 4;
      local canDo2, toolTip = ISMetalWeldingMenu.checkWire(1,playerObj,toolTip);
      if getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) < metalWeldingSkill and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_MetalWelding") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) .. "/" .. metalWeldingSkill;
        wiredGateOption.notAvailable = true;
      elseif metalWeldingSkill > 0 and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_MetalWelding") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) .. "/" .. metalWeldingSkill;
      end
      if not canDo or not canDo2 then wiredGateOption.notAvailable = true; end

      local bigFenceGateOption = subMenuDoor:addOption(getText("ContextMenu_BigMetalFenceGate"), worldobjects, ISMetalWeldingMenu.onBigMetalFenceGate, player,"8");
      local toolTip = ISMetalWeldingMenu.addToolTip(bigFenceGateOption, getText("ContextMenu_BigMetalFenceGate"), "fixtures_doors_fences_01_24");
      toolTip.description = getText("Tooltip_craft_bigMetalFenceDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(5,0,0,2,4,8,7,playerObj,toolTip);
      if not canDo then bigFenceGateOption.notAvailable = true; end

      local doubleDoor2Option = subMenuDoor:addOption(getText("ContextMenu_BigMetalDoubleDoor"), worldobjects, ISMetalWeldingMenu.onDoublePoleDoor, player,"8");
      local toolTip = ISMetalWeldingMenu.addToolTip(doubleDoor2Option, getText("ContextMenu_BigMetalDoubleDoor"), "fixtures_doors_fences_01_80");
      toolTip.description = getText("Tooltip_craft_bigMetalDoubleDoorDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(10,0,0,2,4,10,8,playerObj,toolTip);
      if not canDo then doubleDoor2Option.notAvailable = true; end

      local doubleDoorOption = subMenuDoor:addOption(getText("ContextMenu_Double_Metal_Door"), worldobjects, ISMetalWeldingMenu.onDoubleMetalDoor, player,"8");
      local toolTip = ISMetalWeldingMenu.addToolTip(doubleDoorOption, getText("ContextMenu_Double_Metal_Door"), "fixtures_doors_fences_01_64");
      toolTip.description = getText("Tooltip_craft_doubleMetalDoorDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(8,0,0,2,2,10,0,playerObj,toolTip);
      local metalWeldingSkill = 8;
      local canDo2, toolTip = ISMetalWeldingMenu.checkWire(4,playerObj,toolTip);
      if getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) < metalWeldingSkill and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <RGB:1,0,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_MetalWelding") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) .. "/" .. metalWeldingSkill;
        doubleDoorOption.notAvailable = true;
      elseif metalWeldingSkill > 0 and not ISBuildMenu.cheat then
        toolTip.description = toolTip.description .. " <RGB:0,1,0>" .. " <LINE> <LINE>" .. getText("IGUI_perks_MetalWelding") .. " " .. getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) .. "/" .. metalWeldingSkill;
      end
      if not canDo or not canDo2 then doubleDoor2Option.notAvailable = true; end
      if fenceGateOption.notAvailable and bigFenceGateOption.notAvailable and doubleDoorOption.notAvailable and doubleDoor2Option.notAvailable and wiredGateOption.notAvailable then
        doorOption.notAvailable = true;
      end
    end

    -- **************** STAIRS **************** --
    if playerObj:getKnownRecipes():contains("Make Metal Roof") or ISBuildMenu.cheat then
      local stairsSprite = ISMetalWeldingMenu.getStairsSprite(player);
      local metalStairsOption = subMenuStairs:addOption(getText("ContextMenu_MetalStairs"), worldobjects, ISMetalWeldingMenu.onMetalStairs, player,"20");
      local toolTip = ISMetalWeldingMenu.addToolTip(metalStairsOption, getText("ContextMenu_MetalStairs"), stairsSprite.sprite1);
      toolTip.description = getText("Tooltip_craft_stairsDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(0,15,3,0,0,20,6,playerObj,toolTip, 10);
      if not canDo then metalStairsOption.notAvailable = true; end

      if metalStairsOption.notAvailable then
        stairsOption.notAvailable = true;
      end
    end

    -- **************** ROOF/FLOOR **************** --
    if playerObj:getKnownRecipes():contains("Make Metal Roof") or ISBuildMenu.cheat then
      local metalFloorOption = subMenuFloor:addOption(getText("ContextMenu_MetalFloor"), worldobjects, ISMetalWeldingMenu.onMetalFloor, player,"2");
      local toolTip = ISMetalWeldingMenu.addToolTip(metalFloorOption, getText("ContextMenu_MetalFloor"), "industry_01_7");
      toolTip.description = getText("Tooltip_craft_metalFloorDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(0,1,0,0,1,0,1,playerObj,toolTip);
      if not canDo then metalFloorOption.notAvailable = true; end

      local metalRoofOption = subMenuFloor:addOption(getText("ContextMenu_MetalRoof"), worldobjects, ISMetalWeldingMenu.onMetalRoof, player,"2");
      local toolTip = ISMetalWeldingMenu.addToolTip(metalRoofOption, getText("ContextMenu_MetalRoof"), "constructedobjects_01_86");
      toolTip.description = getText("Tooltip_craft_metalRoofDesc") .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(0,1,0,0,1,0,1,playerObj,toolTip);
      if not canDo then metalRoofOption.notAvailable = true; end

      if metalRoofOption.notAvailable and metalFloorOption.notAvailable then
        floorOption.notAvailable = true;
      end
    end

    -- **************** FURNITURE **************** --
    if playerObj:getKnownRecipes():contains("Make Metal Containers") or ISBuildMenu.cheat then
      keepMenu = true;

      local shelvesOption = subMenuFurniture:addOption(getText("ContextMenu_MetalShelves"), worldobjects, ISMetalWeldingMenu.onMetalShelves, player,"7");
      local toolTip = ISMetalWeldingMenu.addToolTip(shelvesOption, getText("ContextMenu_MetalShelves"), "furniture_shelving_01_29");
      toolTip.description = getText("Tooltip_craft_metalShelvesDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "30" .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(2,1,0,0,1,7,2,playerObj,toolTip);
      if not canDo then shelvesOption.notAvailable = true; end

      local crateOption = subMenuFurniture:addOption(getText("ContextMenu_MetalCrate"), worldobjects, ISMetalWeldingMenu.onMetalCrate, player,"7");
      local toolTip = ISMetalWeldingMenu.addToolTip(crateOption, getText("ContextMenu_MetalCrate"), "constructedobjects_01_47");
      toolTip.description = getText("Tooltip_craft_metalCrateDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "80" .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(2,2,2,0,1,7,4,playerObj,toolTip);
      if not canDo then crateOption.notAvailable = true; end

      local metalCounterOption = subMenuFurniture:addOption(getText("ContextMenu_MetalCounter"), worldobjects, ISMetalWeldingMenu.onMetalCounter, player,"12");
      local toolTip = ISMetalWeldingMenu.addToolTip(metalCounterOption, getText("ContextMenu_MetalCounter"), "fixtures_counters_01_35");
      toolTip.description = getText("Tooltip_craft_metalCounterDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "50" .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(2,4,0,2,0,12,5,playerObj,toolTip);
      if not canDo then metalCounterOption.notAvailable = true; end

      local metalCounterCornerOption = subMenuFurniture:addOption(getText("ContextMenu_MetalCounterCorner"), worldobjects, ISMetalWeldingMenu.onMetalCounterCorner, player,"12");
      local toolTip = ISMetalWeldingMenu.addToolTip(metalCounterCornerOption, getText("ContextMenu_MetalCounterCorner"), "fixtures_counters_01_34");
      toolTip.description = getText("Tooltip_craft_metalCounterCornerDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "50" .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(2,4,0,2,0,12,5,playerObj,toolTip);
      if not canDo then metalCounterCornerOption.notAvailable = true; end

      local metalChairOption = subMenuFurniture:addOption(getText("ContextMenu_MetalChair"), worldobjects, ISMetalWeldingMenu.onMetalChair, player,"8");
      local toolTip = ISMetalWeldingMenu.addToolTip(metalChairOption, getText("ContextMenu_MetalChair"), "furniture_seating_indoor_01_53");
      toolTip.description = getText("Tooltip_craft_metalChairDesc") .. " <LINE> " .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(0, 2, 0, 0, 0, 8, 6, playerObj, toolTip, 4);
      if not canDo then metalChairOption.notAvailable = true; end

      local smallLockerOption = subMenuFurniture:addOption(getText("ContextMenu_SmallLocker"), worldobjects, ISMetalWeldingMenu.onSmallLocker, player,"12");
      local toolTip = ISMetalWeldingMenu.addToolTip(smallLockerOption, getText("ContextMenu_SmallLocker"), "furniture_storage_02_9");
      toolTip.description = getText("Tooltip_craft_smallLockerDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "40" .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(3,4,0,2,0,12,6,playerObj,toolTip);
      if not canDo then smallLockerOption.notAvailable = true; end

      local bigLockerOption = subMenuFurniture:addOption(getText("ContextMenu_BigLocker"), worldobjects, ISMetalWeldingMenu.onBigLocker, player,"15");
      local toolTip = ISMetalWeldingMenu.addToolTip(bigLockerOption, getText("ContextMenu_BigLocker"), "furniture_storage_02_1");
      toolTip.description = getText("Tooltip_craft_bigLockerDesc") .. " <LINE> " .. getText("Tooltip_container_Capacity") .. ": " .. "50" .. toolTip.description;
      local canDo, toolTip = ISMetalWeldingMenu.checkMetalWeldingFurnitures(8,4,0,2,0,15,9,playerObj,toolTip);
      if not canDo then bigLockerOption.notAvailable = true; end
      if shelvesOption.notAvailable and crateOption.notAvailable and metalCounterOption.notAvailable and metalCounterCornerOption.notAvailable and smallLockerOption.notAvailable and bigLockerOption.notAvailable and metalChairOption.notAvailable then
        furnitureOption.notAvailable = true;
      end
    end
    if not keepMenu then
        context:removeLastOption()
    end
  end
end

ISMetalWeldingMenu.checkWire = function(wireUses, player, toolTip)
  if ISBuildMenu.cheat or wireUses == 0 then
    return true, toolTip;
  end
  local canDo = true;
  local totalUse = ISMetalWeldingMenu.getMaterialUses(player, "Wire");
  if totalUse > wireUses then
    toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.Wire") .. " " .. getText("ContextMenu_Uses") .. " " .. totalUse .. "/" .. wireUses;
  else
    toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.Wire") .. " " .. getText("ContextMenu_Uses") .. " " .. totalUse .. "/" .. wireUses;
    canDo = false;
  end
  return canDo, toolTip;
end

ISMetalWeldingMenu.checkDoorknob = function(player, toolTip)
    if ISBuildMenu.cheat then
        return true, toolTip;
    end
    local doorknob = player:getInventory():getItemFromType("Doorknob");
    local canDo = true;
    if not doorknob then
        toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemText("Doorknob") .. " 0/1" ;
        canDo = false;
    else
        toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemText("Doorknob") .. " 1/1" ;
    end
    return canDo, toolTip;
end

local function comparatorDrainableUsesInt(item1, item2)
  return item1:getDrainableUsesInt() - item2:getDrainableUsesInt()
end

function ISMetalWeldingMenu.getBlowTorchWithMostUses(container)
  return container:getBestTypeEvalRecurse("Base.BlowTorch", comparatorDrainableUsesInt)
end

function ISMetalWeldingMenu.getFirstBlowTorchWithUses(container, uses)
  return container:getFirstTypeEvalArgRecurse("Base.BlowTorch", predicateDrainableUsesInt, uses)
end

function ISMetalWeldingMenu.getMaterialCount(playerObj, type)
  local playerInv = playerObj:getInventory()
  local count = playerInv:getCountTypeRecurse(type)
  if ISMetalWeldingMenu.groundItemCounts[type] then
    count = count + ISMetalWeldingMenu.groundItemCounts[type]
  end
  return count
end

function ISMetalWeldingMenu.getMaterialUses(playerObj, type)
  local playerInv = playerObj:getInventory()
  local count = playerInv:getUsesTypeRecurse(type)
  if ISMetalWeldingMenu.groundItemUses[type] then
    count = count + ISMetalWeldingMenu.groundItemUses[type]
  end
  return count
end

ISMetalWeldingMenu.checkMetalWeldingFurnitures = function(metalPipes, smallMetalSheet, metalSheet, hinge, scrapMetal, torchUse, skill, player, toolTip, metalBar, wire)
  if ISBuildMenu.cheat then
    return true, toolTip;
  else
    toolTip.description = toolTip.description .. "<LINE> <LINE>" .. getText("Tooltip_craft_Needs") .. ": ";
  end
  local inv = player:getInventory();
  local isOk = true;
  local blowTorch = ISMetalWeldingMenu.getFirstBlowTorchWithUses(inv, torchUse) or ISMetalWeldingMenu.getBlowTorchWithMostUses(inv)
  if blowTorch then
    local blowTorchUseLeft = blowTorch:getDrainableUsesInt()
    if torchUse > 0 then
      if blowTorchUseLeft < torchUse then
        toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.BlowTorch") .. " " .. getText("ContextMenu_Uses") .. " " .. blowTorchUseLeft .. "/" .. torchUse;
        isOk = false;
      else
        toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.BlowTorch") .. " " .. getText("ContextMenu_Uses") .. " " .. blowTorchUseLeft .. "/" .. torchUse;
      end
    end
  else
    toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.BlowTorch") .. " 0" .. "/" .. torchUse;
    isOk = false;
  end
  local rodUse = ISMetalWeldingMenu.weldingRodUses(torchUse)
  local weldingRods = ISMetalWeldingMenu.getMaterialUses(player, "Base.WeldingRods")
  if rodUse > 0 then
    if weldingRods < rodUse then
      toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.WeldingRods") .. " " .. getText("ContextMenu_Uses") .. " " .. weldingRods .. "/" .. rodUse;
      isOk = false;
    else
      toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.WeldingRods") .. " " .. getText("ContextMenu_Uses") .. " " .. weldingRods .. "/" .. rodUse;
    end
  end
  local weldingMask = ISBlacksmithMenu.getMaterialCount(player, "WeldingMask")
  if not inv:containsTypeRecurse("WeldingMask") then
    toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.WeldingMask") .. " " .. weldingMask .. "/1" ;
    isOk = false;
  else
    toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.WeldingMask") .. " " .. weldingMask .. "/1" ;
  end
  if metalBar and metalBar > 0 then
    local count = ISMetalWeldingMenu.getMaterialCount(player, "MetalBar")
    if count < metalBar then
      toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.MetalBar") .. " " .. count .. "/" .. metalBar;
      isOk = false;
    else
      toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.MetalBar") .. " " .. count .. "/" .. metalBar ;
    end
  end
  if metalPipes > 0 then
    local count = ISMetalWeldingMenu.getMaterialCount(player, "MetalPipe")
    if count < metalPipes then
      toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.MetalPipe") .. " " .. count .. "/" .. metalPipes;
      isOk = false;
    else
      toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.MetalPipe") .. " " .. count .. "/" .. metalPipes ;
    end
  end
  if smallMetalSheet > 0 then
    local count = ISMetalWeldingMenu.getMaterialCount(player, "SmallSheetMetal")
    if count < smallMetalSheet then
      toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.SmallSheetMetal") .. " " .. count .. "/" .. smallMetalSheet;
      isOk = false;
    else
      toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.SmallSheetMetal") .. " " .. count .. "/" .. smallMetalSheet ;
    end
  end
  if metalSheet > 0 then
    local count = ISMetalWeldingMenu.getMaterialCount(player, "SheetMetal")
    if count < metalSheet then
      toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.SheetMetal") .. " " .. count .. "/" .. metalSheet;
      isOk = false;
    else
      toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.SheetMetal") .. " " .. count .. "/" .. metalSheet ;
    end
  end
  if hinge > 0 then
    local count = ISMetalWeldingMenu.getMaterialCount(player, "Hinge")
    if count < hinge then
      toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.Hinge") .. " " .. count .. "/" .. hinge;
      isOk = false;
    else
      toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.Hinge") .. " " .. count .. "/" .. hinge ;
    end
  end
  if scrapMetal > 0 then
    local count = ISMetalWeldingMenu.getMaterialCount(player, "ScrapMetal")
    if count < scrapMetal then
      toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.ScrapMetal") .. " " .. count .. "/" .. scrapMetal;
      isOk = false;
    else
      toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.ScrapMetal") .. " " .. count .. "/" .. scrapMetal ;
    end
  end
  if wire ~= nil and wire > 0 then
    local count = ISMetalWeldingMenu.getMaterialUses(player, "Wire");
    if count < wire then
      toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.Wire") .. " " .. getText("ContextMenu_Uses") .. " " .. count .. "/" .. wire;
      isOk = false;
    else
      toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getItemNameFromFullType("Base.Wire") .. " " .. getText("ContextMenu_Uses") .. " " .. wire .. "/" .. wire;
    end
  end
  toolTip.description = toolTip.description .. " <LINE> ";
  if skill > 0 then
    if player:getPerkLevel(Perks.MetalWelding) < skill then
      toolTip.description = toolTip.description .. " <LINE> <RGB:1,0,0> " .. getText("IGUI_perks_MetalWelding") .. " " .. player:getPerkLevel(Perks.MetalWelding) .. "/" .. skill;
      isOk = false;
    else
      toolTip.description = toolTip.description .. " <LINE> <RGB:0,1,0> " .. getText("IGUI_perks_MetalWelding") .. " " .. player:getPerkLevel(Perks.MetalWelding) .. "/" .. skill ;
    end
  end
  if ISBuildMenu.cheat then
    return true, toolTip;
  end
  if isOk then
    ISMetalWeldingMenu.canDoSomething = true;
  end
  return isOk, toolTip;
end

ISMetalWeldingMenu.addToolTip = function(option, name, texture)
  local toolTip = ISWorldObjectContextMenu.addToolTip();
  option.toolTip = toolTip;
  toolTip:setName(name);
  toolTip.description = " ";
  toolTip:setTexture(texture);
  toolTip.footNote = getText("Tooltip_craft_pressToRotate", Keyboard.getKeyName(getCore():getKey("Rotate building")))
  return toolTip;
end

-- **********************************************
-- **                  *WALL*                  **
-- **********************************************

ISMetalWeldingMenu.onMetalWallFrame = function(worldobjects, player, torchUse)
    local fence = ISWoodenWall:new("constructedobjects_01_68","constructedobjects_01_69", "constructedobjects_01_67");
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.canBarricade = false
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.health = 120;
    fence.name = "MetalWallFrame";
    fence.modData["xp:MetalWelding"] = 20;
    fence.modData["need:Base.MetalBar"]= "3";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onMetalWallCorner = function(worldobjects, player, torchUse)
    local wall = ISWoodenWall:new("constructedobjects_01_67", "constructedobjects_01_67", nil);
    wall.firstItem = "BlowTorch";
    wall.secondItem = "WeldingMask";
    wall.craftingBank = "BlowTorch";
    wall.canBarricade = false
    wall.noNeedHammer = true;
    wall.actionAnim = "BlowTorchMid";
    wall.canPassThrough = true;
    wall.isCorner = true;
    wall.health = 120;
    wall.name = "Metal Corner"
    wall.modData["wallType"] = "pillar";
    wall.modData["need:Base.MetalBar"]= "2";
    wall.modData["use:Base.BlowTorch"] = torchUse;
    wall.modData["use:Base.WeldingRods"] = torchUse / 2;
    wall.player = player;
    getCell():setDrag(wall, player);
end

ISMetalWeldingMenu.onMetalDoorFrame = function(worldobjects, sprite, player, torchUse)
    local doorFrame = ISWoodenDoorFrame:new(sprite.sprite, sprite.northSprite, sprite.corner);
    doorFrame.firstItem = "BlowTorch";
    doorFrame.secondItem = "WeldingMask";
    doorFrame.craftingBank = "BlowTorch";
    doorFrame.noNeedHammer = true;
    doorFrame.actionAnim = "BlowTorchMid";
    doorFrame.health = 220;
    doorFrame.name = "MetalDoorFrameLvl" .. ISMetalWeldingMenu.getSpriteLvl(player);
    doorFrame.modData["xp:MetalWelding"] = 30;
    doorFrame.modData["need:Base.SheetMetal"]= "3";
    doorFrame.modData["need:Base.MetalBar"]= "3";
    doorFrame.modData["use:Base.BlowTorch"] = torchUse;
    doorFrame.modData["use:Base.WeldingRods"] = torchUse / 2;
    doorFrame.player = player
    getCell():setDrag(doorFrame, player);
end

ISMetalWeldingMenu.onMetalJailDoorFrame = function(worldobjects, player, torchUse)
    local fence = ISWoodenDoorFrame:new("location_community_police_01_10","location_community_police_01_11", nil);
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.health = 400;
    fence.name = "Metal Jail Door Frame";
    fence.modData["xp:MetalWelding"] = 30;
    fence.modData["need:Base.MetalPipe"]= "5";
    fence.modData["need:Base.ScrapMetal"]= "5";
    fence.modData["need:Base.MetalBar"]= "3";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onMetalJailWall = function(worldobjects, player, torchUse, sprite)
    local fence = ISWoodenWall:new("location_community_police_01_0", "location_community_police_01_1", "location_community_police_01_2");
    fence.name = "Metal Jail Wall"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.health = 400;
    fence.modData["xp:MetalWelding"] = 30;
    fence.modData["need:Base.MetalPipe"]= "8";
    fence.modData["need:Base.ScrapMetal"]= "3";
    fence.modData["need:Base.MetalBar"]= "3";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onJailWallCorner = function(worldobjects, player, torchUse)
    local wall = ISWoodenWall:new("location_community_police_01_3", "location_community_police_01_3", nil);
    wall.firstItem = "BlowTorch";
    wall.secondItem = "WeldingMask";
    wall.craftingBank = "BlowTorch";
    wall.canBarricade = false
    wall.noNeedHammer = true;
    wall.actionAnim = "BlowTorchMid";
    wall.canPassThrough = true;
    wall.health = 250;
    wall.name = "Jail Corner"
    wall.isCorner = true;
    wall.modData["xp:MetalWelding"] = 15;
    wall.modData["wallType"] = "pillar";
    wall.modData["need:Base.MetalBar"]= "2";
    wall.modData["use:Base.BlowTorch"] = torchUse;
    wall.modData["use:Base.WeldingRods"] = torchUse / 2;
    wall.player = player;
    getCell():setDrag(wall, player);
end

ISMetalWeldingMenu.onMetalJailWindow = function(worldobjects, player, torchUse, sprite)
    local fence = ISWoodenWall:new("location_community_police_01_40", "location_community_police_01_41", nil);
    fence.name = "Metal Jail Window"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.health = 400;
    fence.modData["xp:MetalWelding"] = 30;
    fence.modData["need:Base.MetalPipe"]= "8";
    fence.modData["need:Base.ScrapMetal"]= "3";
    fence.modData["need:Base.MetalBar"]= "3";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

-- **********************************************
-- **               *FURNITURE*                **
-- **********************************************

ISMetalWeldingMenu.onMetalCrate = function(worldobjects, player, torchUse)
    -- sprite, northSprite
    local crate = ISWoodenContainer:new("constructedobjects_01_47", "constructedobjects_01_46");
    crate.name = "Metal Crate"
    crate.firstItem = "BlowTorch";
    crate.secondItem = "WeldingMask";
    crate.craftingBank = "BlowTorch";
    crate.canBeAlwaysPlaced = true;
    crate.noNeedHammer = true;
    crate.actionAnim = "BlowTorchMid";
    crate.modData["xp:MetalWelding"] = 20;
    crate.modData["need:Base.MetalPipe"]= "2";
    crate.modData["need:Base.SmallSheetMetal"]= "2";
    crate.modData["need:Base.SheetMetal"]= "2";
    crate.modData["need:Base.ScrapMetal"]= "1";
    crate.modData["use:Base.BlowTorch"] = torchUse;
    crate.modData["use:Base.WeldingRods"] = torchUse / 2;
    crate:setEastSprite("constructedobjects_01_45");
    crate:setSouthSprite("constructedobjects_01_44");
    crate.player = player
    getCell():setDrag(crate, player);
end

ISMetalWeldingMenu.onMetalShelves = function(worldobjects, player, torchUse)
    local crate = ISSimpleFurniture:new("shelves", "furniture_shelving_01_29","furniture_shelving_01_28");
    crate.noNeedHammer = true;
    crate.actionAnim = "BlowTorchMid";
    crate.needToBeAgainstWall = true;
    crate.isContainer = true;
    crate.containerType = "shelves";
    crate.firstItem = "BlowTorch";
    crate.secondItem = "WeldingMask";
    crate.craftingBank = "BlowTorch";
    crate.modData["xp:MetalWelding"] = 20;
    crate.modData["need:Base.MetalPipe"]= "2";
    crate.modData["need:Base.SmallSheetMetal"]= "1";
    crate.modData["need:Base.ScrapMetal"]= "1";
    crate.modData["use:Base.BlowTorch"] = torchUse;
    crate.modData["use:Base.WeldingRods"] = torchUse / 2;
    crate.player = player
    getCell():setDrag(crate, player);
end

ISMetalWeldingMenu.onMetalCounter = function(worldobjects, player, torchUse)
    local crate = ISWoodenContainer:new("fixtures_counters_01_35","fixtures_counters_01_37", nil);
    crate.name = "Metal Counter"
    crate.firstItem = "BlowTorch";
    crate.secondItem = "WeldingMask";
    crate.craftingBank = "BlowTorch";
    crate:setEastSprite("fixtures_counters_01_39");
    crate:setSouthSprite("fixtures_counters_01_33");
    crate.noNeedHammer = true;
    crate.actionAnim = "BlowTorchMid";
    crate.modData["xp:MetalWelding"] = 20;
    crate.modData["need:Base.MetalPipe"]= "2";
    crate.modData["need:Base.SmallSheetMetal"]= "4";
    crate.modData["need:Base.Hinge"]= "2";
    crate.modData["use:Base.BlowTorch"] = torchUse;
    crate.modData["use:Base.WeldingRods"] = torchUse / 2;
    crate.player = player
    getCell():setDrag(crate, player);
end

ISMetalWeldingMenu.onMetalCounterCorner = function(worldobjects, player, torchUse)
    local crate = ISWoodenContainer:new("fixtures_counters_01_34","fixtures_counters_01_36", nil);
    crate.firstItem = "BlowTorch";
    crate.secondItem = "WeldingMask";
    crate.craftingBank = "BlowTorch";
    crate:setEastSprite("fixtures_counters_01_38");
    crate:setSouthSprite("fixtures_counters_01_32");
    crate.noNeedHammer = true;
    crate.actionAnim = "BlowTorchMid";
    crate.modData["xp:MetalWelding"] = 20;
    crate.modData["need:Base.MetalPipe"]= "2";
    crate.modData["need:Base.SmallSheetMetal"]= "4";
    crate.modData["need:Base.Hinge"]= "2";
    crate.modData["use:Base.BlowTorch"] = torchUse;
    crate.modData["use:Base.WeldingRods"] = torchUse / 2;
    crate.player = player
    getCell():setDrag(crate, player);
end

ISMetalWeldingMenu.onSmallLocker = function(worldobjects, player, torchUse)
    local crate = ISWoodenContainer:new("furniture_storage_02_9","furniture_storage_02_8", nil);
    crate.name = "Small Metal Locker"
    crate.firstItem = "BlowTorch";
    crate.secondItem = "WeldingMask";
    crate.craftingBank = "BlowTorch";
    crate:setEastSprite("furniture_storage_02_11");
    crate:setSouthSprite("furniture_storage_02_10");
    crate.noNeedHammer = true;
    crate.actionAnim = "BlowTorchMid";
    crate.modData["xp:MetalWelding"] = 25;
    crate.modData["need:Base.MetalPipe"]= "3";
    crate.modData["need:Base.SmallSheetMetal"]= "4";
    crate.modData["need:Base.Hinge"]= "2";
    crate.modData["use:Base.BlowTorch"] = torchUse;
    crate.modData["use:Base.WeldingRods"] = torchUse / 2;
    crate.player = player
    getCell():setDrag(crate, player);
end

ISMetalWeldingMenu.onBigLocker = function(worldobjects, player, torchUse)
    local crate = ISWoodenContainer:new("furniture_storage_02_1","furniture_storage_02_0", nil);
    crate.name = "Big Metal Locker"
    crate.firstItem = "BlowTorch";
    crate.secondItem = "WeldingMask";
    crate.craftingBank = "BlowTorch";
    crate:setEastSprite("furniture_storage_02_3");
    crate:setSouthSprite("furniture_storage_02_2");
    crate.noNeedHammer = true;
    crate.actionAnim = "BlowTorchMid";
    crate.modData["xp:MetalWelding"] = 30;
    crate.modData["need:Base.MetalPipe"]= "8";
    crate.modData["need:Base.SmallSheetMetal"]= "4";
    crate.modData["need:Base.Hinge"]= "2";
    crate.modData["use:Base.BlowTorch"] = torchUse;
    crate.modData["use:Base.WeldingRods"] = torchUse / 2;
    crate.player = player
    getCell():setDrag(crate, player);
end

ISMetalWeldingMenu.onMetalChair = function(worldobjects, player, torchUse)
    local furniture = ISSimpleFurniture:new("Metal Chair", "furniture_seating_indoor_01_53", "furniture_seating_indoor_01_54");
    furniture:setEastSprite("furniture_seating_indoor_01_52");
    furniture:setSouthSprite("furniture_seating_indoor_01_55");
    furniture.noNeedHammer = true;
    furniture.actionAnim = "BlowTorchMid";
    furniture.name = "Metal Chair"
    furniture.firstItem = "BlowTorch";
    furniture.secondItem = "WeldingMask";
    furniture.craftingBank = "BlowTorch";
    furniture.modData["xp:MetalWelding"] = 10;
    furniture.modData["need:Base.MetalBar"]= "4";
    furniture.modData["need:Base.SmallSheetMetal"]= "2";
    furniture.modData["use:Base.BlowTorch"] = torchUse;
    furniture.modData["use:Base.WeldingRods"] = torchUse / 2;
    furniture.canPassThrough = true;
    furniture.player = player
    getCell():setDrag(furniture, player);
end

ISMetalWeldingMenu.onMetalDrum = function(worldobjects, player, torchUse)
    local barrel = ISMetalDrum:new(player, "crafted_01_24");
    barrel.name = "Metal Drum"
    barrel.firstItem = "BlowTorch";
    barrel.secondItem = "WeldingMask";
    barrel.craftingBank = "BlowTorch";
    barrel.noNeedHammer = true;
    barrel.actionAnim = "BlowTorchMid";
    barrel.modData["xp:MetalWelding"] = 30;
    barrel.modData["need:Base.SheetMetal"]= "3";
    barrel.modData["need:Base.MetalBar"]= "2";
    barrel.modData["use:Base.BlowTorch"] = torchUse;
    barrel.modData["use:Base.WeldingRods"] = torchUse / 2;
    barrel.player = player
    getCell():setDrag(barrel, player);
end

-- **********************************************
-- **                  *FENCE*                 **
-- **********************************************

ISMetalWeldingMenu.onMetalFence = function(worldobjects, player, torchUse, sprite)
    local fence = ISWoodenWall:new(sprite.sprite,sprite.northSprite, nil);
    fence.name = "Metal Panel Fence"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.canBarricade = false;
    fence.modData["xp:MetalWelding"] = 20;
    fence.modData["need:Base.MetalPipe"]= "1";
    fence.modData["need:Base.SmallSheetMetal"]= "2";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onMetalPoleFence = function(worldobjects, player, torchUse)
    local fence = ISWoodenWall:new("constructedobjects_01_62","constructedobjects_01_61", nil);
    fence.name = "Small Metal Pole Fence"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.canBarricade = false
    fence.modData["xp:MetalWelding"] = 20;
    fence.modData["need:Base.MetalPipe"]= "3";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onWiredFence = function(worldobjects, player, torchUse)
    local fence = ISWoodenWall:new("fencing_01_26","fencing_01_25", nil);
    fence.name = "Small Metal Wire Fence"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.canBarricade = false
    fence.modData["xp:MetalWelding"] = 15;
    fence.modData["use:Base.Wire"] = "1";
    fence.modData["need:Base.MetalPipe"] = "2";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onWiredFencePost = function(worldobjects, player, torchUse)
    local fence = ISWoodenWall:new("fencing_01_29","fencing_01_29", nil);
    fence.name = "Metal Post"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.canPassThrough = true;
    fence.canBarricade = false
    fence.canBeAlwaysPlaced = true;
    fence.modData["xp:MetalWelding"] = 10;
    fence.modData["need:Base.MetalPipe"] = "1";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onBigMetalFence = function(worldobjects, player, torchUse)
    local fence = ISWoodenWall:new("constructedobjects_01_78","constructedobjects_01_77", nil);
    fence.name = "Big Metal Pole Fence"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.canBarricade = false
    fence.modData["xp:MetalWelding"] = 25;
    fence.modData["need:Base.MetalPipe"] = "5";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onBigWiredFence = function(worldobjects, player, torchUse)
    local fence = ISWoodenWall:new("fencing_01_58","fencing_01_57", nil);
    fence.name = "Big Metal Wire Fence"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.canBarricade = false
    fence.modData["xp:MetalWelding"] = 20;
    fence.modData["use:Base.Wire"] = "3";
    fence.modData["need:Base.MetalPipe"] = "3";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onBigWiredFencePost = function(worldobjects, player, torchUse)
    local fence = ISWoodenWall:new("fencing_01_61", "fencing_01_61", nil);
    fence.name = "Big Metal Wire Fence Post"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.canBarricade = false
    fence.canPassThrough = true;
    fence.modData["xp:MetalWelding"] = 20;
    fence.modData["wallType"] = "pillar";
    fence.modData["need:Base.MetalPipe"] = "2";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player;
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onBigMetalPost = function(worldobjects, player, torchUse)
    local fence = ISWoodenWall:new("fencing_01_29","fencing_01_29", nil);
    fence.name = "Metal Post"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.canPassThrough = true;
    fence.canBarricade = false
    fence.canBeAlwaysPlaced = true;
    fence.modData["xp:MetalWelding"] = 10;
    fence.modData["need:Base.MetalPipe"] = "2";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

-- **********************************************
-- **               *DOOR/GATE*                **
-- **********************************************

ISMetalWeldingMenu.onMetalDoor = function(worldobjects, player, torchUse)
    local fence = ISWoodenDoor:new("fixtures_doors_01_52","fixtures_doors_01_53", "fixtures_doors_01_54", "fixtures_doors_01_55");
    fence.name = "Metal Door"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.canBarricade = true;
    fence.modData["xp:MetalWelding"] = 25;
    fence.modData["need:Base.SheetMetal"]= "4";
    fence.modData["need:Base.Hinge"]= "2";
    fence.modData["need:Base.ScrapMetal"]= "2";
    fence.modData["need:Base.Doorknob"]= "1";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onMetalJailDoor = function(worldobjects, player, torchUse)
    local fence = ISWoodenDoor:new("location_community_police_01_4","location_community_police_01_5", "location_community_police_01_6", "location_community_police_01_7");
    fence.name = "Metal Door"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.canBarricade = true;
    fence.modData["xp:MetalWelding"] = 25;
    fence.modData["need:Base.MetalPipe"]= "5";
    fence.modData["need:Base.Hinge"]= "2";
    fence.modData["need:Base.ScrapMetal"]= "3";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onFenceGate = function(worldobjects, player, torchUse)
    local fence = ISWoodenDoor:new("fixtures_doors_fences_01_28","fixtures_doors_fences_01_29", "fixtures_doors_fences_01_30", "fixtures_doors_fences_01_31");
    fence.name = "Small Metal Pole Gate"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.dontNeedFrame = true;
    fence.canBarricade = false
    fence.modData["xp:MetalWelding"] = 25;
    fence.modData["need:Base.MetalPipe"]= "3";
    fence.modData["need:Base.Hinge"]= "2";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onWiredGate = function(worldobjects, player, torchUse)
    -- sprite, northsprite, openSprite, openNorthSprite
    local gate = ISWoodenDoor:new("fixtures_doors_fences_01_16", "fixtures_doors_fences_01_17", "fixtures_doors_fences_01_18", "fixtures_doors_fences_01_19");
    fence.name = "Small Metal Wire Gate"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.dontNeedFrame = true;
    fence.canBarricade = false
    fence.modData["xp:MetalWelding"] = 15;
    fence.modData["use:Base.Wire"] = "1";
    fence.modData["need:Base.MetalPipe"] = "2";
    fence.modData["need:Base.ScrapMetal"]= "1";
    fence.modData["need:Base.Hinge"]= "2";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

ISMetalWeldingMenu.onDoubleMetalDoor = function(worldobjects, player, torchUse)
    local door = ISDoubleDoor:new("fixtures_doors_fences_01_", 72);
    door.name = "Double Metal Wire Gate"
    door.firstItem = "BlowTorch";
    door.secondItem = "WeldingMask";
    door.craftingBank = "BlowTorch";
    door.noNeedHammer = true;
    door.actionAnim = "BlowTorchMid";
    door.canBarricade = false;
    door.modData["xp:MetalWelding"] = 25;
    door.modData["use:Base.Wire"] = "4";
    door.modData["need:Base.MetalPipe"] = "8";
    door.modData["use:Base.BlowTorch"] = torchUse;
    door.modData["use:Base.WeldingRods"] = torchUse / 2;
    door.player = player
    door.ignoreNorth = true;
    getCell():setDrag(door, player);
end

ISMetalWeldingMenu.onDoublePoleDoor = function(worldobjects, player, torchUse)
    local door = ISDoubleDoor:new("fixtures_doors_fences_01_", 88);
    door.name = "Double Metal Pole Gate"
    door.firstItem = "BlowTorch";
    door.secondItem = "WeldingMask";
    door.craftingBank = "BlowTorch";
    door.noNeedHammer = true;
    door.actionAnim = "BlowTorchMid";
    door.canBarricade = false;
    door.modData["xp:MetalWelding"] = 25;
    door.modData["need:Base.MetalPipe"] = "10";
    door.modData["use:Base.BlowTorch"] = torchUse;
    door.modData["use:Base.WeldingRods"] = torchUse / 2;
    door.player = player
    door.ignoreNorth = true;
    getCell():setDrag(door, player);
end

ISMetalWeldingMenu.onBigMetalFenceGate = function(worldobjects, player, torchUse)
    local fence = ISWoodenDoor:new("fixtures_doors_fences_01_24","fixtures_doors_fences_01_25", "fixtures_doors_fences_01_26", "fixtures_doors_fences_01_27");
    fence.name = "Big Metal Pole Gate"
    fence.firstItem = "BlowTorch";
    fence.secondItem = "WeldingMask";
    fence.craftingBank = "BlowTorch";
    fence.noNeedHammer = true;
    fence.actionAnim = "BlowTorchMid";
    fence.dontNeedFrame = true;
    fence.canBarricade = false
    fence.modData["xp:MetalWelding"] = 25;
    fence.modData["need:Base.MetalPipe"] = "5";
    fence.modData["need:Base.Hinge"]= "2";
    fence.modData["use:Base.BlowTorch"] = torchUse;
    fence.modData["use:Base.WeldingRods"] = torchUse / 2;
    fence.player = player
    getCell():setDrag(fence, player);
end

-- **********************************************
-- **                 *STAIRS*                 **
-- **********************************************

ISMetalWeldingMenu.onMetalStairs = function(worldobjects, player, torchUse)
    local stairsSprite = ISMetalWeldingMenu.getStairsSprite(player);
    local stairs = ISWoodenStairs:new(stairsSprite.northSprite1, stairsSprite.northSprite2, stairsSprite.northSprite3, stairsSprite.sprite1, stairsSprite.sprite2, stairsSprite.sprite3, stairsSprite.northSprite4, stairsSprite.sprite4);
    stairs.firstItem = "BlowTorch";
    stairs.secondItem = "WeldingMask";
    stairs.craftingBank = "BlowTorch";
    stairs.noNeedHammer = true;
    stairs.actionAnim = "BlowTorchMid";
    stairs.modData["xp:MetalWelding"] = 40;
    stairs.modData["need:Base.SmallSheetMetal"] = "15";
    stairs.modData["need:Base.SheetMetal"] = "3";
    stairs.modData["need:Base.MetalBar"] = "10";
    stairs.modData["use:Base.BlowTorch"] = torchUse;
    stairs.modData["use:Base.WeldingRods"] = torchUse / 2;
    stairs.player = player
    getCell():setDrag(stairs, player);
end

-- **********************************************
-- **               *ROOF/FLOOR*               **
-- **********************************************

ISMetalWeldingMenu.onMetalRoof = function(worldobjects, player, torchUse)
    local floor = ISWoodenFloor:new("constructedobjects_01_86","constructedobjects_01_86");
    floor.firstItem = "BlowTorch";
    floor.secondItem = "WeldingMask";
    floor.craftingBank = "BlowTorch";
    floor.noNeedHammer = true;
    floor.modData["xp:MetalWelding"] = 5;
    floor.modData["need:Base.SmallSheetMetal"] = "1";
    floor.modData["use:Base.BlowTorch"] = torchUse;
    floor.modData["use:Base.WeldingRods"] = torchUse / 2;
    floor.player = player
    getCell():setDrag(floor, player);
end

ISMetalWeldingMenu.onMetalFloor = function(worldobjects, player, torchUse)
    local floor = ISWoodenFloor:new("industry_01_7","industry_01_7");
    floor.firstItem = "BlowTorch";
    floor.secondItem = "WeldingMask";
    floor.craftingBank = "BlowTorch";
    floor.noNeedHammer = true;
    floor.modData["xp:MetalWelding"] = 5;
    floor.modData["need:Base.SmallSheetMetal"] = "1";
    floor.modData["use:Base.BlowTorch"] = torchUse;
    floor.modData["use:Base.WeldingRods"] = torchUse / 2;
    floor.player = player
    getCell():setDrag(floor, player);
end

ISMetalWeldingMenu.getSpriteLvl = function(player)
    -- 0 to 1 wood work xp mean lvl 1 sprite
    if getSpecificPlayer(player):getPerkLevel(Perks.MetalWelding) <= 7 then
        return 1;
    else
        return 2;
    end
end

ISMetalWeldingMenu.getMetalDoorFrameSprites = function(player)
    local spriteLvl = ISMetalWeldingMenu.getSpriteLvl(player);
    local sprite = {};
    if spriteLvl == 1 then
        sprite.sprite = "constructedobjects_01_74";
        sprite.northSprite = "constructedobjects_01_75";
    else
        sprite.sprite = "constructedobjects_01_58";
        sprite.northSprite = "constructedobjects_01_59";
    end
    sprite.corner = nil;
    return sprite;
end

ISMetalWeldingMenu.getFenceSprite = function(player)
  local sprite = {};
  if player:getPerkLevel(Perks.Metalwelding) <= 5 then
    sprite.sprite = "constructedobjects_01_82";
    sprite.northSprite = "constructedobjects_01_81";
  else
    sprite.sprite = "constructedobjects_01_83";
    sprite.northSprite = "constructedobjects_01_80";
  end
  return sprite;
end

ISMetalWeldingMenu.getStairsSprite = function(player)
    local sprite = {};
    sprite.sprite1 = "fixtures_stairs_01_11";
    sprite.sprite2 = "fixtures_stairs_01_12";
    sprite.sprite3 = "fixtures_stairs_01_13";
    sprite.sprite4 = nil;
    sprite.northSprite1 = "fixtures_stairs_01_3";
    sprite.northSprite2 = "fixtures_stairs_01_4";
    sprite.northSprite3 = "fixtures_stairs_01_5";
    sprite.northSprite4 = nil;
    return sprite;
end

Events.OnFillWorldObjectContextMenu.Add(ISMetalWeldingMenu.doBuildMenu);