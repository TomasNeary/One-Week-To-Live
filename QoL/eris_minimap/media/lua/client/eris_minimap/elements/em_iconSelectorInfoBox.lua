----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_iconSelectorInfoBox
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
require "ISUI/ISPanel"
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_iconSelectorInfoBox = ISPanel:derive("em_iconSelectorInfoBox");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconSelectorInfoBox:onMouseUp()
	self:close();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconSelectorInfoBox:onMouseUpOutside()
	self:close();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconSelectorInfoBox:onButtonClick(_button)
	if _button.iconGroup == "customMarkerGroup" then
		if em_core.editmarkerwindow then em_core.editmarkerwindow:close(); end;
		em_core.editmarkerwindow = em_editmarker:new(_button.icon, _button.icon.x, _button.icon.y);
		em_core.editmarkerwindow:initialise();
	else
		if _button.iconGroup == "localPlayerGroup" then
			if em_core.avatarInfoBox then em_core.avatarInfoBox:close(); end;
			em_core.avatarInfoBox = em_avatarInfoBox:new(_button.icon, getMouseX(), getMouseY(), true);
			em_core.avatarInfoBox:initialise();
		elseif _button.iconGroup == "cellObjectGroup" and _button.icon.class == "Player" then
			if em_core.avatarInfoBox then em_core.avatarInfoBox:close(); end;
			em_core.avatarInfoBox = em_avatarInfoBox:new(_button.icon, getMouseX(), getMouseY(), false);
			em_core.avatarInfoBox:initialise();
		elseif _button.iconGroup == "safehouseGroup" then
			if em_core.safehouseInfoBox then em_core.safehouseInfoBox:close(); end;
			em_core.safehouseInfoBox = em_safehouseInfoBox:new(_button.icon, getMouseX(), getMouseY());
			em_core.safehouseInfoBox:initialise();
		else
			if em_core.iconInfoBox then em_core.iconInfoBox:close(); end;
			em_core.iconInfoBox = em_iconInfoBox:new(_button.icon, getMouseX(), getMouseY());
			em_core.iconInfoBox:initialise();
		end;
	end;
	self:close();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconSelectorInfoBox:prerender()
	if self.showBackground then self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b); end;
	if self.showBorder then self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b); end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconSelectorInfoBox:initialise()
	ISPanel.initialise(self);
	local x, y = 10, 10;
	local columns = 5;
	local col = 1;
	local rows = 1;
	local items = 0;
	for iconGroup, icons in pairs(self.icons) do
		for iconID, icon in pairs(icons) do
			if icon.iconData ~= "Destroyed Vehicle" and icon.iconData ~= "Zombie" then
				self[iconID] = ISButton:new(x, y, 24, 24, "", self, em_iconSelectorInfoBox.onButtonClick);
				self[iconID]:initialise();
				self[iconID]:instantiate();
				self[iconID]:setImage(icon.iconTexture);
				self[iconID].displayBackground = true;
				self[iconID]:setTooltip(icon.iconData);
				self[iconID].internal = iconID;
				self[iconID].textureColor = {r = icon.r, g = icon.g, b = icon.b, a = icon.a};
				self[iconID].icon = icon;
				self[iconID].iconGroup = iconGroup;
				self:addChild(self[iconID]);
				x = x + 34;
				col = col + 1;
				if col > columns then
					x = 10;
					y = y + 34;
					col = 1;
					rows = rows + 1;
				end;
				items = items + 1;
			end;
		end;
	end;
	items = math.min(items, columns);
	self:setWidth((items * 34) + 10);
	self:setHeight(rows * 34 + 10);
	self:addToUIManager();
	self:bringToTop();
	if items == 0 then self:close(); end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconSelectorInfoBox:close()
	self:setVisible(false);
	self:removeFromUIManager();
	self = nil;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_iconSelectorInfoBox:new(_icons, _x, _y)
	local window_background = em_settings.color_settings.window_background;
	local o = ISPanel:new(_x, _y,0,0);
	setmetatable(o, self)
		self.__index = self;
		o.icons = _icons;
		o.timer = getTimestampMs();
		o.closeDelay = 2000;
		o.font_height_medium = getTextManager():getFontHeight(UIFont.NewMedium)
		o.showBackground = true;
		o.showBorder = true;
		o.backgroundColor = window_background.enabled and window_background.color or {r=0, g=0, b=0, a=1};
		o.borderColor = {r=1, g=1, b=1, a=0.5};
	return o;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------