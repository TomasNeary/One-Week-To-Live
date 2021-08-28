----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_avatarInfoBox
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
require "ISUI/ISPanel"
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_avatarInfoBox = ISPanel:derive("em_avatarInfoBox");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:killRecieveRemoteData()
	if not self.isLocal then
		local stopRemoteUpdates = true;
		for plID, icon in pairs(self.localPlayers) do
			for windowID, window in pairs(ISMedicalCheckAction.HealthWindows) do
				if windowID == icon.obj then
					stopRemoteUpdates = false;
				end;
			end;
			if stopRemoteUpdates then
				icon.obj:stopReceivingBodyDamageUpdates(self.icon.obj);
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:doRecieveRemoteData()
	if not self.isLocal then
		local startRemoteUpdates = true;
		for plID, icon in pairs(self.icon.spottedList) do self.localPlayers[plID] = icon; end;
		for plID, icon in pairs(self.localPlayers) do
			self.hasGoodDoctorNearby = self.hasGoodDoctorNearby or self:isGoodDoctor(icon.obj);
			for windowID, window in pairs(ISMedicalCheckAction.HealthWindows) do
				if windowID == icon.obj then
					startRemoteUpdates = false;
				end;
			end;
			if startRemoteUpdates then
				icon.obj:startReceivingBodyDamageUpdates(self.icon.obj);
			end;
		end;
	else
		self.hasGoodDoctorNearby = self:isGoodDoctor(self.icon.obj);
		self.hasFitnessAwarePersonNearby = self:isFitnessAware(self.icon.obj);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:isGoodDoctor(_obj)
	if em_core.adminMode then return true; end;
	local traitsWithImpliedFirstAidTraining = {"FirstAid", "Formerscout", "Herbalist"};
	local profWithImpliedFirstAidTraining = {"doctor", "nurse", "parkranger", "fireofficer", "policeofficer", "fitnessInstructor", "veteran"};
	local goodDoctorFromPerks = _obj:getPerkLevel(Perks.Doctor) >= 7;
	for _, traitID in ipairs(traitsWithImpliedFirstAidTraining) do
		if _obj:HasTrait(traitID) then goodDoctorFromPerks = true; end;
	end;
	local goodDoctorFromProfession = false;
	local profession = _obj:getDescriptor():getProfession();
	for _, profID in ipairs(profWithImpliedFirstAidTraining) do
		if profession == profID then goodDoctorFromProfession = true; end;
	end;
	return goodDoctorFromPerks or goodDoctorFromProfession;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:isFitnessAware(_obj)
	if em_core.adminMode then return true; end;
	local traitsWithImpliedFitnessAwareness = {"Athletic", "Fit", "Asthmatic", "Hiker", "Formerscout"};
	local profWithImpliedFitnessAwareness = {"doctor", "nurse", "parkranger", "fireofficer", "policeofficer", "fitnessInstructor", "veteran"};
	local fitnessAwareFromPerks = _obj:getPerkLevel(Perks.Fitness) >= 7;
	for _, traitID in ipairs(traitsWithImpliedFitnessAwareness) do
		if _obj:HasTrait(traitID) then fitnessAwareFromPerks = true; end;
	end;
	local fitnessAwareFromProfession = false;
	local profession = _obj:getDescriptor():getProfession();
	for _, profID in ipairs(profWithImpliedFitnessAwareness) do
		if profession == profID then fitnessAwareFromProfession = true; end;
	end;
	return fitnessAwareFromPerks or fitnessAwareFromProfession;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:getFuzzyDescription(_bodyDamage)
	-- local description = "";
	-- local numBites = _bodyDamage:getNumPartsBitten();
	-- local numBleeds = _bodyDamage:getNumPartsBleeding();
	-- local numScratches = _bodyDamage:getNumPartsScratched();
	-- local wetness = _bodyDamage:getWetness();
	-- local hasCold = _bodyDamage:isHasACold();
	-- local isFoodSick = _bodyDamage:getFoodSicknessLevel();
	-- local isPoisonSick = _bodyDamage:getPoisonLevel();
	-- print(numBites, numBleeds, numScratches, wetness, hasCold, isFoodSick, isPoisonSick)
	-- local fuzzyStatsAmounts = {
		-- {value = "a few ", minVal = 1, maxVal = 3},
		-- {value = "many ", minVal = 3, maxVal = 5},
		-- {value = "numerous ", minVal = 6, maxVal = 100},
	-- };
	-- local fuzzyStatsValues = {
		-- {value = "slightly ", minVal = 1, maxVal = 3},
		-- {value = "very ", minVal = 3, maxVal = 5},
		-- {value = "completely ", minVal = 6, maxVal = 100},
	-- };
	-- if self.isLocal then
		-- description = description .. "I ";
	-- else
		-- description = description .. "They  ";
	-- end;
	-- "They appear to be in good health, Their clothing is bloodied and dirty. They have several bandages on their hands and arms, some are still dripping blood."
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:getFuzzyExertStat()
	local fuzzyStats = {
		{value = "Spent", minVal = -1, maxVal = 1},
		{value = "Depleted", minVal = 1, maxVal = 10},
		{value = "Exhausted", minVal = 10, maxVal = 20},
		{value = "Feeling faint", minVal = 20, maxVal = 30},
		{value = "Fatigued", minVal = 30, maxVal = 40},
		{value = "Weary", minVal = 40, maxVal = 50},
		{value = "Tired", minVal = 50, maxVal = 60},
		{value = "Beginning to tire", minVal = 60, maxVal = 70},
		{value = "Feeling ok", minVal = 70, maxVal = 80},
		{value = "Feeling fine", minVal = 80, maxVal = 90},
		{value = "Bursting with energy", minVal = 90, maxVal = 200},
	};
	for statID, stat in pairs(fuzzyStats) do
		if self.stamina >= stat.minVal and self.stamina <= stat.maxVal then
			return stat.value;
		end;
	end;
	return "Unknown";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:getFuzzyHealthStat()
	local fuzzyStats = {
		{value = "Dead", minVal = -1, maxVal = 1},
		{value = "Barely Alive", minVal = 1, maxVal = 10},
		{value = "Vitals Weak", minVal = 10, maxVal = 20},
		{value = "Fading Away", minVal = 20, maxVal = 30},
		{value = "Outlook Is Grim", minVal = 30, maxVal = 40},
		{value = "Severe Injuries", minVal = 40, maxVal = 50},
		{value = "Moderate Injuries", minVal = 50, maxVal = 60},
		{value = "Minor Injuries", minVal = 60, maxVal = 70},
		{value = "Minor Damage", minVal = 70, maxVal = 80},
		{value = "Fine", minVal = 80, maxVal = 90},
		{value = "Excellent", minVal = 90, maxVal = 200},
	};
	for statID, stat in pairs(fuzzyStats) do
		if self.health >= stat.minVal and self.health <= stat.maxVal then
			return stat.value;
		end;
	end;
	return "Unknown";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:onButtonClick(_button)
	if _button.internal == "follow" then
		-- em_core.minimap:setFollowIcon(_button.icon);
		em_core.minimap:setFollowIcon(self.icon);
	end;
	if _button.internal == "pin" then
		self.pinned = not self.pinned;
		if self.pinned then
			self.pinButton:setImage(em_window.mapButtonTex.button_lockOn);
		else
			self.pinButton:setImage(em_window.mapButtonTex.button_lockOff);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:update()
	local bodyDamage;
	if self.isLocal then
		-- self.avatar:updateLocalAnim();
		bodyDamage = self.icon.obj:getBodyDamage();
		if bodyDamage then
			self.health = bodyDamage:getOverallBodyHealth();
			self.bodyParts = bodyDamage:getBodyParts();
		end;
		self.stamina = self.icon.obj:getStats():getEndurance() * 100;
	else
		-- self.avatar:updateAnim();
		bodyDamage = self.icon.obj:getBodyDamageRemote();
		if bodyDamage then
			self.health = bodyDamage:getOverallBodyHealth();
			self.bodyParts = bodyDamage:getBodyParts();
		end;
		self.stamina = 100;
	end;
	-- if bodyDamage then
		-- self.description = self:getFuzzyDescription(bodyDamage);
	-- end;
	-- self.avatar:update();
	self.lastSeenLocation = "Last Seen At: " .. math.floor(self.icon.x).."-"..math.floor(self.icon.y);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:prerender()
	if self.showBackground then self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b); end;
	if self.showBorder then self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b); end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:render()
	local yOff = 1;
	self:drawText(self.icon.iconData or "", 55, yOff, 1, 1, 1, 1, UIFont.NewMedium);
	yOff = yOff + self.font_height_medium;
	self:drawText(self.icon.iconDataExt or "", 55, yOff, 1, 1, 1, 1, UIFont.NewMedium);
	yOff = yOff + self.font_height_medium;
	self:drawText("Profession: " .. self.icon.profName or "", 55, yOff, 1, 1, 1, 1, UIFont.NewMedium);
	yOff = yOff + self.font_height_medium;
	yOff = yOff + self.font_height_medium;
	self:drawText(self.lastSeenLocation or "", 55, yOff, 1, 1, 1, 1, UIFont.NewMedium);
	yOff = yOff + self.font_height_medium;
	yOff = yOff + self.font_height_medium;
	if self.hasGoodDoctorNearby then
		self:drawText("Health: " , 55, yOff, 1, 1, 1, 1, UIFont.NewMedium);
		em_progressBar.render(self, 120, yOff + 4, self.width - 130, 12, self.health);
	else
		self:drawText("Health: " .. self:getFuzzyHealthStat(), 55, yOff, 1, 1, 1, 1, UIFont.NewMedium);
	end;
	yOff = yOff + self.font_height_medium;
	if self.isLocal then
		if self.hasFitnessAwarePersonNearby then
			self:drawText("Stamina: " , 55, yOff, 1, 1, 1, 1, UIFont.NewMedium);
			em_progressBar.render(self, 120, yOff + 4, self.width - 130, 12, self.stamina);
		else
			self:drawText("Stamina: " .. self:getFuzzyExertStat(), 55, yOff, 1, 1, 1, 1, UIFont.NewMedium);
		end;
		yOff = yOff + self.font_height_medium;
	end;
	-- self.avatar:setDraw(self:getAbsoluteX() + 30, self:getAbsoluteY() + 200);
	-- self.avatar:render();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:onMouseUpOutside()
	if not self.pinned then self:close(); end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:close()
	self:killRecieveRemoteData();
	self:setVisible(false);
	self:removeFromUIManager();
	em_core.avatarInfoBox = nil;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:initialise()
	ISPanel.initialise(self);
	self:setHeight(180);
	self:setWidth(math.max(getTextManager():MeasureStringX(UIFont.NewMedium, self.icon.iconData) + 70, self:getWidth()));
	self:setWidth(math.max(getTextManager():MeasureStringX(UIFont.NewMedium, self.icon.iconDataExt) + 70, self:getWidth()));
	self:setWidth(math.max(getTextManager():MeasureStringX(UIFont.NewMedium, self.lastSeenLocation) + 70, self:getWidth()));
	self:setWidth(math.max(getTextManager():MeasureStringX(UIFont.NewMedium, "Stamina: Could use some rest") + 70, self:getWidth()));
	self.followButton = ISButton:new(0, 0, 24, 24, "", self, em_avatarInfoBox.onButtonClick);
	self.followButton:initialise();
	self.followButton:instantiate();
	self.followButton:setImage(em_window.mapButtonTex.button_lockOn);
	self.followButton.displayBackground = false;
	self.followButton:setTooltip(em_translationData.label_follow);
	self.followButton.textureColor = {r = self.icon.r, g = self.icon.g, b = self.icon.b, a = self.icon.a};
	self.followButton.icon = self.icon;
	self.followButton.iconGroup = iconGroup;
	self.followButton.internal = "follow";
	self:addChild(self.followButton);
	self.pinButton = ISButton:new(self:getWidth() - 24, 0, 24, 24, "", self, em_avatarInfoBox.onButtonClick);
	self.pinButton:initialise();
	self.pinButton:instantiate();
	self.pinButton:setImage(em_window.mapButtonTex.button_lockOff);
	self.pinButton.displayBackground = false;
	self.pinButton:setTooltip(em_translationData.label_pin);
	self.pinButton.textureColor = {r = 1, g = 1, b = 1, a = 1};
	self.pinButton.icon = self.icon;
	self.pinButton.iconGroup = iconGroup;
	self.pinButton.internal = "pin";
	self:addChild(self.pinButton);
	-- self.avatar:setDraw(self:getAbsoluteX() + 30, self:getAbsoluteY() + 100);
	self:doRecieveRemoteData();
	self:addToUIManager();
	self:setVisible(true);
	self:bringToTop();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatarInfoBox:new(_icon, _x, _y, _isLocal)
	local window_background = em_settings.color_settings.window_background;
	local o = ISPanel:new(_x, _y, 0, 0);
	setmetatable(o, self)
		self.__index = self;
		o.icon = _icon;
		o.isLocal = _isLocal;
		o.localPlayers = {};
		o.lastSeenLocation = "Last Seen At: 99999-99999";
		o.description = "Unknown";
		o.hasGoodDoctorNearby = false;
		o.hasFitnessAwarePersonNearby = false;
		o.bodyParts = nil;
		o.health = 100;
		o.stamina = 100;
		-- o.avatar = em_avatar:new(_icon.obj, _icon, true);
		o.timer = getTimestampMs();
		o.closeDelay = 2000;
		o.font_height_medium = getTextManager():getFontHeight(UIFont.NewMedium)
		o.showBackground = true;
		o.showBorder = true;
		o.backgroundColor = window_background.enabled and window_background.color or {r=0, g=0, b=0, a=1};
		o.borderColor = {r=1, g=1, b=1, a=1};
		o.moveWithMouse = true;
		o.pinned = false;
	return o;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------