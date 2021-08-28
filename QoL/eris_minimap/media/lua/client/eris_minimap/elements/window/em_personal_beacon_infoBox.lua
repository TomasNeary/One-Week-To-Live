----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_personal_beacon_infoBox
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
require "ISUI/ISPanel"
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_personal_beacon_infoBox = ISPanel:derive("em_personal_beacon_infoBox");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_personal_beacon_infoBox:onMouseUpOutside()
	if not self.pinned then self:close(); end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_personal_beacon_infoBox:onChangeSlider(_target, _value)
	self.item:getModData()["channel"] = 10000 * _value;
	em_personal_beacon.doItemName(self.item);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_personal_beacon_infoBox:onButtonClick(_button)
	if _button.internal == "pin" then
		self.pinned = not self.pinned;
		if self.pinned then
			self.pinButton:setImage(em_window.mapButtonTex.button_lockOn);
		else
			self.pinButton:setImage(em_window.mapButtonTex.button_lockOff);
		end;
	end;
	if _button.internal == "channel" then
		if not self.slider:getIsVisible() then
			if not self.pinned then self:onButtonClick({internal = "pin"}); end;
			self.slider:setVisible(true);
		else
			if self.pinned then self:onButtonClick({internal = "pin"}); end;
			self.slider:setVisible(false);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_personal_beacon_infoBox:prerender()
	if self.showBackground then self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b); end;
	if self.showBorder then self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b); end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_personal_beacon_infoBox:update()
	if self.item then
		self.text = {
			name = self.item:getModData()["name"] or nil,
			channel = em_translationData.label_channel .. self.item:getModData()["channel"] / 1000 .. "MHz" or nil,
			range = em_translationData.label_range .. self.item:getModData()["range"] .. " m" or nil,
			battery = em_translationData.label_battery .. math.floor(self.item:getModData()["battery"] / self.item:getModData()["maxBattery"] * 10000) / 100 .. " %" or nil,
		};
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_personal_beacon_infoBox:render()
	local yOff = 1;
	for id, text in pairs(self.text) do
		self:drawText(text or "", 34, yOff, 1, 1, 1, 1, UIFont.NewMedium);
		yOff = yOff + self.font_height_medium;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_personal_beacon_infoBox:close()
	self:setVisible(false);
	self:removeFromUIManager();
	em_core.radioInfoBox = nil;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_personal_beacon_infoBox:initialise()
	ISPanel.initialise(self);
	self:update();
	for id, text in pairs(self.text) do
		self:setWidth(math.max(getTextManager():MeasureStringX(UIFont.NewMedium, text) + 64, self:getWidth()));
	end;
	self:setHeight(self.font_height_medium * 5);
	self.pinButton = ISButton:new(self:getWidth() - 24, 0, 24, 24, "", self, em_personal_beacon_infoBox.onButtonClick);
	self.pinButton:initialise();
	self.pinButton:instantiate();
	self.pinButton:setImage(em_window.mapButtonTex.button_lockOff);
	self.pinButton.displayBackground = false;
	self.pinButton:setTooltip(em_translationData.label_pin);
	self.pinButton.textureColor = {r = 1, g = 1, b = 1, a = 1};
	self.pinButton.icon = self.icon;
	self.pinButton.iconGroup = iconGroup;
	self.pinButton.internal = "pin";
	self:addChild(self.pinButton);
	self.channelButton = ISButton:new(0, 0, 24, 24, "", self, em_personal_beacon_infoBox.onButtonClick);
	self.channelButton:initialise();
	self.channelButton:instantiate();
	self.channelButton:setImage(em_window.mapButtonTex.button_radio);
	self.channelButton.displayBackground = false;
	self.channelButton:setTooltip(em_translationData.label_set_channel);
	self.channelButton.textureColor = {r = 1, g = 1, b = 1, a = 1};
	self.channelButton.icon = self.icon;
	self.channelButton.iconGroup = iconGroup;
	self.channelButton.internal = "channel";
	self:addChild(self.channelButton);

	self.slider = em_slider:new(34, self:getHeight() - 16, 120, 16, self.item:getModData()["channel"] / 10000, 1, 100, "channel", self, em_personal_beacon_infoBox.onChangeSlider);
	self.slider:initialise();
	self.slider.sliderColor = {r = 0, g = 0, b = 0, a = 1};
	self.slider.backgroundColor = {r = 0, g = 0, b = 0, a = 1};
	self:addChild(self.slider);
	self.slider:setWidth(120);
	self.slider:setHeight(16);
	self.slider:setX(34);
	self.slider:setY(self:getHeight() - 16);
	self.slider:setVisible(false);

	self:addToUIManager();
	self:setVisible(true);
	self:bringToTop();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_personal_beacon_infoBox:new(_item, _x, _y)
	local window_background = em_settings.color_settings.window_background;
	local o = ISPanel:new(_x, _y,0,0);
	setmetatable(o, self)
		self.__index = self;
		o.item = _item;
		o.text = {};
		o.font_height_medium = getTextManager():getFontHeight(UIFont.NewMedium)
		o.showBackground = true;
		o.showBorder = true;
		o.backgroundColor = window_background.enabled and window_background.color or {r=0, g=0, b=0, a=1};
		o.borderColor = {r=1, g=1, b=1, a=1};
		o.moveWithMouse = true;
		o.pinned = false;
	return o;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------