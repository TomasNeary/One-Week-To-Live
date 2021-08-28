----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_mapIconGroupBase
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require "em_mapIconBase";

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_mapIconGroupBase = {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_mapIconGroupBase.arrowTex = { 
	N = getTexture("media/textures/arrow/arrow_N.png"),
	NE = getTexture("media/textures/arrow/arrow_NE.png"),
	NW = getTexture("media/textures/arrow/arrow_NW.png"),
	S = getTexture("media/textures/arrow/arrow_S.png"),
	SE = getTexture("media/textures/arrow/arrow_SE.png"),
	SW = getTexture("media/textures/arrow/arrow_SW.png"),
	E = getTexture("media/textures/arrow/arrow_E.png"),
	W = getTexture("media/textures/arrow/arrow_W.png"),
	player_circle = getTexture("media/textures/arrow/player_circle.png"),
	override = getTexture("media/textures/arrow/override.png"),
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_mapIconGroupBase.mapIconTex = { 
	map_worldArea_inner = getTexture("media/textures/icons/map_worldArea_inner.png"),
	map_worldArea = getTexture("media/textures/icons/map_worldArea.png"),
	house_icon = getTexture("media/textures/icons/home.png"),
	vehicle_icon = getTexture("media/textures/icons/car.png"),
	flag_icon = getTexture("media/textures/icons/map_flag.png"),
	flag_icon_tall = getTexture("media/textures/icons/map_flag_tall.png"),
	flag_icon_large = getTexture("media/textures/icons/map_flag_large.png"),
	pin_icon = getTexture("media/textures/icons/map_pin.png"),
	pin_icon_medium = getTexture("media/textures/icons/map_pin_medium.png"),
	pin_icon_large = getTexture("media/textures/icons/map_pin_large.png"),
	mapHighlight = getTexture("media/textures/icons/map_highlight.png"),
	radio_icon_on = getTexture("media/textures/icons/radio_icon_on.png"),
	radio_icon_off = getTexture("media/textures/icons/radio_icon_off.png"),
	danger_icon = getTexture("media/textures/icons/danger_icon.png"),
	fuel_icon = getTexture("media/textures/icons/fuel_icon.png"),
	electric_icon = getTexture("media/textures/icons/electric_icon.png"),
	ammo_icon = getTexture("media/textures/icons/ammo_icon.png"),
	car_icon = getTexture("media/textures/icons/car_icon.png"),
	car_icon_on = getTexture("media/textures/icons/car_icon_on.png"),
	dot_icon = getTexture("media/textures/icons/dot_icon.png"),
	dot_icon_small = getTexture("media/textures/icons/dot_icon_small.png"),
	player_circle = getTexture("media/textures/icons/player_circle.png"),
	radio_player_icon_1 = getTexture("media/textures/icons/radio_player_icon_1.png"),
	radio_player_icon_2 = getTexture("media/textures/icons/radio_player_icon_2.png"),
	radio_player_icon_3 = getTexture("media/textures/icons/radio_player_icon_3.png"),
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:isInRect(_x, _y, _tlX, _tlY, _brX, _brY)
	return _x >= _tlX and _y >= _tlY and _x <= _brX and _y <= _brY;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:getAngleOffset2D(_angle1, _angle2)
	return 180 - math.abs(math.abs(_angle1 - _angle2) - 180);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:getAngle2D(_x1, _y1, _x2, _y2)
	local angle = math.atan2(_x1 - _x2, -(_y1 - _y2));
	if angle < 0 then angle = math.abs(angle) else angle = 2 * math.pi - angle end;
	return math.deg(angle);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:getDistance2D(_x1, _y1, _x2, _y2)
	return math.sqrt(math.abs(_x2 - _x1)^2 + math.abs(_y2 - _y1)^2);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:doFadeOut(_icon, _fadeStep)
	if _icon.a > 0 then
		_icon.a = _icon.a - (_fadeStep);
		if _icon.a < 0 then _icon.a = 0; end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:doFadeIn(_icon, _fadeStep)
	if _icon.a < 1 then
		_icon.a = _icon.a + _fadeStep;
		if _icon.a > 1 then _icon.a = 1; end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:deferPreCheck(_icon)
	local deferred = _icon.deferred;
	if deferred then
		if deferred.tick == 1 then
			deferred.deferring = false;
			deferred.tick = deferred.tick + 1;
		else
			deferred.tick = deferred.tick + 1;
			if deferred.tick > deferred.rate then
				deferred.tick = 1;
				deferred.deferring = false;
			end;
		end;
		return deferred.deferring;
	end;
	return false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:deferPostCheck(_icon, _seen, _precheck)
	local deferred = _icon.deferred;
	if deferred and not _precheck then
		deferred.seen = _seen;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:checkVehicleOccupied(_vehObj, _thisPlayer)
	local vehPlayers = false;
	local vehLocalPlayers = false;
	local passenger;
	for i = 0, _vehObj:getMaxPassengers() - 1 do
		passenger = _vehObj:getCharacter(i);
		if passenger then 
			vehPlayers = true;
			if passenger:isLocalPlayer() then
				if _thisPlayer.username == passenger:getUsername() then
					vehLocalPlayers = true;
				end;
			end;
		end;
	end;
	return vehPlayers, vehLocalPlayers;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:canSee2D(_icon1, _icon2, _isOutside)
	if em_pluginsettings.radarMode then return true; end;
	local seen, precheck = false, false;
	if self:deferPreCheck(_icon2) then
		seen = _icon2.deferred.seen;
		precheck = true;
	else
		local x1, y1 = _icon1.x, _icon1.y;
		local x2, y2 = _icon2.x, _icon2.y;
		local obj1, obj2 = _icon1:getObj(), _icon2:getObj();
		local minVD_outside = math.max(_icon1.minViewDist, _icon2.minViewDist);
		local maxVD_outSide = math.max(_icon1.maxViewDist, _icon2.maxViewDist);
		local minVD_inside = minVD_outside / 1.7;
		local maxVD_inside = maxVD_outSide / 1.7;
		local minVD = (_icon1.isOutside and minVD_outside or minVD_inside) + _icon1.minViewDistBonus;
		local maxVD = (_icon1.isOutside and maxVD_outSide or maxVD_inside) - (_icon1.panicAmountOffset / 2) + _icon1.maxViewDistBonus;
		local maxViewAngle = _icon2.maxViewAngle - _icon1.panicAmountOffset;
		local objDist = self:getDistance2D(x1, y1, x2, y2);
		if objDist <= maxVD then
			if objDist <= minVD then
				seen = true;
			else
				if _icon1.isAtHome then
					seen = true; 
				else
					if obj1:CanSee(obj2) then
						local objAngle1;
						if em_core.IWBUMS then
							objAngle1 = math.deg(obj1:getLastAngle():getDirection());
							print(objAngle1);
							if objAngle1 > 180 then
								objAngle1 = objAngle1 + 180;
							end;
						else
							objAngle1 = math.deg(obj1:getLastAngle():getDirection()) + 180;
						end;
						local objAngle2 = self:getAngle2D(x2, y2, x1, y1);
						if self:getAngleOffset2D(objAngle1, objAngle2) <= maxViewAngle then
							seen = true;
						end;
					end;
				end;
			end;
		end;
	end;
	self:deferPostCheck(_icon2, seen, precheck);
	return seen;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:rotateDirection(_direction)
	if em_settings.map_settings.viewMode > 1 then
		if _direction == "player_circle" then return _direction; end;
		if _direction == "N" then return "NE"; end;
		if _direction == "NE" then return "E"; end;
		if _direction == "E" then return "SE"; end;
		if _direction == "SE" then return "S"; end;
		if _direction == "S" then return "SW"; end;
		if _direction == "SW" then return "W"; end;
		if _direction == "W" then return "NW"; end;
		if _direction == "NW" then return "N"; end;
	else
		return _direction;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--     0  = E  = -22.5 - 22.5
--    45  = SE = 22.5 - 67.5
--    90  = S  = 67.5 - 112.5
--   135  = SW = 112.5 - 157.5


--  -135  = NW = -112.5 - -157.5
--  -90   = N  = -67.5 - -112.5
--  -45  =  NE = -22.5 - -67.5

--   180  = W  = 157.5 - -157.5

function em_mapIconGroupBase:getDirectionFromAngle(_angle)
	local angle = _angle;

	if _angle >= -22.5 and _angle <= 22.499 then return "E"; end;
	if _angle >= 22.5 and _angle <= 67.499 then return "SE"; end;
	if _angle >= 67.5 and _angle <= 112.499 then return "S"; end;
	if _angle >= 112.5 and _angle <= 157.499 then return "SW"; end;

	if _angle <= -112.5 and _angle >= -157.499 then return "NW"; end;
	if _angle <= -67.5 and _angle >= -112.499 then return "N"; end;
	if _angle <= -22.5 and _angle >= -67.499 then return "NE"; end;

	if _angle >= 157.5 or _angle <= -157.5 then return "W"; end;

	return "player_circle";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- function em_mapIconGroupBase:getFacingDirection(_obj)
	-- local direction = "player_circle";
	-- local lastDir = _obj.getLastdir;
	-- local dirAngle = _obj.getDirectionAngle;
	-- if lastDir then
		-- direction = lastDir(_obj):toString() or direction;
	-- elseif dirAngle then
		-- direction = self:getDirectionFromAngle(dirAngle(_obj)) or direction;
	-- end;
	-- return self:rotateDirection(direction);
-- end

function em_mapIconGroupBase:getFacingDirection(_obj)
	local direction = "player_circle";
	if em_core.IWBUMS then
		direction = self:getDirectionFromAngle(_obj:getDirectionAngle()) or direction;
	else
		local lastDir = _obj:getLastdir();
		direction = lastDir and lastDir:toString() or direction;
	end;
	return self:rotateDirection(direction);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:generateProfessionTable()
	self.professionTable = {};
	for i = 0, ProfessionFactory.getProfessions():size() - 1 do
		local profObj = ProfessionFactory.getProfessions():get(i);
		if profObj then
			self.professionTable[profObj:getType()] = profObj:getName();
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:getProfessionName(_descriptor)
	local profName;
	if _descriptor then
		local prof = _descriptor:getProfession();
		if prof then
			profName = self.professionTable[prof];
		end;
	end;
	return profName or "Unknown Profession";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:getPlayerColor(_obj)
	local speakColor = _obj:getSpeakColour();
	local colorTable = {
			r = (speakColor:getRedByte() / 255) or 1,
			g = (speakColor:getGreenByte() / 255) or 1,
			b = (speakColor:getBlueByte() / 255) or 1,
			a = 1,
		};
	return colorTable.r, colorTable.g, colorTable.b, colorTable.a;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:getFactionTag(_icon)
	local factionTag;
	local factionObj = Faction.getPlayerFaction(_icon.obj);
	if _faction then factionTag = "[".._faction:getTag().."] "; end;
	return factionTag or "";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:getVehicleRadio(_vehObj)
	if _vehObj then
		local partObj;
		for i = 0, _vehObj:getPartCount() - 1 do
			partObj = _vehObj:getPartByIndex(i);
			if partObj then
				local devdataObj = partObj:getDeviceData();
				local partItemObj = partObj:getInventoryItem();
				if devdataObj and partItemObj then
					return partObj, partItemObj;
				end;
			end;
		end;
	end;
	return nil, nil;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:getRadios(_icon)
	_icon.radios = {};
	local locations = {
		primary = _icon.obj:getPrimaryHandItem(),
		secondary = _icon.obj:getSecondaryHandItem(),
	};
	for locationID, obj in pairs(locations) do
		if obj then
			local objType = obj:getType();
			if em_radio.validRadios[objType] then
				local radio = {
					user = _icon.username,
					radioID = _icon.username .. " - " .. locationID,
					class = objType,
					deviceData = obj:getDeviceData(),
					mode = {tx = false, rx = false},
					scanner = false,
					scannerEnabled = false,
					batteryLevel = math.floor(obj:getDeviceData():getPower() * 100) / 100,
					channel = obj:getDeviceData():getChannel(),
					range = obj:getDeviceData():getTransmitRange(),
					r = _icon.r,
					g = _icon.g,
					b = _icon.b,
					a = _icon.a,
				};
				local isTurnedOn = radio.deviceData:getIsTurnedOn() and (radio.deviceData:getPower() > 0 or radio.deviceData:canBePoweredHere());
				local isTuned = radio.deviceData:getChannel() or false;
				local isReceiving = radio.deviceData:getDeviceVolume() > 0 or false;
				local isTransmitting = radio.deviceData:getIsTwoWay() and not radio.deviceData:getMicIsMuted() or false;
				local isCapable = isReceiving or isTransmitting;
				if isTurnedOn and isTuned and isCapable then
					if isReceiving then radio.mode.rx = true; end;
					if isTransmitting then radio.mode.tx = true; end;
					_icon.radios[locationID] = radio;
				end;
			end;
		end;
	end;
	local vehRadio, vehRadioItem = self:getVehicleRadio(_icon.obj:getVehicle());
	if vehRadio and vehRadioItem then
		local itemDevData = vehRadioItem:getDeviceData();
		local radio = {
			user = _icon.username,
			radioID = _icon.username .. " - vehRadio",
			class = "vehRadio",
			deviceData = vehRadio:getDeviceData(),
			mode = {tx = false, rx = false};
			scanner = false,
			scannerEnabled = false,
			batteryLevel = 100,
			channel = vehRadio:getDeviceData():getChannel(),
			range = itemDevData:getTransmitRange(),
			r = _icon.r,
			g = _icon.g,
			b = _icon.b,
			a = _icon.a,
		};
		local isTurnedOn = radio.deviceData:getIsTurnedOn() and (radio.deviceData:getPower() > 0 or radio.deviceData:canBePoweredHere());
		local isTuned = radio.deviceData:getChannel() or false;
		local isReceiving = radio.deviceData:getDeviceVolume() > 0 or false;
		local isTransmitting = itemDevData:getIsTwoWay() or false;
		local isCapable = isReceiving or isTransmitting;
		if isTurnedOn and isTuned and isCapable then
			if isReceiving then radio.mode.rx = true; end;
			if isTransmitting then radio.mode.tx = true; end;
			_icon.radios["vehRadio"] = radio;
		end;
	end;
	local total_transponders = 0;
	local max_transponders = 3;
	for transponderID, _ in pairs(em_personal_beacon.transponders) do
		local transponders = _icon.obj:getInventory():getItemsFromType(transponderID);
		for i = 0, transponders:size() - 1 do
			local transponder = transponders:get(i);
			total_transponders = total_transponders + 1;
			if not transponder:getModData()["initialised"] then
				em_personal_beacon.initialiseItem(transponder);
			end;
			transponder:setUsedDelta(transponder:getModData()["battery"] / 100000);
			local radio = {
				user = _icon.username,
				radioID = _icon.username .. " - " .. transponderID,
				class = "transponder",
				mode = {tx = true, rx = true},
				scanner = transponder:getModData()["scanner"],
				scannerEnabled = transponder:getModData()["scannerEnabled"],
				batteryLevel = math.floor(((transponder:getModData()["battery"] / 1000) * 100)) / 100,
				channel = transponder:getModData()["channel"],
				range = transponder:getModData()["range"],
				transponder = transponder,
				r = _icon.r,
				g = _icon.g,
				b = _icon.b,
				a = _icon.a,
			};
			if transponder:getModData()["battery"] == 0 then
				radio.mode.tx = false;
				radio.mode.rx = false;
			end;
			if total_transponders <= max_transponders then
				_icon.radios[transponderID .."-"..i] = radio;
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:isMatchingFactionTags(_icon1, _icon2)
	return _icon1.factionTag ~= "" and _icon2.factionTag ~= "" and _icon1.factionTag == _icon2.factionTag;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:getVehicleColor(_obj)
	local colorKey = _obj:createVehicleKey();
	local colorTable = {r = 0.5, g = 0.5, b = 0.5, a = 0.9};
	if colorKey then 
		colorTable.r = colorKey:getR();
		colorTable.g = colorKey:getG();
		colorTable.b = colorKey:getB();
	end;
	return colorTable.r, colorTable.g, colorTable.b, colorTable.a;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:getVehicleName(_obj)
	local vehName = "Unknown Vehicle";
	local vehScriptName = _obj:getScript():getName();
	if string.match(vehScriptName, "Burnt") then
		vehName = "Destroyed Vehicle";
	else
		vehName = getTextOrNull("IGUI_VehicleName" .. vehScriptName) or vehName;
	end;
	return vehName;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:doIconTransform(_icon)
	local map = em_core.map;
	local mapTransform = map.transforms.mapTransform;
	local scaleTransform = map.transforms.scale;
	local drawPosX, drawPosY = mapTransform(-(map.vpCenterXInWorld - _icon.x), -(map.vpCenterYInWorld - _icon.y));
	local size = _icon.iconSize and _icon.iconSize / 2 or self.iconSize / 2;
	if _icon.mapScale then size, size = scaleTransform(size, size); end;
	_icon.rect.x1, _icon.rect.y1 = drawPosX - size, drawPosY - size;
	_icon.rect.x2, _icon.rect.y2 = drawPosX + size, drawPosY - size;
	_icon.rect.x3, _icon.rect.y3 = drawPosX - size, drawPosY + size;
	_icon.rect.x4, _icon.rect.y4 = drawPosX + size, drawPosY + size;
	_icon.dpX, _icon.dpY = drawPosX, drawPosY;
	_icon.textX, _icon.textY = _icon.dpX - em_core.window:getAbsoluteX(), _icon.dpY - (size * 3) - em_core.window:getAbsoluteY();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:doMapTransform(_transform, _drawX, _drawY, _size)
	local rect = {};
	local map = em_core.map;
	local mapTransform = map.transforms.mapTransform;
	rect.x1, rect.y1 = mapTransform(_drawX, _drawY);
	rect.x2, rect.y2 = mapTransform(_drawX + _size, _drawY);
	rect.x3, rect.y3 = mapTransform(_drawX, _drawY + _size);
	rect.x4, rect.y4 = mapTransform(_drawX + _size, _drawY + _size);
	return rect;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:doOverlayTransform(_icon)
	local map = em_core.map;
	local mapTransform = map.transforms.mapTransform;
	local imapTransform = map.transforms.imapTransform;
	_icon.rect.x1, _icon.rect.y1 = mapTransform(-(map.vpCenterXInWorld - _icon.bounds.x1), -(map.vpCenterYInWorld - _icon.bounds.y1));
	_icon.rect.x2, _icon.rect.y2 = mapTransform(-(map.vpCenterXInWorld - _icon.bounds.x2), -(map.vpCenterYInWorld - _icon.bounds.y2));
	_icon.rect.x3, _icon.rect.y3 = mapTransform(-(map.vpCenterXInWorld - _icon.bounds.x3), -(map.vpCenterYInWorld - _icon.bounds.y3));
	_icon.rect.x4, _icon.rect.y4 = mapTransform(-(map.vpCenterXInWorld - _icon.bounds.x4), -(map.vpCenterYInWorld - _icon.bounds.y4));
	_icon.dpX, _icon.dpY = mapTransform(-(map.vpCenterXInWorld - _icon.bounds.centerX), -(map.vpCenterYInWorld - _icon.bounds.centerY));
	_icon.textX, _icon.textY = _icon.dpX - em_core.window:getAbsoluteX(), _icon.dpY - em_core.window:getAbsoluteY();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:renderEffects()
	local drawTexture = em_core.minimap.drawTextureAllPoint;
	for effectID, effect in pairs(self.effects) do
		drawTexture(em_core.minimap, effect.iconTexture,
		effect.rect.x1, effect.rect.y1, effect.rect.x2, effect.rect.y2, effect.rect.x4, effect.rect.y4, effect.rect.x3, effect.rect.y3,
		effect.r, effect.g, effect.b, effect.a);
		effect:update();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:renderIcons()
	local drawTexture = em_core.minimap.drawTextureAllPoint;
	for iconID, icon in pairs(self.drawIcons) do
		drawTexture(em_core.minimap, icon.iconTexture,
		icon.rect.x1, icon.rect.y1, icon.rect.x2, icon.rect.y2, icon.rect.x4, icon.rect.y4, icon.rect.x3, icon.rect.y3,
		icon.r, icon.g, icon.b, icon.a);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:render()
	self:renderIcons();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:getMouseOverIcons(_mouseOverIcons, _numIcons, _size, _x, _y)
	_mouseOverIcons[self.groupID] = {};
	for iconID, icon in pairs(self.drawIcons) do
		if self:isInRect(_x, _y, icon.x - _size, icon.y - _size, icon.x + _size, icon.y + _size) then
			_mouseOverIcons[self.groupID][iconID] = icon;
			_numIcons = _numIcons + 1;
		end;
	end;
	return _numIcons;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:getNextIcon()
	if self.selected > #self.drawIcons then
		self.selected = 1;
		return nil;
	else
		self.selected = self.selected + 1;
		return self.drawIcons[self.selected - 1];
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:setGroupID(_groupID)
	self.groupID = _groupID;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconGroupBase:new()
	local o = {};

	setmetatable(o, self)

	o.map = nil;
	o.minimap = nil;

	o.effects = {};

	o.drawIcons = {};

	o.mapIcons = {};

	o.selected = 1;

	o.iconSize = 24;

	return o;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------