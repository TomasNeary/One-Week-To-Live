ISUICheatWindow = ISCollapsableWindow:derive("ISUICheatWindow");

--ISUIDummyWindow = ISCollapsableWindow:derive("ISUIDummyWindow"); -- used for perfecting box sizes and such. edit: thanks to the lua editor, I could edit window sizes in-game. no more use for this.
ISUICheatWindow.compassLines = {}

function ISUICheatWindow:initialise()
	ISCollapsableWindow.initialise(self);
end

function ISUICheatWindow:new(x, y, width, height)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.title = "GPS";
	o.pin = false;
	o:noBackground();
	return o;
end

function ISUICheatWindow:createChildren()
	ISCollapsableWindow.createChildren(self);
	self.HomeWindow = ISRichTextPanel:new(0, 16, 250, 100);
	self.HomeWindow:initialise();
	self.HomeWindow.autosetheight = false
	self.HomeWindow:ignoreHeightChange()
	self:addChild(self.HomeWindow)
end


	
-- dummy window --

--[[
function ISUIDummyWindow:initialise()
	ISCollapsableWindow.initialise(self);
end

function ISUIDummyWindow:new(x, y, width, height)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.title = "dummy window";
	o.pin = false;
	return o;
end
--]]


-- end of window creation --

	
function CheatWindowCreate()
	ISUICheatWindow = ISUICheatWindow:new(35, 250, 250, 125)
	ISUICheatWindow:addToUIManager();
	ISUICheatWindow:setVisible(false);
	ISUICheatWindow.pin = true;
	ISUICheatWindow.resizable = true
end

--function ISTextEntryBox:onCommandEntered()
	--local str = ISUILuaWindow.LuaBar:getText()
	--ISUILuaWindow.LuaBar:setText(str.."\n ")
--end



Events.OnGameStart.Add(CheatWindowCreate);