ArmorWindow = ISCollapsableWindow:derive("ArmorWindow");
ArmorWindow.compassLines = {}

-- Calls the parent window initializer. In Lua OOP patterns, colon syntax means
-- self is passed automatically.
function ArmorWindow:initialise()
	ISCollapsableWindow.initialise(self);
end

-- Constructor for the collapsable window. It creates the parent window, assigns
-- this table as its metatable, then sets basic window options.
function ArmorWindow:new(x, y, width, height)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.title = "Armor";
	o.pin = false;
	o:noBackground();
	return o;
end

-- Replaces the rich-text panel text and re-paginates it.
function ArmorWindow:setText(newText)
	ArmorWindow.HomeWindow.text = newText;
	ArmorWindow.HomeWindow:paginate();
end


-- Creates the child rich-text panel inside the window.
function ArmorWindow:createChildren()
	ISCollapsableWindow.createChildren(self);
	self.HomeWindow = ISRichTextPanel:new(0, 16, 375, 455);
	self.HomeWindow:initialise();
	self.HomeWindow.autosetheight = false
	self.HomeWindow:ignoreHeightChange()
	self:addChild(self.HomeWindow)
end

-- Game-start hook that creates the window once and hides it by default.
function CompassWindowCreate()
	ArmorWindow = ArmorWindow:new(35, 250, 375, 455)
	ArmorWindow:addToUIManager();
	ArmorWindow:setVisible(false);
	ArmorWindow.pin = true;
	ArmorWindow.resizable = true
end

Events.OnGameStart.Add(CompassWindowCreate);
