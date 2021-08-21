CheatCoreCM = CheatCoreCM or {}

local modVehicles = {} -- do not modify

--correct format is: modVehicles["MODID"] = { {"display name (can be anything)", "vehicle ID", "category name (can be anything)"} }
--table key must be the modID defined in the mod's modinfo.txt file, i.e modVehicles["FRUsedCars"] for Filibuster Rhyme's used cars.

--definitions go below here. thank you Oh God Spiders No for the existing definitions

modVehicles["VileM113APC"] = {
	{"M113A1","Base.m113a1", "Vile M113APC"},
}

modVehicles["FRUsedCars"] = {
	{"Roanoke Goat", "Base.65gto", "Filibuster"},
	{"Chevalier El Chimera", "Base.68elcamino", "Filibuster"},
	{"Utana Lynx", "Base.68wildcat", "Filibuster"},
	{"Utana Lynx", "Base.68wildcatconvert", "Filibuster"},
	{"Dash Blitzer", "Base.69charger", "Filibuster"},
	{"Dash Blitzer R/P Edition", "Base.69chargerdaytona", "Filibuster"},
	{"Chevalier Bulette", "Base.70chevelle", "Filibuster"},
	{"Chevalier El Chimera", "Base.70elcamino", "Filibuster"},
	{"Chevalier Nyala", "Base.71impala", "Filibuster"},
	{"Franklin Thundercougar", "Base.73falcon", "Filibuster"},
	{"Franklin Jalapeno", "Base.73pinto", "Filibuster"},
	{"Roanoke Grand Slam", "Base.77transam", "Filibuster"},
	{"Laumet Davis Hogg", "Base.79brougham", "Filibuster"},
	{"Franklin Crest Andarta LTD", "Base.85vicranger", "Filibuster"},
	{"Franklin Crest Andarta LTD", "Base.85vicsed", "Filibuster"},
	{"Franklin Crest Andarta LTD", "Base.85vicsheriff", "Filibuster"},
	{"Franklin Crest Andarta Wagon", "Base.85vicwag", "Filibuster"},
	{"Franklin Crest Andarta Wagon", "Base.85vicwag2", "Filibuster"},
	{"Franklin Trip", "Base.86bounder", "Filibuster"},
	{"Slavski Nogo", "Base.86yugo", "Filibuster"},
	{"Chevalier Kobold", "Base.87blazer", "Filibuster"},
	{"Chevalier D20", "Base.87c10fire", "Filibuster"},
	{"Chevalier D20", "Base.87c10lb", "Filibuster"},
	{"Chevalier D20", "Base.87c10mccoy", "Filibuster"},
	{"Chevalier D20", "Base.87c10sb", "Filibuster"},
	{"Chevalier D20", "Base.87c10utility", "Filibuster"},
	{"Chevalier Carnifex", "Base.87suburban", "Filibuster"},
	{"Dash Buck", "Base.90ramlb", "Filibuster"},
	{"Dash Buck", "Base.90ramsb", "Filibuster"},
	{"Chevalier Kobold", "Base.91blazerpd", "Filibuster"},
	{"Tokai Renaissance", "Base.91crx", "Filibuster"},
	{"Chevalier Cosmo", "Base.astrovan", "Filibuster"},
	{"Franklin EF70 Box Truck", "Base.f700box", "Filibuster"},
	{"Franklin EF70 Dump Truck", "Base.f700dump", "Filibuster"},
	{"Franklin EF70 Flatbed", "Base.f700flatbed", "Filibuster"},
	{"Fire Engine", "Base.firepumper", "Filibuster"},
	{"The General Lee", "Base.generallee", "Filibuster"},
	{"The General Meh", "Base.generalmeh", "Filibuster"},
	{"M1025", "Base.hmmwvht", "Filibuster"},
	{"M1069", "Base.hmmwvtr", "Filibuster"},
	{"Pazuzu N5", "Base.isuzubox", "Filibuster"},
	{"Pazuzu N5", "Base.isuzuboxelec", "Filibuster"},
	{"Pazuzu N5", "Base.isuzuboxfood", "Filibuster"},
	{"Pazuzu N5", "Base.isuzuboxmccoy", "Filibuster"},
	{"M151A2", "Base.m151canvas", "Filibuster"},
	{"M35A2", "Base.m35a2bed", "Filibuster"},
	{"M35A2", "Base.m35a2covered", "Filibuster"},
	{"Move Urself Box Truck", "Base.moveurself", "Filibuster"},
	{"Pursuit Special", "Base.pursuitspecial", "Filibuster"},
	{"Franklin BE70 School Bus", "Base.schoolbus", "Filibuster"},
	{"Franklin BE70 School Bus", "Base.schoolbusshort", "Filibuster"},
	{"Bohag 244", "Base.volvo244", "Filibuster"},
}

modVehicles["FRUsedCarsBETA"] = modVehicles["FRUsedCars"]

modVehicles["ZIL130PACK2"] = {
	{"ZIL-130","Base.zil130", "ZIL-130 #2"},
	{"AC-40(130)","Base.ac40", "ZIL-130 #2"},
	{"ZIL-130 Bread Furgon","Base.zil130bread", "ZIL-130 #2"},
	{"ZIL-130","Base.zil130tent", "ZIL-130 #2"},
	{"ZIL-MMZ-555","Base.zil130mmz555", "ZIL-130 #2"},
	{"ZIL-130 Milk Furgon","Base.zil130milk", "ZIL-130 #2"},
	{"ZIL-130 Furgon","Base.zil130furgon", "ZIL-130 #2"},
	{"ZIL-130G","Base.zil130g", "ZIL-130 #2"},
	{"ZIL-130G","Base.zil130gtent", "ZIL-130 #2"},
	{"ZIL-130 Food Furgon","Base.zil130products", "ZIL-130 #2"},
}


modVehicles["MysteryMachineOGSN"] = {
	{"Mystery Machine","Base.VanMysterymachine", "Mystery Machine"},
}

CheatCoreCM.modVehicles = modVehicles -- do not modify. do not place definitions below this