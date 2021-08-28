----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_localPlayerIconGroup
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require("em_mapIconGroupBase");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_localPlayerIconGroup = em_mapIconGroupBase:new();

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_localPlayerIconGroup:renderText()
	local drawTextCentre = em_core.minimap.drawTextCentre;
	local colorset = em_settings.color_settings.localplayerTitle;
	local r, g, b, a = 1, 1, 1, 1;
	if colorset and colorset.enabled then
		r, g, b, a = colorset.color.r, colorset.color.g, colorset.color.b, colorset.color.a;
	end;
	for iconID, icon in pairs(self.drawIcons) do
		if not colorset.enabled then
			r, g, b, a = icon.r, icon.g, icon.b, icon.a;
		end;
		if icon.doRenderText then
			drawTextCentre(
				em_core.window,
				icon.iconData,
				icon.textX + 1, icon.textY + (icon.iconSize / 2) + 1,
				0, 0, 0, a,
				UIFont.NewMedium
			);
			drawTextCentre(
				em_core.window,
				icon.iconData,
				icon.textX, icon.textY + (icon.iconSize / 2),
				r, g, b, a,
				UIFont.NewMedium
			);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_localPlayerIconGroup:render()
	self:renderTargetLines();
	self:renderIcons();
	self:renderText();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_localPlayerIconGroup:doTargetTransform(_target)
	local map = em_core.map;
	local mapTransform = map.transforms.mapTransform;
	local scaleTransform = map.transforms.scale;
	local drawPosX, drawPosY = mapTransform(-(map.vpCenterXInWorld - _target.x), -(map.vpCenterYInWorld - _target.y));
	_target.dpX, _target.dpY = drawPosX, drawPosY;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_localPlayerIconGroup:doTargetLines()
	local zoomLevel = em_settings.map_settings.zoomLevel;
	self.targetLines = {};
	local target = em_core.minimap:getTarget();
	if target then
		local rotationXY;
		local x, y;
		local x1, y1, x2, y2;
		for iconID, icon in pairs(self.mapIcons) do
			self:doTargetTransform(target);
			rotationXY = math.rad(em_mapIconGroupBase.getAngle2D(nil, icon.dpX, icon.dpY, target.dpX, target.dpY));
			x, y = em_core.map:rotateXY(icon.x - (8 / zoomLevel), icon.y, icon.x, icon.y, -rotationXY)
			local xy1 = {x = x, y = y};
			x, y = em_core.map:rotateXY(icon.x + (8 / zoomLevel), icon.y, icon.x, icon.y, -rotationXY)
			local xy2 = {x = x, y = y};
			x, y = em_core.map:rotateXY(target.x - (2 / zoomLevel), target.y, target.x, target.y, rotationXY)
			local xy3 = {x = x, y = y};
			x, y = em_core.map:rotateXY(target.x + (2 / zoomLevel), target.y, target.x, target.y, rotationXY)
			local xy4 = {x = x, y = y};
			self:doTargetTransform(xy1);
			self:doTargetTransform(xy2);
			self:doTargetTransform(xy3);
			self:doTargetTransform(xy4);
			self.targetLines[iconID] = {
				x1 = xy1.dpX, y1 = xy1.dpY,
				x2 = xy2.dpX, y2 = xy2.dpY,
				x3 = xy3.dpX, y3 = xy3.dpY,
				x4 = xy4.dpX, y4 = xy4.dpY,
				r = icon.r,
				g = icon.g,
				b = icon.b,
				a = 0.7,
			};
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_localPlayerIconGroup:renderTargetLines()
	local drawTexture = em_core.minimap.drawTextureAllPoint;
	for lineID, line in pairs(self.targetLines) do
		drawTexture(
			em_core.minimap, nil,
			line.x1, line.y1, line.x2, line.y2,
			line.x4, line.y4, line.x3, line.y3,
			line.r, line.g, line.b, line.a
		);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_localPlayerIconGroup:updateGroup(_updateTime)
	if em_pluginsettings.disableLocalPlayers then return; end;
	self.drawIcons = {};
	if not em_settings.context_settings.localplayerToggle.enabled then return; end;
	local IsoPlayerList = IsoPlayer.getPlayers();
	for i = 0, IsoPlayerList:size() - 1 do
		local obj = IsoPlayerList:get(i);
		if obj then
			local ID = "localPlayer" .. (i + 1);
			if not self.mapIcons[ID] then
				local mapIcon = em_mapIconBase:new();
				self:initialiseIcon(mapIcon, obj);
				self.mapIcons[ID] = mapIcon;
			end;
			self:updateHomes(self.mapIcons[ID]);
		end;
	end;
	self:update(_updateTime);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_localPlayerIconGroup:update(_updateTime)
	if em_pluginsettings.disableLocalPlayers then return; end;
	local map_settings = em_settings.map_settings;
	local context_settings = em_settings.context_settings;
	if context_settings.localplayerToggle.enabled then
		self.drawIcons = self.mapIcons;
	else
		self.drawIcons = {};
		return;
	end;
	for iconID, icon in pairs(self.mapIcons) do
		icon:updateTimeStamp(_updateTime);
		icon:updateLocation();
		icon.direction = self:getFacingDirection(icon.obj);
		icon.iconTexture = self.arrowTex[icon.direction];
		icon.iconSize = 24 + map_settings.playerIconSize;
		icon.cellObjects = icon.obj:getCell():getObjectList();
		icon.iconDataExt = em_translationData.label_survival_time .. icon.obj:getTimeSurvived();
		self:doEquipmentStats(icon);
		self:doPanicStats(icon);
		icon.isOutside = icon.obj:isOutside();
		self:doIconTransform(icon);
		self:doTargetLines();
		if not icon.obj:getVehicle() then 
			self.drawIcons[iconID] = icon;
			if context_settings.localplayerTitle.enabled then
				icon.doRenderText = true;
			else
				icon.doRenderText = false;
			end;
		else
			icon.doRenderText = false;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------doEquipmentStats

function em_localPlayerIconGroup:doEquipmentStats(_icon)
	local locations = {
		primary = _icon.obj:getPrimaryHandItem(),
		secondary = _icon.obj:getSecondaryHandItem(),
	};
	local minRange, maxRange = 0, 0;
	for locationID, obj in pairs(locations) do
		if obj then
			local objType = obj:getType();
			local objCat = obj:getCategory();
			if objType == "binoculars" and _icon.obj:isAiming() then
				minRange = math.max(minRange, 0);
				maxRange = math.max(maxRange, 50);
			elseif objCat == "Weapon" and _icon.obj:isAiming() then
				if obj:isRanged() and obj:getScope() then
					minRange = math.max(minRange, obj:getMinRange());
					maxRange = math.max(maxRange, obj:getMaxRange());
				end;
			end;
		end;
	end;
	_icon.minViewDistBonus = minRange;
	_icon.maxViewDistBonus = maxRange;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------doPanicStats

function em_localPlayerIconGroup:doPanicStats(_icon)
	_icon.panicAmountOffset = 45 - (((100 - _icon.stats:getPanic()) / 100) * 45) or 0;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------doTraitStats

function em_localPlayerIconGroup:doTraitStats(_icon, _obj)
	local Blind, ShortSighted, EagleEyed = _obj:HasTrait("Blind"), _obj:HasTrait("ShortSighted"), _obj:HasTrait("EagleEyed");
	local Deaf, HardOfHearing, KeenHearing = _obj:HasTrait("Deaf"), _obj:HasTrait("HardOfHearing"), _obj:HasTrait("KeenHearing");
	local sight = Blind and 0 or ShortSighted and 20 or EagleEyed and 50 or 40;
	local hearing = Deaf and 0 or HardOfHearing and 1 or KeenHearing and 7 or 5;
	_icon.minViewDist = math.max(hearing, EagleEyed and 5 or ShortSighted and 7 or hearing);
	_icon.maxViewDist = sight;
	_icon.minViewDistBonus = 0;
	_icon.maxViewDistBonus = 0;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_localPlayerIconGroup:updateHomes(_icon)
	local safehouseGroup = self.metaGroup.groups.safehouseGroup;
	if safehouseGroup then
		local playerHomes = safehouseGroup.playerHomes;
		for iconID, icon in pairs(playerHomes) do
			if icon.obj:playerAllowed(_icon.obj) then
				_icon.cohabitants = {};
				for _, member in ipairs(icon.members) do _icon.cohabitants[member] = member; end;
				if self:isInRect(_icon.x, _icon.y, icon.shBounds.x1, icon.shBounds.y1, icon.shBounds.x2, icon.shBounds.y2) then
					_icon.isAtHome = true;
					return;
				end;
			end;
		end;
	end;
	_icon.isAtHome = false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_localPlayerIconGroup:initialiseIcon(_icon, _obj)
	_icon:setObj(_obj);
	_icon:setClass("localPlayer");
	_icon.iconID = _icon.class .. _obj:getPlayerNum();
	local colorSet = em_settings.color_settings[_icon.iconID];
	if colorSet and colorSet.enabled then
		_icon:setColor(colorSet.color.r,colorSet.color.g,colorSet.color.b,colorSet.color.a);
	else
		_icon:setColor(self:getPlayerColor(_obj));
	end;
	_icon.username = _obj:getUsername();
	_icon.factionTag = self:getFactionTag(_icon);
	_icon.iconData = _icon.factionTag .. _icon.username;
	_icon.descriptor = _obj:getDescriptor();
	_icon.profName = self:getProfessionName(_icon.descriptor);
	_icon.cell = _obj:getCell();
	_icon.cellObjects = _icon.cell:getObjectList();
	self:doTraitStats(_icon, _obj)
	_icon.stats = _obj:getStats();
	_icon.panicAmountOffset = 0;
	_icon.radios = {};
	_icon.isAtHome = false;
	_icon.cohabitants = {};
	_icon.isOutside = _icon.obj:isOutside();
	_icon.doRenderText = false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_localPlayerIconGroup:initialise()
	self:updateGroup();
	em_radio.initialise(self);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_localPlayerIconGroup:pre_initialise()
	self.targetLines = {};
	self:generateProfessionTable();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------