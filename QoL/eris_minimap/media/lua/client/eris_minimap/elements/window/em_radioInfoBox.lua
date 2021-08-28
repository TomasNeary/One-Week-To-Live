----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_radioInfoBox
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
require "ISUI/ISPanel"
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_radioInfoBox = ISPanel:derive("em_radioInfoBox");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioInfoBox:onMouseUpOutside()
	if not self.pinned then self:close(); end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioInfoBox:onButtonClick(_button)
	if _button.internal == "pin" then
		self.pinned = not self.pinned;
		if self.pinned then
			self.pinButton:setImage(em_window.mapButtonTex.button_lockOn);
		else
			self.pinButton:setImage(em_window.mapButtonTex.button_lockOff);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioInfoBox:prerender()
	if self.showBackground then self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b); end;
	if self.showBorder then self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b); end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioInfoBox:update()
	self.text = {
		channel = em_translationData.label_channel .. self.radio.channel / 1000 .. " MHz" or "",
		range = em_translationData.label_range .. self.radio.range .. " m" or "",
		battery = em_translationData.label_battery .. self.radio.batteryLevel .. " %" or "",
		transmit = em_translationData.label_transmit .. tostring(self.radio.mode.tx) or "",
		receive = em_translationData.label_receive .. tostring(self.radio.mode.rx) or ""
	};
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioInfoBox:render()
	local yOff = 1;
	for id, text in pairs(self.text) do
		self:drawText(text or "", 34, yOff, 1, 1, 1, 1, UIFont.NewMedium);
		yOff = yOff + self.font_height_medium;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioInfoBox:close()
	self:setVisible(false);
	self:removeFromUIManager();
	em_core.radioInfoBox = nil;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioInfoBox:initialise()
	ISPanel.initialise(self);
	self:update();
	for id, text in pairs(self.text) do
		self:setWidth(math.max(getTextManager():MeasureStringX(UIFont.NewMedium, text) + 64, self:getWidth()));
	end;
	self:setHeight(self.font_height_medium * 6);
	self.pinButton = ISButton:new(self:getWidth() - 24, 0, 24, 24, "", self, em_radioInfoBox.onButtonClick);
	self.pinButton:initialise();
	self.pinButton:instantiate();
	self.pinButton:setImage(em_window.mapButtonTex.button_lockOff);
	self.pinButton.displayBackground = false;
	self.pinButton:setTooltip("Pin This");
	self.pinButton.textureColor = {r = 1, g = 1, b = 1, a = 1};
	self.pinButton.icon = self.icon;
	self.pinButton.iconGroup = iconGroup;
	self.pinButton.internal = "pin";
	self:addChild(self.pinButton);
	self:addToUIManager();
	self:setVisible(true);
	self:bringToTop();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_radioInfoBox:new(_radio, _x, _y)
	local window_background = em_settings.color_settings.window_background;
	local o = ISPanel:new(_x, _y,0,0);
	setmetatable(o, self)
		self.__index = self;
		o.radio = _radio;
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