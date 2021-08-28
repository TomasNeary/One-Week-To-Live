----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_minimap
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading EM_MINIMAP ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_minimap = em_minimap or ISPanel:derive("em_minimap");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:doTeleport(_x, _y)
	local obj = self.followIcon and self.followIcon.obj or getSpecificPlayer(0);
	if obj then
		obj:setX(_x); obj:setY(_y); obj:setZ(0);
		obj:setLx(_x); obj:setLy(_y); obj:setLz(0);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:getFollowIcon()
	return self.followIcon;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:doAttackCheck()
	local plObj = getSpecificPlayer(0);
	if plObj then
		if plObj:isAiming() then
			plObj:DoAttack(1);
			return true;
		end;
	end;
	return false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:clearFollowIcon()
	self.followIcon = nil;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:getNextIconToFollow()
	self.followIcon = self.mapIconMetaGroup:getNextIconToFollow();
	if not self.followIcon then self:clearFollowIcon(); return; end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:setFollowIcon(_icon)
	self.followIcon = _icon;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:getTarget()
	return self.target;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:clearTarget()
	self.target = nil;
end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:setTarget(_target)
	self.target = _target;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:clearMoveTarget()
	if self.moveTarget then
		self.moveTarget.moveObject:StopAllActionQueue();
	end;
	self.moveTarget = nil;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:moveToTarget(_target, _moveObject)
	self.moveTarget = _target;
	self.moveTarget.moveObject = _moveObject;
	self:updateMoveAction();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:updateMoveAction()
	if self.moveTarget then
		if self.moveTarget.moveObject:pressedMovement() then
			self:clearMoveTarget();
			return;
		end;
		local x, y = self.moveTarget.moveObject:getX(), self.moveTarget.moveObject:getY();
		if em_mapIconGroupBase.getDistance2D(nil, x, y, self.moveTarget.x, self.moveTarget.y) > 1 then
			self.moveTarget.moveAction = ISTimedActionQueue.add(ISPathFindAction:pathToLocationF(self.moveTarget.moveObject, self.moveTarget.x, self.moveTarget.y, 0));
		else
			self:clearMoveTarget();
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:onMouseWheel(_mod)
	self.map:zoomMap(-_mod);
	self.mapIconMetaGroup:update();
	return true;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:onMouseDown()
	self.dragging = true;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:updateMouseOverIcons()
	local numIcons = 0;
	if self.mouseOver then
		self.map:updateCoordinates();
		self.mouseOverIcons, numIcons = self.mapIconMetaGroup:getMouseOverIcons(20 / em_settings.map_settings.zoomLevel, self.map.mX, self.map.mY);
	else
		self.mouseOverIcons = {};
	end;
	return numIcons > 0 or false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:onMouseUp(_x, _y)
	self.dragging = false;
	self:doAttackCheck()
	em_core.window:onMouseUp(_x, _y);
	if em_core.iconSelectorInfoBox then em_core.iconSelectorInfoBox:close(); end;
	if self:updateMouseOverIcons() then
		em_core.iconSelectorInfoBox = em_iconSelectorInfoBox:new(self.mouseOverIcons, getMouseX(), getMouseY());
		em_core.iconSelectorInfoBox:initialise();
	end;
	return true;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:onMouseMove(_x, _y)
	self.mouseOver = true;
	if self.dragging then
		self.map:dragMap(_x, _y, false, true);
		return true;
	end;
	-- if self:updateMouseOverIcons() then

	-- end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:createCustomMarker(_x, _y)
	if em_core.editmarkerwindow then em_core.editmarkerwindow:close(); end;
	em_core.editmarkerwindow = em_editmarker:new(nil, _x, _y);
	em_core.editmarkerwindow:initialise();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:getSubMenu(_header, _data)
	local contextOption = self.contextMenu:addOption(_header, _data);
	local subcontextMenu = self.contextMenu:getNew(self.contextMenu);
	self.contextMenu:addSubMenu(contextOption, subcontextMenu);
	return subcontextMenu;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:doGlobalContextOptions()
	local contextOption;
	local target = {x = self.map.mX, y = self.map.mY};
	local moveObject = self.followIcon and self.followIcon.class == "localPlayer" and self.followIcon.obj or getSpecificPlayer(0);
	if self:getFollowIcon() then
		contextOption = self.contextMenu:addOption(em_translationData.label_context_unlockDrag, self, em_minimap.clearFollowIcon);
	end;
	if self.target then
		contextOption = self.contextMenu:addOption(em_translationData.label_context_unsetTarget, self, em_minimap.clearTarget);
	end;
	contextOption = self.contextMenu:addOption(em_translationData.label_context_setTarget..self.map.mX.."-"..self.map.mY, self, em_minimap.setTarget, target);
	if self.moveTarget then
		contextOption = self.contextMenu:addOption(em_translationData.label_context_stopMoving..self.moveTarget.moveObject:getUsername(), self, em_minimap.clearMoveTarget);
	else
		if not moveObject:getVehicle() then
			contextOption = self.contextMenu:addOption(em_translationData.label_context_startMoving..moveObject:getUsername().." : "..self.map.mX.."-"..self.map.mY, self, em_minimap.moveToTarget, target, moveObject);
		end;
	end;
	contextOption = self.contextMenu:addOption(em_translationData.label_context_addMarker..self.map.mX.."-"..self.map.mY, self, em_minimap.createCustomMarker, self.map.mX, self.map.mY);
	if em_core.adminMode then
		contextOption = self.contextMenu:addOption(em_translationData.label_context_adminTeleport..self.map.mX.."-"..self.map.mY, self, em_minimap.doTeleport, self.map.mX, self.map.mY);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:doIconContextOptions(_icons)
	local tooltip;
	local subcontextMenu;
	local subcontextOption;
	local plObj = self.followIcon and self.followIcon.obj or getSpecificPlayer(0);
	local mechStr = getText("ContextMenu_VehicleMechanics");
	local enterStr = getText("IGUI_EnterVehicle");
	local medCheckStr = getText("ContextMenu_Medical_Check");
	for iconGroup, icons in pairs(_icons) do
		for iconID, icon in pairs(icons) do
			if icon.class == "Vehicle" then
				subcontextMenu = self:getSubMenu(icon.iconData, icon);
				subcontextOption = subcontextMenu:addOption(mechStr, plObj, ISVehicleMenu.onMechanic, icon.obj);
				subcontextOption = subcontextMenu:addOption(enterStr, plObj, ISVehicleMenu.onShowSeatUI, icon.obj);
				if math.abs(plObj:getX() - icon.x) > 5 or math.abs(plObj:getY() - icon.y) > 5 then
					tooltip = ISWorldObjectContextMenu.addToolTip();
					subcontextOption.notAvailable = true;
					tooltip.description = em_translationData.label_context_getCloserToVehicle;
					subcontextOption.toolTip = tooltip;
				end;
				if em_core.clientMode and em_core.adminMode then
					subcontextOption = subcontextMenu:addOption(em_translationData.label_context_adminRemoveVehicle, plObj, ISVehicleMechanics.onCheatRemove, icon.obj);
				end;
			elseif icon.class == "Player" then
				subcontextMenu = self:getSubMenu(icon.iconData, icon);
				subcontextOption = subcontextMenu:addOption(medCheckStr..": "..icon.obj:getDisplayName(), nil, ISWorldObjectContextMenu.onMedicalCheck, plObj, icon.obj)
				subcontextOption = subcontextMenu:addOption(getText("ContextMenu_Trade", icon.obj:getDisplayName()), nil, ISWorldObjectContextMenu.onTrade, plObj, icon.obj)
				if math.abs(plObj:getX() - icon.x) > 2 or math.abs(plObj:getY() - icon.y) > 2 then
					tooltip = ISWorldObjectContextMenu.addToolTip();
					subcontextOption.notAvailable = true;
					tooltip.description = getText("ContextMenu_GetCloserToTrade", icon.obj:getDisplayName());
					subcontextOption.toolTip = tooltip;
				end;
				if em_core.clientMode and em_core.adminMode and canSeePlayerStats() then
					subcontextOption = subcontextMenu:addOption(em_translationData.label_context_adminCheckStats, nil, ISWorldObjectContextMenu.onCheckStats, plObj, icon.obj);
				end;
				self:doAddPlayerToSafehouseOptions(plObj, icon);
			elseif icon.class == "localPlayer" then
				subcontextMenu = self:getSubMenu(icon.iconData, icon);
				subcontextOption = subcontextMenu:addOption(medCheckStr, nil, ISWorldObjectContextMenu.onMedicalCheck, plObj, icon.obj)
			elseif icon.class == "Safehouse" then
				if icon.obj:playerAllowed(plObj) then
					subcontextMenu = self:getSubMenu(em_translationData.label_context_safehouseSubmenu..icon.owner, icon);
					subcontextOption = subcontextMenu:addOption(getText("ContextMenu_ViewSafehouse"), nil, ISWorldObjectContextMenu.onViewSafeHouse, icon.obj, plObj);
				end;
			elseif icon.class == "customMarker" then
				subcontextMenu = self:getSubMenu(em_translationData.label_context_editMarker, icon);
				subcontextOption = subcontextMenu:addOption(icon.iconData, icon, em_minimap.launchMarkerEditWindow);
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap.launchMarkerEditWindow(_icon)
	if em_core.editmarkerwindow then em_core.editmarkerwindow:close(); end;
	em_core.editmarkerwindow = em_editmarker:new(_icon, _icon.x,  _icon.y);
	em_core.editmarkerwindow:initialise();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:onRightMouseUp()
	self.dragging = false;
	self.contextMenu = ISContextMenu.get(0, getMouseX(), getMouseY());
	if self.contextMenu then
		self:doGlobalContextOptions();
		if self:updateMouseOverIcons() then
			self:doIconContextOptions(self.mouseOverIcons);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:getIsMemberOfSafehouse(_shIcon, _plName)
	for i, member in ipairs(_shIcon.members) do
		if member == _plName then
			return true;
		end;
	end;
	return false;
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap.getIsInSafehouse(_shObj, _plIcon)
	local x, y = _plIcon.x, _plIcon.y;
	local x1, y1 = _shObj:getX() - 2, _shObj:getY() - 2;
	local x2, y2 = _shObj:getX2() + 2, _shObj:getY2() + 2;
	return em_mapIconGroupBase.isInRect(nil, x, y, x1, y1, x2, y2);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap.doSafehouseAction(_shIcon, _plIcon, _action)
	if _action == "add" then
		_shIcon.obj:addPlayer(_plIcon.username);
	end;
	if _action == "remove" then
		_shIcon.obj:removePlayer(_plIcon.username);
		if em_minimap.getIsInSafehouse(_shIcon.obj, _plIcon) then
			_shIcon.obj:kickOutOfSafehouse(_plIcon.username);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:doAddPlayerToSafehouseOptions(_plObj, _plIconRemote)
	local subcontextMenu;
	local subcontextOption;
	local plNameLocal = _plObj:getUsername();
	local plNameRemote = _plIconRemote.username;
	local ownedHomes, hasHomes = self:getPlayerHomeList(plNameLocal);
	if hasHomes then
		local subcontextMenu = self:getSubMenu("Safehouse Options - "..plNameLocal, icon);
		for iconID, icon in pairs(ownedHomes) do
			if self:getIsMemberOfSafehouse(icon, plNameRemote) then
				subcontextOption = subcontextMenu:addOption("Remove "..plNameRemote.." from - "..icon.title, icon, em_minimap.doSafehouseAction, _plIconRemote, "remove");
			else
				subcontextOption = subcontextMenu:addOption("Add "..plNameRemote.." to - "..icon.title, icon, em_minimap.doSafehouseAction, _plIconRemote, "add");
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:getPlayerHomeList(_plName)
	local numHomes = 0;
	local ownedHomes = {};
	local safehouseGroup = self.mapIconMetaGroup.groups.safehouseGroup;
	if safehouseGroup then
		local playerHomes = safehouseGroup.playerHomes;
		for iconID, icon in pairs(playerHomes) do
			icon.members = safehouseGroup:updateResidents(icon.obj);
			icon.owner = icon.obj:getOwner();
			if icon.owner == _plName then
				ownedHomes[iconID] = icon;
				numHomes = numHomes + 1;
			end;
		end;
	end;
	return ownedHomes, numHomes > 0;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:onMouseUpOutside()
	self.dragging = false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:onMouseMoveOutside(_x, _y)
	self.mouseOver = false;
	self.mouseOverIcons = {a = {}};
	if self.dragging then
		self.map:dragMap(_x, _y, false, true);
		return true;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:renderOverheadMap()
	local settings = em_settings;
	local isEnabled = em_pluginsettings.enableOverheadMapData and em_settings.context_settings.showOverheadMapData.enabled;
	if settings.map_settings.viewMode == 1 and isEnabled then
		drawOverheadMap(self.javaObject, em_settings.map_settings.zoomLevel, em_core.map.vpCenterXInWorld, em_core.map.vpCenterYInWorld);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:render()

	if not self:getIsVisible() then return; end;
	if em_core.window.moving or em_core.window.isCollapsed then return; end;

	self:setStencilRect(0, 0, self:getWidth(), self:getHeight());

	self.map:render();

	self:renderOverheadMap();

	self.mapIconMetaGroup:render();

	self:clearStencilRect(); self:repaintStencilRect(0, 0, self:getWidth(), self:getHeight());
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:update(_updateTime)

	if not self:getIsVisible() then return; end;

	self.map:process_queuedTiles();

	local updateTime = _updateTime or getTimestampMs();

	self.mapIconMetaGroup.groups.localPlayerGroup:update(updateTime);

	if self.updateTick % em_settings.rate_settings.map_updateRate.value == 0 then
		self.map:update();
	else
		self.map:quickupdate()
	end;

	self.mapIconMetaGroup:update(updateTime);

	if self.updateTick % em_settings.rate_settings.cell_updateRate.value == 0 then
		self.mapIconMetaGroup.groups.cellObjectGroup:updateGroup(updateTime);
	end;

	self.updateTick = self.updateTick + 1;
	if self.updateTick > self.updateTickMax then self.updateTick = 1; end;

	self:updateMoveAction();

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:initialise()

	ISPanel.initialise(self);

	self.map = em_map:new();

	self.map:initialise();

	em_core.map = self.map;

	self.mapIconMetaGroup = em_mapIconMetaGroup:new(self.map, self);

	self.mapIconMetaGroup:initialise();

	em_core.mapIconMetaGroup = self.mapIconMetaGroup;

	self:update();

	self.followIcon = self.mapIconMetaGroup:getNextIconToFollow();

	if em_core.clientMode then
		scoreboardUpdate();
	end;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_minimap:new(_window)

	local o = ISPanel:new(0, 0, 0, 0);

	setmetatable(o, self)
	self.__index = self;

	o.width = 0;
	o.height = 0;

	o.x = 0;
	o.y = 0;

	o.mouseOverIcons = {a = {}};

	o.target = nil;

	o.moveTarget = nil;

	o.followIcon = nil;

	o.font = UIFont.NewMedium;

	o.settings = {};
	o.contextMenu = nil;

	o.mouseOver = false;

	o.borderColor = {r=0, g=0, b=0, a=0};
	o.backgroundColor = {r=0, g=0, b=0, a=0};

	o.noBackground = false;

	o.showLiveData = true;

	o.updateTick = 1;
	o.updateTickMax = 20;

	o.dragging = false;

	o.anchorLeft = true;
	o.anchorRight = true;
	o.anchorTop = true;
	o.anchorBottom = true;

	o.moveWithMouse = false;

	return o;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------