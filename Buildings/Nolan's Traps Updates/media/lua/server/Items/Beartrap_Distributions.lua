require 'Items/SuburbsDistributions'
require "Items/ProceduralDistributions"
require "Items/VehicleDistributions"
require "Items/ItemPicker"
	
	table.insert(SuburbsDistributions["gunstorestorage"]["all"].items, "Trap.BearTrap");
	table.insert(SuburbsDistributions["gunstorestorage"]["all"].items, 1.0);
	
	table.insert(SuburbsDistributions["hunting"]["locker"].items, "Trap.BearTrap");
	table.insert(SuburbsDistributions["hunting"]["locker"].items, 1.0);

	table.insert(SuburbsDistributions["hunting"]["metal_shelves"].items, "Trap.BearTrap");
	table.insert(SuburbsDistributions["hunting"]["metal_shelves"].items, 1.0);
	
	table.insert(SuburbsDistributions["hunting"]["metal_shelves"].items, "Trap.BearTrap");
	table.insert(SuburbsDistributions["hunting"]["metal_shelves"].items, 1.0);

	table.insert(SuburbsDistributions["Bag_WeaponBag"].items, "Trap.BearTrap");
	table.insert(SuburbsDistributions["Bag_WeaponBag"].items, 1.0);
	
	table.insert(ProceduralDistributions.list["MeleeWeapons"].items, "Trap.BearTrap");
	table.insert(ProceduralDistributions.list["MeleeWeapons"].items, 1.0);