----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_window
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading EM_WINDOW ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require "ISUI/ISPanel"
require "ISUI/ISWindow"
require "ISUI/ISCollapsableWindow"
require "ISUI/ISLayoutManager"

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_window = em_window or ISCollapsableWindow:derive("em_window");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_window.mapButtonTex = {
	button_lockOn = getTexture("media/textures/icons/lock_player_on.png"),
	button_lockOff = getTexture("media/textures/icons/lock_player_off.png"),
	button_zoomLevel = getTexture("media/textures/icons/zoom_in.png"),
	button_viewMode = getTexture("media/textures/icons/map_btn_topdown.png"),
	button_gridToggle = getTexture("media/textures/icons/map_grid.png"),
	button_addMarker = getTexture("media/textures/icons/map_flagbutton.png"),
	button_liveMapData = getTexture("media/textures/icons/danger_button_icon_on.png"),
	button_transparencyLevel = getTexture("media/textures/icons/map_trans_off.png"),
	button_settings_icon = getTexture("media/textures/icons/settings.png"),
	button_radio = getTexture("media/textures/icons/radio_off.png"),
	resize_TL = getTexture("media/textures/window/resize_TL.png"),
	resize_TR = getTexture("media/textures/window/resize_TR.png"),
	resize_BL = getTexture("media/textures/window/resize_BL.png"),
	resize_BR = getTexture("media/textures/window/resize_BR.png"),
	resize_TL_pinned = getTexture("media/textures/window/resize_TL_pinned.png"),
	resize_TR_pinned = getTexture("media/textures/window/resize_TR_pinned.png"),
	resize_BL_pinned = getTexture("media/textures/window/resize_BL_pinned.png"),
	resize_BR_pinned = getTexture("media/textures/window/resize_BR_pinned.png"),
	-- map_btn_iso = getTexture("media/textures/icons/map_btn_iso.png"),
	-- danger_button_icon = getTexture("media/textures/icons/danger_button_icon.png"),
	-- danger_button_icon_off = getTexture("media/textures/icons/danger_button_icon_off.png"),
	-- map_trans_on = getTexture("media/textures/icons/map_trans_on.png"),
	-- map_trans_half = getTexture("media/textures/icons/map_trans_half.png"),
	-- radio_none = getTexture("media/textures/icons/radio_none.png"),
	-- radio_on = getTexture("media/textures/icons/radio_on.png"),
	-- lockOff = getTexture("media/textures/icons/lock_player_off.png"),
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------appendTable

function em_window:appendTable(_t1, _t2)
	for k, v in pairs(_t1) do _t2[k] = v; end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateInfoBoxes

function em_window:updateInfoBoxes()
	self.coordinateInfoBox:setVisible(not (em_settings.window_geometry.compactMode or self.collapsed or (not em_settings.context_settings.coordinatesToggle)));
	self.calendarInfoBox:setVisible(not (em_settings.window_geometry.compactMode or self.collapsed or (not em_settings.context_settings.timedateToggle)));
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------closeOptionSlider

function em_window:closeOptionSlider()
	if self.slider then
		self.slider:close();
		self:removeChild(self.slider);
		self.slider = nil;
		return true;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------onChangeSlider

function em_window:onChangeSlider(_target, _value)
	if em_settings.map_settings[_target] and _value and em_settings.map_settings[_target] ~= _value then
		em_settings.map_settings[_target] = _value;
		em_core.map:updateTransparency();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------createOptionSlider

function em_window:createOptionSlider(_button)
	local x, y = _button:getX() + 32, _button:getY() + 4;
	local minVal, maxVal =  _button.setting_minVal, _button.setting_maxVal;
	local button_settings = em_settings.button_settings;
	local map_settings = em_settings.map_settings;
	local value = (map_settings[_button.setting] / maxVal) * 100;
	self.slider = em_slider:new(x, y, 120, 16, value, minVal, maxVal, _button.setting, self, em_window.onChangeSlider);
	self:appendTable(button_settings[_button.internal], self.slider);
	self.slider:initialise();
	self:addView(self.slider);
	self.slider:setWidth(120); self.slider:setHeight(16);
	self.slider:setX(x); self.slider:setY(y);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------onMouseUp

function em_window:onMouseUp(_x, _y)
	if not self:getIsVisible() then return; end;
	self.moving = false;
	self.resizing = false;
	self:closeOptionSlider();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------onMouseUpOutside

function em_window:onMouseUpOutside(_x, _y)
	if not self:getIsVisible() then return; end;
	self.moving = false;
	self.resizing = false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------onResizeUp

function em_window:onResizeUp(_button)
	self.resizing = false;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateResizeWidgets

function em_window:updateResizeWidgets()
	local btnSize = 24;
	local resizeButtons = {
		resize_TL = {x = 0, y = 0},
		resize_TR = {x = self:getWidth() - btnSize, y = 0},
		resize_BL = {x = 0, y = self:getHeight() - btnSize},
		resize_BR = {x = self:getWidth() - btnSize, y = self:getHeight() - btnSize},
	};
	for buttonID, button in pairs(resizeButtons) do
		self[buttonID]:setX(button.x);
		self[buttonID]:setY(button.y);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateWindow


function em_window:updateWindow()

	self:updateResizeWidgets();

	self.minimap:setWidth(self:getWidth() - 25);
	self.minimap:setHeight(self:getHeight() - 25);

	self.advanced_settings:setWidth(self:getWidth() - 24);
	self.advanced_settings:setHeight(self:getHeight() - 24);

	em_core.map.vpcenterX = self:getAbsoluteX() + (self:getWidth() / 2);
	em_core.map.vpcenterY = self:getAbsoluteY() + (self:getHeight() / 2);

	self.coordinateInfoBox:setY(self:getHeight() - 50);
	self.calendarInfoBox:setX(math.max(self:getWidth() - 40 - 160, 200));
	self.calendarInfoBox:setY(self:getHeight() - 50);

	em_settings:update(self);

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------collapse

function em_window:collapse()
	local settings = em_settings.window_geometry;
	if not self.collapsed then
		self.advanced_settings:setVisible(false);
		em_settings:update(self);
		self.collapsed = self.pinned;
		self:setWidth(48);
		self:setHeight(48);
		if self.collapsed == "resize_TR" then
			self:setX(settings.window_x + settings.window_width - 48);
		elseif self.collapsed == "resize_BL" then
			self:setY(settings.window_y + settings.window_height - 48);
		elseif self.collapsed == "resize_BR" then
			self:setX(settings.window_x + settings.window_width - 48);
			self:setY(settings.window_y + settings.window_height - 48);
		end;
		self.minimap:setVisible(false);
		self:updateResizeWidgets();
		self:closeOptionSlider();
		self:updateInfoBoxes();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------expand

function em_window:expand()
	local settings = em_settings.window_geometry;
	self.advanced_settings:setVisible(self.showSettings);
	self.collapsed = false;
	self:setWidth(settings.window_width);
	self:setHeight(settings.window_height);
	self:setX(settings.window_x);
	self:setY(settings.window_y);
	self.minimap:setVisible(true);
	self:updateResizeWidgets();
	self:update();
	em_core.update();
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------moveWindow

function em_window:moveWindow(_x, _y)
	self:setX(self.x + _x);
	self:setY(self.y + _y);
	self:updateWindow();
	self:bringToTop();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------onMouseMove

function em_window:onMouseMove(_x, _y)
	self.mouseOver = true;
	if self.resizing then self:resizeWindow(); return; end;
	if self.moving then self:moveWindow(_x, _y); return; end;
	if self.collapsed and not isMouseButtonDown(0) and not isMouseButtonDown(1) and not isMouseButtonDown(2) then self:expand(); return; end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------onMouseMoveOutside

function em_window:onMouseMoveOutside(_x, _y)
	if self.collapsed then return; end;
	if self.resizing then self:resizeWindow(); return; end;
	if self.moving then self:moveWindow(_x, _y); return; end;
	if self.pinned then self:collapse(); return; end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------resizeWindow

function em_window:resizeWindow()
	if self.collapsed then return; end;
	local resizeBtn = self.resizing;
	local mX, mY = getMouseX(), getMouseY();
	local wX, wY, wW, wH = self:getX(), self:getY(), self:getWidth(), self:getHeight();
	local minimumSize =  em_settings.window_minimumSize;
	local x, y, width, height = 0, 0, 0, 0;
	local rect = {};
	rect.x1 = wX;
	rect.y1 = wY;
	rect.x2 = wX + wW;
	rect.y2 = rect.y1;
	rect.x3 = rect.x1;
	rect.y3 = rect.y1 + wH;
	rect.x4 = rect.x2;
	rect.y4 = rect.y3;
	if resizeBtn == "resize_TL" then
		rect.x1 = rect.x1 - (rect.x1 - mX);
		rect.y1 = rect.y1 - (rect.y1 - mY);
		wW, wH = rect.x2 - rect.x1, rect.y3 - rect.y1;
		rect.x2 = rect.x1 + wW;
		rect.y2 = rect.y1;
		rect.x3 = rect.x1;
		rect.y3 = rect.y1 + wH;
	elseif resizeBtn == "resize_TR" then
		rect.x2 = rect.x1 - (rect.x1 - mX)
		rect.y2 = rect.y2 - (rect.y2 - mY)
		wW, wH = rect.x2 - rect.x1, rect.y4 - rect.y2;
		rect.x1 = rect.x2 - wW;
		rect.y1 = rect.y2;
		rect.x4 = rect.x2;
		rect.y4 = rect.y2 + wH; 
	elseif resizeBtn == "resize_BL" then
		rect.x3 = rect.x3 - (rect.x3 - mX)
		rect.y3 = rect.y3 - (rect.y3 - mY)
		wW, wH = rect.x4 - rect.x3, rect.y3 - rect.y1;
		rect.x1 = rect.x3;
		rect.y1 = rect.y3 - wH;
		rect.x4 = rect.x3 + wW;
		rect.y4 = rect.y2; 
	elseif resizeBtn == "resize_BR" then
		rect.x4 = rect.x4 - (rect.x4 - mX);
		rect.y4 = rect.y4 - (rect.y4 - mY);
		wW, wH = rect.x4 - rect.x3, rect.y4 - rect.y2;
		rect.x3 = rect.x4 - wW;
		rect.y3 = rect.y4;
		rect.x2 = rect.x4;
		rect.y2 = rect.y4 - wH;
	end;
	width = math.max(wW, minimumSize);
	height = math.max(wH, minimumSize);
	if width ~= minimumSize then self:setX(rect.x1); end;
	if height ~= minimumSize then self:setY(rect.y1); end;
	self:setWidth(width);
	self:setHeight(height);
	self:updateWindow();
	em_core.update();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------onResizePin

function em_window:onResizePin()
	if em_core.window.collapsed then return; end;
	local doublePinned = em_core.window.pinned == self.internal;
	if em_core.window.pinned then em_core.window[em_core.window.pinned]:setImage(em_window.mapButtonTex[em_core.window.pinned]); em_core.window.pinned = false; end;
	if doublePinned then return; end;
	em_core.window.pinned = self.internal;
	em_core.window[self.internal]:setImage(em_window.mapButtonTex[self.internal .. "_pinned"])
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------onResizeDown

function em_window:onResizeDown(_button)
	if self.collapsed then return; end;
	self.resizing = _button.internal;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------onButtonClick

function em_window:onButtonClick(_button)
	local internal = _button.internal;
	local clickedSameSliderButtonTwice = self.slider and internal == self.slider.internal;
	if self.slider then self:closeOptionSlider(); end;
	if clickedSameSliderButtonTwice then return true; end;
	if internal == "button_zoomLevel" or internal == "button_transparencyLevel" then
		em_core.mapDebugX = 0;
		em_core.mapDebugY = 0;
		self:createOptionSlider(_button);
	end;
	if internal == "button_viewMode" then
		em_settings.map_settings.viewMode = em_settings.map_settings.viewMode == 1 and 2 or 1;
	end;
	if internal == "button_gridToggle" then
		em_settings.context_settings.gridToggle.enabled = not em_settings.context_settings.gridToggle.enabled;
		em_core.map:updateGridLines();
	end;
	if internal == "button_addMarker" then
		if em_core.editmarkerwindow then em_core.editmarkerwindow:close(); end;
		em_core.editmarkerwindow = em_editmarker:new(nil, em_core.map.vpCenterXInWorld, em_core.map.vpCenterYInWorld);
		em_core.editmarkerwindow:initialise();
	end;
	if internal == "button_lockOn" then
		self.minimap:getNextIconToFollow();
	end;
	if internal == "button_settings_icon" then
		self.showSettings = not self.showSettings;
		self.advanced_settings:setVisible(self.showSettings);
		if self.showSettings then
			self.prev_x = self:getX();
			self.prev_y = self:getY();
			self.prev_width = self:getWidth();
			self.prev_height = self:getHeight();
			if self.prev_width < 500 then
				self:setWidth(500);
			end;
			if self.prev_height < 750 then
				self:setHeight(750);
			end;
		else
			self:setWidth(self.prev_width);
			self:setHeight(self.prev_height);
			self:setX(self.prev_x);
			self:setY(self.prev_y);
		end;
	end;
	self:updateWindow();
	return true;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------onRadioBeaconClick

function em_window:onRadioBeaconClick(_button)
	if em_core.radioInfoBox then em_core.radioInfoBox:close(); end;
	if em_core.iconInfoBox then em_core.iconInfoBox:close(); end;
	em_core.iconInfoBox = em_iconInfoBox:new(_button.icon, getMouseX(), getMouseY());
	em_core.iconInfoBox:initialise();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------onRadioClick

function em_window:onRadioClick(_button)
	if em_core.iconInfoBox then em_core.iconInfoBox:close(); end;
	if em_core.radioInfoBox then 
		if em_core.radioInfoBox.radioID == _button.radio.radioID then
			em_core.radioInfoBox:close();
			em_core.radioInfoBox = nil;
			return;
		else
			em_core.radioInfoBox:close();
		end;
	end;
	em_core.radioInfoBox = em_radioInfoBox:new(_button.radio, getMouseX(), getMouseY());
	em_core.radioInfoBox:initialise();
	em_core.radioInfoBox.radioID = _button.radio.radioID;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateRadioButtons

function em_window:updateRadioButtons()
	local x, y = 40, 12;
	local freqs = {};
	for buttonID, button in pairs(self.radio_buttons) do
		self[buttonID]:setVisible(false);
	end;
	if em_settings.context_settings.radioToggle.enabled and em_settings.context_settings.radioInfoToggle.enabled then
		for plID, player in pairs(em_radio.radios) do
			for radioID, radio in pairs(player) do
				freqs[radio.channel] = true;
				if self[radioID] then
					self[radioID].radio = radio;
					self[radioID]:setTooltip(radio.user .. " on channel " .. radio.channel / 1000 .. "Mhz");
					self[radioID]:setVisible(true);
					self[radioID]:setX(x);
					x = x + 34;
				else
					self[radioID] = ISButton:new(x, y, 24, 24, "", self, em_window.onRadioClick);
					self[radioID]:initialise();
					self[radioID]:instantiate();
					self[radioID]:setImage(self.mapButtonTex.button_radio);
					self[radioID].displayBackground = false;
					self[radioID]:setTooltip(radio.user .. " on channel " .. radio.channel / 1000 .. "Mhz");
					self[radioID].internal = radioID;
					self[radioID].textureColor = {r = radio.r, g = radio.g, b = radio.b, a = radio.a};
					self[radioID].radio = radio;
					self:addChild(self[radioID]);
					self.radio_buttons[radioID] = self[radioID];
					x = x + 34;
				end;
			end;
		end;
		for iconID, icon in pairs(em_core.mapIconMetaGroup.groups.radioPingGroup.mapIcons) do
			if freqs[icon.channel] then
				if self[iconID] then
					self[iconID]:setVisible(true);
					self[iconID]:setX(x);
					x = x + 34;
				else
					self[iconID] = ISButton:new(x, y, 24, 24, "", self, em_window.onRadioBeaconClick);
					self[iconID]:initialise();
					self[iconID]:instantiate();
					self[iconID]:setImage(em_mapIconGroupBase.mapIconTex.player_circle);
					self[iconID].displayBackground = false;
					self[iconID]:setTooltip(icon.iconData);
					self[iconID].internal = radioID;
					self[iconID].textureColor = {r = icon.r, g = icon.g, b = icon.b, a = icon.a};
					self[iconID].icon = icon;
					self:addChild(self[iconID]);
					self.radio_buttons[iconID] = self[iconID];
					x = x + 34;
				end;
			else
				em_radio:removeBeacon(icon.iconID);
				em_core.mapIconMetaGroup.groups.radioPingGroup:updateGroup();
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateButtons

function em_window:updateButtons()

	local settings = em_settings.context_settings;
	local button_settings = em_settings.button_settings;

	for buttonID, button in pairs(button_settings) do
		self[buttonID]:setVisible(settings[button.toggle].enabled and not em_settings.window_geometry.compactMode and not self.collapsed);
	end;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------createButtons

function em_window:createButtons()
	local btnSize = 24;
	local btnSpacing = 28;
	local settings = em_settings.context_settings;
	local button_settings = em_settings.button_settings;
	local buttonObj;
	for buttonID, button in pairs(button_settings) do
		buttonObj = ISButton:new(10, button.index * btnSpacing, btnSize, btnSize, "", self, em_window.onButtonClick);
		self:appendTable(button, buttonObj);
		buttonObj:initialise();
		buttonObj:instantiate();
		buttonObj:setImage(self.mapButtonTex[buttonID]);
		buttonObj.displayBackground = false;
		buttonObj:setTooltip(button.tooltip);
		self[buttonID] = buttonObj;
		self:addChild(self[buttonID]);
		self[buttonID]:setVisible(settings[button.toggle].enabled and not em_settings.window_geometry.compactMode);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------createChildren

function em_window:createChildren()
	local btnSize = 24;
	local resizeButtons = {
		resize_TL = {x = 0, y = 0},
		resize_TR = {x = self:getWidth() - btnSize, y = 0},
		resize_BL = {x = 0, y = self:getHeight() - btnSize},
		resize_BR = {x = self:getWidth() - btnSize, y = self:getHeight() - btnSize},
	};
	for buttonID, button in pairs(resizeButtons) do
		self[buttonID] = ISButton:new(button.x, button.y, btnSize, btnSize, "", self, em_window.onResizeUp, em_window.onResizeDown);
		self[buttonID].internal = buttonID;
		self[buttonID].onRightMouseUp = em_window.onResizePin;
		self[buttonID]:initialise();
		self[buttonID]:instantiate();
		self[buttonID]:setImage(self.mapButtonTex[buttonID]);
		self[buttonID].displayBackground = false;
		self[buttonID]:setTooltip(em_translationData.tooltip_window_resize);
		self[buttonID]:setVisible(true);
		self:addChild(self[buttonID]);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------createMinimap

function em_window:createMinimap()

	self.minimap = em_minimap:new(self);

	em_core.minimap = self.minimap;

	self.minimap:initialise();

	self:addChild(self.minimap);

	self.minimap:setX(13);
	self.minimap:setY(13);

	self.minimap:setWidth(self:getWidth() - 24);
	self.minimap:setHeight(self:getHeight() - 24);

	self.coordinateInfoBox = em_coordinateInfoBox:new()
	self.calendarInfoBox = em_calendarInfoBox:new()

	self.coordinateInfoBox:initialise();
	self.calendarInfoBox:initialise();

	self:addChild(self.coordinateInfoBox);
	self:addChild(self.calendarInfoBox);

	self.coordinateInfoBox:setX(40);
	self.coordinateInfoBox:setY(self:getHeight() - 50);
	self.coordinateInfoBox:setWidth(160);
	self.coordinateInfoBox:setHeight(30);

	self.calendarInfoBox:setX(math.max(self:getWidth() - 40 - 160, 200));
	self.calendarInfoBox:setY(self:getHeight() - 50);
	self.calendarInfoBox:setWidth(160);
	self.calendarInfoBox:setHeight(30);

	self.advanced_settings = em_advanced_settings:new()

	em_core.advanced_settings = self.advanced_settings;

	self.advanced_settings:initialise();

	self:addChild(self.advanced_settings);

	self.advanced_settings:setX(13);
	self.advanced_settings:setY(13);

	self.advanced_settings:setWidth(self:getWidth() - 24);
	self.advanced_settings:setHeight(self:getHeight() - 24);

	self.advanced_settings:setVisible(false);

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------prerender

function em_window:prerender()

	local width = self:getWidth();
	local height = self:getHeight();
	local w2, h2 = width - 12, height - 12;
	local w3, h3 = width - 23, height - 23;
	local bga, bgr, bgg, bgb = self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b;

	self:drawRect(12, 12, w3, h3, em_settings.map_settings.transparencyLevel, 0, 0, 0);

	self:drawRect(0, 0, 12, height, bga, bgr, bgg, bgb);
	self:drawRect(w2, 0, 12, height, bga, bgr, bgg, bgb);
	self:drawRect(0, 0, width, 12, bga, bgr, bgg, bgb);
	self:drawRect(0, h2, width, 12, bga, bgr, bgg, bgb);

	self:drawRectBorder(12, 12, w3, h3, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------render

function em_window:render()

	local height = self:getHeight();
	local width = self:getWidth();

	if self.clearStencil then
		self:clearStencilRect();
	end;

	self:drawRectBorder(0, 0, width, height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

	if self.drawJoypadFocus then
		self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), 0.4, 0.2, 1.0, 1.0);
		self:drawRectBorder(1, 1, self:getWidth()-2, self:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
	end;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------update

function em_window:update()

	em_settings:update(self);

	self:updateButtons();

	self:updateInfoBoxes();

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------initialise

function em_window:initialise()
	ISCollapsableWindow.initialise(self);
	em_settings:load();
	em_settings:apply(self);
	self:createMinimap();
	self:createButtons();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------close

function em_window:close()
	em_core.kill();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------new

function em_window:new(_x, _y, _w, _h)
	local window_border = em_settings.color_settings.window_border;
	local window_background = em_settings.color_settings.window_background;
	local o = ISCollapsableWindow:new(_x,_y,_w,_h);

	setmetatable(o, self)
	self.__index = self

	o.x = _x;
	o.y = _y;
	o.width = _w;
	o.height = _h;

	o.coreObj = getCore();

	o.buttons = {};

	o.radio_buttons = {};

	o.borderColor = window_border.enabled and window_border.color or {r=0.8, g=0.8, b=0.8, a=1};

	o.backgroundColor = window_background.enabled and window_background.color or {r=0, g=0, b=0, a=0.5};

	o.showSettings = false;

	o.moveWithMouse = false;

	o.ignoreClick = false;

	return o;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------