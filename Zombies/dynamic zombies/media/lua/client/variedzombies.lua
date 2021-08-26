--[[
Zombies become very active, scattering and moving around often

By Nolan Ritchie

--edit by ddraig, to incorporate code from Nolan's Nocturnal Zombies speed changes

]]

local VZScatter=true; --turn to false to have zombies not randomly scatter

local VZDynamicSpeeds=true; --turn to false to not have zombies change speeds

local VPUCount = 0;


function VScatterZombies() 

	--sendClientCommand(getPlayer(), "RestlessZombies", "ScatterZombies", {difficulty= "easyPZ"});
	sendClientCommand(getPlayer(), "VariedZombies", "VScatterZombies", {difficulty= "easyPZ"});
	local tempx;
	local tempy;
	
	local zlist = getPlayer():getCell():getZombieList();
	if(zlist ~= nil) then
		for i=0, zlist:size()-1 do
			if ZombRand(10) == 0 and VZScatter then --1 in 3 chance to scatter the zombie
				if(zlist:get(i):getModData().oldScatter == nil) then 
					tempx = zlist:get(i):getX() + ZombRand(-50,50);
					tempy = zlist:get(i):getY() + ZombRand(-50,50);
					zlist:get(i):getModData().oldScatter = 1;
				elseif(zlist:get(i):getModData().oldScatter~= nil) then
					tempx = zlist:get(i):getX() + ZombRand(-1,1);
					tempy = zlist:get(i):getY() + ZombRand(-1,1);
					zlist:get(i):getModData().oldScatter = nil;
				end
				zlist:get(i):PathTo(tempx,tempy,zlist:get(i):getZ(),true);
			end
			if ZombRand(10) == 0  and VZDynamicSpeeds and not zlist:get(i).bCrawling then --1 in 10 chance to alter the zombie speed, or slow it back down
				if(zlist:get(i):getModData().oldMoveSpeed == nil) then 
					zlist:get(i):getModData().oldMoveSpeed = zlist:get(i):getSpeedMod();
					if ZombRand(2) == 0 then
						zlist:get(i):setSpeedMod((1 + ZombRandFloat(0.0,0.6))); --speed up --1.5
					else
						zlist:get(i):setSpeedMod((1 - ZombRandFloat(0.0,0.6))); --slow down --1.5
					end
				elseif(zlist:get(i):getModData().oldMoveSpeed ~= nil) then
					zlist:get(i):setSpeedMod(zlist:get(i):getModData().oldMoveSpeed);
					zlist:get(i):getModData().oldMoveSpeed = nil;				
				end
			end			
	
		end
	end
	
end

--[[
function NZKeyUp(keyNum)

	getPlayer():Say(tostring(keyNum));
	if(keyNum == 199) then
		ScatterZombies();
	end
	
end]]

--Events.EveryTenMinutes.Add(VScatterZombies);

function VZInit()
	VPUCount = 0;
	
end

function VZPlayerUpdateHandle(player)
VPUCount = VPUCount + 1;
	--player:Say(tostring(TwoHoursOfTerrorUse))
	if(VPUCount == 400) then
		--player:Say("working");
		VPUCount = 0;
		VScatterZombies();
	end
	
end

Events.OnGameStart.Add(VZInit);
Events.OnPlayerUpdate.Add(VZPlayerUpdateHandle);