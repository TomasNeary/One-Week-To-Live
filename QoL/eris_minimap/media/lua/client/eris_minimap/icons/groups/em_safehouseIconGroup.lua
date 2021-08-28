----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_safehouseIconGroup
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require("em_mapIconGroupBase");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_safehouseIconGroup = em_mapIconGroupBase:new();

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_safehouseIconGroup:updateResidents(_obj)
	local members = {};
	for i = 0, _obj:getPlayers():size()-1 do
		table.insert(members, _obj:getPlayers():get(i));
	end;
	return members;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_safehouseIconGroup:updateGroup(_updateTime)
	if em_core.clientMode then
		self.playerHomes = {};
		self.drawIcons = {};
		local mapIcon;
		local obj, objID;
		local x, y, w, h;
		local map_settings = em_settings.map_settings;
		local context_settings = em_settings.context_settings;
		local safehouseList = SafeHouse.getSafehouseList();
		for plID, plIcon in pairs(self.playerIcons) do
			for i = 0, safehouseList:size() - 1 do
				obj = safehouseList:get(i);
				w, h = obj:getW(), obj:getH()
				x, y = obj:getX() + (w / 2), obj:getY() + (h / 2);
				objID = "safehouse" .. x .."x" .. y;
				self.mapIcons[objID] = self:initialiseIcon(em_mapIconBase:new(), obj, obj:playerAllowed(plIcon.obj), plIcon);
				if context_settings.ownSafehouseToggle.enabled then
					if obj:playerAllowed(plIcon.obj) or em_core.adminMode then
						self.playerHomes[objID] = self.mapIcons[objID];
						self.mapIcons[objID].iconSize = 24 + map_settings.safehouseIconSize;
						self.mapIcons[objID]:setColor(plIcon:getColor());
						self.drawIcons[objID] = self.mapIcons[objID];
					end;
				end;
			end;
		end;
		self:update(_updateTime);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_safehouseIconGroup:update(_updateTime)
	if em_core.clientMode then
		local map_settings = em_settings.map_settings;
		local context_settings = em_settings.context_settings;
		for plID, plIcon in pairs(self.playerIcons) do
			for iconID, icon in pairs(self.mapIcons) do
				if context_settings.otherSafehouseToggle.enabled then
					if not icon.obj:playerAllowed(plIcon.obj) and self:getDistance2D(plIcon.x, plIcon.y, icon.x, icon.y) <= icon.maxViewDist then
						icon:updateTimeStamp(_updateTime);
						icon.iconSize = 8 + map_settings.safehouseIconSize;
						self.drawIcons[iconID] = icon;
					end;
				end;
			end;
		end;
		for iconID, icon in pairs(self.drawIcons) do
			self:doIconTransform(icon);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_safehouseIconGroup:render()
	self:renderIcons();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_safehouseIconGroup:initialiseIcon(_icon, _obj, _permitted, _permIcon)
	local colorSet = em_settings.color_settings;
	local settingPerm = colorSet.ownSafehouse;
	local settingNoPerm = colorSet.otherSafehouse;
	local x, y = _obj:getX() + (_obj:getW() / 2), _obj:getY() + (_obj:getH() / 2);
	_icon:setObj(_obj);
	_icon:setClass("Safehouse");
	_icon.iconID = _icon.class .. x .."x" .. y;
	if _permitted then
		if settingPerm.enabled then
			_icon:setColor(settingPerm.color.r, settingPerm.color.g, settingPerm.color.b, settingPerm.color.a);
		else
			_icon:setColor(_permIcon:getColor());
		end;
	else
		if settingNoPerm.enabled then
			_icon:setColor(settingNoPerm.color.r, settingNoPerm.color.g, settingNoPerm.color.b, settingNoPerm.color.a);
		else
			_icon:setColor(1,1,1,1);
		end;
	end;
	_icon:setLocation(x, y);
	_icon.owner = _obj:getOwner();
	_icon.title = _obj:getTitle();
	_icon.iconData = _icon.owner .. " - " .. _icon.title;
	_icon.iconDataExt = math.floor(x) .. "," .. math.floor(y);
	_icon.iconTexture = self.mapIconTex["house_icon"];
	_icon.iconTextureExt = "house_icon";
	_icon.maxViewDist = 100;
	_icon.members = self:updateResidents(_obj);
	_icon.shBounds = {};
	_icon.shBounds.x1 = _obj:getX();
	_icon.shBounds.y1 = _obj:getY();
	_icon.shBounds.x2 = _icon.shBounds.x1 + _obj:getW();
	_icon.shBounds.y2 = _icon.shBounds.y1 + _obj:getH();
	return _icon;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_safehouseIconGroup:initialise()
	self.playerIcons = self.metaGroup.groups.localPlayerGroup.drawIcons;
	self:updateGroup();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_safehouseIconGroup:pre_initialise()
	self.playerHomes = {};
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------