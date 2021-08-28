----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_calendarInfoBox
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_calendarInfoBox = em_infoBoxBase:new();

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_calendarInfoBox:initialise()
	ISPanel.initialise(self);
	self.textColor = em_settings.color_settings.timeDate_text.color;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_calendarInfoBox:update()
	if em_settings.context_settings.timedateToggle.enabled then
		local hasWatch = UIManager.getClock():isVisible();
		if hasWatch or em_core.adminMode then
			local timeStr, dateStr;
			local gtObj = GameTime:getInstance();
			if getCore():getOptionClockFormat() == 1 then
				dateStr = gtObj:getMonth() + 1 .. "/" .. gtObj:getDay() + 1 .. "/" ..  gtObj:getYear();
			else
				dateStr = gtObj:getDay() + 1 .. "/" .. gtObj:getMonth() + 1 .. "/" ..  gtObj:getYear();
			end;
			if getCore():getOptionClock24Hour() then
				timeStr = string.format("%02d", gtObj:getHour()) .. ":" .. string.format("%02d", gtObj:getMinutes())
			else
				if gtObj:getHour() <= 12 then
					timeStr = string.format("%02d", gtObj:getHour()) .. ":" .. string.format("%02d", gtObj:getMinutes()) .. " AM";
				else
					timeStr = string.format("%02d", gtObj:getHour() - 12) .. ":" .. string.format("%02d", gtObj:getMinutes()) .. " PM";
				end;
			end;
			if timeStr and dateStr then
				self.text =  dateStr .. " " .. timeStr;
			end;
		else
			self.text = "";
		end;
	else
		self.text = "";
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_calendarInfoBox:render()

	self:drawTextCentre(self.text or "", self:getWidth() / 2, 1, self.textColor.r, self.textColor.g, self.textColor.b, self.textColor.a, UIFont.NewMedium);

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------