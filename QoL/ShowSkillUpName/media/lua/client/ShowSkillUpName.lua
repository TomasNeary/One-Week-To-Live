local gameVersion = tonumber(string.sub(getCore():getVersionNumber(), 0, 2))

local function ShowSkill(player, skill, level)
	local perk = PerkFactory.getPerk(Perks.FromString(tostring(skill)))

	if perk ~= nil then
		if gameVersion > 40 then
			if player:isNPC() == false then -- Super Survivor compatibility. Otherwise player spams nearby survivor skill level ups.
				player:Say(perk:getName() .. " Lvl." .. tostring(level))
			end
		else
			local parentPerk = perk:getParent()
			local parentName = ""
				
			if parentPerk == Perks.BladeParent or parentPerk == Perks.BluntParent then
				parentName = string.sub(tostring(parentPerk), 0, 5) .. " "
			end
			
			player:Say(parentName .. perk:getName() .. " Lvl." .. tostring(level))
		end
	end
end

Events.LevelPerk.Add(ShowSkill)