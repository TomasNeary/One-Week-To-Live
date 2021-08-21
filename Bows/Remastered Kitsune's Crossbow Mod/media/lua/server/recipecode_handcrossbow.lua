function DismantleHandCrossbow_OnCreate(items, result, player, selectedItem)

	local luckyNumber = ZombRand(1,6);

    for i=1, ZombRand(1,3) do
	
		if luckyNumber == 1 then 
			break
		end		
        player:getInventory():AddItem("Base.ScrapMetal");
    end
	
end

function DismantleHuntingCrossbow_OnCreate(items, result, player, selectedItem)

	player:getInventory():AddItem("Base.Rope");
	
	local luckyNumber = ZombRand(1,6);
	
    for i=1, luckyNumber do
		if luckyNumber == 1 then 
			break
		end
        player:getInventory():AddItem("Base.ScrapMetal");
    end
end