----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_core
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require "ISUI/ISLayoutManager"

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading EM_TRANSLATIONDATA ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

--TODO: finish this
em_translationData = {
	label_window_minimap = "minimap",
	label_window_settings = "settings",
	label_window_custom_marker = "Add/Edit Marker",
	label_update_rate = "Map Update Rate",
	label_cellupdate_rate = "Cell Update Rate",
	label_loading_rate = "Tile Loading Rate",
	label_drag_rate = "Map Drag Rate",
	label_follow = "Follow This",
	label_pin = "Pin This",
	label_survival_time = "Survived: ",
	label_disable_scanner = "Disable Scanner",
	label_enable_scanner = "Enable Scanner",
	label_remove_battery = "Remove Battery",
	label_insert_battery = "Insert Battery",
	label_view_device = "View Device",
	label_set_channel = "Set Channel",
	label_channel = "Channel: ",
	label_range = "Range: ",
	label_battery = "Battery: ",
	label_transmit = "Can Transmit: ",
	label_receive = "Can Receive: ",
	label_last_broadcast = "Last broadcast location ",
	label_last_update = "Last Update: ",
	label_minutes_passed = " minutes ago",
	label_hours_passed = " hours ago",
	label_custom_marker_initial = "Custom Marker",
	label_custom_marker_color = "Marker Color",
	label_settings_clear_markers = "Delete All Custom Markers",
	label_settings_modal_clear_markers = "Are you sure?",
	label_settings_modal_remove = "Delete All",
	label_settings_modal_cancel = "Cancel",
	label_save = "Save",
	label_remove = "Remove",
	context_label_add_edit_marker = "Add/Edit Marker",
	context_label_lock_toggle = "Show Follow Player Button",
	context_label_zoom_toggle = "Show Zoom Button",
	context_label_addmarker_toggle = "Show Add Marker Button",
	context_label_livedata_toggle = "Show Live Map Data Button",
	context_label_transparency_toggle = "Show Transparency Button",
	label_privacyToggleOption = "Show Privacy Toggle Button",
	tooltip_lockOn = "Follow Player",
	tooltip_zoomLevel = "Change Zoom Level",
	tooltip_addMarker = "Add Marker",
	tooltip_liveMapData = "Toggle Live Map Data",
	tooltip_viewMode = "Change View Mode",
	tooltip_gridToggle = "Toggle Map Grid",
	tooltip_transparencyLevel = "Change Map Transparency",
	tooltip_privacyLevel = "Change Map Privacy Level <LINE> White = Visible to all. <LINE> Green = Visible to own faction. <LINE> Grey = Not visible on map. <LINE> Radio location beacons can still be used when hidden.",
	tooltip_window_resize = "Hold left click to resize window. Right-click to pin this corner.",
	tooltip_settings = "Click to show advanced settings",
	label_colors_localPlayer0 = "Player 1",
	label_colors_localPlayer1 = "Player 2",
	label_colors_localPlayer2 = "Player 3",
	label_colors_localPlayer3 = "Player 4",
	label_colors_zombies = "Zombies",
	label_colors_otherplayers = "Other Players",
	label_colors_otherplayersTitle = "Other Player Name Color",
	label_colors_emptyVeh = "Vehicles",
	label_colors_ownSafehouse = "Own Safehouses",
	label_colors_otherSafehouse = "Other Safehouses",
	label_colors_mapTint = "Map Tint",
	label_colors_mapGridTint = "Map Grid Tint",
	label_colors_window_border = "Window Border",
	label_colors_window_background = "Window Background",
	label_colors_coordinates_text = "Coordinates Text",
	label_colors_timeDate_text = "Time and Date Text",
	label_colors_areaTitle = "Area Title Color",
	label_colors_custom_markerTitle = "Custom Marker Name Color",
	label_colors_localplayerTitle = "Local Player Name Color",
	label_colors_otherPlayerTitle = "Other Player Name Color",
	label_nullOption = "(this option should not be visible or disabled)",
	label_followToggleOption = "Show Follow Button",
	label_zoomToggleOption = "Show Zoom Button",
	label_addMarkerToggleOption = "Show Add Marker Button",
	label_transparencyToggleOption = "Show Map Transparency Button",
	label_viewModeToggleOption = "Show View Mode Button",
	label_gridToggleOption = "Show Grid Toggle Button",
	label_zombiesOption = "Show Zombies",
	label_vehiclesOption = "Show Vehicles",
	label_ownSafehousesOption = "Show Own Safehouses",
	label_otherSafehousesOption = "Show Other Safehouses",
	label_otherPlayersOption = "Show Other Players",
	label_localplayerTitle = "Show Local Player Names",
	label_otherplayerTitle = "Show Other Player Names",
	label_coordinatesOption = "Show Coordinates",
	label_gridCoordinatesOption = "Show Grid Coordinates",
	label_mapGridOption = "Show Map Grid",
	label_timeDateOption = "Show Time and Date",
	label_radioBeaconInfoOption = "Show Radio Beacon Info",
	label_radioLocationsOption = "Enable Radio Location Functions",
	label_txOption = "Transmit Location",
	label_rxOption = "Recieve Locations",
	label_unlockOption = "Unlock Map With Mouse Drag",
	label_arrowControlOption = "Arrow Keys Control Map",
	label_dayNightCycleOption = "Map day/night cycle",
	label_mapZoomFollowMouse = "Map Zoom Follows Mouse",
	label_show_vanilla_areas = "Show Knox County Area Names",
	label_show_communitymap_areas = "Show Community Map Area Names",
	label_show_custom_areas = "Show Custom Areas",
	label_show_custom_marker_title = "Show Custom Marker Names",
	label_show_nonpvp_areas = "Show Non PVP Areas",
	label_alwaysShowAreaTitle = "Show All Area Names",
	label_neverShowAreaTitle = "Never Show Area Names",
	label_context_unlockDrag = "Unlock Map Dragging",
	label_context_unsetTarget = "Unset Target",
	label_context_setTarget = "Set Target: ",
	label_context_stopMoving = "Stop Moving ",
	label_context_startMoving = "Move ",
	label_context_addMarker = "Add Marker: ",
	label_context_adminTeleport = "ADMIN: Teleport: ",
	label_context_adminRemoveVehicle = "ADMIN: Remove vehicle",
	label_context_adminCheckStats = "ADMIN: Check Stats",
	label_context_getCloserToVehicle = "Get closer to enter vehicle",
	label_context_editMarker = "Edit Custom Marker",
	label_context_safehouseSubmenu = "Safehouse: ",
	label_show_buildings_areas = "Show Building Data",
	label_localPlayersOption = "Show Local Players",
	label_showOverheadMapData = "Show Overhead Map Data",
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading EM_CORE ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_core = {
	version = getCore():getVersionNumber(),
	IWBUMS = string.match(getCore():getVersionNumber(), "IWBUMS"),
	serverMode = isServer() or false;
	clientMode = isClient() or false;
	adminMode = isAdmin() or false;
	window = nil,
	minimap = nil,
	map = nil,
	mapIconMetaGroup = nil,
	editmarkerwindow = nil,
	iconSelectorInfoBox = nil,
	iconInfoBox = nil,
	radioInfoBox = nil,
	beaconInfoBox = nil,
	avatarInfoBox = nil,
	safehouseInfoBox = nil,
	personal_beacon_infoBox = nil,
	mapDebugX = 0,
	mapDebugY = 0,
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_core.initPluginSettings = function()
	em_pluginsettings = em_pluginsettings or {};
	em_pluginsettings.radarMode = em_pluginsettings.radarMode or false;
	em_pluginsettings.enableOverheadMapData = em_pluginsettings.enableOverheadMapData or false;
	em_pluginsettings.disableLocalPlayers = em_pluginsettings.disableLocalPlayers or false;
	em_pluginsettings.disableRemotePlayers = em_pluginsettings.disableRemotePlayers or false;
	em_pluginsettings.disableRemoteVehicles = em_pluginsettings.disableRemoteVehicles or false;
	em_pluginsettings.disableRemoteZombies = em_pluginsettings.disableRemoteZombies or false;
	em_pluginsettings.requireGPS = em_pluginsettings.requireGPS or false; --TODO
	em_pluginsettings.requireMap = em_pluginsettings.requireMap or false; --TODO
	em_pluginsettings.psychicMode = em_pluginsettings.psychicMode or false; --TODO
	em_pluginsettings.psychicModeFaction = em_pluginsettings.psychicModeFaction or false; --TODO
	em_pluginsettings.psychicModeCohabitants = em_pluginsettings.psychicModeCohabitants or false; --TODO

	if (em_core.adminMode and em_core.clientMode) or em_core.IWBUMS then
		print("ERIS_MINIMAP is in Admin Mode");
		if em_core.IWBUMS then
			print("ERIS_MINIMAP is in IWBUMS Mode");
		end;
		em_pluginsettings.radarMode = true;
		em_pluginsettings.enableOverheadMapData = true;
		em_pluginsettings.disableLocalPlayers = false;
		em_pluginsettings.disableRemotePlayers = false;
		em_pluginsettings.disableRemoteVehicles = false;
		em_pluginsettings.disableRemoteZombies = false;
	end;
end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_core.boot = function()
	em_core.initPluginSettings();
	em_settings:load();
	em_core.window = em_window:new(getCore():getScreenWidth() / 2 - 240, getCore():getScreenHeight() / 2 - 180, 480, 360);
	em_core.window:initialise();
	em_core.window:addToUIManager();
	em_core.map:loadMapTiles();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_core.checkPress = function(_keyPressed)
	--TODO: bind for full screen mode
	if _keyPressed == getCore():getKey("Show Map") then
		if em_core.window then
			em_core.kill();
		else
			em_core.boot();
		end;
	end;
	if em_core.map then
		if em_settings.context_settings.arrowKeyControl.enabled then
			--TODO: custom binds for arrow control mode
			if _keyPressed == 200 then
				em_core.map:dragMap(0, 200, true);
			end;
			if _keyPressed == 208 then
				em_core.map:dragMap(0, -200, true);
			end;
			if _keyPressed == 203 then
				em_core.map:dragMap(200, 0, true);
			end;
			if _keyPressed == 205 then
				em_core.map:dragMap(-200, 0, true);
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_core.init_binds = function()
	table.insert(keyBinding, { value = "[ERIS_MINIMAP]" } );
	table.insert(keyBinding, { value = "Show Map", key = 199 } );
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_core.init_checkPress = function()
	Events.OnKeyPressed.Add(em_core.checkPress);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_core.kill = function()
	if em_core.map then
		em_core.map:storeMapTiles();
		em_core.map = nil;
	end;
	if em_core.minimap then
		em_core.minimap:setVisible(false);
		em_core.minimap:removeFromUIManager();
		em_core.minimap = nil;
	end;
	if em_core.window then
		em_core.window:setVisible(false);
		em_core.window:removeFromUIManager();
		em_core.window = nil;
	end;
	if em_core.editmarkerwindow then
		em_core.editmarkerwindow:setVisible(false);
		em_core.editmarkerwindow:removeFromUIManager(false);
		em_core.editmarkerwindow = nil;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_core.update = function()
	local updateTime = getTimestampMs();
	if em_core.window then
		em_core.window:update(updateTime);
		em_core.minimap:update(updateTime);
		em_core.map:update(updateTime);
		em_core.mapIconMetaGroup:update(updateTime);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.OnGameStart.Add(em_core.init_checkPress);
Events.OnGameBoot.Add(em_core.init_binds);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------