function Recipe.OnGiveXP.Woodwork3(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Woodwork, 3);
end

function Recipe.OnGiveXP.Woodwork5(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Woodwork, 5);
end

function Recipe.OnGiveXP.Woodwork10(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Woodwork, 10);
end

-- These functions are defined to avoid breaking mods.
Give3WoodworkXP = Recipe.OnGiveXP.Woodwork3
Give5WoodworkXP = Recipe.OnGiveXP.Woodwork5
Give10WoodworkXP = Recipe.OnGiveXP.Woodwork10

function Recipe.OnGiveXP.MetalWelding3(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.MetalWelding, 3);
end

function Recipe.OnGiveXP.MetalWelding5(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.MetalWelding, 5);
end

function Recipe.OnGiveXP.MetalWelding10(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.MetalWelding, 10);
end

-- These functions are defined to avoid breaking mods.
Give3MetalWeldingXP = Recipe.OnGiveXP.MetalWelding3
Give5MetalWeldingXP = Recipe.OnGiveXP.MetalWelding5
Give10MetalWeldingXP = Recipe.OnGiveXP.MetalWelding10
