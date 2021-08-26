
NocturnalZombies = {}
NocturnalZombies = {}
NocturnalZombies.version = "1.0";
NocturnalZombies.author = "Nolan";
NocturnalZombies.modName = "NocturnalZombies";

NocturnalZombies.OnClientCommand = function(module, command, player, args)
	
	if not isServer() then return end;
	if module ~= "NocturnalZombies" then return end; 
	
	if command == "ScatterZombies" then       
	local hour = getGameTime():getTimeOfDay();
		local tempx;
		local tempy;
		local zlist = player:getCell():getZombieList();
		if(zlist ~= nil) then
			for i=0, zlist:size()-1 do
				if(args.TwoHoursOfTerror == "true") then
					if(( hour < 2.0 ) or ( hour >= 24.0)) and (zlist:get(i):getModData().oldMoveSpeed == nil) then 
						zlist:get(i):getModData().oldMoveSpeed = zlist:get(i):getSpeedMod();
						zlist:get(i):setSpeedMod(1.4);
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
	
Events.OnClientCommand.Add(NocturnalZombies.OnClientCommand);