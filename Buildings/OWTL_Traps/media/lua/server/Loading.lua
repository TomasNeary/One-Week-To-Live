require "Items/SuburbsDistributions"
require "Items/ItemPicker"

TTrap = {}
TTrap.getSprites = function()
	getTexture("Item_BicycleHelmet.png");
	print("Textures and Sprites Loaded.");
end

	table.insert(SuburbsDistributions["all"]["crate"].items, "Trap.BearTrap");
	table.insert(SuburbsDistributions["all"]["crate"].items, 1.0);
	


print("SuburbsDistributions added. ");
Events.OnPreMapLoad.Add(TTrap.getSprites);