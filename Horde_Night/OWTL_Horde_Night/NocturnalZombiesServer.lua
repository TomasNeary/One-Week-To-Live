local TwoHoursOfTerror = true; --three hours! 0:00 - 3:00
local interval = 400;

local DISTANCE_PLAYER_MAX_SQ = 115*115; --ignore zombies. may be over 170 and even 1000+
local DISTANCE_PLAYER = 90;
local DISTANCE_PLAYER_SQ = DISTANCE_PLAYER * DISTANCE_PLAYER; --pull zombies 90..115
local DISTANCE_PLAYER_IGNORE_SQ = 8*8; --ignore zombies 0..8 and let em crash doors and windows or eat the player.

local SPEED_MOD_PLUS = 0.55; -- additional speed
local SPEED_MOD_MAX = 1.3; --max speed mod
--local SPEED_MOD_MIN = 0.32;

function ScatterZombies(player) --, TwoHoursOfTerror)
	local zlist = player:getCell():getZombieList();
	if not zlist then		
		return;
	end
	local hour = getGameTime():getTimeOfDay();
	--print('---ScatterZombies ',player:getFullName());
	--print("Hour:",hour);
	local playerX = player:getX();
	local playerY = player:getY();
	local playerZ = player:getZ();
	local cnt_toofar,cnt_far,cnt_far1 = 0,0,0;
	
	--count zombies around the player in certain radius.
	local cnt1 = zlist:size()-1;
	local cnt2 = 0;
	local cnt_near = 0;
	local zombie_obj = {}
	local zombie_sq = {}
	for i=0,cnt1 do
		local zombie = zlist:get(i);
		local diffX = playerX - zombie:getX();
		local diffY = playerY - zombie:getY();
		local distsq = diffX*diffX + diffY*diffY;
		if distsq <= DISTANCE_PLAYER_MAX_SQ then
			cnt2 = cnt2 + 1;
			zombie_obj[cnt2] = zombie;
			zombie_sq[cnt2] = distsq;
			if distsq <= DISTANCE_PLAYER_SQ then
				cnt_near = cnt_near + 1;
			end
		end
	end
	
	--move zombies
	for i=1,cnt2 do
		local chance = 0; --means 100% chance
		if hour < 22 and hour > 5 then
			chance = 200;
		elseif hour >= 22 and hour < 23 then
			chance = (23 - hour) * 100;
		elseif hour > 4 and hour <= 5 then
			chance = (hour - 4) * 100;
		end
		local zombie = zombie_obj[i]; --current zombie
		local distanceFromPlayerSQ = zombie_sq[i];
		local save = zombie:getModData();
		--chance = 0; --move anyway
		
		if chance == 200 then
			--day time.
		elseif chance <= 1 or ZombRand(chance) == 0 then --moving in random direction
			local new_target = save.target and (save.target - save.increment);
			if new_target then
				save.target = new_target;
			end
			if save.gToPl == 1 then
				if new_target < 0 then
					save.gToPl = nil; --change direction on next iteration
				else
					if distanceFromPlayerSQ < DISTANCE_PLAYER_SQ then
						save.gToPl = nil;
					end
				end
			elseif (not new_target or new_target < 0) then
				local zombieZ = zombie:getZ();
				if zombieZ == 0 then
					if distanceFromPlayerSQ > DISTANCE_PLAYER_SQ then
						--cnt_far = cnt_far + 1;
						local simple_algorithm = cnt_near > 110 or cnt_near > ZombRand(70) + 40;
						if not simple_algorithm then
							--cnt_far1 = cnt_far1 + 1;
							local diffX = playerX - zombie:getX();
							local diffY = playerY - zombie:getY();
							local dx,dy = 0,0;
							if math.abs(diffX) > math.abs(diffY) then
								dx = 0.4 * DISTANCE_PLAYER * (diffX > 0 and 1 or -1);
								dy = dx * (diffY/diffX);
							else
								dy = 0.4 * DISTANCE_PLAYER * (diffY > 0 and 1 or -1);
								dx = dy * (diffX/diffY);
							end
							--cheating a bit, but zombie doesn't come to the player
							zombie:pathToLocation(playerX - math.floor(dx), playerY - math.floor(dy), 0);
							save.target = interval * 2;
							save.increment = ZombRand(150, interval);
							save.gToPl = 1;
						end
					elseif distanceFromPlayerSQ >= DISTANCE_PLAYER_IGNORE_SQ then
						local simple_algorithm = cnt_near > 110 or cnt_near > ZombRand(70) + 40;
						if simple_algorithm then
							local tempx = zombie:getX() + ZombRand(-50,50);
							local tempy = zombie:getY() + ZombRand(-50,50);
							zombie:pathToLocation(tempx,tempy,zombieZ);
						else --cheating AI again
							local tempx = playerX + ZombRand(-55,55); -- radius div sqrt(2)
							local tempy = playerY + ZombRand(-55,55);
							zombie:pathToLocation(tempx,tempy,zombieZ);
						end
						save.target = ZombRand(interval, interval * 3);
						save.increment = ZombRand(100, interval);
						--save.gToPl = nil;
					end
				elseif playerZ >= zombieZ and distanceFromPlayerSQ < 18*18 then --probably some building
					local tempx = playerX + ZombRand(-18,18); -- radius div sqrt(2)
					local tempy = playerY + ZombRand(-18,18);
					local sq = getCell():getGridSquare(tempx,tempy,zombieZ);
					if sq and sq:isSolidFloor() then --only if there is a floor
						zombie:pathToLocation(tempx,tempy,zombieZ);
						save.target = ZombRand(interval, interval * 3);
						save.increment = ZombRand(100, interval);
					end
				end
			end
		end
		if TwoHoursOfTerror then
			local speed = zombie:getSpeedMod();
			local deep_night; -- 0 .. 1.5 .. 0
			if hour >= 24 then
				deep_night = hour - 24;
			elseif hour <= 1.5 then
				deep_night = hour;
			else
				deep_night = 3 - hour;
			end
			if deep_night > 1 then
				deep_night = 1;
			end
			--deep_night=1; --high speed anyway
			
			if deep_night >= 0 then -- 0 .. 1
				if not save.oldMoveSpeed then
					if speed > 1 then --why??? isn't modData stable enough??
						print("NZ ERROR: modData was probably lost",speed,player:getFullName());
						speed = 0.9; --rude fix
					end
					save.oldMoveSpeed = speed;
				end
				local new_speed = save.oldMoveSpeed + deep_night * SPEED_MOD_PLUS;
				if new_speed > SPEED_MOD_MAX then
					new_speed = SPEED_MOD_MAX; -- 1.3
				end
				zombie:setSpeedMod(new_speed);
			else --day
				if save.oldMoveSpeed then --restore old.
					zombie:setSpeedMod(save.oldMoveSpeed);
					save.oldMoveSpeed = nil;
				elseif speed > 1 then --something goes wrong! Fix it!
					print("NZ ERROR: zombie is too fast "..speed..' '..player:getFullName());
					zombie:setSpeedMod(0.9); --rude fix
				end
			end
		end
	end
	--print("far: "..cnt_far1.."/"..cnt_far..", near: "..cnt_near..", cnt="..cnt2.."/"..(cnt1+1));
	--print("Player:",playerX,playerY,playerZ);
end

local OnClientCommand = function(module, command, player, args)
	if not isServer() or module ~= "NocturnalZombies" or command ~= "ScatterZombies" then
		return
	end;
	ScatterZombies(player); --, args.TwoHoursOfTerror == "true");
end
Events.OnClientCommand.Add(OnClientCommand);






