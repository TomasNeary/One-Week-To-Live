-- pull the vehicle distributions into a local table
local distributionTable = VehicleDistributions[1]

VehicleDistributions.MilitaryGearTrunk = {
    rolls = 4,
    items ={
        "Bag_ALICEpack_Army", 3,
        "Vest_BulletArmy", 3,
        "556Clip", 3,
        "556Clip", 3,
        "556Clip", 3,
        "556Box", 3,
        "556Box", 3,
        "556Box", 3,
        "556Box", 3,
        "556Box", 3,
        "Hat_Army", 3,
        "Hat_GasMask", 3,
        "Hat_GasMask", 3,
        "Hat_GasMask", 3,
        "AssaultRifle", 2,
        "AssaultRifle", 2,
        "Pistol", 3,
        "Pistol", 3,
        "Pistol", 3,
        "9mmClip", 3,
        "9mmClip", 3,
        "9mmClip", 3,
        "Bullets9mm", 3,
        "Bullets9mm", 3,
        "Bullets9mm", 3,
        "Bullets9mm", 3,
        "Bullets9mm", 3,
		"HolsterSimple", 3,
        "Trousers_CamoGreen", 1,
        "Shirt_CamoGreen", 1,
        "Jacket_ArmyCamoGreen", 1,
        "Hat_BonnieHat_CamoGreen", 1,
        "Hat_PeakedCapArmy", 0.5,
        "Hat_BeretArmy", 0.5,
        "Jacket_CoatArmy", 0.5,
        "Shoes_ArmyBoots", 1,
        "Shirt_CamoGreen", 1,
        "Radio.WalkieTalkie5", 3,
        "HuntingKnife", 3,
        "FirstAidKit", 3,
		"EmptyPetrolCan", 3,
		"PetrolCan", 2,
		"x2Scope", 0.7,
		"x4Scope", 0.5,
		"x8Scope", 0.3,
    }
}

VehicleDistributions.MilitarySeat = {
    rolls = 1,
    items ={
        "556Clip", 3,
        "Hat_Army", 3,
        "Hat_GasMask", 3,
        "Pistol", 3,
        "9mmClip", 3,
		"HolsterSimple", 3,
        "Jacket_ArmyCamoGreen", 3,
        "Hat_BonnieHat_CamoGreen", 3,
        "Hat_PeakedCapArmy", 1,
        "Hat_BeretArmy", 1,
        "Jacket_CoatArmy", 1,
        "Radio.WalkieTalkie5", 3,
        "HuntingKnife", 3,
		"Cigarettes", 7,
        "Bag_ALICEpack_Army", 3,
        "Vest_BulletArmy", 3,
	
    }
}

VehicleDistributions.MadmaxGear = {
    rolls = 1,
    items ={
        "ShotgunShellsBox", 80,
		"DoubleBarrelShotgun", 90,
        "Dogfood", 100,
        "Base.Splint", 100,
    }
}


-- add a new military distributions table
VehicleDistributions.Military = {
    TruckBed = VehicleDistributions.MilitaryGearTrunk;
    TruckbedOpen = VehicleDistributions.MilitaryGearTrunk;

    SeatRearLeft = VehicleDistributions.MilitarySeat;
    SeatRearRight = VehicleDistributions.MilitarySeat;
}

VehicleDistributions.Madmax = {
    SeatRearRight = VehicleDistributions.MadmaxGear;
}


-- now setup the cars. we can just use tables for already existing cars for them:
-- dont use the corvette table for the muscle cars, as it only encludes doctors stuff
-- and things for golfers. CarNormal will give a better selection of stuff for the
-- average joe.
distributionTable["65gto"] = distributionTable["CarNormal"]
distributionTable["69charger"] = distributionTable["CarNormal"]
distributionTable["73falcon"] = distributionTable["CarNormal"]
distributionTable["77transam"] = distributionTable["CarNormal"]
distributionTable["85vicsed"] = distributionTable["CarNormal"]
distributionTable["70chevelle"] = distributionTable["CarNormal"]
distributionTable["volvo244"] = distributionTable["CarNormal"]
distributionTable["71impala"] = distributionTable["CarNormal"]
distributionTable["68wildcat"] = distributionTable["CarNormal"]
distributionTable["68wildcatconvert"] = distributionTable["CarNormal"]
distributionTable["79brougham"] = distributionTable["CarNormal"]

-- New cars
distributionTable["72beetle"] = distributionTable["CarNormal"]
distributionTable["87caprice"] = distributionTable["CarNormal"]
distributionTable["90corolla"] = distributionTable["CarNormal"]
distributionTable["91celica"] = distributionTable["CarNormal"]
distributionTable["92crownvic"] = distributionTable["CarNormal"]

distributionTable["79datsun280z"] = distributionTable["SportsCar"]


distributionTable["85vicwag"] = distributionTable["CarStationWagon"]
distributionTable["85vicwag2"] = distributionTable["CarStationWagon"]
distributionTable["68elcamino"] = distributionTable["CarStationWagon"]
distributionTable["70elcamino"] = distributionTable["CarStationWagon"]

distributionTable["86yugo"] = distributionTable["SmallCar"]
distributionTable["91crx"] = distributionTable["SmallCar"]
distributionTable["73pinto"] = distributionTable["SmallCar"]

-- Emergency Vehicles
distributionTable["85vicranger"] = distributionTable["PickUpVanLights0"]
distributionTable["85vicsheriff"] = distributionTable["PickUpVanLightsPolice"]
distributionTable["91blazerpd"] = distributionTable["PickUpVanLightsPolice"]
distributionTable["87c10fire"] = distributionTable["PickUpTruckLightsFire"]
distributionTable["firepumper"] = distributionTable["PickUpTruckLightsFire"]
distributionTable["92wranglerranger"] = distributionTable["PickUpVanLights0"]

-- New Emergency
distributionTable["80f350ambulance"] = distributionTable["VanAmbulance"]
distributionTable["86econolineambulance"] = distributionTable["VanAmbulance"]
distributionTable["87capricePD"] = distributionTable["PickUpVanLightsPolice"]
distributionTable["92crownvicPD"] = distributionTable["PickUpVanLightsPolice"]
distributionTable["chevystepvanswat"] = distributionTable["PickUpVanLightsPolice"]


-- McCoy
distributionTable["87c10mccoy"] = distributionTable["StepVan"]
distributionTable["isuzuboxmccoy"] = distributionTable["PickUpVanMccoy"]



-- Pickup Trucks
distributionTable["87blazer"] = distributionTable["PickUpTruck"]
distributionTable["87c10sb"] = distributionTable["PickUpTruck"]
distributionTable["87c10lb"] = distributionTable["PickUpTruck"]
distributionTable["90ramsb"] = distributionTable["PickUpTruck"]
distributionTable["90ramlb"] = distributionTable["PickUpTruck"]
distributionTable["68elcamino"] = distributionTable["PickUpTruck"]
distributionTable["70elcamino"] = distributionTable["PickUpTruck"]
distributionTable["87c10utility"] = distributionTable["StepVan"]

-- New Pickups
distributionTable["51chevy3100"] = distributionTable["CarNormal"]
distributionTable["51chevy3100old"] = distributionTable["OffRoad"]
distributionTable["80f350"] = distributionTable["PickUpTruck"]
distributionTable["80f350offroad"] = distributionTable["OffRoad"]
distributionTable["80f350quad"] = distributionTable["PickUpTruck"]
distributionTable["83hilux"] = distributionTable["PickUpTruck"]
distributionTable["83hiluxoffroad"] = distributionTable["OffRoad"]
distributionTable["87c10offroadlb"] = distributionTable["OffRoad"]
distributionTable["87c10offroadsb"] = distributionTable["OffRoad"]
distributionTable["87blazeroffroad"] = distributionTable["OffRoad"]
distributionTable["90ramoffroadlb"] = distributionTable["OffRoad"]
distributionTable["90ramoffroadsb"] = distributionTable["OffRoad"]
distributionTable["92wrangler"] = distributionTable["OffRoad"]
distributionTable["92wrangleroffroad"] = distributionTable["OffRoad"]
distributionTable["92wranglerjurassic"] = distributionTable["PickUpTruck"]

-- SUV
distributionTable["87suburban"] = distributionTable["SUV"]

-- New SUVs
distributionTable["91wagoneer"] = distributionTable["SUV"]
distributionTable["93explorer"] = distributionTable["SUV"]
distributionTable["93explorerjurassic"] = distributionTable["SUV"]

-- Vans
distributionTable["astrovan"] = distributionTable["Van"]

-- New vans
distributionTable["86econoline"] = distributionTable["Van"]

-- RVs and Campers
distributionTable["86bounder"] = { Normal = VehicleDistributions.Groceries; }
distributionTable["86econolinerv"] = { Normal = VehicleDistributions.Groceries; }


-- Box trucks
distributionTable["moveurself"] = distributionTable["Van"]
distributionTable["isuzubox"] = distributionTable["StepVan"]
distributionTable["f700box"] = distributionTable["StepVan"]
distributionTable["isuzuboxfood"] = { Normal = VehicleDistributions.Groceries; }

-- New box truck
distributionTable["chevystepvan"] = distributionTable["StepVan"]


VehicleDistributions.SideBox = {
	TruckBed = VehicleDistributions.TrunkHeavy;
	
	TruckBedOpen = VehicleDistributions.TrunkHeavy;
	
	GloveBox = VehicleDistributions.GloveBox;
	
	SeatRearLeft = VehicleDistributions.Seat;
	SeatRearRight = VehicleDistributions.Seat;
}

-- Side boxes like construction or fuel trucks
distributionTable["f700propane"] = { Normal = VehicleDistributions.SideBox; }
distributionTable["m35a2fuel"] = { Normal = VehicleDistributions.SideBox; }
distributionTable["tractorford7810"] = { Normal = VehicleDistributions.SideBox; }


VehicleDistributions.NormalElectrician = {
	TruckBed = VehicleDistributions.ElectricianTruckBed;
	
	TruckBedOpen = VehicleDistributions.ElectricianTruckBed;
	
	GloveBox = VehicleDistributions.GloveBox;
	
	SeatRearLeft = VehicleDistributions.Seat;
	SeatRearRight = VehicleDistributions.Seat;
}

distributionTable["isuzuboxelec"] = { Normal = VehicleDistributions.NormalElectrician; }


distributionTable["pursuitspecial"] = { Normal = VehicleDistributions.Madmax; }

--Trailers
distributionTable["Trailermovingbig"] = distributionTable["Van"]
distributionTable["Trailermovingmedium"] = distributionTable["Van"]
distributionTable["Trailer51chevy"] = distributionTable["PickUpTruck"]


-- use the custom military loot table for the hmmwv's
distributionTable["hmmwvht"] = { Normal = VehicleDistributions.Military; }
distributionTable["hmmwvtr"] = { Normal = VehicleDistributions.Military; }
distributionTable["m35a2bed"] = { Normal = VehicleDistributions.Military; }
distributionTable["m35a2covered"] = { Normal = VehicleDistributions.Military; }
distributionTable["m151canvas"] = { Normal = VehicleDistributions.Military; }

