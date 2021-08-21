AttachedWeaponDefinitions = AttachedWeaponDefinitions or {};

AttachedWeaponDefinitions.chanceOfAttachedWeapon = 6; -- Global chance of having an attached weapon, if we pass this we gonna add randomly one from the list


-- Hunting Crossbow on any zed's back
AttachedWeaponDefinitions.A_CrossbowBack = {
	chance = 2,
	weaponLocation =  {"Rifle On Back"},
	bloodLocations = nil,
	addHoles = false,
	daySurvived = 7,
	weapons = {
		"OWTLweapons.OWTL_Compound",
	},
}

AttachedWeaponDefinitions.B_CrossbowBack = {
	chance = 2,
	weaponLocation =  {"Rifle On Back"},
	bloodLocations = nil,
	addHoles = false,
	daySurvived = 14,
	weapons = {
		"OWTLweapons.OWTL_Compound02",
	},
}

AttachedWeaponDefinitions.C_CrossbowBack = {
	chance = 2,
	weaponLocation =  {"Rifle On Back"},
	bloodLocations = nil,
	addHoles = false,
	daySurvived = 21,
	weapons = {
		"OWTLweapons.OWTL_Compound03"
	},
}

--Bows on Zombie backs
AttachedWeaponDefinitions.A_BowBack = {
	chance = 2,
	weaponLocation =  {"Rifle On Back"},
	bloodLocations = nil,
	addHoles = false,
	daySurvived = 7,
	weapons = {
		"OWTLweapons.OWTL_Bow"
	},
}
AttachedWeaponDefinitions.B_BowBack = {
	chance = 2,
	weaponLocation =  {"Rifle On Back"},
	bloodLocations = nil,
	addHoles = false,
	daySurvived = 14,
	weapons = {
		"OWTLweapons.OWTL_Bow02",
	},
}