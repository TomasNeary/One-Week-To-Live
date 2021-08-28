----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_editmarker
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

require "ISUI/ISPanel"
require "ISUI/ISWindow"
require "ISUI/ISCollapsableWindow"
require "ISUI/ISLayoutManager"
require "ISUI/ISResizeWidget"

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_editmarker = em_editmarker or ISCollapsableWindow:derive("em_editmarker");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading EM_EDITMARKER ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_editmarker.custom_mapIconTexStr = {
	"house_icon",
	"vehicle_icon",
	"flag_icon",
	"flag_icon_tall",
	"flag_icon_large",
	"pin_icon",
	"pin_icon_medium",
	"pin_icon_large",
	"radio_icon_on",
	"radio_icon_off",
	"danger_icon",
	"electric_icon",
	"ammo_icon",
	"fuel_icon",
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker:fixEntries()
--TODO - Non english charset support
	local minX = (em_core.map.worldMinX) * 300;
	local minY = (em_core.map.worldMinY) * 300;
	local maxX = (em_core.map.worldMaxX + 1) * 300;
	local maxY = (em_core.map.worldMaxY + 1) * 300;

	self.iconDataEntry:setText(self.iconDataEntry:getInternalText():gsub("[^%a%d%s]", ""));
	self.iconDataExtEntry:setText(self.iconDataExtEntry:getInternalText():gsub("[^%a%d%s]", ""));
	if self.iconDataEntry:getInternalText() == "" then
		self.iconDataEntry:setText(self.mapIcon.x .. " x " .. self.mapIcon.y);
	end;
	if self.iconDataExtEntry:getInternalText() == "" then
		self.iconDataExtEntry:setText("Custom Marker");
	end;
	if self.x_Inputbox:getInternalText() == "" or tonumber(self.x_Inputbox:getInternalText()) <= minX or tonumber(self.x_Inputbox:getInternalText()) > maxX then
		self.x_Inputbox:setText(tostring(self.mapIcon.x));
	end;
	if self.y_Inputbox:getInternalText() == "" or tonumber(self.y_Inputbox:getInternalText()) <= minY or tonumber(self.y_Inputbox:getInternalText()) > maxY then
		self.y_Inputbox:setText(tostring(self.mapIcon.y));
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker:update()
	self:updateIcon();
end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker:onChangeColor()
	self:updateIcon();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker:onChangeIcon()
	self:updateIcon();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker:updateIcon()
--TODO - Non english charset support
	if not self.mapIcon then return; end;
	if self.created then
		local minX = (em_core.map.worldMinX) * 300;
		local minY = (em_core.map.worldMinY) * 300;
		local maxX = (em_core.map.worldMaxX + 1) * 300;
		local maxY = (em_core.map.worldMaxY + 1) * 300;

		self.mapIcon.r = self.r_scroll:getVolume() / 10;
		self.mapIcon.g = self.g_scroll:getVolume() / 10;
		self.mapIcon.b = self.b_scroll:getVolume() / 10;
		self.mapIcon.a = self.a_scroll:getVolume() / 10;
		self.r_scroll.backgroundColor = {r=self.mapIcon.r, g=0, b=0, a=self.mapIcon.a};
		self.g_scroll.backgroundColor = {r=0, g=self.mapIcon.g, b=0, a=self.mapIcon.a};
		self.b_scroll.backgroundColor = {r=0, g=0, b=self.mapIcon.b, a=self.mapIcon.a};
		self.a_scroll.backgroundColor = {r=1, g=1, b=1, a=self.mapIcon.a};
		self.iconTexture:setColor(self.mapIcon.r, self.mapIcon.g, self.mapIcon.b);
		self.mapIcon.iconData = self.iconDataEntry:getInternalText();
		self.mapIcon.iconDataExt = self.iconDataExtEntry:getInternalText();
		self.mapIcon.iconTextureExt = self.iconTextureCombo:getOptionText(self.iconTextureCombo.selected);
		self.mapIcon.iconTexture = self.mapIconTex[self.iconTextureCombo:getOptionText(self.iconTextureCombo.selected)];

		local xVal, yVal = tonumber(self.x_Inputbox:getInternalText()), tonumber(self.y_Inputbox:getInternalText());
		if not xVal or xVal <= minX or xVal >= maxX then
			self.x_Inputbox:setValid(false);
			self.x_Inputbox.validData = false;
		else
			self.x_Inputbox:setValid(true);
			self.x_Inputbox.validData = true;
			self.mapIcon.x = xVal;
		end;
		if not yVal or yVal <= minY or yVal > maxY then
			self.y_Inputbox:setValid(false);
			self.y_Inputbox.validData = false;
		else
			self.y_Inputbox:setValid(true);
			self.y_Inputbox.validData = true;
			self.mapIcon.y = yVal;
		end;
		self.iconTexture.texture = self.mapIcon.iconTexture;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker.onKeyPress(_keyPressed)
	if _keyPressed == Keyboard.KEY_ESCAPE then
		if em_core.editmarkerwindow then
			em_core.editmarkerwindow:close();
			if em_core.mapIconMetaGroup.groups.customMarkerGroup.tempMarker then em_core.mapIconMetaGroup.groups.customMarkerGroup:removeIcon(nil); end;
		end;
		Events.OnKeyPressed.Remove(em_editmarker.onKeyPress);
		return;
	end;
	if _keyPressed == Keyboard.KEY_RETURN then
		if em_core.editmarkerwindow then
			em_core.editmarkerwindow:saveMarker();
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker:removeMarker()
	self.customMarkerGroup:removeIcon(self.mapIcon.iconID);
	self.mapIcon = nil;
	self:close();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker:saveMarker()
	self.customMarkerGroup:saveIcon(self.mapIcon.iconID, self.mapIcon);
	self.mapIcon = nil;
	self:close();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker:onClick(_button)
	self:fixEntries();
	if _button.internal == "save" then
		self:saveMarker();
	end;
	if _button.internal == "remove" then
		self:removeMarker();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker:createChildren()

	ISCollapsableWindow.createChildren(self);

	local x = 10
	local y = 30
	local ySpacing = 25;
	local textboxWidth = 150;
	local scrollbarHeight = 12;
	local centerSplit = self.width / 2;
	local xoff = 0;

	self.font_height_small = getTextManager():getFontHeight(UIFont.NewSmall)
	self.font_height_medium = getTextManager():getFontHeight(UIFont.NewMedium)

	self.iconTextureCombo = ISComboBox:new(10, y, 110, self.font_height_small, self, em_editmarker.onChangeIcon)

	for i = 1, #self.custom_mapIconTexStr do
		self.iconTextureCombo:addOption(self.custom_mapIconTexStr[i]);
		if tostring(self.mapIcon.iconTextureExt) == tostring(self.custom_mapIconTexStr[i]) then
			self.iconTextureCombo.selected = i;
		end;
	end;

	self.iconTextureCombo:initialise();
	self:addChild(self.iconTextureCombo)

	self.iconTexture = ISImage:new(self.width - 52, 20, 32, 32, self.mapIconTex.flag_icon);
	self.iconTexture:initialise();
	self.iconTexture:instantiate();
	self:addChild(self.iconTexture);

	y = y + ySpacing;
	self.r_scroll = ISVolumeControl:new(10, y, self.width - 10, scrollbarHeight, self, self.onChangeColor);
	y = y + scrollbarHeight
	self.g_scroll = ISVolumeControl:new(10, y, self.width - 10, scrollbarHeight, self, self.onChangeColor);
	y = y + scrollbarHeight
	self.b_scroll = ISVolumeControl:new(10, y, self.width - 10, scrollbarHeight, self, self.onChangeColor);
	y = y + scrollbarHeight
	self.a_scroll = ISVolumeControl:new(10, y, self.width - 10, scrollbarHeight, self, self.onChangeColor);
	-- y = y + scrollbarHeight
	-- self.size_scroll = ISVolumeControl:new(10, y, self.width - 10, scrollbarHeight, self, self.onChangeColor);

	self.r_scroll.backgroundColor = {r=self.mapIcon.r, g=0, b=0, a=self.mapIcon.a};
	self.g_scroll.backgroundColor = {r=0, g=self.mapIcon.g, b=0, a=self.mapIcon.a};
	self.b_scroll.backgroundColor = {r=0, g=0, b=self.mapIcon.b, a=self.mapIcon.a};
	self.a_scroll.backgroundColor = {r=1, g=1, b=1, a=self.mapIcon.a};
	-- self.size_scroll.backgroundColor = {r=1, g=1, b=1, a=1};

	self.r_scroll:setVolume(self.mapIcon.r * 10);
	self.g_scroll:setVolume(self.mapIcon.g * 10);
	self.b_scroll:setVolume(self.mapIcon.b * 10);
	self.a_scroll:setVolume(self.mapIcon.a * 10);
	-- self.size_scroll:setVolume(self.mapIcon.iconSize * 10);

	self.r_scroll:initialise();
	self:addChild(self.r_scroll);
	self.g_scroll:initialise();
	self:addChild(self.g_scroll);
	self.b_scroll:initialise();
	self:addChild(self.b_scroll);
	self.a_scroll:initialise();
	self:addChild(self.a_scroll);
	-- self.size_scroll:initialise();
	-- self:addChild(self.size_scroll);

	y = y + scrollbarHeight

	self.x_Label = ISLabel:new(10, y, self.font_height_small, "X", 1, 1, 1, 1, UIFont.NewSmall, true);
	self.x_Label:initialise();
	self.x_Label:instantiate();
	self:addChild(self.x_Label);

	self.y_Label = ISLabel:new(90, y, self.font_height_small, "Y", 1, 1, 1, 1, UIFont.NewSmall, true);
	self.y_Label:initialise();
	self.y_Label:instantiate();
	self:addChild(self.y_Label);

	y = y + self.font_height_small;

	self.x_Inputbox = ISTextEntryBox:new(tostring(self.mapIcon.x), 10, y, 70, 20);
	self.x_Inputbox:initialise();
	self.x_Inputbox:instantiate();
	self.x_Inputbox:setOnlyNumbers(true);
	self.x_Inputbox:setMaxLines(1);
	self.x_Inputbox.onOtherKey =  em_editmarker.onKeyPress;
	self.x_Inputbox.onCommandEntered =  em_editmarker.onKeyPress;
	self:addChild(self.x_Inputbox);

	self.y_Inputbox = ISTextEntryBox:new(tostring(self.mapIcon.y), 90, y, 70, 20);
	self.y_Inputbox:initialise();
	self.y_Inputbox:instantiate();
	self.y_Inputbox:setOnlyNumbers(true);
	self.y_Inputbox:setMaxLines(1);
	self.y_Inputbox.onOtherKey =  em_editmarker.onKeyPress;
	self.y_Inputbox.onCommandEntered =  em_editmarker.onKeyPress;
	self:addChild(self.y_Inputbox);

	y = y + ySpacing;

	self.iconDataLabel = ISLabel:new(x, y, self.font_height_small, "Name", 1, 1, 1, 1, UIFont.NewSmall, true);
	self.iconDataLabel:initialise();
	self.iconDataLabel:instantiate();
	self:addChild(self.iconDataLabel);

	y = y + self.font_height_small;

	self.iconDataEntry = ISTextEntryBox:new(tostring(self.mapIcon.iconData), 10, y, textboxWidth, 20);
	self.iconDataEntry:initialise();
	self.iconDataEntry:instantiate();
	self.iconDataEntry:setMaxLines(1);
	self.iconDataEntry.onOtherKey = em_editmarker.onKeyPress;
	self.iconDataEntry.onCommandEntered = em_editmarker.onKeyPress;
	self:addChild(self.iconDataEntry);

	y = y + ySpacing;

	self.iconDataExtLabel = ISLabel:new(x, y, self.font_height_small, "Info", 1, 1, 1, 1, UIFont.NewSmall, true);
	self.iconDataExtLabel:initialise();
	self.iconDataExtLabel:instantiate();
	self:addChild(self.iconDataExtLabel);

	y = y + self.font_height_small;

	self.iconDataExtEntry = ISTextEntryBox:new(tostring(self.mapIcon.iconDataExt), 10, y, textboxWidth, 20);
	self.iconDataExtEntry:initialise();
	self.iconDataExtEntry:instantiate();
	self.iconDataExtEntry:setMaxLines(1);
	self.iconDataExtEntry.onOtherKey = em_editmarker.onKeyPress;
	self.iconDataExtEntry.onCommandEntered = em_editmarker.onKeyPress;
	self:addChild(self.iconDataExtEntry);

	y = y + ySpacing;

	self.save_button = ISButton:new(10, y, 70, 20, em_translationData.label_save, self, em_editmarker.onClick);
	self.save_button.internal = "save";
	self.save_button:initialise();
	self.save_button:instantiate();
	self:addChild(self.save_button);

	self.save_button = ISButton:new(90, y, 70, 20, em_translationData.label_remove, self, em_editmarker.onClick);
	self.save_button.internal = "remove";
	self.save_button:initialise();
	self.save_button:instantiate();
	self:addChild(self.save_button);

	self.entryBoxes = {self.iconDataEntry, self.iconDataExtEntry, self.x_Inputbox, self.y_Inputbox};

	self.created = true;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker:close()
	if self.mapIcon and self.customMarkerGroup.tempMarker then self.customMarkerGroup:removeIcon(self.mapIcon.iconID); end;
	Events.OnKeyPressed.Remove(em_editmarker.onKeyPress);
	self:setVisible(false);
	self:removeFromUIManager();
	em_core.editmarkerwindow = nil;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker:initialise()
	ISPanel.initialise(self)
	em_core.mapIconMetaGroup.groups.customMarkerGroup:updateGroup();
	Events.OnKeyPressed.Add(em_editmarker.onKeyPress);
	self:addToUIManager();
	self:setVisible(true);
	self:bringToTop();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_editmarker:new(_mapIcon, _x, _y)
	local window_background = em_settings.color_settings.window_background;

	local x, y = getMouseX(), getMouseY();
	local w, h = 170, 250;
	local core = getCore();
	if x + w > core:getScreenWidth() then
		x = core:getScreenWidth() - w - 10;
	end;
	if y + h > core:getScreenHeight() then
		y = core:getScreenHeight() - h - 10;
	end;

	local _x, _y = math.floor(_x or em_core.map.vpCenterXInWorld), math.floor(_y or em_core.map.vpCenterYInWorld);
	local o = ISCollapsableWindow:new(x,y,w,h);

	setmetatable(o, self)
	self.__index = self

	o.x = x;
	o.y = y;
	o.width = w;
	o.height = h;
	o.resizable = false;

	o.backgroundColor = window_background.enabled and window_background.color or {r=0, g=0, b=0, a=1};

	o.created = false;

	o.mapIconTex = em_mapIconGroupBase.mapIconTex;

	o.customMarkerGroup =  em_core.mapIconMetaGroup.groups.customMarkerGroup;

	o.mapIcon = _mapIcon or o.customMarkerGroup:createIcon(_x, _y);

	o.title = em_translationData.label_window_custom_marker;

	return o

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------