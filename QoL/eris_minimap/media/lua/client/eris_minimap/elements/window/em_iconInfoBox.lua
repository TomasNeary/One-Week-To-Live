----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_iconInfoBox
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
require "ISUI/ISPanel"
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_iconInfoBox = ISPanel:derive("em_iconInfoBox");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconInfoBox:onMouseUpOutside()
	if not self.pinned then self:close(); end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconInfoBox:onButtonClick(_button)
	if _button.internal == "follow" then
		em_core.minimap:setFollowIcon(_button.icon);
	end;
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

function em_iconInfoBox:prerender()
	if self.showBackground then self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b); end;
	if self.showBorder then self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b); end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconInfoBox:render()
	local yOff = 1;
	self:drawText(self.icon.iconData or "", 34, yOff, 1, 1, 1, 1, UIFont.NewMedium);
	yOff = yOff + self.font_height_medium;
	self:drawText(self.icon.iconDataExt or "", 34, yOff, 1, 1, 1, 1, UIFont.NewMedium);
	yOff = yOff + self.font_height_medium;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconInfoBox:close()
	self:setVisible(false);
	self:removeFromUIManager();
	em_core.iconInfoBox = nil;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconInfoBox:initialise()
	ISPanel.initialise(self);
	self:setHeight(88);
	self:setWidth(math.max(getTextManager():MeasureStringX(UIFont.NewMedium, self.icon.iconData) + 64, self:getWidth()));
	self:setWidth(math.max(getTextManager():MeasureStringX(UIFont.NewMedium, self.icon.iconDataExt) + 64, self:getWidth()));
	self.followButton = ISButton:new(0, 0, 24, 24, "", self, em_iconInfoBox.onButtonClick);
	self.followButton:initialise();
	self.followButton:instantiate();
	self.followButton:setImage(em_window.mapButtonTex.button_lockOn);
	self.followButton.displayBackground = false;
	self.followButton:setTooltip(em_translationData.label_follow);
	self.followButton.textureColor = {r = self.icon.r, g = self.icon.g, b = self.icon.b, a = self.icon.a};
	self.followButton.icon = self.icon;
	self.followButton.iconGroup = iconGroup;
	self.followButton.internal = "follow";
	self:addChild(self.followButton);
	self.pinButton = ISButton:new(self:getWidth() - 24, 0, 24, 24, "", self, em_iconInfoBox.onButtonClick);
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
	self:addToUIManager();
	self:setVisible(true);
	self:bringToTop();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconInfoBox:new(_icon, _x, _y)
	local window_background = em_settings.color_settings.window_background;
	local o = ISPanel:new(_x, _y,0,0);
	setmetatable(o, self)
		self.__index = self;
		o.icon = _icon;
		o.timer = getTimestampMs();
		o.closeDelay = 2000;
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