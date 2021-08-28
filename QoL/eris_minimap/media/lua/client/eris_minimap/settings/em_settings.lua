----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_settings
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading EM_SETTINGS ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_settings = {

	coreObj = getCore(),

	contextmenu = nil,

	queueSave = false,

	map_settings = {
		viewMode = 1,
		rotationXY = 0,
		transparencyLevel = 1,
		zoomLevel = 1,
		zombieGridSize = 3,
		zombieIconSize = 8,
		vehicleIconSize = 8,
		safehouseIconSize = 8,
		playerIconSize = 8,
		customMarkerIconSize = 8,
		privacy_level = 0,
		vpCenterXInWorld = 0,
		vpCenterYInWorld = 0,
	},

	window_geometry = {
		window_x = 100,
		window_y = 100,
		window_width = 250,
		window_height = 250,
		screenWidth = 800,
		screenHeight = 600,
		compactMode = false,
		pinned = false,
		collapsed = false,
	},

	window_minimumSize = 48,
	window_compactSize = 250,

	rate_settings = {
		map_updateRate		= {option = em_translationData.label_update_rate, value = 5},
		cell_updateRate		= {option = em_translationData.label_cellupdate_rate, value = 5},
		tile_loadingRate	= {option = em_translationData.label_loading_rate, value = 3},
		map_flickRate		= {option = em_translationData.label_drag_rate, value = 0.666},
	},

	context_settings = {
		settingsToggle 				= {enabled = true, option = em_translationData.label_nullOption},
		lockToggle					= {enabled = true, option = em_translationData.label_followToggleOption},
		zoomToggle					= {enabled = true, option = em_translationData.label_zoomToggleOption},
		addMarkerToggle				= {enabled = true, option = em_translationData.label_addMarkerToggleOption},
		transparencyToggle			= {enabled = true, option = em_translationData.label_transparencyToggleOption},
		viewmodeToggle				= {enabled = true, option = em_translationData.label_viewModeToggleOption},
		mapGridModeToggle			= {enabled = true, option = em_translationData.label_gridToggleOption},
		-- privacyLevelToggle			= {enabled = true, option = em_translationData.label_privacyToggleOption},
		localplayerToggle			= {enabled = true, option = em_translationData.label_localPlayersOption},
		zombieToggle				= {enabled = true, option = em_translationData.label_zombiesOption},
		vehToggle					= {enabled = true, option = em_translationData.label_vehiclesOption},
		ownSafehouseToggle			= {enabled = true, option = em_translationData.label_ownSafehousesOption},
		otherSafehouseToggle		= {enabled = true, option = em_translationData.label_otherSafehousesOption},
		otherplayerToggle			= {enabled = true, option = em_translationData.label_otherPlayersOption},
		otherplayerTitle			= {enabled = false, option = em_translationData.label_otherplayerTitle},
		localplayerTitle			= {enabled = false, option = em_translationData.label_localplayerTitle},
		coordinatesToggle			= {enabled = true, option = em_translationData.label_coordinatesOption},
		gridCoordinatesToggle		= {enabled = true, option = em_translationData.label_gridCoordinatesOption},
		gridToggle					= {enabled = false, option = em_translationData.label_mapGridOption},
		timedateToggle				= {enabled = true, option = em_translationData.label_timeDateOption},
		radioInfoToggle				= {enabled = true, option = em_translationData.label_radioBeaconInfoOption},
		radioToggle					= {enabled = true, option = em_translationData.label_radioLocationsOption},
		radioTX_Toggle				= {enabled = false, option = em_translationData.label_txOption},
		radioRX_Toggle				= {enabled = false, option = em_translationData.label_rxOption},
		unlockOnDrag				= {enabled = false, option = em_translationData.label_unlockOption},
		arrowKeyControl				= {enabled = false, option = em_translationData.label_arrowControlOption},
		mapZoomFollowMouse			= {enabled = true, option = em_translationData.label_mapZoomFollowMouse},
		mapDayNightCycle			= {enabled = false, option = em_translationData.label_dayNightCycleOption},
		show_vanilla_areas			= {enabled = true, option = em_translationData.label_show_vanilla_areas},
		show_communitymap_areas		= {enabled = true, option = em_translationData.label_show_communitymap_areas},
		show_custom_marker_title	= {enabled = true, option = em_translationData.label_show_custom_marker_title},
		-- show_custom_areas			= {enabled = true, option = em_translationData.label_show_custom_areas},
		show_nonpvp_areas			= {enabled = true, option = em_translationData.label_show_nonpvp_areas},
		show_buildings_areas		= {enabled = false, option = em_translationData.label_show_buildings_areas},
		-- show_safehouse_areas		= {enabled = true, option = em_translationData.label_show_safehouse_areas},
		alwaysShowAreaTitle			= {enabled = true, option = em_translationData.label_alwaysShowAreaTitle},
		neverShowAreaTitle			= {enabled = false, option = em_translationData.label_neverShowAreaTitle},
		showOverheadMapData			= {enabled = false, option = em_translationData.label_showOverheadMapData},
		-- scaleVehiclesWithMap		= {enabled = false, option = em_translationData.label_scaleVehiclesWithMap},
		-- scaleZombiesWithMap			= {enabled = false, option = em_translationData.label_scaleZombiesWithMap},
		-- scalePlayersWithMap			= {enabled = false, option = em_translationData.label_scalePlayersWithMap},
		-- scaleCustomMarkersWithMap	= {enabled = false, option = em_translationData.label_scaleCustomMarkersWithMap},
	},

	color_settings = {
		localPlayer0		= {enabled = false, option = em_translationData.label_colors_localPlayer0, icon = em_mapIconGroupBase.arrowTex.N, color = {r = 1, g = 1, b = 1, a = 1}},
		localPlayer1		= {enabled = false, option = em_translationData.label_colors_localPlayer1, icon = em_mapIconGroupBase.arrowTex.N, color = {r = 1, g = 1, b = 1, a = 1}},
		localPlayer2		= {enabled = false, option = em_translationData.label_colors_localPlayer2, icon = em_mapIconGroupBase.arrowTex.N, color = {r = 1, g = 1, b = 1, a = 1}},
		localPlayer3		= {enabled = false, option = em_translationData.label_colors_localPlayer3, icon = em_mapIconGroupBase.arrowTex.N, color = {r = 1, g = 1, b = 1, a = 1}},
		localplayerTitle	= {enabled = false, option = em_translationData.label_colors_localplayerTitle, icon = em_mapIconGroupBase.mapIconTex.dot_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		zombies				= {enabled = false, option = em_translationData.label_colors_zombies, icon = em_mapIconGroupBase.mapIconTex.dot_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		otherplayers		= {enabled = false, option = em_translationData.label_colors_otherplayers, icon = em_mapIconGroupBase.arrowTex.N, color = {r = 1, g = 1, b = 1, a = 1}},
		otherPlayerTitle	= {enabled = false, option = em_translationData.label_colors_otherPlayerTitle, icon = em_mapIconGroupBase.mapIconTex.dot_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		emptyVeh			= {enabled = false, option = em_translationData.label_colors_emptyVeh, icon = em_mapIconGroupBase.mapIconTex.vehicle_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		ownSafehouse		= {enabled = false, option = em_translationData.label_colors_ownSafehouse, icon = em_mapIconGroupBase.mapIconTex.house_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		otherSafehouse		= {enabled = false, option = em_translationData.label_colors_otherSafehouse, icon = em_mapIconGroupBase.mapIconTex.house_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		mapTint				= {enabled = false, option = em_translationData.label_colors_mapTint, icon = em_mapIconGroupBase.mapIconTex.dot_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		mapGridTint			= {enabled = false, option = em_translationData.label_colors_mapGridTint, icon = em_mapIconGroupBase.mapIconTex.dot_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		window_border		= {enabled = false, option = em_translationData.label_colors_window_border, icon = em_mapIconGroupBase.mapIconTex.dot_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		window_background	= {enabled = false, option = em_translationData.label_colors_window_background, icon = em_mapIconGroupBase.mapIconTex.dot_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		coordinates_text	= {enabled = false, option = em_translationData.label_colors_coordinates_text, icon = em_mapIconGroupBase.mapIconTex.dot_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		timeDate_text		= {enabled = false, option = em_translationData.label_colors_timeDate_text, icon = em_mapIconGroupBase.mapIconTex.dot_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		areaTitle			= {enabled = false, option = em_translationData.label_colors_areaTitle, icon = em_mapIconGroupBase.mapIconTex.dot_icon, color = {r = 1, g = 1, b = 1, a = 1}},
		custom_markerTitle	= {enabled = false, option = em_translationData.label_colors_custom_markerTitle, icon = em_mapIconGroupBase.mapIconTex.dot_icon, color = {r = 1, g = 1, b = 1, a = 1}},
	},

	button_settings = {
		button_lockOn = {
			index = 1,
			position = "left",
			internal = "button_lockOn",
			tooltip = em_translationData.tooltip_lockOn,
			toggle = "lockToggle",
			setting = "none",
		},
		button_zoomLevel = {
			index = 2,
			position = "left",
			internal = "button_zoomLevel",
			tooltip = em_translationData.tooltip_zoomLevel,
			toggle = "zoomToggle",
			setting = "zoomLevel",
			setting_minVal = 0.1,
			setting_maxVal = 7,
		},
		button_addMarker = {
			index = 3,
			position = "left",
			internal = "button_addMarker",
			tooltip = em_translationData.tooltip_addMarker,
			toggle = "addMarkerToggle",
			setting = "none",
		},
		button_viewMode = {
			index = 4,
			position = "left",
			internal = "button_viewMode",
			tooltip = em_translationData.tooltip_viewMode,
			toggle = "viewmodeToggle",
			setting = "none",
		},
		button_gridToggle = {
			index = 5,
			position = "left",
			internal = "button_gridToggle",
			tooltip = em_translationData.tooltip_gridToggle,
			toggle = "mapGridModeToggle",
			setting = "none",
		},
		button_transparencyLevel = {
			index = 6,
			position = "left",
			internal = "button_transparencyLevel",
			tooltip = em_translationData.tooltip_transparencyLevel,
			toggle = "transparencyToggle",
			setting = "transparencyLevel",
			setting_minVal = 0.1,
			setting_maxVal = 1,
		},
		button_settings_icon = {
			index = 8,
			position = "left",
			internal = "button_settings_icon",
			tooltip = em_translationData.tooltip_settings,
			toggle = "settingsToggle",
			setting = "none",
		},
		-- button_privacyLevel = {
			-- index = 9,
			-- position = "left",
			-- internal = "button_privacyLevel",
			-- tooltip = em_translationData.tooltip_privacyLevel,
			-- toggle = "privacyLevelToggle",
			-- setting = "none",
		-- },
	},
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_settings:apply(_window)
	_window:setWidth(self.window_geometry.window_width);
	_window:setHeight(self.window_geometry.window_height);
	_window:setX(self.window_geometry.window_x);
	_window:setY(self.window_geometry.window_y);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_settings:update(_window)

	if _window.collapsed then return; end;

	local window_geo = self.window_geometry;
	local geo = {};

	geo.window_x = _window:getX();
	geo.window_y = _window:getY();
	geo.window_width = _window:getWidth();
	geo.window_height = _window:getHeight();
	geo.screenWidth = self.coreObj:getScreenWidth();
	geo.screenHeight = self.coreObj:getScreenHeight();
	geo.compactMode = math.min(geo.window_width, geo.window_height) < self.window_compactSize;

	if geo.window_x < 0 then geo.window_x = 0; end;
	if geo.window_y < 0 then geo.window_y = 0; end;
	if geo.window_x + geo.window_width > geo.screenWidth then geo.window_x = geo.screenWidth - geo.window_width; end;
	if geo.window_y + geo.window_height > geo.screenHeight then geo.window_y = geo.screenHeight - geo.window_height; end;
	if geo.window_width > geo.screenWidth then geo.window_width = geo.screenWidth; end;
	if geo.window_height > geo.screenHeight then geo.window_height = geo.screenHeight; end;

	if geo.screenHeight ~= window_geo.screenHeight or geo.screenWidth ~= window_geo.screenWidth then
		geo.window_x = geo.screenWidth - (window_geo.screenWidth - window_geo.window_x);
		geo.window_y = geo.screenHeight - (window_geo.screenHeight - window_geo.window_y);
	end;

	local geo_changed = false;

	for key, value in pairs(geo) do if window_geo[key] ~= value then window_geo[key] = value; geo_changed = true; end; end;

	if geo_changed then
		self:apply(_window);
		self:save();
	end;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_settings:load_color_settings()
	local info = "";
	local fileReaderObj = getFileReader("em_color_settings.ini", true);
	if not fileReaderObj:readLine() then
		print("[eris_minimap] Info: Settings file not found: em_color_settings.ini... Creating file.")
		self:save();
	else
		local fileData = {};
		while true do
			local fileLine = fileReaderObj:readLine();
			if fileLine then
				table.insert(fileData, fileLine);
			else
				break;
			end;
		end;
		for i = 1, #fileData do
			local fileDataExp = {}; local j = 1;
			for dataExp in string.gmatch(fileData[i], "([^,]+)") do
				fileDataExp[j] = dataExp;
				j = j + 1;
			end;
			if #fileDataExp == 6 then
				local colorsetting = self.color_settings[fileDataExp[1]];
				if colorsetting then
					colorsetting.enabled = self:toBool(fileDataExp[2]);
					colorsetting.color.r = tonumber(fileDataExp[3]) or 1;
					colorsetting.color.g = tonumber(fileDataExp[4]) or 1;
					colorsetting.color.b = tonumber(fileDataExp[5]) or 1;
					colorsetting.color.a = tonumber(fileDataExp[6]) or 1;
				else
					print("[eris_minimap] Info: Setting not found: " .. (fileDataExp[1] or "") .. " @ line " .. (i + 1) .. " skipped this item.");
					print("[eris_minimap] " .. #fileDataExp .. " - " .. table.concat(fileDataExp, ", "));
				end;
			else
				print("[eris_minimap] Info: Malformed item in em_color_settings.ini, skipped this item.");
				print("[eris_minimap] " .. #fileDataExp .. " - " .. table.concat(fileDataExp, ", "));
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_settings:save_color_settings()
	local fileWriterObj = getFileWriter("em_color_settings.ini", true, false);
	fileWriterObj:write("[ERIS MINIMAP COLOR SETTINGS]" .. "\r\n");
	for setting, value in pairs(self.color_settings) do
		fileWriterObj:write(
			setting .. "," ..
			tostring(value.enabled) .. "," ..
			value.color.r .. "," ..
			value.color.g .. "," ..
			value.color.b .. "," ..
			value.color.a .. "\r\n"
		);
	end;
	fileWriterObj:close();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_settings:load_minimap_settings()
	local info = "";
	local fileReaderObj = getFileReader("em_settings.ini", true);
	if not fileReaderObj:readLine() then
		print("[eris_minimap] Info: Settings file not found: em_settings.ini... Creating file.")
		self:save();
	else
		local fileData = {};
		while true do
			local fileLine = fileReaderObj:readLine();
			if fileLine then
				table.insert(fileData, fileLine);
			else
				break;
			end;
		end;
		for i = 1, #fileData do
			local fileDataExp = {}; local j = 1;
			for dataExp in string.gmatch(fileData[i], "([^=]+)") do
				fileDataExp[j] = dataExp;
				j = j + 1;
			end;
			if #fileDataExp == 2 then
				if self.context_settings[fileDataExp[1]] ~= nil then
					if fileDataExp[2] == "true" then
						fileDataExp[2] = true;
					elseif fileDataExp[2] == "false" then
						fileDataExp[2] = false;
					end;
					self.context_settings[fileDataExp[1]].enabled = fileDataExp[2];
				elseif self.rate_settings[fileDataExp[1]] ~= nil then
					self.rate_settings[fileDataExp[1]].value = tonumber(fileDataExp[2]) or self.rate_settings[fileDataExp[1]].value;
				elseif self.window_geometry[fileDataExp[1]] ~= nil then
					if tonumber(fileDataExp[2]) then
						fileDataExp[2] = tonumber(fileDataExp[2]);
					elseif fileDataExp[2] == "true" then
						fileDataExp[2] = true;
					elseif fileDataExp[2] == "false" then
						fileDataExp[2] = false;
					end;
					self.window_geometry[fileDataExp[1]] = fileDataExp[2];
				elseif self.map_settings[fileDataExp[1]] ~= nil then
					if tonumber(fileDataExp[2]) then
						fileDataExp[2] = tonumber(fileDataExp[2]);
					elseif fileDataExp[2] == "true" then
						fileDataExp[2] = true;
					elseif fileDataExp[2] == "false" then
						fileDataExp[2] = false;
					end;
					self.map_settings[fileDataExp[1]] = fileDataExp[2];
				else
					print("[eris_minimap] Info: Setting not found: " .. fileDataExp[1] .. " @ line " .. (i + 1) .. " skipped this item.");
					print("[eris_minimap] " .. #fileDataExp .. " - " .. table.concat(fileDataExp, ", "));
				end;
			else
				print("[eris_minimap] Info: Malformed settings item in em_settings.ini : " .. (fileDataExp[1] or "") .. " @ line " .. (i + 1) .. " skipped this item");
				print("[eris_minimap] " .. #fileDataExp .. " - " .. table.concat(fileDataExp, ", "));
			end;
		end;
	end;
	fileReaderObj:close();
	if self.window_geometry.window_width < 48 then self.window_geometry.window_width = 200; end;
	if self.window_geometry.window_height < 48 then self.window_geometry.window_height = 200; end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_settings:save_minimap_settings()
	local fileWriterObj = getFileWriter("em_settings.ini", true, false);
	fileWriterObj:write("[ERIS MINIMAP SETTINGS]" .. "\r\n");
	for setting, value in pairs(self.context_settings) do
		fileWriterObj:write(setting .. "=" .. tostring(value.enabled) .. "\r\n");
	end;
	for setting, value in pairs(self.map_settings) do
		fileWriterObj:write(setting .. "=" .. tostring(value) .. "\r\n");
	end
	for setting, value in pairs(self.window_geometry) do
		if type(value) == "number" then
			fileWriterObj:write(setting .. "=" .. tostring(math.floor(value * 100) / 100) .. "\r\n");
		else
			fileWriterObj:write(setting .. "=" .. tostring(value) .. "\r\n");
		end;
	end;
	for setting, value in pairs(self.rate_settings) do
		fileWriterObj:write(setting .. "=" .. tostring(value.value) .. "\r\n");
	end;
	fileWriterObj:close();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_settings:load()
	self:load_minimap_settings();
	self:load_color_settings();
end


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_settings:save()
	self:save_minimap_settings();
	self:save_color_settings();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_settings:toBool(_string)
	if _string == "true" then return true; end;
	if _string == "false" then return false; end;
	return false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
em_settings:load()
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------