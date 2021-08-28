----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_avatar
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("Loading EM_AVATAR");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_avatar = {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatar:update()
	self.animationStep = self.animationStep + 1;
	if self.animationStep > self.animationStepMax then self.animationStep = 1; end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatar:render()
	self.avatar:setDir(self.direction);
	self.avatar:SetAnimFrame(self.animationStep, true);
	self.avatar:drawAt(self.drawX, self.drawY);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatar:setAnim(_anim)
	self.animation = _anim;
	-- self.avatar:PlayAnimFrame(self.animation, self.animationStep);
	self.avatar:PlayAnim(self.animation);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatar:setDraw(_x, _y)
	self.drawX, self.drawY = _x, _y;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatar:rotateDirection(_direction)
	if em_settings.map_settings.viewMode > 1 then
		if _direction == "player_circle" then return _direction; end;
		if _direction == "N" then return "NE"; end;
		if _direction == "NE" then return "E"; end;
		if _direction == "E" then return "SE"; end;
		if _direction == "SE" then return "S"; end;
		if _direction == "S" then return "SW"; end;
		if _direction == "SW" then return "W"; end;
		if _direction == "W" then return "NW"; end;
		if _direction == "NW" then return "N"; end;
	else
		return _direction;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatar:getDirectionFromAngle(_angle)
	local angle = _angle;

	if _angle >= -22.5 and _angle <= 22.499 then return "E"; end;
	if _angle >= 22.5 and _angle <= 67.499 then return "SE"; end;
	if _angle >= 67.5 and _angle <= 112.499 then return "S"; end;
	if _angle >= 112.5 and _angle <= 157.499 then return "SW"; end;

	if _angle <= -112.5 and _angle >= -157.499 then return "NW"; end;
	if _angle <= -67.5 and _angle >= -112.499 then return "N"; end;
	if _angle <= -22.5 and _angle >= -67.499 then return "NE"; end;

	if _angle >= 157.5 or _angle <= -157.5 then return "W"; end;

	return "player_circle";
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatar:getFacingDirection(_obj)
	local direction = "player_circle";
	local lastDir = _obj.getLastdir;
	local dirAngle = _obj.getDirectionAngle;
	if lastDir then
		direction = lastDir(_obj):toString() or direction;
	elseif dirAngle then
		direction = self:getDirectionFromAngle(dirAngle(_obj)) or direction;
	end;
	return self:rotateDirection(direction);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatar:updateLocalAnim()
	local anim = "Idle";
	local x, y = self.icon.x, self.icon.y;
	local movement = math.sqrt(math.abs(self.lastX - x)^2 + math.abs(self.lastY - y)^2);
	if self.obj:IsRunning() then
		anim = "Run";
	-- elseif getSpecificPlayer(0):pressedMovement() then
	elseif movement > 0 then
		if self.obj:isAiming() then
			anim = "Strafe";
		else
			anim = "Walk";
		end;
	end;
	self.animation = anim;
	-- self.direction = self.obj:getLastdir();
	self.direction = self:getFacingDirection(self.obj);
	-- self.avatar:PlayAnimFrame(self.animation, self.animationStep);
	self.avatar:PlayAnim(self.animation);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatar:updateAnim()
	local anim = "Idle";
	local x, y = self.icon.x, self.icon.y;
	local movement = math.sqrt(math.abs(self.lastX - x)^2 + math.abs(self.lastY - y)^2);
	if movement > 0 then
		if movement > 0.5 then
			anim = "Run";
		else
			anim = "Walk";
		end;
	end;
	self.lastX, self.lastY = x, y;
	self.animation = anim;
	-- self.direction = self.obj:getLastdir();
	self.direction = self:getFacingDirection(self.obj);
	-- self.avatar:PlayAnimFrame(self.animation, self.animationStep);
	self.avatar:PlayAnim(self.animation);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function em_avatar:new(_obj, _icon, _isSurvivor)

	local o = {};
	local isoAvatar = nil;

	local descriptor = _obj:getDescriptor();

	if _isSurvivor then
		isoAvatar = IsoSurvivor.new(descriptor, nil, 0, 0, 0);
	else
		isoAvatar = IsoZombie.new(nil, descriptor, 1);
	end;

	setmetatable(o, self)
		o.obj = _obj;
		o.icon = _icon;
		o.avatar = isoAvatar;
		o.drawX = 0;
		o.drawY = 0;
		o.lastX = 0;
		o.lastY = 0;
		o.animation = "Idle";
		-- o.direction = _obj:getLastdir();
		o.direction = self:getFacingDirection(_obj);
		o.descriptor = descriptor;
		o.animationStep = 1;
		o.animationStepMax = 10;
	return o;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------