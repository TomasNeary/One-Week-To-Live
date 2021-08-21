crucibleUI = ISCollapsableWindow:derive("crucibleUI")
--crucibleText = ISPanel:derive("crucibleText")
--crucibleContext = ISUIElement:derive("crucibleContext")


function crucibleUI:initialise()
	ISCollapsableWindow.initialise(self)
end

function crucibleUI:createChildren()
	ISCollapsableWindow.createChildren(self);
	self.srchString = nil; -- to prevent scoping problems.
	self.curCat = "Normal" -- default is "Normal"
	local bh = self:titleBarHeight()
	local rh = self:resizeWidgetHeight() or 0
	
	self.catPanel = crucibleList:new(0,bh,self.width, self.height * 0.05) -- scrollable panel for categories
	self.catPanel.horizontal = true
	self.catPanel:initialise()
	local i = 0
	for k,v in pairs(crucibleCore.items) do
		local w = self.catPanel.width / 4
		local x = w * (i)
		local cat = k
		i = i+1
		local pnl = ISButton:new(0 + x,0,w,self.catPanel.height - 15, cat, self, function() self.curCat = cat; self:repopulate(); end)
		pnl.cat = cat
		
		function pnl:update()
		    breakpoint(); -- I don't know why there's a breakpoint here, but ISButton implements it so I'm assuming it's important
			ISUIElement.update(self)
			
			if self.cat == self.target.curCat then
				self.backgroundColor = {r=0.3, g=0.3, b=0.3, a=0.8}
			else
				self.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.8}
			end
		end
		
		pnl.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.8}
		pnl.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
		self.catPanel:addChild(pnl)
	end
	
	self.catPanel:setScrollWidth(i * (self.catPanel.width * 0.30))
	self:addChild(self.catPanel)
	
	--self.catPanel:setScrollWidth( (#crucibleCore.categories * (self.catPanel.width * 0.30)) - (self.catPanel.width - self.catPanel.hscroll:getWidth()))
	self.catPanel:setScrollWidth( (i * (self.catPanel.width / 4)) - (self.catPanel.width - self.catPanel.hscroll:getWidth()))
	self.catPanel.hscroll:setWidth(self.catPanel.width)
	
	self.btmPanel = ISPanel:new(0,crucibleCore.scale(self.height,0.05,true) - (bh - rh),self.width,self.height * 0.05)
	self.btmPanel:initialise()
	self.btmPanel.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.8}
	self:addChild(self.btmPanel)
	
	self.srchBar = ISTextEntryBox:new("", self.btmPanel.width * 0.05, self.btmPanel.height / 5, self.btmPanel.width * 0.30, crucibleCore.scale(self.btmPanel.height,0.40,true));
	self.srchBar:initialise()
	function self.srchBar.onTextChange()
		self.srchString = string.lower(self.srchBar:getInternalText())
		self.contPanel:clearChildren();
		self.contPanel:populate(self.srchString:len() > 0 and "All" or self.curCat, self.srchString);
		self.contPanel:createChildren()
	end
	self.srchBar:setAlwaysOnTop(true)
	
	
	self.srchIcon = ISImage:new(self.srchBar.x,self.srchBar.y + 2, 0,0,getTexture("media/UI/crucibleUI/search.png"))
	--self.srchIcon.backgroundColor = {r=0.6, g=0.6, b=0.6, a=1}
	self.srchIcon.scaledWidth = (self.srchBar.width / 4) * 0.80
	self.srchIcon.scaledHeight = (self.srchBar.height * 0.80)
	self.srchIcon:initialise()
	
	self.btmPanel:addChild(self.srchIcon)
	self.btmPanel:addChild(self.srchBar)
	
	
	self.sortBtn = ISButton:new(self.srchBar.x + self.srchBar.width, self.srchBar.y, self.btmPanel.width * 0.08, self.srchBar.height, "Sort by", self, nil)
	self.sortBtn.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.8}
	self.sortBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	self.sortBtn:initialise()
	function self.sortBtn:onMouseMove()
		self.sortMenu:setVisible(true)
	end
	self.btmPanel:addChild(self.sortBtn)
	
	self.amountBtn = ISButton:new(self.srchBar.x + self.srchBar.width + self.sortBtn.width, self.srchBar.y, self.btmPanel.width * 0.08, self.srchBar.height, "Amount", self, nil)
	self.amountBtn.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.8}
	self.amountBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	self.amountBtn:initialise()
	function self.amountBtn:onMouseMove()
		self.amountMenu:setVisible(true)
	end
	self.btmPanel:addChild(self.amountBtn)
	

	--self.sortList:setVisible(false)
	
	self:makeDropDownMenu()

	self.contPanel = crucibleList:new(0,bh + self.catPanel.height, self.width, (self.height - rh) - (self.catPanel.height + self.btmPanel.height + bh) )
	self.contPanel.background = true
	self.contPanel.backgroundColor = {r=0.1,g=0.1,b=0.1,a=0.6}

	self.contPanel:initialise()
	self.contPanel:populate(self.curCat)
	self:addChild(self.contPanel)
	
	self.btmBar = ISPanel:new(0, self.height-rh, self.width, rh)
	self.btmBar.backgroundColor = {r=0, g=0, b=0, a=1.0};
	self:addChild(self.btmBar)
	
	
	
	crucibleCore.debug = self -- used for debugging with CheatCore's lua interpreter
end

function crucibleUI:makeDropDownMenu()
	self.sortMenu = crucibleHoverMenu:new(self.sortBtn.x, self.srchBar:getAbsoluteY() - (self.sortBtn.height * 2), self.sortBtn.width, self.sortBtn.height)
	self.sortMenu:initialise()
	--self.sortMenu:makeChildren()
	self.sortMenu.backgroundColor = {r=1,g=0.1,b=0.1,a=1}
	self:addChild(self.sortMenu)
	self.sortBtn.sortMenu = self.sortMenu
	
	self.sortMenu:getNew("Name", function() crucibleCore.sort(function (a, b) return string.lower(a:getDisplayName()) < string.lower(b:getDisplayName()) end); self:repopulate(); end)
	self.sortMenu:getNew("Weight", function() crucibleCore.sort(function (a, b) return (a:getActualWeight() or 0) < (b:getActualWeight() or 0) end); self:repopulate(); end)
	self.sortMenu:fixY() -- hack
	
	self.amountMenu = crucibleHoverMenu:new(self.amountBtn.x, self.srchBar:getAbsoluteY() - (self.amountBtn.height * 2), self.amountBtn.width, self.amountBtn.height)
	self.amountMenu:initialise()
	self.amountMenu.backgroundColor = {r=1,g=0.1,b=0.1,a=1}
	self:addChild(self.amountMenu)
	self.amountBtn.amountMenu = self.amountMenu
	
	for i = 50,1,-1 do -- loop backwards for aesthetic purposes, otherwise menu entries would count from 1 to 50 top to bottom which looks awkward
		if i % 5 == 0 or i == 1 then
			self.amountMenu:getNew(tostring(i), function() crucibleCore.amount = i end)
		end
	end
	
	self.amountMenu:fixY()
end

function crucibleUI:repopulate()
	self.contPanel:clearChildren()
	self.contPanel:populate(self.curCat, self.srchString)
	self.contPanel:createChildren()
end

function crucibleUI:new(x, y, width, height)
	local o = {};
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.title = "Item Spawner";
	o.pin = true;
	o.resizable = false;
	o.x = x
	o.y = y
	o.width = width
	o.height = height
	o:noBackground();
	o.clearStentil = false
	--o.borderColor = {r=0.4, g=0.4, b=0.4, a=0.4};
	return o;
end




function crucibleUI.makeWindow()
	if crucibleCore.mainWindow == nil then
		crucibleCore.getItems()
		local sw = getCore():getScreenWidth()
		local sh = getCore():getScreenHeight()
		local w = (sw / 3.8) * crucibleCore.Wmod <= sw and (sw / 3.8) * crucibleCore.Wmod or sw -- window will not be larger than the display area
		local h = (sh / 1.3) * crucibleCore.Hmod <= sh and (sh / 1.3) * crucibleCore.Hmod or sh
		local window = crucibleUI:new(50,50, w,h) -- original design is scaled on getScreenWidth() / 3.8, old height is 1.3
		window:setVisible(true)
		window:addToUIManager()
		local mt = getmetatable(crucibleCore.debug)
		crucibleCore.mainWindow = window
		setmetatable(crucibleCore.mainWindow, mt)
	else
		crucibleCore.mainWindow:setVisible(true)
	end
end

function crucibleUI.removeWindow()
	local window = crucibleCore.mainWindow
	window:setVisible(false)
	window:removeFromUIManager()
end

--[[
function crucibleText:new(x,y,width,height,text)
	local o = {};
	o = ISPanel:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.x = x
	o.y = y
	o.width = width
	o.height = height
	o.text = text
	o.background = true
	o.border = true
	o.font = UIFont.Small
	o.fontHgt = getTextManager():getFontFromEnum(o.font):getLineHeight()
	o.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.6};
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	return o;
end

function crucibleText:prerender()
	if self.background then
		self:drawRectStatic(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	end
	if self.border then
		self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
	end
	self:drawTextCentre(self.text, self.width / 2, self.height / 2 - (self.fontHgt / 2), 1, 1, 1, 1, self.font);
end
--]]



--[[
function crucibleContext:new(x,y,width,height)
	local o = {};
	o = ISUIElement:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.x = x
	o.y = y
	o.width = width
	o.height = height
	o.horizontal = false
	o.backgroundColor = {r=0.1,g=0.1,b=0.1,a=0.8}
	o.borderColor = {r=0.4,g=0.4,b=0.4,a=1}
	o.menus = {}
	return o;
end

function crucibleContext:addNew(x,y,width,height)
	table.insert(ISButton:new(0, h * (i - 1), self.sortMenu.width, h, "TEST", self.sortMenu, function() print("TEST") end))
	self.menus[#self.menus]:instantiate()
	self.addChild(self.menus[#self.menus])
end
--]]





