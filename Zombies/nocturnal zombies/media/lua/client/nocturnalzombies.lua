
--[[
Zombies become very active at night, scattering and moving around often

TwoHoursOfTerrorUse: from midnight to 2am zombies gain a speed boost

By Nolan Ritchie


]]

local PUCount = 0;
local TwoHoursOfTerrorUse = false;

function ScatterZombies() 
local hour = getGameTime():getTimeOfDay();
	if( hour < 5.0 ) or ( hour >= 22.0) then
		if(TwoHoursOfTerrorUse) then sendClientCommand(getPlayer(), "NocturnalZombies", "ScatterZombies", {TwoHoursOfTerror= "true"}); 
		else  sendClientCommand(getPlayer(), "NocturnalZombies", "ScatterZombies", {TwoHoursOfTerror= "false"}) end
		local tempx;
		local tempy;
		
		local zlist = getPlayer():getCell():getZombieList();
		if(zlist ~= nil) then
			for i=0, zlist:size()-1 do
				if(TwoHoursOfTerrorUse) then
					if(( hour < 2.0 ) or ( hour >= 24.0)) and (zlist:get(i):getModData().oldMoveSpeed == nil) then 
						zlist:get(i):getModData().oldMoveSpeed = zlist:get(i):getSpeedMod();
						zlist:get(i):setSpeedMod(1.5);
					elseif(zlist:get(i):getModData().oldMoveSpeed ~= nil) and not((( hour < 2.0 ) or ( hour >= 24.0))) then
						zlist:get(i):setSpeedMod(zlist:get(i):getModData().oldMoveSpeed);
						zlist:get(i):getModData().oldMoveSpeed = nil;
					end
				end
				tempx = zlist:get(i):getX() + ZombRand(-50,50);
				tempy = zlist:get(i):getY() + ZombRand(-50,50);
				
				zlist:get(i):PathTo(tempx,tempy,zlist:get(i):getZ(),true);
				
			end
		end
	end
end

function NZInit()
	PUCount = 0;
	if (TwoHoursOfTerror ~= nil) then
		TwoHoursOfTerrorUse = TwoHoursOfTerror;
	else 
		TwoHoursOfTerrorUse = false;
	end
end

function NZPlayerUpdateHandle(player)
PUCount = PUCount + 1;
	--player:Say(tostring(TwoHoursOfTerrorUse))
	if(PUCount == 400) then
		--player:Say("working");
		PUCount = 0;
		ScatterZombies();
	end
	
end

Events.OnGameStart.Add(NZInit);
Events.OnPlayerUpdate.Add(NZPlayerUpdateHandle);