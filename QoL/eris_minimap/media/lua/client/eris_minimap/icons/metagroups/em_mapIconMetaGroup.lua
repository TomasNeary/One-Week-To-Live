----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_mapIconMetaGroup
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_mapIconMetaGroup = {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- function em_mapIconMetaGroup:doIconSort()
	-- self.mapIcons = table.sort(self.drawIcons, function(a,b) return a.rect.y4 < b.rect.y4 end)
-- end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconMetaGroup:getNextIconToFollow()
	local icon = self.groups.localPlayerGroup.mapIcons["localPlayer" .. self.followIndex];
	if icon then self.followIndex = self.followIndex + 1; else self.followIndex = 1; end;
	return icon;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconMetaGroup:getMouseOverIcons(_size, _x, _y)
	local mouseOverIcons = {};
	local numIcons = 0;
	for groupID, group in pairs(self.groups) do
		numIcons = group:getMouseOverIcons(mouseOverIcons, numIcons, _size, _x, _y);
	end;
	return mouseOverIcons, numIcons;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconMetaGroup:render()
	for _, group in pairs(self.groups) do group:render(); end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconMetaGroup:addGroup(_group, _groupID)
	self.drawIcons[_groupID] = _group.drawIcons;
	self.groups[_groupID] = _group;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconMetaGroup:removeGroup(_groupID)
	self.groups[_groupID] = nil;
end


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconMetaGroup:updateTimeStamp(_updateTime)
	self.lastUpdateTime = self.updateTime;
	self.updateTime = _updateTime;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconMetaGroup:update(_updateTime)
	self:updateTimeStamp(_updateTime);
	if self.updateTick < self.updateTickMax then
		for _, group in pairs(self.groups) do group:update(_updateTime); end;
	else
		for _, group in pairs(self.groups) do group:updateGroup(_updateTime); end;
	end;
	self.updateTick = self.updateTick + 1; if self.updateTick > self.updateTickMax then self.updateTick = 1; end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconMetaGroup:initialise()
	local mapIconGroups = {
		localPlayerGroup = em_localPlayerIconGroup:new(),
		areaIconGroup = em_areaIconGroup:new(),
		worldObjectsGroup = em_worldObjectsGroup:new(),
		customMarkerGroup = em_customMarkerIconGroup:new(),
		safehouseGroup = em_safehouseIconGroup:new(),
		cellObjectGroup = em_cellObjectIconGroup:new(),
		radioPingGroup = em_radioPingIconGroup:new(),
	};
	local renderOrder = {
		[1] = {ID = "areaIconGroup", group = mapIconGroups.areaIconGroup},
		[2] = {ID = "worldObjectsGroup", group = mapIconGroups.worldObjectsGroup},
		[3] = {ID = "safehouseGroup", group = mapIconGroups.safehouseGroup},
		[4] = {ID = "cellObjectGroup", group = mapIconGroups.cellObjectGroup},
		[5] = {ID = "radioPingGroup", group = mapIconGroups.radioPingGroup},
		[6] = {ID = "customMarkerGroup", group = mapIconGroups.customMarkerGroup},
		[7] = {ID = "localPlayerGroup", group = mapIconGroups.localPlayerGroup},
	};
	for _, groupData in ipairs(renderOrder) do
		groupData.group:setGroupID(groupData.ID);
		groupData.group:pre_initialise();
		self:addGroup(groupData.group, groupData.ID);
	end;
	for groupID, group in pairs(mapIconGroups) do
		group.metaGroup = self;
		group:initialise();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_mapIconMetaGroup:new(_map, _minimap)
	local o = {};

	setmetatable(o, self)
	self.__index = self;

	o.map = _map;
	o.minimap = _minimap;

	o.groups = {};

	o.drawIcons = {};

	o.updateTick = 1;
	o.updateTickMax = 100;

	o.followIndex = 1;

	o.animationStep = 1;
	o.avatarAnimationStep = 1;
	o.animationStepMax = 30;

	o.updateTime = 0;
	o.lastUpdateTime = 0;

	return o;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------