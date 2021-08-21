compassPOI = ISUIElement:derive("compassPOI")

function compassPOI:initialise()
	ISUIElement.initialise(self)
	self:makeChildren()
end

function compassPOI:makeChildren()
	self.made = true
	
	self.teleportBtn = ISButton:new(self.width - (self.width / 4) - 1, 0, self.width / 4, self.height / 2, "Teleport", self, function() self:teleport() end)
	self.teleportBtn.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.6};
	self.teleportBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	self.teleportBtn:initialise()
	self:addChild(self.teleportBtn)
	
	self.gpsBtn = ISButton:new(self.width - (self.width / 4) - 1, self.teleportBtn.height, self.width / 4, self.height / 2, "Mark On GPS", self, function() self:setGPS() end)
	self.gpsBtn.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.6};
	self.gpsBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	self.gpsBtn:initialise()
	self:addChild(self.gpsBtn)
	
	if self.customID then
		self.renameBtn = ISButton:new(self.width - (self.width / 2) - 1, 0, self.width / 4, self.height / 2, "Rename", self, function() self.renameBar:setVisible(true); self.renameBar:focus(); self.renameBtn:setVisible(false) end)
		self.renameBtn.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.6};
		self.renameBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
		self.renameBtn:initialise()
		self:addChild(self.renameBtn)
		
		self.renameBar = ISTextEntryBox:new("", self.renameBtn.x, self.renameBtn.y, self.renameBtn.width, self.renameBtn.height)
		self.renameBar.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.6};
		self.renameBar.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
		
		function self.renameBar.onCommandEntered()
			self:editName(self.renameBar:getInternalText())
			--self.renameBar.commandFinished = true
			self.renameBar:unfocus()
			self.renameBar:setVisible(false)
			self.renameBtn:setVisible(true)
		end
		
		--[[
		function self.renameBar.unfocus()
			if self.renameBar:getIsVisible() then
				if not self.renameBar.commandFinished then 
					self.renameBar.onCommandEntered()
					print("TEST")
				end
			end
		end
		--]]
		
		self.renameBar:initialise()
		self:addChild(self.renameBar)
		self.renameBar:setVisible(false)
		
		self.deleteBtn = ISButton:new(self.width - (self.width / 2) - 1, self.renameBtn.height, self.width / 4, self.height / 2, "Delete", self, function() if not self.confirm then self.deleteBtn.backgroundColor =  {r=0.8, g=0.1, b=0.1, a=0.8};  self.deleteBtn.backgroundColorMouseOver = {r=0.6, g=0.1, b=0.1, a=0.8}; self.deleteBtn.title = "Confirm"; self.confirm = true; else self:delete(); end end)
		self.deleteBtn.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.6};
		self.deleteBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
		self.deleteBtn:initialise()
		self:addChild(self.deleteBtn)
	end
end

function compassPOI:teleport()
	getPlayer():setX(self.poi["x"]);
	getPlayer():setY(self.poi["y"]);
	getPlayer():setZ(0);
	getPlayer():setLx(getPlayer():getX());
	getPlayer():setLy(getPlayer():getY());
	getPlayer():setLz(getPlayer():getZ());
end

function compassPOI:setGPS()
	ISUICheatWindow:setVisible(true);
	CheatCoreCM.DisplayName = self.poi["name"]
	CheatCoreCM.MarkedX = self.poi["x"]
	CheatCoreCM.MarkedY = self.poi["y"]
	CheatCoreCM.updateCoords()
end

function compassPOI:editName(name)
	compassCore.locations["Custom"]["pois"][self.customID]["name"] = name
	compassCore:updateCustom()
	--compassUI:repopulate()
end

function compassPOI:delete()
	table.remove(compassCore.locations["Custom"]["pois"], self.customID)
	compassCore:updateCustom()
	compassCore.mainWindow:repopulate()
end

function compassPOI:onRightMouseDown() -- placeholder
	
end

function compassPOI:prerender()
	if self:checkIfVisible() then -- culling
		
		if not self.made then self:makeChildren() end -- recreates culled children when element is made visible again
		
		if self.background then
			self.fade:setFadeIn(self:isMouseOver() or false)
			self.fade:update()
			local f = 1 - self.fade:fraction()
			self:drawRectStatic(0, 0, self.width, self.height, self.backgroundColor.a * f, self.backgroundColor.r * f, self.backgroundColor.g * f, self.backgroundColor.b * f);
		end
		
		if self.border then
			self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
		end
		
		self:drawText(self.poi["name"], ( self.width / 10 ) , (self.height - self.fontHgt) / 2, 1, 1, 1, 1, UIFont.Small)
		
		--[[
		if self:isMouseOver() then
			--print(f)
			self:drawRect(0, 0, self.width, self.height,
			self.backgroundColor.a * f,
			self.backgroundColor.r * f,
			self.backgroundColor.g * f,
			self.backgroundColor.b * f)
		end
		--]]
	else
		self:clearChildren()
		self.made = false
	end
		
end

function compassPOI:checkIfVisible() -- the game renders UI objects even if they're outside the stencil zone, which can cause severe amounts of lag in large lists. 
	local y = self:getAbsoluteY()
	local sh = getCore():getScreenHeight()
	if y < (0 - sh) or y > sh then
		return false
	else
		return true
	end
end


function compassPOI:new(x, y, width, height, poi, customID)
	local o = {};
	o = ISUIElement:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.x = x
	o.y = y
	o.width = width
	o.height = height
	o.background = true
	o.border = true
	o.debug = false
	o.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.6};
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.poi = poi
	o.font = UIFont.Small
	o.fontHgt = getTextManager():getFontFromEnum(o.font):getLineHeight()
	o.fontWdth = function(str) return getTextManager():getFontFromEnum(o.font):getWidth(str) end
	o.fade = UITransition.new()
	o.backgroundColorMouseOver = {r=0.3, g=0.3, b=0.3, a=1.0}
	o.doFade = false
	o.customID = customID
	return o;
end