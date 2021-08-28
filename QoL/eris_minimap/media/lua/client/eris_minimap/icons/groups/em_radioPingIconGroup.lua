----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_radioPingIconGroup
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require("em_mapIconGroupBase");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_radioPingIconGroup = em_mapIconGroupBase:new();

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioPingIconGroup:updateGroup()
	self.drawIcons = {};
	for beaconID, beacon in pairs(self.radioPings.localPings) do
		if not self.mapIcons[beaconID] then
			self.mapIcons[beaconID] = self:initialiseIcon(em_mapIconBase:new(), beacon, true);
		end;
		self.mapIcons[beaconID]:updateLocation(beacon.x, beacon.y);
		self.drawIcons[beaconID] = self.mapIcons[beaconID];
	end;
	for beaconID, beacon in pairs(self.radioPings.remotePings) do
		if not self.nearbyPlayers[beacon.username] then
			if not self.mapIcons[beaconID] then
				self.mapIcons[beaconID] = self:initialiseIcon(em_mapIconBase:new(), beacon, false);
			end;
			self.mapIcons[beaconID]:updateLocation(beacon.x, beacon.y);
			self.drawIcons[beaconID] = self.mapIcons[beaconID];
		end;
	end;
	self:update();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioPingIconGroup:update()
	if em_settings.context_settings["radioToggle"].enabled then
		em_radio.update();
		for iconID, icon in pairs(self.drawIcons) do
			icon:updateTimeStamp(_updateTime);
			icon.iconTexture = self.mapIconTex["radio_player_icon_" .. self.animationStep];
			self:doIconTransform(icon);
		end;
	end;
	self.animationStep = self.animationStep + 1;
	if self.animationStep > 3 then self.animationStep = 1; end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioPingIconGroup:initialiseIcon(_icon, _beacon, _local)
	_icon:setObj(nil);
	_icon:setClass("radioPing");
	_icon.iconID = _beacon.beaconID;
	_icon:updateLocation(_beacon.x, _beacon.y);
	if _local then
		_icon:setColor(_beacon.r,_beacon.g,_beacon.b,0.5);
		_icon.iconData = em_translationData.label_last_broadcast .. _beacon.iconData;
	else
		_icon:setColor(_beacon.r,_beacon.g,_beacon.b,_beacon.a);
		_icon.iconData = _beacon.iconData;
	end
	_icon.iconDataExt = _beacon.iconDataExt;
	_icon.iconTexture = self.mapIconTex["radio_player_icon_1"];
	_icon.iconTextureExt = "flag_icon";
	_icon.channel = _beacon.channel;
	return _icon;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioPingIconGroup:render()
	self:renderIcons();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioPingIconGroup:initialise()
	self.radioPings = em_radio.radioPings;
	self.nearbyPlayers = self.metaGroup.groups.cellObjectGroup.nearbyPlayers;
	self.playerIcons = self.metaGroup.groups.localPlayerGroup.drawIcons;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioPingIconGroup:pre_initialise()
	self.animationStep = 1;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------