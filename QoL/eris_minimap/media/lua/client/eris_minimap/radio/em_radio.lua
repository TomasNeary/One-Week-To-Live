----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_radio
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

if isServer() then return; end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading em_radio ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_radio = {

	localMode = isClient(),

	radios = {},

	playerGroup = {},

	radioPings = {
		localPings = {},
		remotePings = {},
	},

	validRadios = {
		WalkieTalkieMakeShift = "", 
		WalkieTalkie1 = "", 
		WalkieTalkie2 = "",
		WalkieTalkie3 = "",
		WalkieTalkie4 = "",
		WalkieTalkie5 = "",
		HamRadioMakeShift = "",
		HamRadio1 = "",
		HamRadio2 = "",
		HamRadio3 = "",
		HamRadio4 = "",
		HamRadio5 = "",
		RadioRed = "",
		RadioBlack = "",
	},

	updateTick = 1,
	updateTickMax = 50,

};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------createBeacon

em_radio.createBeacon = function(_icon, _channel, _range)
	em_radio.radioPings.localPings[beacon.beaconID] = em_beacon:new(_icon, _channel, _range);
	return em_radio.radioPings.localPings[beacon.beaconID];
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------receiveMapBeacon

em_radio.receiveMapBeacon = function(_beacon)
	if em_core.window and em_core.mapIconMetaGroup then
		if em_settings.context_settings.radioToggle.enabled and em_settings.context_settings.radioRX_Toggle.enabled then
			if em_radio.playerGroup then
				em_radio.radios = {};
				local validBeacon = false;
				local localPings = em_radio.radioPings.localPings;
				local remotePings = em_radio.radioPings.remotePings;
				if localPings[_beacon.beaconID] then return; end;
				if em_core.adminMode then
					remotePings[_beacon.beaconID] = _beacon;
					return;
				end;
				for plID, plIcon in pairs(em_radio.playerGroup.mapIcons) do
					em_radio.radios[plID] = {};
					em_radio.playerGroup:getRadios(plIcon);
					for radioID, radio in pairs(plIcon.radios) do
						em_radio.radios[plID][radioID] = radio;
						if radio.channel == _beacon.channel and radio.mode.rx or radio.scannerEnabled then
							local distance = em_radio.playerGroup:getDistance2D(plIcon.x, plIcon.y, _beacon.origin.x, _beacon.origin.y);
							if distance < _beacon.range then
								if radio.scannerEnabled and radio.channel ~= _beacon.channel then
									if 10 < ZombRand(1,100) or distance < 100 then
										validBeacon = true;
										if radio.transponder then
											if radio.transponder:getModData()["battery"] > 0 then
												radio.transponder:getModData()["battery"] = radio.transponder:getModData()["battery"] - 4;
											else
												validBeacon = false;
											end;
										end;
									end;
								elseif radio.channel == _beacon.channel then
									validBeacon = true;
								end;
								if validBeacon then
									local range = plIcon.isOutside and radio.range or radio.range / 1.5;
									if em_beacon.doRelay(_beacon, plIcon, radio.channel, range) and radio.mode.tx then
										em_radio.relayMapBeacon(plIcon, _beacon);
									end;
									remotePings[_beacon.beaconID] = _beacon;
								end;
							end;
						end;
					end;
				end;
				em_core.mapIconMetaGroup.groups.radioPingGroup:updateGroup();
				em_core.window:updateRadioButtons();
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------removeBeacon

em_radio.removeBeacon = function(_ID)
	if em_radio.radioPings.localPings[_ID] then em_radio.radioPings.localPings[_ID] = nil; end;
	if em_radio.radioPings.remotePings[_ID] then em_radio.radioPings.remotePings[_ID] = nil; end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------sendBeacons

em_radio.sendBeacons = function()
	if em_settings.context_settings.radioToggle.enabled and em_settings.context_settings.radioTX_Toggle.enabled then
		if em_radio.playerGroup then
			em_radio.radios = {};
			local localPings = em_radio.radioPings.localPings;
			local sendBeacon = true;
			for plID, plIcon in pairs(em_radio.playerGroup.mapIcons) do
				em_radio.radios[plID] = {};
				em_radio.playerGroup:getRadios(plIcon);
				for radioID, radio in pairs(plIcon.radios) do
					em_radio.radios[plID][radioID] = radio;
					if radio.mode.tx then
						sendBeacon = true;
						if radio.transponder then
							if radio.transponder:getModData()["battery"] > 0 then
								radio.transponder:getModData()["battery"] = radio.transponder:getModData()["battery"] - 1;
							else
								sendBeacon = false;
							end;
						end;
						if sendBeacon then
							local range = plIcon.isOutside and radio.range or radio.range / 1.5;
							local beacon = em_beacon:new(plIcon, radio.channel, range);
							em_radio.sendMapBeacon(plIcon, beacon);
						end;
					end;
				end;
			end;
			em_core.mapIconMetaGroup.groups.radioPingGroup:updateGroup();
			em_core.window:updateRadioButtons();
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------relayMapBeacon

em_radio.relayMapBeacon = function(_icon, _beacon)
	if em_settings.context_settings.radioToggle.enabled and em_settings.context_settings.radioTX_Toggle.enabled then
		if em_radio.localMode then
			em_radio.onServerCommand("eris_minimap_beacon", "ping", _beacon);
		else
			sendClientCommand(_icon.obj, "eris_minimap_beacon", "ping", _beacon);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------sendMapBeacon

em_radio.sendMapBeacon = function(_icon, _beacon)
	if em_settings.context_settings.radioToggle.enabled and em_settings.context_settings.radioTX_Toggle.enabled then
		em_radio.radioPings.localPings[_beacon.beaconID] = _beacon;
		if em_radio.localMode then
			em_radio.onServerCommand("eris_minimap_beacon", "ping", _beacon);
		else
			sendClientCommand(_icon.obj, "eris_minimap_beacon", "ping", _beacon);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------update

em_radio.update = function()
	em_radio.updateTick = em_radio.updateTick + 1;
	local worldAge = getGameTime():getWorldAgeHours();
	for beaconID, beacon in pairs(em_radio.radioPings.localPings) do
		if worldAge - beacon.age >= 1 then beacon = nil; end;
	end;
	for beaconID, beacon in pairs(em_radio.radioPings.remotePings) do
		if worldAge - beacon.age >= 1 then beacon = nil; end;
	end;
	if em_radio.updateTick > em_radio.updateTickMax then
		em_radio.updateTick = 1;
		em_radio.sendBeacons();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------initialise

em_radio.initialise = function(_playerGroup)
	em_radio.playerGroup = _playerGroup;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------onServerCommand

em_radio.onServerCommand = function(_module, _command, _args)
	if _module ~= "eris_minimap_beacon" then return; end;
	if _command == "ping" then
		if _args then
			em_radio.receiveMapBeacon(_args);
		end;
	elseif _command == "set_beacon" then
		return;
	elseif _command == "unset_beacon" then
		return;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

if em_core.clientMode then
	Events.OnServerCommand.Add(em_radio.onServerCommand);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------