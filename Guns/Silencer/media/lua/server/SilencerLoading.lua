require "Items/SuburbsDistributions"
require "Items/ItemPicker"

SSilencer = {}
SSilencer.getSprites = function()
	getTexture("Item_Silencer.png");
	print("Silencer:Textures and Sprites Loaded.");
end


	-- Add items for Gun Store locker
	table.insert(SuburbsDistributions["gunstore"]["locker"].items, "Silencer.Silencer");
	table.insert(SuburbsDistributions["gunstore"]["locker"].items, 10);

	table.insert(SuburbsDistributions["gunstore"]["displaycase"].items, "Silencer.Silencer");
	table.insert(SuburbsDistributions["gunstore"]["displaycase"].items, 10);
	
	table.insert(SuburbsDistributions["gunstore"]["locker"].items, "Silencer.Silencer");
	table.insert(SuburbsDistributions["gunstore"]["locker"].items, 10);

	-- Add items for Police Storage
	table.insert(SuburbsDistributions["policestorage"]["locker"].items, "Silencer.Silencer");
	table.insert(SuburbsDistributions["policestorage"]["locker"].items, 10);
	
	table.insert(SuburbsDistributions["policestorage"]["metal_shelves"].items, "Silencer.Silencer");
	table.insert(SuburbsDistributions["policestorage"]["metal_shelves"].items, 10);

--	table.insert(SuburbsDistributions["hunting"]["all"].items, "Silencer.Silencer");
--	table.insert(SuburbsDistributions["hunting"]["all"].items, 10);

	table.insert(SuburbsDistributions["storageunit"]["all"].items, "Silencer.Silencer");
	table.insert(SuburbsDistributions["storageunit"]["all"].items, 2);

	-- Avery rare in crates, locker and metal shelves
	table.insert(SuburbsDistributions["all"]["crate"].items, "Silencer.Silencer");
	table.insert(SuburbsDistributions["all"]["crate"].items, 1);

	table.insert(SuburbsDistributions["all"]["metal_shelves"].items, "Silencer.Silencer");
	table.insert(SuburbsDistributions["all"]["metal_shelves"].items, 1);
	

	if(not WeaponUpgrades["VarmintRifle"]) then WeaponUpgrades["VarmintRifle"] = {} end
	table.insert(WeaponUpgrades["VarmintRifle"], "Silencer.Silencer"); 
	if(not WeaponUpgrades["HuntingRifle"]) then WeaponUpgrades["HuntingRifle"] = {} end
	table.insert(WeaponUpgrades["HuntingRifle"], "Silencer.Silencer");
	if(not WeaponUpgrades["Pistol"]) then WeaponUpgrades["Pistol"] = {} end
	table.insert(WeaponUpgrades["Pistol"], "Silencer.Silencer");
	if(not WeaponUpgrades["Pistol2"]) then WeaponUpgrades["Pistol2"] = {} end
	table.insert(WeaponUpgrades["Pistol2"], "Silencer.Silencer");
	if(not WeaponUpgrades["Pistol3"]) then WeaponUpgrades["Pistol3"] = {} end
	table.insert(WeaponUpgrades["Pistol3"], "Silencer.Silencer");
	if(not WeaponUpgrades["AssaultRifle"]) then WeaponUpgrades["AssaultRifle"] = {} end
	table.insert(WeaponUpgrades["AssaultRifle"], "Silencer.Silencer");
	if(not WeaponUpgrades["AssaultRifle2"]) then WeaponUpgrades["AssaultRifle2"] = {} end
	table.insert(WeaponUpgrades["AssaultRifle2"], "Silencer.Silencer");

print("Silencer: SuburbsDistributions added. ");
Events.OnPreMapLoad.Add(SSilencer.getSprites);