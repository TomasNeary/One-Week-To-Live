-- Shows zombie healthpoint on hit --

function playerYelp()
if zedDown > 0 then
zedDown = zedDown - 1;
print(zedDown);
end
	
if zedDown == 2 then
zhealth = zrnd(zTarget:getHealth());
zhpmx = zrnd(zTarget:getModData().mHealth) * 0.01;
		
zTarget:Say(tostring(zhealth) .. " / " .. tostring(zhpmx), 1.0, 1.0, 1.0, UIFont.Dialogue, 30.0, "radio");
		
if zhpmx < zhealth then
zTarget:Say(tostring(zhealth) .. " / ---", 1.0, 1.0, 1.0, UIFont.Dialogue, 30.0, "radio");
end
		
if zhealth <= 25 then
zTarget:Say(tostring(zhealth) .. " / " .. tostring(zhpmx), 1.0, 1.0, 0.0, UIFont.Dialogue, 30.0, "radio");
end
		
if zhealth == 0 then
zTarget:Say("1" .. " / " .. tostring(zhpmx), 1.0, 1.0, 0.0, UIFont.Dialogue, 30.0, "radio");
end
		
if zhealth < 0 then
zTarget:Say("0" .. " / " .. tostring(zhpmx), 1.0, 0.0, 0.0, UIFont.Dialogue, 30.0, "radio");
end
		
-- Shows player damage --

--
if zhealth >= -666 then
tosay = zhealth - zTarget:getModData().newHealth;
if tosay < 0 then 
tosay = tosay * -1
end
getPlayer(0):Say(wptp, 1.0, 0.0, 0.0, UIFont.Dialogue, 30.0, "radio");
getPlayer(0):Say(tostring(tosay) .. " Damage", 1.0, 1.0, 1.0, UIFont.Dialogue, 30.0, "radio");
end
		
if zhealth < -666 then
getPlayer(0):Say(wptp, 1.0, 0.0, 0.0, UIFont.Dialogue, 30.0, "radio");
getPlayer(0):Say("Critical Damage", 1.0, 1.0, 1.0, UIFont.Dialogue, 30.0, "radio");
end		
--
		
end	
end

function zrnd(num)
return math.floor(num * 100 + 0.5);
end

local function zombieYelp(zombie)
zMod = zombie:getModData();
if zMod.hTag ~= true then
zMod.hTag = true;
zMod.mHealth = tostring(zrnd(zombie:getHealth()));
end
end

function markTarget(wielder, victim, weapon, damage)
wptp = weapon:getType()
zedDown = 4;
zTarget = victim;
zTarget:getModData().newHealth = zrnd(zTarget:getHealth());
end

zedDown = 0;

-- Shows zombie healthpoint permanently (not recommended for use)--

--[[
function zedhealth(zombie)
local zdff = math.floor(zombie:getHealth() * 100 + 0.5);
local zhxm = zombie:getModData().mHealth;
zombie:Say(tostring(zdff) .. " / " .. tostring(zhxm), 1.0, 1.0, 1.0, UIFont.Dialogue, 30.0, "radio");
end

Events.OnZombieUpdate.Add(zedhealth);
--]]

Events.OnWeaponHitCharacter.Add(markTarget);
Events.OnPlayerUpdate.Add(playerYelp)