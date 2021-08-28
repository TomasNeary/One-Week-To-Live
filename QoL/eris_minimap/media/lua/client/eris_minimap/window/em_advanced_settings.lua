----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_advanced_settings
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_advanced_settings = em_advanced_settings or ISPanel:derive("em_advanced_settings");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_advanced_settings:update()
	local rate_settings = em_settings.rate_settings;
	self.label_map_updateRate.name = "Map Update Rate [1 per " .. rate_settings.map_updateRate.value .. " updates]";
	self.label_cell_updateRate.name = "Cell Update Rate [1 per " .. rate_settings.cell_updateRate.value .. " updates]";
	self.label_tile_loadingRate.name = "Tile Loading Rate [" .. rate_settings.tile_loadingRate.value .. " per update]";
	self.label_map_flickRate.name = "Map Drag Rate [" ..  math.floor(rate_settings.map_flickRate.value * 100) .. "%]";
	self.label_zombieGridSize.name = "Zombie Grid Size [" .. em_settings.map_settings.zombieGridSize .. " tiles]";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_advanced_settings:onChangeIconSizeSlider(_target, _value)
	local map_settings = em_settings.map_settings;
	map_settings[_target] = _value;
	em_settings:save();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_advanced_settings:onChangeGridSizeSlider(_target, _value)
	em_settings.map_settings.zombieGridSize = math.max(math.floor(_value), 1);
	em_settings:save();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_advanced_settings:onChangeUpdateSlider(_target, _value)
	local rate_settings = em_settings.rate_settings;
	if _target == "tile_loadingRate" then 
		rate_settings[_target].value = math.max(math.floor(_value), 1);
	elseif  _target == "map_flickRate" then
		rate_settings[_target].value = _value;
	else
		rate_settings[_target].value = math.floor(21 - _value);
	end;
	em_settings:save();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_advanced_settings:onChangeColor(_settingID, _r, _g, _b, _a)
	self.colorPickerTarget = self.colorSettingsCombo.options[self.colorSettingsCombo.selected].data;
	if self.customColorTickBox.selected[1] then
		local color_settings = em_settings.color_settings;
		local colorSet = color_settings[self.colorPickerTarget].color;
		colorSet.r,colorSet.g,colorSet.b,colorSet.a = self.colorPicker:getColor();
		self.iconTexture:setColor(self.colorPicker:getColor());
		em_settings:save();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_advanced_settings:onChangeColorTarget(_comboBox)
	self.colorPickerTarget = _comboBox.options[_comboBox.selected].data;
	local color_settings = em_settings.color_settings;
	local colorSet = color_settings[self.colorPickerTarget].color;
	self.customColorTickBox.selected[1] = color_settings[self.colorPickerTarget].enabled;
	self.customColorTickBox.changeOptionArgs[1] = self.colorPickerTarget;
	self.colorPicker:setColor(colorSet.r,colorSet.g,colorSet.b,colorSet.a);
	self.iconTexture.texture = color_settings[self.colorPickerTarget].icon;
	self.iconTexture:setColor(self.colorPicker:getColor());
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_advanced_settings:onCustomColorTickBoxChange(_optionIndex, _value, _settingID)
	local color_settings = em_settings.color_settings;
	local colorSet = color_settings[_settingID].color;
	if _value == false then 
		colorSet.r,colorSet.g,colorSet.b,colorSet.a = 1, 1, 1, 1;
		self.colorPicker:setColor(1, 1, 1, 1);
		self.iconTexture:setColor(1, 1, 1, 1);
		em_settings:save();
	end;
	color_settings[_settingID].enabled = _value;
	colorSet.r,colorSet.g,colorSet.b,colorSet.a = self.colorPicker:getColor();
	self.iconTexture:setColor(self.colorPicker:getColor());
	em_settings:save();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_advanced_settings:onContextTickBoxChange(_optionIndex, _value, _settingID)
	em_settings.context_settings[_settingID].enabled = _value;
	em_settings:save();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_advanced_settings:initialise()
	ISPanel.initialise(self);
	local x = 30;
	local y = 10;

	local rate_settings = em_settings.rate_settings;
	local context_settings = em_settings.context_settings;
	local color_settings = em_settings.color_settings;
	local map_settings = em_settings.map_settings;

	self.label_contextOptions = ISLabel:new(x, y, 16, "Change Map Settings", 1, 1, 1, 1, UIFont.Small, true);
	self.label_contextOptions:initialise();
	self.label_contextOptions:instantiate();
	self:addChild(self.label_contextOptions);

	y = y + 20;

	for settingID, settings in pairs(context_settings) do
		if settingID ~= "settingsToggle" then
			self[settingID] = ISTickBox:new(x, y, 100, 16, "", self, em_advanced_settings.onContextTickBoxChange, settingID);
			self[settingID].choicesColor = {r=1, g=1, b=1, a=1};
			self[settingID]:initialise();
			self[settingID]:instantiate();
			self[settingID].selected[1] = settings.enabled;
			self[settingID]:addOption(settings.option);
			self:addChild(self[settingID]);
			y = y + 20;
		end;
	end;

	x = 240;
	y = 10;

	self.label_colorOptions = ISLabel:new(x, y, 16, "Change Colors (Reload map to apply)", 1, 1, 1, 1, UIFont.Small, true);
	self.label_colorOptions:initialise();
	self.label_colorOptions:instantiate();
	self:addChild(self.label_colorOptions);

	y = y + 20;

	self.colorSettingsCombo = ISComboBox:new(x, y, 200, 20, self, em_advanced_settings.onChangeColorTarget);

	for	settingID, settings in pairs(color_settings) do
		self.colorSettingsCombo:addOption({text = settings.option, data = settingID});
	end;

	self.colorSettingsCombo:initialise();
	self:addChild(self.colorSettingsCombo);

	y = y + 24;

	self.colorPickerTarget = self.colorSettingsCombo.options[self.colorSettingsCombo.selected].data;

	self.customColorTickBox = ISTickBox:new(x, y, 200, 16, "", self, em_advanced_settings.onCustomColorTickBoxChange, self.colorPickerTarget);
	self.customColorTickBox.choicesColor = {r=1, g=1, b=1, a=1};
	self.customColorTickBox:initialise();
	self.customColorTickBox:instantiate();
	self.customColorTickBox:addOption("Use Custom Color");
	self:addChild(self.customColorTickBox);
	self.customColorTickBox.selected[1] = color_settings[self.colorPickerTarget].enabled;

	y = y + 24;

	local colorSet = color_settings[self.colorPickerTarget].color;

	self.colorPicker = em_colorPicker_RGBA:new();
	self.colorPicker:initialise(0, 0, 0, 1, self, em_advanced_settings.onChangeColor, self.colorPickerTarget);
	self:addChild(self.colorPicker);
	self.colorPicker:setX(x);
	self.colorPicker:setY(y);
	self.colorPicker:setWidth(120);
	self.colorPicker:setHeight(120);
	self.colorPicker:setColor(colorSet.r,colorSet.g,colorSet.b,colorSet.a);

	self.iconTexture = ISImage:new(x + 130, y, 32, 32, color_settings[self.colorPickerTarget].icon);
	self.iconTexture:initialise();
	self.iconTexture:instantiate();
	self:addChild(self.iconTexture);
	self.iconTexture:setColor(self.colorPicker:getColor());
	self.iconTexture.scaledWidth = 64;
	self.iconTexture.scaledHeight = 64;

	y = y + 80;

	local optionSliders = {
		map_updateRate = {
			option = "Map Update Rate",
			value =  math.floor(21 - rate_settings.map_updateRate.value) * 5, 
			minVal = 1,
			maxVal = 20,
			onChangeTarget = em_advanced_settings.onChangeUpdateSlider
		},
		map_flickRate = {
			option = "Map Drag Rate",
			value =  rate_settings.map_flickRate.value * 100, 
			minVal = 0.01,
			maxVal = 1,
			onChangeTarget = em_advanced_settings.onChangeUpdateSlider
		},
		cell_updateRate = {
			option = "Cell Update Rate",
			value = math.floor(21 - rate_settings.cell_updateRate.value) * 5,
			minVal = 1,
			maxVal = 20,
			onChangeTarget = em_advanced_settings.onChangeUpdateSlider
		},
		tile_loadingRate = {
			option = "Tile Loading Rate",
			value = math.floor(rate_settings.tile_loadingRate.value) * 5,
			minVal = 1,
			maxVal = 20,
			onChangeTarget = em_advanced_settings.onChangeUpdateSlider
		},
		zombieGridSize = {
			option = "Zombie Grid Size",
			value = math.floor(map_settings.zombieGridSize) * 5,
			minVal = 1,
			maxVal = 20,
			onChangeTarget = em_advanced_settings.onChangeGridSizeSlider
		},
		zombieIconSize = {
			option = "Zombie Icon Size",
			value = math.floor(map_settings.zombieIconSize),
			minVal = 1,
			maxVal = 100,
			onChangeTarget = em_advanced_settings.onChangeIconSizeSlider
		},
		safehouseIconSize = {
			option = "Safehouse Icon Size",
			value = math.floor(map_settings.safehouseIconSize),
			minVal = 1,
			maxVal = 100,
			onChangeTarget = em_advanced_settings.onChangeIconSizeSlider
		},
		vehicleIconSize = {
			option = "Vehicle Icon Size",
			value = math.floor(map_settings.vehicleIconSize),
			minVal = 1,
			maxVal = 100,
			onChangeTarget = em_advanced_settings.onChangeIconSizeSlider
		},
		playerIconSize = {
			option = "Player Icon Size",
			value = math.floor(map_settings.playerIconSize),
			minVal = 1,
			maxVal = 100,
			onChangeTarget = em_advanced_settings.onChangeIconSizeSlider
		},
		customMarkerIconSize = {
			option = "Custom Marker Size",
			value = math.floor(map_settings.customMarkerIconSize),
			minVal = 1,
			maxVal = 100,
			onChangeTarget = em_advanced_settings.onChangeIconSizeSlider
		},
	};
	for sliderID, settings in pairs(optionSliders) do
		self["label_" .. sliderID] = ISLabel:new(x + 10, y, 16, settings.option, 1, 1, 1, 1, UIFont.Small, true);
		self["label_" .. sliderID]:initialise();
		self["label_" .. sliderID]:instantiate();
		self:addChild(self["label_" .. sliderID]);
		y = y + 20;
		self["slider_" .. sliderID] = em_slider:new(x, y, 120, 16, settings.value, settings.minVal, settings.maxVal, sliderID, self, settings.onChangeTarget);
		self["slider_" .. sliderID]:initialise();
		self:addChild(self["slider_" .. sliderID]);
		self["slider_" .. sliderID]:setWidth(120);
		self["slider_" .. sliderID]:setHeight(16);
		self["slider_" .. sliderID]:setX(x);
		self["slider_" .. sliderID]:setY(y);
		y = y + 20;
	end;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_advanced_settings:new()
	local window_background = em_settings.color_settings.window_background;
	local o = ISPanel:new(0,0,0,0);

	setmetatable(o, self)
	self.__index = self;

	o.x = 0;
	o.y = 0;
	o.width = 0;
	o.height = 0;

	o.backgroundColor = window_background.enabled and window_background.color or {r=0, g=0, b=0, a=0.2};

	o.anchorLeft = true;
	o.anchorRight = true;
	o.anchorTop = true;
	o.anchorBottom = true;

	o.moveWithMouse = false;

	return o;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------