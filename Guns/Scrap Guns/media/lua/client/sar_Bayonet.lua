require "Reloading/ISReloadableWeapon"


-- Sawn-off recipe callback, copies modData to the new sawn-off.
function SAR_OnBayonet(items, result, player)
	for i=0,items:size()-1 do
		local item = items:get(i)
		if item:getType() == "SARB" or item:getType() == "SARBO" then
			result:setCondition(item:getCondition())
			result:setCurrentAmmoCount(item:getCurrentAmmoCount())
			if result:haveChamber() and item:haveChamber() and item:isRoundChambered() then
				result:setRoundChambered(true)
			end
			 if item:isContainsClip() or ( item:getCurrentAmmoCount() > 0 and item:getMagazineType() )  then
				result:setContainsClip(true)
			end
			local modData = result:getModData()
			for k,v in pairs(item:getModData()) do
				modData[k] = v
			end
			result:attachWeaponPart(item:getScope())
			result:attachWeaponPart(item:getClip())
			result:attachWeaponPart(item:getSling())
			result:attachWeaponPart(item:getCanon())
			result:attachWeaponPart(item:getStock())
			result:attachWeaponPart(item:getRecoilpad())
			--if player:getPrimaryItem() == item then
				player:setPrimaryHandItem(result);
				player:setSecondaryHandItem(result);
			--end
			return
		end
    end
end

AttachedWeaponDefinitions = AttachedWeaponDefinitions or {};

AttachedWeaponDefinitions.AirTank = {
	chance = 80,
	outfit = {"FiremanFullSuit"},
	weaponLocation = {"Rifle On Back"},
	bloodLocations = nil,
	addHoles = false,
	daySurvived = 0,
	weapons = {
		"SGuns.AirTank",
	},
}