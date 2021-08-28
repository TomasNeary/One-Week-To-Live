----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_slider
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
require "ISUI/ISPanel"
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_slider = ISPanel:derive("em_slider")

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:updateValue()
	local x = self:getValueAtX(self:getMouseX() - 10);
	self:setValue(x);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:onMouseDown(x, y)
	self.dragging = true;
	self:setCapture(true);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:onMouseUp(x, y)
	self.dragging = false;
	self:setCapture(false);
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:onMouseUpOutside(x, y)
	self.dragging = false
	self:setCapture(false)
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:onMouseMove(dx, dy)
	if self.dragging then
		self:updateValue();
	end
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:getValueAtX(_x)
	local value = _x;
	if value < 1 then value = 1; end;
	if value > 100 then value = 100; end;
	return value;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:render()

	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	self:drawRectBorder(0, 0, self.width, self.height, 1, 0.5, 0.5, 0.5);

	self:drawRect(self.value + 5, 2, 10, 12, self.sliderColor.a, self.sliderColor.r, self.sliderColor.g, self.sliderColor.b);
	self:drawRectBorder(self.value + 5, 2, 10, 12, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:getValue()
	return self.value;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:setValue(_value)
	if _value >= 1 and _value <= 100 and _value ~= self.value then
		self.value = _value;
		if self.targetFunc then
			local retVal = math.floor(((self.step / 100) * self.value * self.minVal) * 100) / 100;
			self.targetFunc(self.targetFuncObj, self.target, retVal);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:setJoypadFocused(_focused)
	self.joypadFocused = focused;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:onJoypadDirLeft(_joypadData)
	self:setValue(self.setValue - 1);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:onJoypadDirRight(_joypadData)
	self:setValue(self.setValue + 1);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:close()
	self:setVisible(false);
	self:removeFromUIManager();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_slider:new(_x, _y, _w, _h, _value, _minVal, _maxVal, _target, _targetFuncObj, _targetFunc)
	local o = ISPanel:new(_x, _y, _w, _h);
	setmetatable(o, self)
		self.__index = self;
		o.backgroundColor = {r=0, g=0, b=0, a=1};
		o.borderColor = {r=1, g=1, b=1, a=0.5};
		o.sliderColor = {r=1, g=1, b=1, a=1};
		o.value = _value;
		o.minVal = _minVal;
		o.maxVal = _maxVal;
		o.step = math.floor(_maxVal / _minVal);
		o.target = _target;
		o.targetFuncObj = _targetFuncObj;
		o.targetFunc = _targetFunc;
	return o;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------