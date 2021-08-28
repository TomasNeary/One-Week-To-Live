----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_areaIconGroup
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require("em_mapIconGroupBase");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_areaIconGroup = em_mapIconGroupBase:new();

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_areaIconGroup:updateGroup(_updateTime)
	self:update(_updateTime);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_areaIconGroup:update(_updateTime)
	local settingsTable = {
		vanilla_areas = "show_vanilla_areas",
		custom_areas = "show_custom_areas",
		communitymap_areas = "show_communitymap_areas",
		nonPVP_areas = "show_nonpvp_areas",
	};
	local isInRect, enabled;
	local isInRectCheck = em_mapIconGroupBase.isInRect;
	local map_settings = em_settings.map_settings;
	local context_settings = em_settings.context_settings;
	if map_settings.zoomLevel > 1 then self.drawIcons = {}; else self.drawIcons = self.mapIcons; end;
	for iconID, icon in pairs(self.drawIcons) do
		icon:updateTimeStamp(_updateTime);
		if not context_settings.neverShowAreaTitle.enabled then
			isInRect = isInRectCheck(nil, em_core.map.mX, em_core.map.mY, icon.bounds.x1, icon.bounds.y1, icon.bounds.x4, icon.bounds.y4);
			enabled = context_settings[settingsTable[icon.class]].enabled;
			if enabled and (isInRect or context_settings.alwaysShowAreaTitle.enabled) then
				icon.doRenderText = true;
			else
				icon.doRenderText = false;
			end;
		else
			icon.doRenderText = false;
		end;
		self:doOverlayTransform(icon);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_areaIconGroup:renderText()
	local drawTextCentre = em_core.minimap.drawTextCentre;
	local colorset = em_settings.color_settings.areaTitle;
	local r, g, b, a = 1, 1, 1, 1;
	if colorset and colorset.enabled then
		r, g, b, a = colorset.color.r, colorset.color.g, colorset.color.b, colorset.color.a;
	end;
	for iconID, icon in pairs(self.drawIcons) do
		if icon.doRenderText then
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
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_areaIconGroup:render()
	self:renderIcons();
	self:renderText();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_areaIconGroup:initialiseIcon(_icon, _areaID, _area, _objID, _type)
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
	_icon.iconTexture = nil;
	_icon.doRenderText = false;
	return _icon;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_areaIconGroup:getVanillaAreaOverlays()
	self.vanilla_areas_icons = {};
	self.vanilla_areas = em_map.vanilla_areas;
	for areaID, area in pairs(self.vanilla_areas) do
		objID = areaID..area.x1.."-"..area.y1.."_"..area.x2.."-"..area.y2;
		self.mapIcons[objID] = self:initialiseIcon(em_mapIconBase:new(), areaID, area, objID, "vanilla_areas");
		self.vanilla_areas_icons[objID] = self.mapIcons[objID];
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_areaIconGroup:getCustomAreaOverlays()
	self.custom_areas_icons = {};
	self.custom_areas = em_map.custom_areas;
	for areaID, area in pairs(self.custom_areas) do
		objID = areaID..area.x1.."-"..area.y1.."_"..area.x2.."-"..area.y2;
		self.mapIcons[objID] = self:initialiseIcon(em_mapIconBase:new(), areaID, area, objID, "custom_areas");
		self.custom_areas_icons[objID] = self.mapIcons[objID];
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_areaIconGroup:getCommunityAreaOverlays()
	self.communitymap_areas_icons = {};
	self.communitymap_areas = em_map.communitymap_areas;
	for areaID, area in pairs(self.communitymap_areas) do
		objID = areaID..area.x1.."-"..area.y1.."_"..area.x2.."-"..area.y2;
		self.mapIcons[objID] = self:initialiseIcon(em_mapIconBase:new(), areaID, area, objID, "communitymap_areas");
		self.communitymap_areas_icons[objID] = self.mapIcons[objID];
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_areaIconGroup:getNonPVPOverlays()
	self.nonpvp_areas = {};
	local nextArea;
	local area, areaID, objID;
	local nonPVP_areas = NonPvpZone.getAllZones();
	for i = 0, nonPVP_areas:size() - 1 do
		nextArea = nonPVP_areas:get(i);
		if nextArea then
			areaID = nextArea:getTitle();
			area = {
				x1 = nextArea:getX(), y1 = nextArea:getY(),
				x2 = nextArea:getX2(), y2 = nextArea:getY2(),
				r = 0, g = 0.8, b = 0, a = 0.2,
			};
			objID = areaID..area.x1.."-"..area.y1.."_"..area.x2.."-"..area.y2;
			self.mapIcons[objID] = self:initialiseIcon(em_mapIconBase:new(), areaID, area, objID, "nonPVP_areas");
			self.nonpvp_areas[objID] = self.mapIcons[objID];
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_areaIconGroup:initialise()
	self:getVanillaAreaOverlays();
	self:getCommunityAreaOverlays();
	self:getCustomAreaOverlays();
	self:getNonPVPOverlays();
	self:updateGroup();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_areaIconGroup:pre_initialise()
	self.drawIcons = self.mapIcons;
	self.buildings = {};
	self.roomSquares = {};
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------