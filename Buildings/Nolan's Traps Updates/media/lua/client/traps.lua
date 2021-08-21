--[[
Player Traps Mod
By Nolan Ritchie


]]


Drag = 0.024;
Gravity = 0.025;

local function smokePop(zombie, radius)
	smoker = HandWeapon.new("Base", "SmokeBomb", "SmokeBomb", "Weapon")
	smoker:setSmokeRange(radius)
	smoker:setTriggerExplosionTimer(0)
	smoker:setSensorRange(0)
	smoker:setRemoteControlID(-1)
	smoker:setExplosionRange(0)
	smoker:setFireRange(0)
	smoker:setNoiseRange(0)
	if smoker == null then
		print("NNNNNNNNNNNNNNNUUUUUUUUUUUUUULLLLLLLLLLL")
	end
	local smoker2 = IsoMolotovCocktail.new(zombie:getCell(), zombie:getX(), zombie:getY(), zombie:getZ(), 0, 0, smoker, zombie )
	--smokes = smokes + 1
end

local function AbsoluteValue(value)
	if(value >= 0) then return value; 
	else return (value * -1);
	end
end

local function getDistanceBetween(z1,z2)
	if(z1 == nil) or (z2 == nil) then return -1 end
	
	local z1x = z1:getX();
	local z1y = z1:getY();
	local z2x = z2:getX();
	local z2y = z2:getY();
	return (AbsoluteValue(z1x-z2x) + (AbsoluteValue(z1y-z2y))/2) ;
	
end

function getMouseSquare2(playerINT)
	local sw = (128 / getCore():getZoom(0));
	local sh = (64 / getCore():getZoom(0));
	
	local mapx = getSpecificPlayer(0):getX();
	local mapy = getSpecificPlayer(0):getY();

	
	local mousex = ( (getMouseX() - (getCore():getScreenWidth() / 2)) ) ;
	local mousey = ( (getMouseY() - (getCore():getScreenHeight() / 2)) ) ; 
	
	local sx = mapx + (mousex / (sw/2) + mousey / (sh/2)) /2;
	local sy = mapy + (mousey / (sh/2) -(mousex / (sw/2))) /2;
	
	local sq = getCell():getGridSquare(sx,sy,getSpecificPlayer(0):getZ());
	return sq;
end

function getMouseSquare(playerINT)
 	
	local sw = (128 / getCore():getZoom(0));
	local sh = (64 / getCore():getZoom(0));
	
	local mapx = getSpecificPlayer(0):getX();
	local mapy = getSpecificPlayer(0):getY();
	
	local mousex = ( (getMouseX() - (getCore():getScreenWidth() / 2)) ) ;
	local mousey = ( (getMouseY() - (getCore():getScreenHeight() / 2)) ) ; 
	
	local AimOffX = 0;
	local AimOffY = 0;	
	
	if(getSpecificPlayer(0):IsAiming()) then
		
		if(getMouseX() < (getCore():getScreenWidth()*0.25)) then
			AimOffX = -1*(mousex*0.5);
		elseif(getMouseX() > (getCore():getScreenWidth()*0.75)) then
			AimOffX = ((mousex-(getCore():getScreenWidth()*0.75))*0.5);
		end
		
		if(getMouseY() < (getCore():getScreenHeight()*0.25)) then
			AimOffY = -1*(mousey*0.5);
		elseif(getMouseY() > (getCore():getScreenHeight()*0.75)) then
			AimOffY = ((mousey-(getCore():getScreenHeight()*0.75))*0.5);
		end
		
	end
	
	mousex = mousex - AimOffX;
	mousey = mousey - AimOffY;
	
	local sx = mapx + (mousex / (sw/2) + mousey / (sh/2)) /2;
	local sy = mapy + (mousey / (sh/2) -(mousex / (sw/2))) /2;
	
	local sq = getCell():getGridSquare(sx,sy,getSpecificPlayer(0):getZ());
	return sq;
end




function getRandomBodyPart(player)
	
	local parttohurt;
	local r = ZombRand(11);
	if(r == 0) then
	parttohurt = BodyPartType.LowerLeg_L;
	elseif(r == 1) then
	parttohurt = BodyPartType.LowerLeg_R;
	elseif(r == 2) then
	parttohurt = BodyPartType.UpperLeg_R;
	elseif(r == 3) then
	parttohurt = BodyPartType.UpperLeg_L;
	elseif(r == 4) then
	parttohurt = BodyPartType.UpperArm_R;
	elseif(r == 5) then
	parttohurt = BodyPartType.UpperArm_L;
	elseif(r == 6) then
	parttohurt = BodyPartType.Head;
	elseif(r == 7) then
	parttohurt = BodyPartType.Torso_Lower;
	elseif(r == 8) then
	parttohurt = BodyPartType.Torso_Upper;
	elseif(r == 9) then
	parttohurt = BodyPartType.ForeArm_L;
	else
	parttohurt = BodyPartType.ForeArm_R;
	end
	
	return player:getBodyDamage():getBodyPart(parttohurt);
	
	
end

function SetTrapDown(items, result, player)
local theTraptoSet;
	for i=0, items:size()-1 do
		theTraptoSet = items:get(i);
	end
	
	local AlreadyTrapOnSquare = false;
	if (player:getCurrentSquare():getModData().isTrapSet == true) then
			local Objs = player:getCurrentSquare():getObjects();
		
		for i=0, Objs:size()-1 do
			if (Objs:get(i):getWorldObjectIndex() ~= -1) then -- (Objs:get(i):getName() == "Spike Trap (Set)") then
				if(Objs:get(i):getItem() ~= nil) and (Objs:get(i):getItem():getModData().isSet == true or Objs:get(i):getModData().isSet == true) then
					AlreadyTrapOnSquare = true;					
				end
			end
		end
	end
	
	if(AlreadyTrapOnSquare == false) then
	
		
	
		player:getCurrentSquare():getModData().isTrapSet = true;
		player:getCurrentSquare():transmitModdata();
		player:getInventory():Remove(theTraptoSet);
		theTraptoSet = player:getCurrentSquare():AddWorldInventoryItem(theTraptoSet,0.5,0.5,0);
		player:getModData().immuneToTrap = true;
		theTraptoSet:getModData().isSet = true;
		theTraptoSet:getWorldItem():getModData().isSet = true;
		theTraptoSet:getWorldItem():transmitModData();
		sendClientCommand(player, "Trap", "SetTrap", {x = player:getX(),y = player:getY(),z = player:getZ(),trapid = theTraptoSet:getWorldItem():getKeyId()});
		
	else
		player:Say("Already a trap on this square");
		sendClientCommand(player, "Trap", "Say", {saythis = "Already a trap on this square"});
	end
	
end

function getTextureFor(name)

	--getPlayer():Say(name);
	local temp = getPlayer():getInventory():AddItem(name);
	--local temp = InventoryItem.new('Base',name,name,name);
	--getPlayer():Say(temp:getType());
	local texture = temp:getTexture();
	getPlayer():getInventory():Remove(temp);
	return texture;

end



local function ExplodeZombies(square,radius)
	if(square == nil) then return false end
	local zlist = getCell():getObjectList() ;
		if(zlist ~= nil) then
			local c = 0;
			for i=0, zlist:size()-1 do
				local zombie = zlist:get(i)
				local distance = getDistanceBetween(square,zombie);
				if(distance <= radius) and (instanceof(zombie,"IsoZombie") or instanceof(zombie,"IsoPlayer")) then
					if(zombie:getModData().xv == nil) or (zombie:getModData().yv == nil) or (zombie:getModData().zv == nil) then
						zombie:getModData().xv = 0;
						zombie:getModData().yv = 0;
						zombie:getModData().zv = 0;
					end
					
					local BlowBackRed = 27;
					--local xdiff = zombie:getX() - square:getX();
					--local ydiff = zombie:getY() - square:getY();
					local xdiff = square:getX() - zombie:getX();
					local ydiff = square:getY() - zombie:getY();
					if(xdiff < 0) then zombie:getModData().xv = (((radius-(xdiff))*1.5)/BlowBackRed) ;
					else zombie:getModData().xv = (((-radius-xdiff)*1.5)/BlowBackRed) ; end
					if(ydiff < 0) then zombie:getModData().yv = (((radius-ydiff)*1.5)/BlowBackRed) ; 
					else zombie:getModData().yv = (((-radius-ydiff)*1.5)/BlowBackRed) ;  end
					zombie:getModData().zv = ((radius-distance)*2)/BlowBackRed;
					
					if(instanceof(zombie,"IsoZombie")) then
						if(ZombRand(radius)+1 > distance) then zombie:getModData().dieonland = true end
						if(ZombRand(radius)+1 > distance) then zombie:getModData().crawlonland = true end
					elseif (instanceof(zombie,"IsoPlayer") and (ZombRand(radius)+1 > distance)) then
						zombie:getBodyDamage():AddRandomDamage() ;
					end
					zombie:getModData().goingup = true;
					zombie:getModData().xa = 0 ;
					zombie:getModData().ya = 0 ; 
					zombie:getModData().za = 0; --(radius-distance)/100;
					c = c + 1;
					--print(tostring(c).."z set " .. tostring(zombie:getModData().xv) .. "," .. tostring(zombie:getModData().yv) .. "," .. tostring(zombie:getModData().zv) .. ",");
				end
			end
		end
end



function HandleTrap(player, trap)
	if(trap:getType() == "BearTrap") and (trap:getModData().isSet == true or trap:getWorldItem():getModData().isSet == true) then
	
		if(instanceof(player,"IsoZombie")) then
			if player:getSpeedMod() > 0.50 then
				player:toggleCrawling();
			else
				player:setHealth( player:getHealth() - ((ZombRand(25) + 40)/100) )
			end
		elseif (instanceof(player,"IsoPlayer")) then	
			local BP;
			if(ZombRand(2) == 0) then
				BP = player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L);
			else
				BP = player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R);
			end
			
			if(ZombRand(2) == 0) then
				BP:setFractureTime(100);
			else
				BP:generateDeepWound();
			end
			
			BP:AddDamage(ZombRand(25) + 40);
		end
		
			trap:getModData().isSet = false;
			trap:getWorldItem():getModData().isSet = false;
			player:getCurrentSquare():getModData().isTrapSet = false;
			player:getCurrentSquare():transmitModdata();
			player:getCurrentSquare():transmitRemoveItemFromSquare(trap:getWorldItem());
			trap:getWorldItem():removeFromSquare();				
			
			local newtrap = player:getInventory():AddItem("Trap."..trap:getType().."Closed");
			player:getCurrentSquare():AddWorldInventoryItem(newtrap,0.5,0.5,0);
			player:getInventory():Remove(newtrap);
			
			getSoundManager():PlayWorldSound("beartrap", false, getPlayer():getCurrentSquare(), 0.2, 60, 0.2, false) ;
		
	elseif (trap:getType() == "SpikeTrap") and (trap:getModData().isSet == true) then
	
		if(instanceof(player,"IsoZombie")) then
			if player:getSpeedMod() > 0.50 then
				if ZombRand(0,2) == 0 then 
					player:toggleCrawling();
				end
			else
				player:setHealth(player:getHealth() - ((ZombRand(25) + 40)/100))
			end
		elseif (instanceof(player,"IsoPlayer")) then		
			local BP;
			
			BP = player:getBodyDamage():getBodyPart(BodyPartType.Foot_L );
			BP:generateDeepWound();
			BP = player:getBodyDamage():getBodyPart(BodyPartType.Foot_R );
			BP:generateDeepWound();
		
			BP:AddDamage(ZombRand(25) + 40);
		end	
		trap:getModData().isSet = false;
		trap:getWorldItem():getModData().isSet = false;
		player:getCurrentSquare():getModData().isTrapSet = false;
		player:getCurrentSquare():transmitModdata();
		
		player:getCurrentSquare():transmitRemoveItemFromSquare(trap:getWorldItem());
		trap:getWorldItem():removeFromSquare();		
		
		local newtrap = player:getInventory():AddItem("Trap."..trap:getType().."Closed");
		player:getCurrentSquare():AddWorldInventoryItem(newtrap,0.5,0.5,0);
		player:getInventory():Remove(newtrap);
		
		getSoundManager():PlayWorldSound("stabbing", false, getPlayer():getCurrentSquare(), 0.2, 60, 0.2, false) ;
	
	elseif (trap:getType() == "PropaneTrap") and (trap:getModData().isSet == true) then
		if(instanceof(player,"IsoZombie")) then
			player:SetOnFire()
		elseif (instanceof(player,"IsoPlayer")) then
			local BP;
			
			BP = getRandomBodyPart(player);
			BP:AddDamage(ZombRand(25) + 40);
			BP:setBurned();
			
			BP = getRandomBodyPart(player);
			BP:AddDamage(ZombRand(25) + 40);
			BP:setBurned();
		end
		trap:getModData().isSet = false;
		trap:getWorldItem():getModData().isSet = false;
		player:getCurrentSquare():getModData().isTrapSet = false;
		player:getCurrentSquare():transmitModdata();
		
		player:getCurrentSquare():explode();
		player:getCurrentSquare():explode();
		
		player:getCurrentSquare():transmitRemoveItemFromSquare(trap:getWorldItem());
		trap:getWorldItem():removeFromSquare();		
		
		getSoundManager():PlayWorldSound("explosion", false, getPlayer():getCurrentSquare(), 0.2, 60, 0.2, false) ;
		
	elseif (trap:getType() == "LandMine") or (trap:getType() == "LandMineBig") then
		
		if (trap:getType() == "LandMine") then 
			-- player:getCurrentSquare():explode();
			ExplodeZombies(player:getCurrentSquare(),9); 
			smokePop(player, 1)	
		end
		if (trap:getType() == "LandMineBig") then 
			ExplodeZombies(player:getCurrentSquare(),12); 
			-- player:getCurrentSquare():getN():getN():getN():getN():explode();
			-- player:getCurrentSquare():getE():getE():getE():getE():explode();
			-- player:getCurrentSquare():getW():getW():getW():getW():explode();
			-- player:getCurrentSquare():getS():getS():getS():getS():explode();
			smokePop(player, 3)	
		end
		player:getCurrentSquare():transmitRemoveItemFromSquare(trap:getWorldItem());
		trap:getWorldItem():removeFromSquare();				
		getSoundManager():PlayWorldSound("explosion_landmine", false, getPlayer():getCurrentSquare(), 0.2, 60, 0.2, false) ;
		smokePop(player)
	end
end

function CheckForTrap(player)
	if(player:getCurrentSquare() ~= nil) then
		if (player:getCurrentSquare():getModData().isTrapSet == true) and (player:getModData().immuneToTrap ~= true) then
				local Objs = player:getCurrentSquare():getObjects();
			
			for i=0, Objs:size()-1 do
				if (Objs:get(i):getWorldObjectIndex() ~= -1) then -- (Objs:get(i):getName() == "Spike Trap (Set)") then
					if(Objs:get(i):getItem() ~= nil) and (Objs:get(i):getItem():getModData().isSet == true or Objs:get(i):getModData().isSet == false) then
						HandleTrap(player,Objs:get(i):getItem());
					end
				end
			end
			
			
		elseif (player:getCurrentSquare():getModData().isTrapSet == nil) or (player:getCurrentSquare():getModData().isTrapSet == false) or (player:getModData().immuneToTrap == nil) then
			player:getModData().immuneToTrap = false; 
		end
	end
end

function TrapupdateThePlayer(player)
	
	CheckForTrap(player);
	player:getInventory():Remove("Nothing");
end

function TrapsKeysUp(keyNum) 
local player = getPlayer();
	--getPlayer():Say(tostring(keyNum));	
	if (keyNum == 210) then
		
	
		--getPlayer():Say(tostring(getPlayer():getModData().immuneToTrap) .. "|" .. tostring(getPlayer():getCurrentSquare():getModData().isTrapSet));
	end
	
end


local function ZombiePhysicsHandle(zombie)

	
	if(zombie:getModData().xa == nil) or (zombie:getModData().ya == nil) or (zombie:getModData().za == nil) then
		return false;
	end
	
	if(zombie:getModData().xv == nil) or (zombie:getModData().yv == nil) or (zombie:getModData().zv == nil) then
		zombie:getModData().xv = 0;
		zombie:getModData().yv = 0;
		zombie:getModData().zv = 0;
		zombie:getModData().goingup = true;
	end
	
	if (zombie:getZ() == 0) and (zombie:getModData().xv == 0 or zombie:getModData().xv == nil) and (zombie:getModData().yv == 0 or zombie:getModData().yv == nil) and (zombie:getModData().zv == 0 or zombie:getModData().zv == nil) then
		zombie:getModData().xa = nil;
		zombie:getModData().ya = nil;
		zombie:getModData().za = nil;
		zombie:getModData().xv = nil;
		zombie:getModData().yv = nil;
		zombie:getModData().zv = nil;
		return false;
	end
	
		if (zombie:getZ() == 0) then useDrag = (Drag*2.5);
		else useDrag = (Drag/2) end
		
		if(zombie:getModData().xv < 0) then
		zombie:getModData().xv = zombie:getModData().xv + useDrag;
			if(zombie:getModData().xv > 0) then
			zombie:getModData().xv = 0;
			end
		elseif (zombie:getModData().xv > 0) then
		zombie:getModData().xv = zombie:getModData().xv - useDrag;
			if(zombie:getModData().xv < 0) then
			zombie:getModData().xv = 0;
			end
		end
		if(zombie:getModData().yv < 0) then
		zombie:getModData().yv = zombie:getModData().yv + useDrag;
			if(zombie:getModData().yv > 0) then
			zombie:getModData().yv = 0;
			end
		elseif (zombie:getModData().yv > 0) then
		zombie:getModData().yv = zombie:getModData().yv - useDrag;
			if(zombie:getModData().yv < 0) then
			zombie:getModData().yv = 0;
			end
		end
		
		if(zombie:getZ() > 0)  then
			zombie:getModData().zv = zombie:getModData().zv - Gravity;
		elseif(not zombie:getModData().goingup) then
			zombie:getModData().zv = 0;
		end
		
		if(zombie:getModData().goingup and zombie:getModData().zv < 0) then zombie:getModData().goingup = false end
		
		
		zombie:getModData().xv = zombie:getModData().xv + zombie:getModData().xa;
		zombie:getModData().yv = zombie:getModData().yv + zombie:getModData().ya;
		zombie:getModData().zv = zombie:getModData().zv + zombie:getModData().za;
		
		local nx = zombie:getX() + zombie:getModData().xv;
		local ny = zombie:getY() + zombie:getModData().yv;
		local nz = zombie:getZ() + zombie:getModData().zv;
				
		if(nz < 0) then nz = 0; 		
		elseif(nz == zombie:getZ()) and (nx == zombie:getX()) and (ny == zombie:getY()) then return false end
		
		--if(zombie == getPlayer() and (ZombRand(10) == 0)) then 
		--	zombie:Say(tostring(zombie:getModData().xv) .. "," .. tostring(zombie:getModData().yv) .. "," .. tostring(zombie:getModData().zv)  ) ;
		---	zombie:Say(tostring(zombie:getModData().xa) .. "," .. tostring(zombie:getModData().ya) .. "," .. tostring(zombie:getModData().za)  ) ;
		--end
		zombie:setX(nx);
		zombie:setY(ny);
		zombie:setZ(nz);
		
		if(zombie:getZ() == 0) and (instanceof(zombie,"IsoZombie")) then 		
			if(zombie:getModData().dieonland == true) then 
			--zombie:Say("!");
			zombie:Kill(nil); 			
			zombie:getModData().dieonland = nil;
			zombie:getModData().crawlonland = nil;
			elseif(zombie:getModData().crawlonland == true) and (zombie:isFakeDead() == false) then 
				if player:getSpeedMod() > 0.50 then
					player:toggleCrawling();
				else
					zombie:setFakeDead(true); 
				end
			--zombie:Say("?");
			zombie:getModData().dieonland = nil;
			zombie:getModData().crawlonland = nil;
			end
		end
		

end

local function ZombieUpdateHandle(zombie)
	
	--if(ZombRand(10) == 0) then zombie:Say(tostring(zombie:getZ())); end
	CheckForTrap(zombie);
	
	if(zombie:getModData().lastX ~= nil) and (zombie:getModData().Mounted ~= nil) then -- mounted on square
		zombie:setX(zombie:getModData().lastX);
		zombie:setY(zombie:getModData().lastY);
		zombie:setZ(zombie:getModData().lastZ);
	elseif(MyZombie ~= nil) and (zombie == MyZombie) then   -- being draged
		
		if(zombie:getModData().lastX == nil) then
			zombie:getModData().lastX = zombie:getX();
			zombie:getModData().lastY = zombie:getY();
			zombie:getModData().lastZ = zombie:getZ();
		end
	end
	
	if(zombie == MyZombie) then
		if(zombie:getModData().lastX ~= nil) then
			zombie:setX(zombie:getModData().lastX);
			zombie:setY(zombie:getModData().lastY);
			zombie:setZ(zombie:getModData().lastZ);
		end
		ZombiePhysicsHandle(zombie);
		if(zombie:getModData().lastX ~= nil) then
			zombie:getModData().lastX = zombie:getX();
			zombie:getModData().lastY = zombie:getY();
			zombie:getModData().lastZ = zombie:getZ();
		end
	else
		ZombiePhysicsHandle(zombie);
	end
	
end



Events.OnZombieDead.Add(ZombieDeadHandle);
Events.OnZombieUpdate.Add(ZombieUpdateHandle)
Events.OnKeyPressed.Add(TrapsKeysUp);
Events.OnPlayerUpdate.Add(TrapupdateThePlayer);
