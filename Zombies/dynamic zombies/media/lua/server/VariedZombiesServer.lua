
--[[
Zombies become very active, scattering and moving around often

By Nolan Ritchie

--edit by ddraig, to incorporate code from Nolan's Nocturnal Zombies speed changes

]]

local VZScatter=true; --turn to false to have zombies not randomly scatter

local VZDynamicSpeeds=true; --turn to false to not have zombies change speeds


VariedZombies = {}
VariedZombies = {}
VariedZombies.version = "1.0";
VariedZombies.author = "edit of Nolan Richie Code by ddraig";
VariedZombies.modName = "VariedZombies";

VariedZombies.OnClientCommand = function(module, command, player, args)
	
	if not isServer() then return end;
	if module ~= "VariedZombies" then return end; 
	
	if command == "VScatterZombies" then       
		local tempx;
		local tempy;
		local zlist = player:getCell():getZombieList();
		if(zlist ~= nil) then
			for i=0, zlist:size()-1 do
			
				if ZombRand(10) == 0 and VZScatter and not zlist:get(i).bCrawling then --1 in 3 chance to scatter the zombie or unscatter it
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
				if ZombRand(10) == 0 and VZDynamicSpeeds then --1 in 10 chance to alter the zombie speed, or slow it back down
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
	
end
	
Events.OnClientCommand.Add(VariedZombies.OnClientCommand);