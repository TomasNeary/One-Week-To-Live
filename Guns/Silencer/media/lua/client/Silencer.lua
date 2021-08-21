Silencer = {}
Silencer = {}
Silencer.version = "1.0";
Silencer.author = "Nolan";
Silencer.modName = "Silencer";

if(ItemValueTable == nil) then ItemValueTable = {}; end
ItemValueTable["Silencer.Silencer"] = 6.00;
ItemValueTable["Silencer.HMSilencer"] = 4.00;


-- function for silencer handling
local silencerOnEquipPrimary = function(player, item)
    if item == nil then return end
    --local itemType = item:getType()
    if not item.getCanon then return end
    if item:getCanon() == nil then return end
    -- get the scriptItem
    local scriptItem = item:getScriptItem()

    local soundVolume = scriptItem:getSoundVolume()
    local soundRadius = scriptItem:getSoundRadius()
    local swingSound = scriptItem:getSwingSound()


    if item:getCanon():getType() == "Silencer" then
        soundVolume = soundVolume * (0.10)
        soundRadius = soundRadius * (0.10)
        swingSound = 'silenced_shot'
    elseif item:getCanon():getType() == "HMSilencer" then
        
        soundVolume = soundVolume * (0.25)
        soundRadius = soundRadius * (0.25)
        swingSound = 'silenced_shot'
    end
	
    item:setSoundVolume(soundVolume)
    item:setSoundRadius(soundRadius)
    item:setSwingSound(swingSound)
end

Events.OnEquipPrimary.Add(silencerOnEquipPrimary)
       
Events.OnGameStart.Add(function() -- make sure our player is setup on game start
	local player = getPlayer()
	--local player = getSpecificPlayer(0)
	silencerOnEquipPrimary(player, player:getPrimaryHandItem())
end)

