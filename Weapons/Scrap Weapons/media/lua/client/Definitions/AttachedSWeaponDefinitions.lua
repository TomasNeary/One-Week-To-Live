-- define weapons to be attached to zombies when creating them
-- random knives inside their neck, spear in their stomach, meatcleaver in their back...
-- this is used in IsoZombie.addRandomAttachedWeapon()

AttachedWeaponDefinitions = AttachedWeaponDefinitions or {};

AttachedWeaponDefinitions.chanceOfAttachedWeapon = 6; -- Global chance of having an attached weapon, if we pass this we gonna add randomly one from the list

-- random spear in the stomach
AttachedWeaponDefinitions.SWspearStomach = {
	chance = 1, -- chance is total, we'll get the chance of every definition and take one from there
	weaponLocation = {"Stomach"}, -- defined in AttachedLocations.lua
	bloodLocations = {"Torso_Lower","Back"}, -- we add blood & hole on this part
	addHoles = true, -- if true, you need at least one bloodLocation
	daySurvived = 30, -- needed day of survival before seeing this one
	weapons = { -- list of possible weapons, we'll take one randomly from there
		"SWeapons.SpearScrapMachete",
		"SWeapons.SpearScrapShiv",
		"SWeapons.SpearSharpenedScrewdriver",
	},
}

-- katana in stomach
AttachedWeaponDefinitions.SWkatanaStomach = {
	chance = 1,
	weaponLocation = {"Stomach"},
	bloodLocations = {"Torso_Lower","Back"},
	addHoles = true,
	daySurvived = 30,
	weapons = {
		"SWeapons.ScrapBlade",
		"SWeapons.ScrapSword",
		"SWeapons.SalvagedSpear",
		"SWeapons.ScrapSpear",
	},
}

-- meat cleaver & some others low weapons (Hand Axes..) in the back
AttachedWeaponDefinitions.SWmeatCleaverBackLowQuality = {
	chance = 1,
	weaponLocation = {"MeatCleaver in Back"},
	bloodLocations = {"Back"},
	addHoles = true,
	daySurvived = 20,
	weapons = {
		"SWeapons.TireIronAxe",
		"SWeapons.ScrapMachete",
		"SWeapons.SalvagedPipeWrench",
		"SWeapons.SalvagedClimbingAxe",
	},
}

-- Better weapons in the back
AttachedWeaponDefinitions.SWmeatCleaverBack = {
	chance = 1,
	weaponLocation = {"MeatCleaver in Back"},
	bloodLocations = {"Back"},
	addHoles = true,
	daySurvived = 20,
	weapons = {
		"SWeapons.TireIronAxe",
		"SWeapons.ScrapMachete",
		"SWeapons.SalvagedClimbingAxe",
		
	},
}

-- random knife (low quality weapon) in the back
AttachedWeaponDefinitions.SWknifeLowQualityBack = {
	chance = 1,
	weaponLocation = {"Knife in Back"},
	bloodLocations = {"Back"},
	addHoles = false,
	daySurvived = 0,
	weapons = {
		"SWeapons.ScrapShiv",
		"SWeapons.SharpenedScrewdriver",
	},
}

-- Axe in the back
AttachedWeaponDefinitions.SWaxeBack = {
	chance = 1,
	weaponLocation = {"Axe Back"},
	bloodLocations = {"Back"},
	addHoles = true,
	daySurvived = 10,
	weapons = {
		"SWeapons.BigScrapPickaxe",
		"SWeapons.PipewithScissors",
		"SWeapons.2x4Can",
		"SWeapons.2x4Nail",
		"SWeapons.2x4Scissors",
		"SWeapons.2x4Bolt",
		"SWeapons.2x4SScrewdriver",
		"SWeapons.2x4Screwdriver",
		"SWeapons.ScrapPickaxe",
		"SWeapons.SalvagedClimbingAxe",
	},
}

-- random knife (better quality) in the back
AttachedWeaponDefinitions.SWknifeBack = {
	chance = 1,
	weaponLocation = {"Knife in Back"},
	bloodLocations = {"Back"},
	addHoles = false,
	daySurvived = 10,
	weapons = {
		"SWeapons.ScrapShiv",
		"SWeapons.SharpenedScrewdriver",
		"SWeapons.SalvagedShiv",
		"SWeapons.GlassShiv",
	},
}

-- random knife (low quality weapon) in the left leg
AttachedWeaponDefinitions.SWknifeLowQualityLeftLeg = {
	chance = 1,
	weaponLocation = {"Knife Left Leg"},
	bloodLocations = {"UpperLeg_L"},
	addHoles = false,
	daySurvived = 0,
	weapons = {
		"SWeapons.ScrapShiv",
		"SWeapons.SharpenedScrewdriver",
		"SWeapons.SalvagedShiv",
		"SWeapons.GlassShiv",
	},
}

-- random knife (better quality) in the left leg
AttachedWeaponDefinitions.SWknifeLeftLeg = {
	chance = 1,
	weaponLocation = {"Knife Left Leg"},
	bloodLocations = {"UpperLeg_L"},
	addHoles = false,
	daySurvived = 10,
	weapons = {
		"SWeapons.ScrapShiv",
		"SWeapons.SharpenedScrewdriver",
		"SWeapons.SalvagedShiv",
		"SWeapons.GlassShiv",
	},
}

-- random knife (low quality weapon) in the right leg
AttachedWeaponDefinitions.SWknifeLowQualityLeftLeg = {
	chance = 1,
	weaponLocation = {"Knife Right Leg"},
	bloodLocations = {"UpperRight_L"},
	addHoles = false,
	daySurvived = 0,
	weapons = {
		"SWeapons.ScrapShiv",
		"SWeapons.SharpenedScrewdriver",
		"SWeapons.SalvagedShiv",
		"SWeapons.GlassShiv",
	},
}

-- random knife (better quality) in the right leg
AttachedWeaponDefinitions.SWknifeRightLeg = {
	chance = 1,
	weaponLocation = {"Knife Right Leg"},
	bloodLocations = {"UpperRight_L"},
	addHoles = false,
	daySurvived = 10,
	weapons = {
		"SWeapons.ScrapShiv",
		"SWeapons.SharpenedScrewdriver",
		"SWeapons.SalvagedShiv",
		"SWeapons.GlassShiv",
	},
}

-- random knife (low quality weapon) in the shoulder
AttachedWeaponDefinitions.SWknifeLowQualityShoulder = {
	chance = 1,
	weaponLocation = {"Knife Shoulder"},
	bloodLocations = {"UpperArm_L", "Torso_Upper"},
	addHoles = false,
	daySurvived = 0,
	weapons = {
		"SWeapons.ScrapShiv",
		"SWeapons.SharpenedScrewdriver",
		"SWeapons.SalvagedShiv",
		"SWeapons.GlassShiv",
	},
}

-- random knife (better quality) in the shoulder
AttachedWeaponDefinitions.SWknifeShoulder = {
	chance = 1,
	weaponLocation = {"Knife Shoulder"},
	bloodLocations = {"UpperArm_L", "Torso_Upper"},
	addHoles = false,
	daySurvived = 5,
	weapons = {
		"SWeapons.ScrapShiv",
		"SWeapons.ScrapMachete",
		"SWeapons.SharpenedScrewdriver",
		"SWeapons.SalvagedShiv",
		"SWeapons.GlassShiv",
	},
}

-- Machete in shoulder
AttachedWeaponDefinitions.SWMacheteShoulder = {
	chance = 1,
	weaponLocation = {"Knife Shoulder"},
	bloodLocations = {"UpperArm_L", "Torso_Upper"},
	addHoles = true,
	daySurvived = 20,
	weapons = {
		"SWeapons.SalvagedMachete",
		"SWeapons.ScrapMachete",
		"SWeapons.SalvagedCrowbar",
		"SWeapons.SalvagedClimbingAxe",
	},
}

-- random knife (low quality weapon) in the stomach
AttachedWeaponDefinitions.SWknifeLowQualityStomach = {
	chance = 1,
	weaponLocation = {"Knife Stomach"},
	bloodLocations = {"Torso_Lower"},
	addHoles = false,
	daySurvived = 0,
	weapons = {
		"SWeapons.ScrapShiv",
		"SWeapons.ScrapMachete",
		"SWeapons.SharpenedScrewdriver",
		"SWeapons.SalvagedShiv",
		"SWeapons.GlassShiv",
	},
}

-- random knife (better quality) in the stomach
AttachedWeaponDefinitions.SWknifeStomach = {
	chance = 1,
	weaponLocation = {"Knife Stomach"},
	bloodLocations = {"Torso_Lower", "Back"},
	addHoles = false,
	daySurvived = 10,
	weapons = {
		"SWeapons.ScrapShiv",
		"SWeapons.SharpenedScrewdriver",
		"SWeapons.SalvagedShiv",
		"SWeapons.GlassShiv",
	},
}

-- random weapon in stomach
AttachedWeaponDefinitions.SWweaponInStomach = {
	chance = 1,
	weaponLocation = {"Knife Stomach"},
	bloodLocations = {"Torso_Lower", "Back"},
	addHoles = true,
	daySurvived = 10,
	weapons = {
		"SWeapons.SharpenedStopSign",
		"SWeapons.TinCanClub",
		"SWeapons.BoltBat",
		"SWeapons.WireBat",
		"SWeapons.SalvagedSledgehammer",
		"SWeapons.Micromaul",
		"SWeapons.GearMace",
		"Sweapons.SalvagedPipe",
	},
}
