ISBuildMenu.buildBridgeMenu = function(subMenu, option, player)
	-- simple wooden floor
    local floorSprite = ISBuildMenu.getWoodenFloorSprites(player);
	local floorOption = subMenu:addOption(getText("ContextMenu_Wooden_Pantone"), worldobjects, ISBuildMenu.onWoodenFloorUnderWater, square, floorSprite, player);
	local tooltip = ISBuildMenu.newCanBuild(4,5,10,1,5,floorOption, player);
	tooltip:setName(getText("ContextMenu_Wooden_Pantone"));
	tooltip.description = getText("Tooltip_craft_woodenFloorDesc") .. tooltip.description;
	tooltip:setTexture(floorSprite.sprite);
	ISBuildMenu.requireHammer(floorOption)
end