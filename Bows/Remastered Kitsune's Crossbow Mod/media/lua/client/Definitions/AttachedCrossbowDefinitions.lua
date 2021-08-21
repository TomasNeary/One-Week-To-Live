AttachedWeaponDefinitions = AttachedWeaponDefinitions or {};

AttachedWeaponDefinitions.chanceOfAttachedWeapon = 6; -- Global chance of having an attached weapon, if we pass this we gonna add randomly one from the list


-- Hunting Crossbow on any zed's back
AttachedWeaponDefinitions.TKCMrossbowBack = {
	chance = 2,
	weaponLocation =  {"Rifle On Back"},
	bloodLocations = nil,
	addHoles = false,
	daySurvived = 14,
	weapons = {
		"KCMweapons.KCM_Compound",
		"KCMweapons.KCM_Compound02",
	},
}