--[[
Zombies become very active , scattering and moving around often
 - By Nolan Ritchie
 - Modified by cerastes
 - Modified and optimized by Star
 - Changed to include the whole day by Conflictx
]]

local interval = 400;
local PUCount = 0;
--local TwoHoursOfTerrorUse = true;

--local DATA_TRUE = {TwoHoursOfTerror = "true"};
--local DATA_FALSE = {TwoHoursOfTerror = "false"};
local EMPTY_TABLE = {};
local function NZUpdateClient()
	local hour = getGameTime():getTimeOfDay();
	--if not (hour <= 5.0 or hour >= 22.0) then
	--	return;
	--end
	local player = getPlayer();
	--local args = { x0 = player:getX(), y0 = player:getY() };
	if not isClient() then --singleplayer
		ScatterZombies(player) --, TwoHoursOfTerrorUse);
		return;
	end
	--local data = TwoHoursOfTerrorUse and DATA_TRUE or DATA_FALSE
	--print("send command");
	sendClientCommand(player, "NocturnalZombies", "ScatterZombies", EMPTY_TABLE) --, data); 
end

function NZInit()
	PUCount = 0;
	--print("WELCOME!");
	--TwoHoursOfTerrorUse = TwoHoursOfTerror and true or false;
end

function NZPlayerUpdateHandle(player)
	--print("w");
	PUCount = PUCount + 1;
	--player:Say(tostring(TwoHoursOfTerrorUse))
	if(PUCount == interval) then
		--player:Say("working");
		--print("working");
		NZUpdateClient();
		PUCount = 0;
	end
end

Events.OnGameStart.Add(NZInit);
Events.OnPlayerUpdate.Add(NZPlayerUpdateHandle);