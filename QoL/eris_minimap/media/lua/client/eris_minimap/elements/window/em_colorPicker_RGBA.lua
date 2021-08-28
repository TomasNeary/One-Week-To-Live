----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_colorPicker_RGBA
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_colorPicker_RGBA = em_infoBoxBase:new();

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_colorPicker_RGBA:onChangeSlider(_target, _value)
	self["slider_" .. _target].backgroundColor[_target] = _value;
	self[_target] = _value;
	self.targetFunc(self.target, self.ID, self.r, self.g, self.b, self.a);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_colorPicker_RGBA:getColor()
	return self.r, self.g, self.b, self.a;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_colorPicker_RGBA:setColor(_r, _g, _b, _a)
	self.r, self.g, self.b, self.a = _r, _g, _b, _a;
	self.sliders = {
		slider_r = {value = _r * 100, target ="r", r = _r, g = 0, b = 0, a = 1},
		slider_g = {value = _g * 100, target ="g", r = 0, g = _g, b = 0, a = 1},
		slider_b = {value = _b * 100, target ="b", r = 0, g = 0, b = _b, a = 1},
		slider_a = {value = _a * 100, target ="a", r = 1, g = 1, b = 1, a = _a},
	};
	for sliderID, sliderSettings in pairs(self.sliders) do
		self[sliderID].value = sliderSettings.value;
		self[sliderID].backgroundColor = {r = sliderSettings.r, g = sliderSettings.g, b = sliderSettings.b, a = sliderSettings.a};
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_colorPicker_RGBA:close()
	self:setVisible(false);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_colorPicker_RGBA:initialise(_r, _g, _b, _a, _target, _targetFunc, _ID)
	self.r, self.g, self.b, self.a = _r, _g, _b, _a;
	self.target = _target;
	self.targetFunc = _targetFunc;
	self.ID = _ID;
	local y = 0;
	self.sliders = {
		slider_r = {value = _r * 100, target ="r", r = _r, g = 0, b = 0, a = 1},
		slider_g = {value = _g * 100, target ="g", r = 0, g = _g, b = 0, a = 1},
		slider_b = {value = _b * 100, target ="b", r = 0, g = 0, b = _b, a = 1},
		slider_a = {value = _a * 100, target ="a", r = 1, g = 1, b = 1, a = _a},
	};
	for sliderID, sliderSettings in pairs(self.sliders) do
		self[sliderID] = em_slider:new(10, y, 120, 16, sliderSettings.value, 0.1, 1, sliderSettings.target, self, em_colorPicker_RGBA.onChangeSlider);
		self[sliderID]:initialise();
		self[sliderID].sliderColor = {r = 0, g = 0, b = 0, a = 1};
		self[sliderID].backgroundColor = {r = sliderSettings.r, g = sliderSettings.g, b = sliderSettings.b, a = sliderSettings.a};
		self:addChild(self[sliderID]);
		self[sliderID]:setWidth(120);
		self[sliderID]:setHeight(16);
		self[sliderID]:setX(10);
		self[sliderID]:setY(y);
		y = y + 16;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------