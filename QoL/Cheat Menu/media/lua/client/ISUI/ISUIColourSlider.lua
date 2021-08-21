ISUIColourWindow = ISCollapsableWindow:derive("ISUIColourWindow")
ISUIColourSlider = ISPanel:derive("ISUIColourSlider")


function ISUIColourWindow:initialise()
	ISCollapsableWindow.initialise(self);
	self:makeChildren()
end


function ISUIColourWindow:changeColour(typeOf, slider)
	local pos = slider.hscroll.pos
	
	if CheatCoreCM.SelectedVehicle then
		local script = CheatCoreCM.SelectedVehicle:getScript()
		if typeOf == "hue" then
			script:setForcedHue(pos)
		elseif typeOf == "saturation" then
			script:setForcedSat(pos)
		else
			script:setForcedVal(pos)
		end
		CheatCoreCM.SelectedVehicle:setColor(script:getForcedVal(), script:getForcedSat(), script:getForcedHue())
		print(script:getForcedVal(), script:getForcedSat(), script:getForcedHue())
	end
end



function ISUIColourWindow:makeChildren()
	
	self.rSlider = ISUIColourSlider:new(self.width - self.width / 1.2, self.height / 4, self.width / 1.2, 16, self, function() self:changeColour("hue", self.rSlider) end)
	self.rSlider:initialise()
	self.rSlider.borderColor = {r=0,g=0,b=0,a=0}
	self:addChild(self.rSlider)
	
	self.gSlider = ISUIColourSlider:new(self.width - self.width / 1.2, self.rSlider.y + 16, self.width / 1.2, 16, self, function() self:changeColour("saturation", self.gSlider) end)
	self.gSlider:initialise()
	self.gSlider.borderColor = {r=0,g=0,b=0,a=0}
	self:addChild(self.gSlider)
	
	self.bSlider = ISUIColourSlider:new(self.width - self.width / 1.2, self.gSlider.y + 16, self.width / 1.2, 16, self, function() self:changeColour("brightness", self.bSlider) end)
	self.bSlider:initialise()
	self.bSlider.borderColor = {r=0,g=0,b=0,a=0}
	self:addChild(self.bSlider)
	
	--[[
	if CheatCoreCM.SelectedVehicle then
		local script = CheatCoreCM.SelectedVehicle:getScript()
		self.rSlider.hscroll.pos = script:getForcedHue() > 0 and script:getForcedHue() or 0
		self.gSlider.hscroll.pos = script:getForcedSat() > 0 and script:getForcedSat() or 0
		self.bSlider.hscroll.pos = script:getForcedVal() > 0 and script:getForcedVal() or 0
	end
	--]]
	--[[
	self.colourSquare = ISPanel:new((self.width / 2) - self.width / 8, self.bSlider.y + (self.height / 4), self.width / 4, self.height / 4)
	self.colourSquare:initialise()
	self.colourSquare.backgroundColor = {r=0.1,g=0.1,b=0.1,a=1}
	self.colourSquare.borderColor = {r=1,g=1,b=1,a=1}
	self:addChild(self.colourSquare)
	--]]
	--self.rSlider:setScrollWithParent(false)
	--self.rSlider:setScrollChildren(true)
end


function ISUIColourWindow:prerender()
	local height = self:getHeight();
	local th = self:titleBarHeight()
	if self.isCollapsed then
		height = th;
    end
    if self.drawFrame then
        self:drawRect(0, 0, self:getWidth(), th, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
        self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, 1, 1, 1, 1);
        self:drawRectBorder(0, 0, self:getWidth(), th, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    end
    if self.background and not self.isCollapsed then
		local rh = self:resizeWidgetHeight()
		if not self.resizable or not self.resizeWidget:getIsVisible() then rh = 0 end
        self:drawRect(0, th, self:getWidth(), self.height - th - rh, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    end

	if self.clearStentil then
		self:setStencilRect(0,0,self.width, height);
	end

	if self.title ~= nil and self.drawFrame then
		self:drawTextCentre(self.title, self:getWidth() / 2, 1, 1, 1, 1, 1, self.titleBarFont);
	end
	if self.rSlider ~= nil then
		self:drawText("Hue", 3, self.rSlider.y, 1, 1, 1, 1, UIFont.Small)
		self:drawText("Saturation", 3, self.gSlider.y, 1, 1, 1, 1, UIFont.Small)
		self:drawText("Brightness", 3, self.bSlider.y, 1, 1, 1, 1, UIFont.Small)
	end
end


function ISUIColourWindow:close()
	self:setVisible(false)
	self:removeFromUIManager()
end


function ISUIColourWindow:new(x, y, width, height)
	local o = {}
	o = ISCollapsableWindow:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.title = "Colour Slider"
	o.resizable = false
	o.pin = true;
	o.isCollapsed = false;
	o.x = x
	o.y = y
	o.width = width
	o.height = height
	--o:noBackground();
	--o.clearStentil = false
	--o.borderColor = {r=0.4, g=0.4, b=0.4, a=0.4};
	return o;
end


function ISUIColourWindow.makeWindow()
	local window = ISUIColourWindow:new(50,50,370,64)
	window:initialise()
	window:addToUIManager()
end




function ISUIColourSlider:initialise()
	ISPanel.initialise(self);
	self:createChildren()
end


function ISUIColourSlider:createChildren()
	self:addScrollBars(true)
	self:setScrollWidth(1000)
	self.hscroll:setWidth(self.width - 1)
	--self.hscroll:setHeight(self.height)
	self.hscroll:setAlwaysOnTop(true)
	self.hscroll.target, self.hscroll.func = self.target, self.func
	
	function self.hscroll:onMouseMove(dx, dy)
		if self.scrolling then
			local sw = self.parent:getScrollWidth()
			if sw > self.parent:getScrollAreaWidth() then
				local del = self:getWidth() / sw
				local boxheight = del * (self:getWidth()- (20 * 2))
				local dif = self:getWidth() - (20 * 2) - boxheight
				self.pos = self.pos + (dx / dif)
				if self.pos < 0 then
					self.pos = 0
				end
				if self.pos > 1 then
					self.pos = 1
				end
				self.parent:setXScroll(-(self.pos * (sw - self.parent:getScrollAreaWidth())))
			end
			if self.func then
				pcall(self.func)
			end
		end
	end
	
end


function ISUIColourSlider:new(x, y, width, height, target, func)
	local o = {};
	o = ISPanel:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	o.x = x
	o.y = y
	o.width = width
	o.height = height
	o.target = target
	o.func = func
	--o:noBackground();
	--o.clearStentil = false
	--o.borderColor = {r=0.4, g=0.4, b=0.4, a=0.4};
	return o;
end



--Events.OnLoad.Add(ISUIColourWindow.makeWindow)