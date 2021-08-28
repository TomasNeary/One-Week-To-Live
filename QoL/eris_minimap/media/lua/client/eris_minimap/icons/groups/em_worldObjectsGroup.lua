----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_worldObjectsGroup
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require("em_mapIconGroupBase");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_worldObjectsGroup = em_mapIconGroupBase:new();

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_worldObjectsGroup:updateGroup(_updateTime)
	if em_settings.context_settings.show_buildings_areas.enabled then
		self:updateBuildingOverlays();
	end;
	self:update(_updateTime);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_worldObjectsGroup:update(_updateTime)
	self.vpBuildings = {};
	self.doTextIcons = {};
	local settingsTable = {
		buildings = "show_buildings_areas",
	};
	local isInView, enabled;
	local mouseOver, playerInside;
	local vpBounds = em_core.map.vpBounds;
	local isInRectCheck = em_mapIconGroupBase.isInRect;
	local map_settings = em_settings.map_settings;
	local context_settings = em_settings.context_settings;
	if map_settings.zoomLevel < 1 then self.drawIcons = {}; else self.drawIcons = self.vpBuildings; end;
	for plID, plIcon in pairs(self.playerIcons) do
		for iconID, icon in pairs(self.buildings) do
			icon:updateTimeStamp(_updateTime);
			isInView = isInRectCheck(nil, icon.bounds.centerX, icon.bounds.centerY, vpBounds.x1, vpBounds.y1, vpBounds.x2, vpBounds.y2);
			if isInView then
				mouseOver = isInRectCheck(nil, em_core.map.mX, em_core.map.mY, icon.bounds.x1, icon.bounds.y1, icon.bounds.x4, icon.bounds.y4);
				enabled = context_settings[settingsTable[icon.class]].enabled;
				if enabled and mouseOver then
					icon.doRenderRooms = true;
					for roomID, roomIcon in pairs(icon.roomIcons) do
						roomIcon:updateTimeStamp(_updateTime);
						self:doOverlayTransform(roomIcon);
						mouseOver = isInRectCheck(nil, em_core.map.mX, em_core.map.mY, roomIcon.bounds.x1, roomIcon.bounds.y1, roomIcon.bounds.x4, roomIcon.bounds.y4);
						roomIcon.isExplored = roomIcon.isExplored or isInRectCheck(nil, plIcon.x, plIcon.y, roomIcon.bounds.x1, roomIcon.bounds.y1, roomIcon.bounds.x4, roomIcon.bounds.y4);
						if mouseOver and roomIcon.isExplored then self.doTextIcons[roomID] = roomIcon; else self.doTextIcons[roomID] = nil; end;
					end;
				else
					icon.doRenderRooms = false;
				end;
				self.vpBuildings[iconID] = icon;
				self:doOverlayTransform(icon);
			else
				icon.doRenderRooms = false;
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_worldObjectsGroup:renderBuildings()
	local drawTexture = em_core.minimap.drawTextureAllPoint;
	for iconID, icon in pairs(self.vpBuildings) do
		drawTexture(em_core.minimap, icon.iconTexture,
		icon.rect.x1, icon.rect.y1, icon.rect.x2, icon.rect.y2, icon.rect.x4, icon.rect.y4, icon.rect.x3, icon.rect.y3,
		icon.r, icon.g, icon.b, icon.a);
		if icon.doRenderRooms then
			for roomID, roomIcon in pairs(icon.roomIcons) do
				drawTexture(em_core.minimap, roomIcon.iconTexture,
				roomIcon.rect.x1, roomIcon.rect.y1, roomIcon.rect.x2, roomIcon.rect.y2, roomIcon.rect.x4, roomIcon.rect.y4, roomIcon.rect.x3, roomIcon.rect.y3,
				roomIcon.r, roomIcon.g, roomIcon.b, roomIcon.a);
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_worldObjectsGroup:renderText()
	local drawTextCentre = em_core.minimap.drawTextCentre;
	local colorset = em_settings.color_settings.areaTitle;
	local r, g, b, a = 1, 1, 1, 1;
	if colorset and colorset.enabled then
		r, g, b, a = colorset.color.r, colorset.color.g, colorset.color.b, colorset.color.a;
	end;
	for iconID, icon in pairs(self.doTextIcons) do
		drawTextCentre(
			em_core.window,
			icon.iconData,
			icon.textX + 1, icon.textY + 1,
			0, 0, 0, a,
			icon.area.font
		);
		drawTextCentre(
			em_core.window,
			icon.iconData,
			icon.textX, icon.textY,
			r, g, b, a,
			icon.area.font
		);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_worldObjectsGroup:render()
	self:renderBuildings();
	self:renderText();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_worldObjectsGroup:initialiseIcon(_icon, _areaID, _area, _objID, _type)
	_icon:setObj(nil);
	_icon:setClass(_type);
	_icon.iconID = _objID;
	_icon.bounds = {
		x1 = _area.x1,
		y1 = _area.y1,
		x2 = _area.x2,
		y2 = _area.y1,
		x3 = _area.x1,
		y3 = _area.y2,
		x4 = _area.x2,
		y4 = _area.y2,
		centerX = _area.x1 + ((_area.x2 - _area.x1) / 2),
		centerY = _area.y1 + ((_area.y2 - _area.y1) / 2),
	};
	_icon.area = _area;
	_icon:setColor(_area.r, _area.g, _area.b, _area.a)
	_icon.iconData = _areaID;
	_icon.iconDataExt = _objID;
	if _type == "buildings" then
		_icon.iconTexture = self.mapIconTex.map_worldArea;
	elseif _type == "roomIcons" then
		_icon.iconTexture = self.mapIconTex.map_worldArea_inner;
	else
		_icon.iconTexture = nil;
	end;
	_icon.doRenderText = false;
	return _icon;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_worldObjectsGroup:initialiseRoomSquares(_buildingIcon, _room)
	local x, y;
	local validSquares;
	local min, max = math.min, math.max;
	local area, areaID, objID;
	local roomSquares, nextSquare;
	local minX, minY, maxX, maxY = 999999, 999999, 0, 0;
	roomSquares = _room:getSquares();
	for i = 0, roomSquares:size() - 1 do
		nextSquare = roomSquares:get(i);
		if nextSquare then
			x, y = nextSquare:getX(), nextSquare:getY();
			minX, minY = min(x, minX), min(y, minY);
			maxX, maxY = max(x, maxX), max(y, maxY);
			validSquares = true;
		end;
	end;
	if validSquares then
		areaID = _room:getName();
		area = {
			x1 = minX, y1 = minY,
			x2 = maxX + 1, y2 = maxY + 1,
			r = 0, g = 0.4, b = 0.8, a = 0.5,
		};
		objID = areaID..area.x1.."-"..area.y1.."_"..area.x2.."-"..area.y2;
		if not self.mapIcons[objID] then
			self.mapIcons[objID] = self:initialiseIcon(em_mapIconBase:new(), areaID, area, objID, "roomIcons");
			self.mapIcons[objID].isExplored = false;
			self.roomIcons[objID] = self.mapIcons[objID];
		end;
		_buildingIcon.roomIcons[objID] = self.mapIcons[objID];
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_worldObjectsGroup:updateBuildingOverlays()
	local cellObj;
	local area, areaID, objID;
	local roomList, nextRoom;
	local nextBuilding, buildingDef;
	for plID, plIcon in pairs(self.playerIcons) do
		cellObj = plIcon.cell;
		if cellObj then
			roomList = cellObj:getRoomList();
			if roomList then
				for i = 0, roomList:size() - 1 do
					nextRoom = roomList:get(i);
					if nextRoom then
						nextBuilding = nextRoom:getBuilding();
						if nextBuilding then
							buildingDef = nextBuilding:getDef();
							areaID = "building";
							area = {
								x1 = buildingDef:getX(), y1 = buildingDef:getY(),
								x2 = buildingDef:getX2(), y2 = buildingDef:getY2(),
								r = 0.36, g = 0.17, b = 0.15, a = 0.2,
							};
							objID = areaID..area.x1.."-"..area.y1.."_"..area.x2.."-"..area.y2;
							if not self.mapIcons[objID] then
								self.mapIcons[objID] = self:initialiseIcon(em_mapIconBase:new(), areaID, area, objID, "buildings");
								self.buildings[objID] = self.mapIcons[objID];
								self.mapIcons[objID].roomIcons = {};
							end;
							self:initialiseRoomSquares(self.mapIcons[objID], nextRoom);
							self.mapIcons[objID].doRenderRooms = false;
						end;
					end;
				end;
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_worldObjectsGroup:initialise()
	self.playerIcons = self.metaGroup.groups.localPlayerGroup.drawIcons;
	self:updateGroup();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_worldObjectsGroup:pre_initialise()
	self.drawIcons = self.mapIcons;
	self.vpBuildings = {};
	self.buildings = {};
	self.roomIcons = {};
	self.doTextIcons = {};
	self.roomColors = {};
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------