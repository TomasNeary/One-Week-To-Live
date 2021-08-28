----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_customMarkerIconGroup
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require("em_mapIconGroupBase");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_customMarkerIconGroup = em_mapIconGroupBase:new();

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:createIcon(_x, _y)
	if self.tempMarker then self.mapIcons[self.tempMarker.iconID] = nil; end;
	local iconID = "customMarker" ..  _x .. _y;
	self.tempMarker = self:initialiseIcon(em_mapIconBase:new(), _x, _y);
	self.mapIcons[iconID] = self.tempMarker;
	return self.tempMarker;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:removeIcon(_iconID)
	self.mapIcons[_iconID] = nil;
	self.tempMarker = nil;
	self:saveFileData();
	self:loadFileData();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:saveIcon(_iconID, _mapIcon)
	self.mapIcons[_iconID] = _mapIcon;
	self:saveFileData();
	self:loadFileData();
	self.tempMarker = nil;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:loadFileData()
	self.mapIcons = {};
	local fileReaderObj = getFileReader("eris_minimap_poi.ini", true);
	if not fileReaderObj:readLine() then
		self:saveFileData();
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
			local j = 1;
			local fileDataExp = {};
			for dataExp in string.gmatch(fileData[i], "([^,]+)") do
				fileDataExp[j] = dataExp;
				j = j + 1;
			end;
			if #fileDataExp >= 9 then
				local customMarker = em_mapIconBase:new();
				local markerFileData = {
					iconData = fileDataExp[1] or "unknown",
					iconDataExt = fileDataExp[2] or "unknown",
					iconTexture = self.mapIconTex[tostring(fileDataExp[3])],
					iconTextureExt = tostring(fileDataExp[3]),
					x = tonumber(fileDataExp[4]) or 0,
					y = tonumber(fileDataExp[5]) or 0,
					r = tonumber(fileDataExp[6]) or 1,
					g = tonumber(fileDataExp[7]) or 1,
					b = tonumber(fileDataExp[8]) or 1,
					a = tonumber(fileDataExp[9]) or 1,
				};
				self:loadIconData(customMarker, markerFileData);
				if not self.mapIcons[customMarker.iconID] then
					self.mapIcons[customMarker.iconID] = customMarker;
				end;
			else
				print("[eris_minimap] Info: Malformed POI in eris_minimap_poi.ini @ line " .. (i + 1) .. " skipping this item.");
				print("[eris_minimap] " .. #fileDataExp .. " - " .. table.concat(fileDataExp, ", "));
			end;
		end;
	end;
	fileReaderObj:close();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:saveFileData()
	local fileWriterObj = getFileWriter("eris_minimap_poi.ini", true, false);
	fileWriterObj:write("[ERIS MINIMAP CUSTOM POIS]\r\n");
	for iconID, icon in pairs(self.mapIcons) do
		fileWriterObj:write(icon.iconData:gsub("[^%a%d%s]", "") .. ","
			.. icon.iconDataExt:gsub("[^%a%d%s]", "") .. ","
			.. icon.iconTextureExt .. ","
			.. icon.x .. ","
			.. icon.y .. ","
			.. icon.r .. ","
			.. icon.g .. ","
			.. icon.b .. ","
			.. icon.a .. "\r\n"
		);
	end;
	fileWriterObj:close();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:loadIconData(_icon, _iconData)
	for key, value in pairs(_iconData) do _icon[key] = value; end;
	-- _icon:setClass("customMarker");
	_icon.iconID = _icon.class .. _icon.x .. _icon.y;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:updateGroup(_updateTime)
	self.drawIcons = self.mapIcons;
	self:update(_updateTime);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:update(_updateTime)
	local map_settings = em_settings.map_settings;
	for iconID, icon in pairs(self.drawIcons) do
		icon:updateTimeStamp(_updateTime);
		icon.iconSize = 16 + map_settings.customMarkerIconSize;
		self:doIconTransform(icon);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:renderText()
	local drawTextCentre = em_core.minimap.drawTextCentre;
	local context_settings = em_settings.context_settings;
	local colorset = em_settings.color_settings.custom_markerTitle;
	local r, g, b, a = 1, 1, 1, 1;
	if colorset and colorset.enabled then
		r, g, b, a = colorset.color.r, colorset.color.g, colorset.color.b, colorset.color.a;
	end;
	for iconID, icon in pairs(self.drawIcons) do
		if context_settings.show_custom_marker_title.enabled then
			drawTextCentre(
				em_core.window,
				icon.iconData,
				icon.textX + 1, icon.textY + 1,
				0, 0, 0, a,
				UIFont.NewSmall
			);
			drawTextCentre(
				em_core.window,
				icon.iconData,
				icon.textX, icon.textY,
				r, g, b, a,
				UIFont.NewSmall
			);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:render()
	self:renderIcons();
	self:renderText();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:initialiseIcon(_icon, _x, _y)
	_icon:setObj(nil);
	_icon:setClass("customMarker");
	_icon.iconID = _icon.class .. _x .. _y;
	_icon:setLocation(_x, _y);
	_icon.iconData = _x .. " x " .. _y;
	_icon.iconDataExt = "Custom Marker";
	_icon.iconTexture = self.mapIconTex["flag_icon"];
	_icon.iconTextureExt = "flag_icon";
	_icon:setColor(1,1,1,1);
	_icon.doRenderText = false;
	return _icon;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:initialise()
	self:loadFileData();
	self:updateGroup();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_customMarkerIconGroup:pre_initialise()
	self.tempMarker = nil;
	self.drawIcons = self.mapIcons;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------