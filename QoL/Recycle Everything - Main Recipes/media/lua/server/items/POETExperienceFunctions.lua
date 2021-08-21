function Recipe.OnGiveXP.ClothMending05(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.Tailoring, 5);
end

function Recipe.OnGiveXP.ClothMending10(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.Tailoring, 10);
end

function Recipe.OnGiveXP.ClothMending15(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.Tailoring, 15);
end

function Recipe.OnGiveXP.ClothMending20(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.Tailoring, 20);
end

function Recipe.OnGiveXP.ClothMending25(recipe, ingredients, result, player)
	player:getXp():AddXP(Perks.Tailoring, 25);
end

ClothMendingXP05 = Recipe.OnGiveXP.ClothMending05
ClothMendingXP10 = Recipe.OnGiveXP.ClothMending10
ClothMendingXP15 = Recipe.OnGiveXP.ClothMending15
ClothMendingXP20 = Recipe.OnGiveXP.ClothMending20
ClothMendingXP25 = Recipe.OnGiveXP.ClothMending25