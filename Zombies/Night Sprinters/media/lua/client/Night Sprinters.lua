
local function ZombieChange(zombie)
	local vMod = zombie:getModData();
	local hour = getGameTime():getTimeOfDay();
	local gametime = GameTime:getInstance();
	local month = gametime:getMonth();
	local gametime = GameTime:getInstance();
	local minute = gametime:getMinutes(); 
	local rain = RainManager:getRainIntensity();
	local rv = 0.02;
	
-----------forallseasons-----------Makes it so that it updates every five seconds. -EveryTenMinutes is too long.
if minute == 1 or minute == 3 or minute == 5 or minute == 7 or minute == 9 or minute == 11 or minute == 13 or minute == 15 or minute == 17 or minute == 19 or minute == 21 or minute == 23 or minute == 25 or minute == 27 or minute == 29 or minute == 31 or minute == 33 or minute == 35 or minute == 37 or minute == 39 or minute == 41 or minute == 43 or minute == 45 or minute == 47 or minute == 49 or minute == 51 or minute == 53 or minute == 55 or minute == 57 or minute == 59 then
		vMod.SummerRunnerCheck = false;
		vMod.SummerFastShamblerCheck = false;
		vMod.AutumnRunnerCheck = false;
		vMod.AutumnFastShamblerCheck = false;
		vMod.WinterRunnerCheck = false;
		vMod.WinterFastShamblerCheck = false;
		vMod.SpringRunnerCheck = false;
		vMod.SpringFastShamblerCheck = false;

	
   ---------------SUMMER---------------
elseif month == 5 or month == 6 or month == 7 then
	if hour >= 23.0 and vMod.SummerRunnerCheck ~= true or hour <= 6.0 and vMod.SummerRunnerCheck ~= true or rain > rv and NS.config.rainsprinters == true and vMod.SummerRunnerCheck ~= true then
		if minute == 2 or minute == 4 or minute == 6 or minute == 8 or minute == 10 or minute == 12 or minute == 14 or minute == 16 or minute == 18 or minute == 20 or minute == 22 or minute == 24 or minute == 26 or minute == 28 or minute == 30 or minute == 32 or minute == 34 or minute == 36 or minute == 38 or minute == 40 or minute == 42 or minute == 44 or minute == 46 or minute == 48 or minute == 50 or minute == 52 or minute == 54 or minute == 56 or minute == 58 or minute == 60 then
		zombie:changeSpeed(1);
		zombie:DoZombieStats();
		--print("SummerRunnerUpdate");
		vMod.SummerRunnerCheck = true;
		if hour >= 6.0 then
			vMod.SummerFastShamblerCheck = false;
		end
		end
   elseif hour >= 6.0 and hour <= 23.0 and vMod.SummerFastShamblerCheck ~= true and NS.config.rainsprinters == true and rain < rv or hour >= 6.0 and hour <= 23.0 and vMod.SummerFastShamblerCheck ~= true and NS.config.rainsprinters == false then
		if minute == 2 or minute == 4 or minute == 6 or minute == 8 or minute == 10 or minute == 12 or minute == 14 or minute == 16 or minute == 18 or minute == 20 or minute == 22 or minute == 24 or minute == 26 or minute == 28 or minute == 30 or minute == 32 or minute == 34 or minute == 36 or minute == 38 or minute == 40 or minute == 42 or minute == 44 or minute == 46 or minute == 48 or minute == 50 or minute == 52 or minute == 54 or minute == 56 or minute == 58 or minute == 60 then
		zombie:changeSpeed(2);
		zombie:DoZombieStats();
		--print("SummerFastShamblerupdate");
		vMod.SummerFastShamblerCheck = true;
		if hour >= 23.0 then
		  vMod.SummerRunnerCheck = false;
		end
	end
	end

	---------------AUTUMN--------------
elseif month == 8 or month == 9 or month == 10 then
	if hour >= 22.0 and vMod.AutumnRunnerCheck ~= true or hour <= 6.0 and vMod.AutumnRunnerCheck ~= true or rain > rv and NS.config.rainsprinters == true and vMod.AutumnRunnerCheck ~= true then
		if minute == 2 or minute == 4 or minute == 6 or minute == 8 or minute == 10 or minute == 12 or minute == 14 or minute == 16 or minute == 18 or minute == 20 or minute == 22 or minute == 24 or minute == 26 or minute == 28 or minute == 30 or minute == 32 or minute == 34 or minute == 36 or minute == 38 or minute == 40 or minute == 42 or minute == 44 or minute == 46 or minute == 48 or minute == 50 or minute == 52 or minute == 54 or minute == 56 or minute == 58 or minute == 60 then
		zombie:changeSpeed(1);
		zombie:DoZombieStats();
		--print("AutumnRunnerUpdate");
		vMod.AutumnRunnerCheck = true;
		if hour >= 6.0 then
			vMod.AutumnFastShamblerCheck = false;
		end
		end

	elseif hour >= 6.0 and hour <= 22.0 and vMod.AutumnFastShamblerCheck ~= true and NS.config.rainsprinters == true and rain < rv or hour >= 6.0 and hour <= 22.0 and vMod.AutumnFastShamblerCheck ~= true and NS.config.rainsprinters == false then
		if minute == 2 or minute == 4 or minute == 6 or minute == 8 or minute == 10 or minute == 12 or minute == 14 or minute == 16 or minute == 18 or minute == 20 or minute == 22 or minute == 24 or minute == 26 or minute == 28 or minute == 30 or minute == 32 or minute == 34 or minute == 36 or minute == 38 or minute == 40 or minute == 42 or minute == 44 or minute == 46 or minute == 48 or minute == 50 or minute == 52 or minute == 54 or minute == 56 or minute == 58 or minute == 60 then
		zombie:changeSpeed(2);
		zombie:DoZombieStats();
		--print("AutumnFastShamblerupdate");
		vMod.AutumnFastShamblerCheck = true;
		if hour >= 22.0 then
		  vMod.AutumnRunnerCheck = false;
		end
	end
	end

	--------------WINTER-------------
elseif month == 11 or month == 0 or month == 1 then
	if hour >= 20.0 and vMod.WinterRunnerCheck ~= true or hour <= 6.0 and vMod.WinterRunnerCheck ~= true or rain > rv and NS.config.rainsprinters == true and vMod.WinterRunnerCheck ~= true then
		if minute == 2 or minute == 4 or minute == 6 or minute == 8 or minute == 10 or minute == 12 or minute == 14 or minute == 16 or minute == 18 or minute == 20 or minute == 22 or minute == 24 or minute == 26 or minute == 28 or minute == 30 or minute == 32 or minute == 34 or minute == 36 or minute == 38 or minute == 40 or minute == 42 or minute == 44 or minute == 46 or minute == 48 or minute == 50 or minute == 52 or minute == 54 or minute == 56 or minute == 58 or minute == 60 then
		zombie:changeSpeed(1);
		zombie:DoZombieStats();
		--print("WinterRunnerUpdate");
		vMod.WinterRunnerCheck = true;
		if hour >= 6.0 then
			vMod.WinterFastShamblerCheck = false;
		end
		end

	elseif hour >= 6.0 and hour <= 20.0 and vMod.WinterFastShamblerCheck ~= true and NS.config.rainsprinters == true and rain < rv or hour >= 6.0 and hour <= 20.0 and vMod.WinterFastShamblerCheck ~= true and NS.config.rainsprinters == false then
		if minute == 2 or minute == 4 or minute == 6 or minute == 8 or minute == 10 or minute == 12 or minute == 14 or minute == 16 or minute == 18 or minute == 20 or minute == 22 or minute == 24 or minute == 26 or minute == 28 or minute == 30 or minute == 32 or minute == 34 or minute == 36 or minute == 38 or minute == 40 or minute == 42 or minute == 44 or minute == 46 or minute == 48 or minute == 50 or minute == 52 or minute == 54 or minute == 56 or minute == 58 or minute == 60 then
		zombie:changeSpeed(2);
		zombie:DoZombieStats();
		--print("WinterFastShamblerupdate");
		vMod.WinterFastShamblerCheck = true;
		if hour >= 20.0 then
		  vMod.WinterRunnerCheck = false;
		end
	end
	end

	-------------SPRING-------------
elseif month == 2 or month == 3 or month == 4 then
	if hour >= 22.0 and vMod.SpringRunnerCheck ~= true or hour <= 6.0 and vMod.SpringRunnerCheck ~= true or rain > rv and NS.config.rainsprinters == true and vMod.SpringRunnerCheck ~= true then
		if minute == 2 or minute == 4 or minute == 6 or minute == 8 or minute == 10 or minute == 12 or minute == 14 or minute == 16 or minute == 18 or minute == 20 or minute == 22 or minute == 24 or minute == 26 or minute == 28 or minute == 30 or minute == 32 or minute == 34 or minute == 36 or minute == 38 or minute == 40 or minute == 42 or minute == 44 or minute == 46 or minute == 48 or minute == 50 or minute == 52 or minute == 54 or minute == 56 or minute == 58 or minute == 60 then
		zombie:changeSpeed(1);
		zombie:DoZombieStats();
		--print("SpringRunnerUpdate");
		vMod.SpringRunnerCheck = true;
		if hour >= 6.0 then
			vMod.SpringFastShamblerCheck = false;
		end
		end

	elseif hour >= 6.0 and hour <= 20.0 and vMod.SpringFastShamblerCheck ~= true and NS.config.rainsprinters == true and rain < rv or hour >= 6.0 and hour <= 20.0 and vMod.SpringFastShamblerCheck ~= true and NS.config.rainsprinters == false then
		if minute == 2 or minute == 4 or minute == 6 or minute == 8 or minute == 10 or minute == 12 or minute == 14 or minute == 16 or minute == 18 or minute == 20 or minute == 22 or minute == 24 or minute == 26 or minute == 28 or minute == 30 or minute == 32 or minute == 34 or minute == 36 or minute == 38 or minute == 40 or minute == 42 or minute == 44 or minute == 46 or minute == 48 or minute == 50 or minute == 52 or minute == 54 or minute == 56 or minute == 58 or minute == 60 then
		zombie:changeSpeed(2);
		zombie:DoZombieStats();
		--print("SpringFastShamblerupdate");
		vMod.SpringFastShamblerCheck = true;
		if hour >= 22.0 then
		  vMod.SpringRunnerCheck = false;
		end
	end
	end
end
	
 
end

Events.OnZombieUpdate.Add(ZombieChange);
   
