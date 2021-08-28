----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_colorPicker_RGB
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_colorPicker_RGB = em_infoBoxBase:new();

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_colorPicker_RGB:onChangeSlider(_target, _value)
	self["slider_" .. _target].backgroundColor[_target] = _value;
	self[_target] = _value;
	self.targetFunc(self.target, self.ID, self.r, self.g, self.b);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_colorPicker_RGB:setColor(_r, _g, _b)
	self.r, self.g, self.b = _r, _g, _b;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_colorPicker_RGB:close()
	self:setVisible(false);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_colorPicker_RGB:initialise(_r, _g, _b, _target, _targetFunc, _ID)
	self.r, self.g, self.b = _r, _g, _b;
	self.target = _target;
	self.targetFunc = _targetFunc;
	self.ID = _ID;
	local y = 0;
	self.sliders = {
		slider_r = {value = _r, target ="r", r = _r, g = 0, b = 0, a = 1},
		slider_g = {value = _g, target ="g", r = 0, g = _g, b = 0, a = 1},
		slider_b = {value = _b, target ="b", r = 0, g = 0, b = _b, a = 1},
	};
	for sliderID, sliderSettings in pairs(self.sliders) do
		self[sliderID] = em_slider:new(10, y, 120, 16, sliderSettings.value, 0.1, 1, sliderSettings.target, self, em_colorPicker_RGB.onChangeSlider);
		self[sliderID]:initialise();
		self[sliderID].sliderColor = {r = 0, g = 0, b = 0};
		self[sliderID].backgroundColor = {r = sliderSettings.r, g = sliderSettings.g, b = sliderSettings.b};
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