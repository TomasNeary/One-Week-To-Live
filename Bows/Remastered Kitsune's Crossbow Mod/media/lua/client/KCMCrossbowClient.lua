local function shootCrossbow(player,item)
	if item:getType() == "LargeCrossbow" then
		if item:getCondition() == 1 then
		--	item:setName("Crossbow (String Snapped)");
		--	item:setCondition(2);
		--	player:Say("string snapped");
		--	if self.gun:getType() == "CrossbowStrungString" then self.gun:setWeaponSprite("LactoseCrossbow.CrossbowSnappedString"); end
		--	if self.gun:getType() == "CrossbowStrungNylon" or self.gun:getType() == "CrossbowStrungSteel" then self.gun:setWeaponSprite("LactoseCrossbow.CrossbowSnappedNylon"); end
		--	if self.gun:getType() == "ModernCrossbowStrungSteel" or self.gun:getType() == "ModernCrossbowStrungNylon" or self.gun:getType() == "ModernCrossbowStrungString" then self.gun:setWeaponSprite("LactoseCrossbow.ModernCrossbowUnstrung"); end
			player:resetEquippedHandsModels();
			--item:setIcon("LactoseCrossbow.CrossbowUnstrung");	--returns an error message
		end
	end
end

local function hitCrossbow(attacker,target,weapon,damage)
    local ammoType = weapon:getAmmoType();
 
    if ammoType ~= nil then
    --If ammoType is nil, it's a melee attack, do nothing
        if ammoType == "KCMweapons.CrossbowBoltLarge" then
            --large bolt, get the targets data.
            local modData = target:getModData();
            --Check if there's already a variable for large bolts, if not create it, if there is add to it.
            if modData.LCquarrels == nil then
                modData.LCquarrels = 1;
            else
                modData.LCquarrels = modData.LCquarrels + 1;
            end
        end
        
        if ammoType == "KCMweapons.CrossbowBolt" then
            --short bolt
            local modData = target:getModData();
            if modData.LCquarrels2 == nil then
                modData.LCquarrels2 = 1;
            else 
                modData.LCquarrels2 = modData.LCquarrels2 + 1;
            end
        end
        
        if ammoType == "KCMweapons.WoodenBolt" then
            --wooden bolt
            local modData = target:getModData();
            if modData.LCquarrels3 == nil then
                modData.LCquarrels3 = 1;
            else 
                modData.LCquarrels3 = modData.LCquarrels3 + 1;
            end
        end
    end
end



local function KCMOnEquiPrimary(player,item)	
	if item ~= nil then  	
		local itemType = item:getType();
		if itemType == "HandCrossbow" or itemType == "KCM_Compound" or itemType == "KCM_Compound02" or itemType == "KCM_Handmade" or itemType == "KCM_Handmade02" then
			if item:getCurrentAmmoCount() > 0 then
				if item:getType() == "HandCrossbow" then item:setWeaponSprite("KCMweapons.HandCrossbowDrawn"); end
				if item:getType() == "KCM_Compound" then item:setWeaponSprite("KCMweapons.KCM_CompoundDrawn"); end
				if item:getType() == "KCM_Compound02" then item:setWeaponSprite("KCMweapons.KCM_CompoundDrawn02"); end
				if item:getType() == "KCM_Handmade" then item:setWeaponSprite("KCMweapons.KCM_HandmadeDrawn"); end
				if item:getType() == "KCM_Handmade02" then item:setWeaponSprite("KCMweapons.KCM_HandmadeDrawn02"); end
				player:resetEquippedHandsModels();
			end
		end
	end
end

local function KCMOnLoad()
	local player = getPlayer();	
	local item = player:getPrimaryHandItem();
	if item ~= nil then  	
		local itemType = item:getType();
		if itemType == "HandCrossbow" or itemType == "KCM_Compound" or itemType == "KCM_Compound02" or itemType == "KCM_Handmade" or itemType == "KCM_Handmade02"  then
			if item:getCurrentAmmoCount() > 0 then
				if item:getType() == "HandCrossbow" then item:setWeaponSprite("KCMweapons.HandCrossbowDrawn"); end
				if item:getType() == "KCM_Compound" then item:setWeaponSprite("KCMweapons.KCM_CompoundDrawn"); end
				if item:getType() == "KCM_Compound02" then item:setWeaponSprite("KCMweapons.KCM_CompoundDrawn02"); end
				if item:getType() == "KCM_Handmade" then item:setWeaponSprite("KCMweapons.KCM_HandmadeDrawn"); end
				if item:getType() == "KCM_Handmade02" then item:setWeaponSprite("KCMweapons.KCM_HandmadeDrawn02"); end
				player:resetEquippedHandsModels();
			end
		end
	end
	local modData = player:getModData();
end

local function KCMOnZombieDead(zombie)
    local modData = zombie:getModData();   
 
    if modData.LCquarrels ~= nil then
        for i = 1,modData.LCquarrels, 1
        do
            local luckyNumber = ZombRand(1,100);
            print(luckyNumber)
            
            local bolt
            
            if luckyNumber <= 90 then
                bolt = zombie:getInventory():AddItem("KCMweapons.CrossbowBoltLarge");
            else
                bolt = zombie:getInventory():AddItem("KCMweapons.LongBrokenBolt");
            end
        end
        modData.LCquarrels = 0;
    end
 
    if modData.LCquarrels2 ~= nil then
        for i = 1,modData.LCquarrels2, 1
        do
            local luckyNumber = ZombRand(1,100);
            print(luckyNumber)
            
            local bolt
            
            if luckyNumber <= 90 then
                bolt = zombie:getInventory():AddItem("KCMweapons.CrossbowBolt");
            else
                bolt = zombie:getInventory():AddItem("KCMweapons.ShortBrokenBolt");
            end
        end
        modData.LCquarrels2 = 0;
    end
 
    if modData.LCquarrels3 ~= nil then
        for i = 1,modData.LCquarrels3, 1
        do
            local luckyNumber = ZombRand(1,100);
            print(luckyNumber)
            
            local bolt
            
            if luckyNumber <= 75 then
                bolt = zombie:getInventory():AddItem("KCMweapons.WoodenBolt");
            else
                bolt = zombie:getInventory():AddItem("KCMweapons.WoodenBrokenBolt");
            end
            
        end
        modData.LCquarrels3 = 0;
    end
end






--------------------------------------------------------
Events.OnPressReloadButton.Remove(ISReloadWeaponAction.OnPressReloadButton);
local original_OnPressReloadButton = ISReloadWeaponAction.OnPressReloadButton
-- Called when pressing reload button when not already reloading, only called when you have an equipped weapon to reload (with available bullets or clip)
ISReloadWeaponAction.OnPressReloadButton = function(player, gun)
	if gun:getType() == "HandCrossbow" or gun:getType() == "KCM_Compound" or gun:getType() == "KCM_Compound02"  or gun:getType() == "KCM_Handmade"  or gun:getType() == "KCM_Handmade02" then
		if gun:getName() ~= "Crossbow (String Snapped)" then
			-- If you press reloading while loading bullets, we stop and rack
			if player:getVariableBoolean("isLoading") then
				ISTimedActionQueue.clear(player);
				ISTimedActionQueue.add(ISKCMReloadCrossbowAction:new(player, gun, true));
			else
				-- if nothing can be loaded in we'll check to insert bullets into mags
				ISKCMReloadCrossbowAction.checkMagazines(player, gun)
				ISTimedActionQueue.add(ISKCMReloadCrossbowAction:new(player, gun, false));
			end
		end
	else
		original_OnPressReloadButton(player, gun);
	end
end

Hook.Attack.Remove(ISReloadWeaponAction.attackHook);
local original_attackHook = ISReloadWeaponAction.attackHook
-- can we attack?
-- need a chambered round
ISReloadWeaponAction.attackHook = function(character, chargeDelta, weapon)
	if weapon:getType() == "HandCrossbow" or weapon:getType() == "KCM_Compound" or weapon:getType() == "KCM_Compound02" or weapon:getType() == "KCM_Handmade" or weapon:getType() == "KCM_Handmade02" then
		ISTimedActionQueue.clear(character)
		if character:isAttackStarted() then return; end
		if weapon:isRanged() and not character:isShoving() then
			if ISKCMReloadCrossbowAction.canShoot(weapon) then
				character:playSound(weapon:getSwingSound());
				AddWorldSound(character, weapon:getSoundRadius(), weapon:getSoundVolume());
				character:DoAttack(0);
			else
				character:DoAttack(0);
				character:setRangedWeaponEmpty(true);
			end
		else
			ISTimedActionQueue.clear(character)
			if(chargeDelta == nil) then
				character:DoAttack(0);
			else
				character:DoAttack(chargeDelta);
			end
		end
	else
		original_attackHook(character, chargeDelta, weapon);
	end
end

Events.OnWeaponSwingHitPoint.Remove(ISReloadWeaponAction.onShoot);
local original_onShoot = ISReloadWeaponAction.onShoot
-- shoot shoot bang bang
-- handle ammo removal, new chamber & jam chance
ISReloadWeaponAction.onShoot = function(player, weapon)
	if not weapon:isRanged() then return; end
	if weapon:getType() == "HandCrossbow"or weapon:getType() == "KCM_Compound" or weapon:getType() == "KCM_Compound02" or weapon:getType() == "KCM_Handmade" or weapon:getType() == "KCM_Handmade02" then
		if weapon:haveChamber() then
			weapon:setRoundChambered(false);
		end
		-- remove ammo, add one to chamber if we still have some
		if weapon:getCurrentAmmoCount() >= weapon:getAmmoPerShoot() then
			if weapon:haveChamber() then
				weapon:setRoundChambered(true);
			end
			weapon:setCurrentAmmoCount(weapon:getCurrentAmmoCount() - weapon:getAmmoPerShoot())
		end
		if weapon:isRackAfterShoot() then -- shotgun need to be rack after each shot to rechamber round
			player:setVariable("RackWeapon", weapon:getWeaponReloadType());
		end
		if weapon:getType() == "HandCrossbow" then weapon:setWeaponSprite("KCMweapons.HandCrossbow"); end
		if weapon:getType() == "KCM_Compound" then weapon:setWeaponSprite("KCMweapons.KCM_Compound"); end
		if weapon:getType() == "KCM_Compound02" then weapon:setWeaponSprite("KCMweapons.KCM_Compound02"); end
		if weapon:getType() == "KCM_Handmade" then weapon:setWeaponSprite("KCMweapons.KCM_Handmade"); end
		if weapon:getType() == "KCM_Handmade02" then weapon:setWeaponSprite("KCMweapons.KCM_Handmade02"); end
		player:resetEquippedHandsModels();
	else
		original_onShoot(player, weapon);
	end
end

Events.OnWeaponSwingHitPoint.Remove(ISReloadWeaponAction.OnPressRackButton);
local original_OnPressRackButton = ISReloadWeaponAction.OnPressRackButton
-- Called when pressing rack (if you rack while having a clip/bullets, we simply remove it and don't reload a new one)
ISReloadWeaponAction.OnPressRackButton = function(player, gun)
	if gun:getType() == "HandCrossbow" or gun:getType() == "KCM_Compound" or gun:getType() == "KCM_Compound02" or gun:getType() == "KCM_Handmade" or gun:getType() == "KCM_Handmade02" then
		-- if you press rack while loading bullets, we stop and rack
		if player:getVariableBoolean("isLoading") and not gun:isRoundChambered() then
			ISTimedActionQueue.clear(player);
		end
		ISTimedActionQueue.add(ISKCMReloadCrossbowAction:new(player, gun, true));
	else
		original_OnPressRackButton(player, gun);
	end
end

Events.OnPressReloadButton.Add(ISReloadWeaponAction.OnPressReloadButton);
Events.OnPressRackButton.Add(ISReloadWeaponAction.OnPressRackButton);
Events.OnWeaponSwingHitPoint.Add(ISReloadWeaponAction.onShoot);
Hook.Attack.Add(ISReloadWeaponAction.attackHook);
--------------------------------------------------------


Events.OnZombieDead.Add(KCMOnZombieDead);
Events.OnLoad.Add(KCMOnLoad);
Events.OnWeaponSwingHitPoint.Add(shootCrossbow);
Events.OnWeaponHitCharacter.Add(hitCrossbow);
Events.OnEquipPrimary.Add(KCMOnEquiPrimary);
Events.OnCreateSurvivor.Add(KCMOnCreateSurvivor);