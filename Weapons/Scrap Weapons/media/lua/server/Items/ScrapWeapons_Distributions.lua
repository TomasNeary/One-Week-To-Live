require 'Items/SuburbsDistributions';

--##################################################################################
-- Code adapted from the excelent Commander's Mods - Hobbies - PZCF_HobbyDistribution.lua
-- @ https://steamcommunity.com/sharedfiles/filedetails/?id=2321449952
--##################################################################################


--##################################################################################
-- Util Functions
--##################################################################################

local function insertTable(t1, t2)
	local n = #t1
	for i=1,#t2 do 
		t1[n+i] = t2[i]
	end
end

local function createProcList(name, minValue, maxValue)
	local procList = {}
	procList["name"] = name
	procList["min"] = minValue
	procList["max"] = maxValue
	return procList
end

local function insertProcList(roomdef, container, list)
	if roomdef ~= nil and container ~= nil then
		if SuburbsDistributions[roomdef] and SuburbsDistributions[roomdef][container] then
			table.insert(SuburbsDistributions[roomdef][container].procList, list)
		else
			print("insertProcList: error generating list for "..roomdef.."-"..container)
		end
	end
end

--##################################################################################
-- Item Reference Tables
--##################################################################################

--Library, Bookstore.
local ScrapWeap_MagBase = {
	"SWeapons.WeaponMag1", 0.2,
	"SWeapons.WeaponMag2", 0.2,
	"SWeapons.WeaponMag3", 0.2,
	"SWeapons.WeaponMag4", 0.05,
	"SWeapons.WeaponMag5", 0.05,
	"SWeapons.WeaponMag6", 0.05,
	"SWeapons.WeaponMag7", 0.3,
	"SWeapons.WeaponMag8", 0.3,
	"SWeapons.WeaponMag9", 0.02,
	"SWeapons.WeaponMag10", 0.2,
}

-- House Books
local ScrapWeap_Maghome = { 
	"SWeapons.WeaponMag1", 0.1,
	"SWeapons.WeaponMag2", 0.1,
	"SWeapons.WeaponMag3", 0.1,
	"SWeapons.WeaponMag4", 0.02,
	"SWeapons.WeaponMag5", 0.02,
	"SWeapons.WeaponMag6", 0.02,
	"SWeapons.WeaponMag7", 0.1,
	"SWeapons.WeaponMag8", 0.1,
	"SWeapons.WeaponMag9", 0.05,
    "SWeapons.WeaponMag10", 0.1,	
}

--Garage
local ScrapWeap_Maggarage = { 
	"SWeapons.WeaponMag1", 0.15,
	"SWeapons.WeaponMag2", 0.15,
	"SWeapons.WeaponMag3", 0.15,
	"SWeapons.WeaponMag4", 0.01,
	"SWeapons.WeaponMag5", 0.01,
	"SWeapons.WeaponMag6", 0.01,
	"SWeapons.WeaponMag7", 0.15,
	"SWeapons.WeaponMag8", 0.15,
	"SWeapons.WeaponMag9", 0.02,
	"SWeapons.WeaponMag10", 0.15,
}

-- TOOLS

local ScrapWeap_garage = {
  "SWeapons.File",2,
	"SWeapons.LargeBolt",5,
	"SWeapons.BoxScrews",2,
	"Base.Screws",10,
}
local ScrapWeap_toolstore1 = {
  "SWeapons.File",4,
	"SWeapons.BoxLargeBolts",4,
	"SWeapons.BoxScrews",10,
}
local ScrapWeap_toolstore2 = {
  "SWeapons.File",4,
	"SWeapons.LargeBolt",7,
	"SWeapons.BoxLargeBolts",2,
	"SWeapons.BoxScrews",4,
}
local ScrapWeap_shed = {
  "SWeapons.File",2,
	"SWeapons.LargeBolt",3,
	"SWeapons.BoxScrews",1,
	"Base.Screws",4,
}
local ScrapWeap_storageunit = {
  "Base.Screws",10,
	"SWeapons.LargeBolt",3,
	"SWeapons.BoxLargeBolts",1,
	"SWeapons.BoxScrews",1,
}
local ScrapWeap_Toolbox = {
  "SWeapons.File",2,
	"SWeapons.LargeBolt",6,
	"SWeapons.BoxScrews",3,
	"Base.Screws",40,
}
--##################################################################################
-- Base Distribution Table Modifications
--##################################################################################

--MAGS
insertTable(SuburbsDistributions["bookstore"]["other"].items, ScrapWeap_MagBase)
insertTable(SuburbsDistributions["gigamart"]["shelvesmag"].items, ScrapWeap_MagBase)
insertTable(SuburbsDistributions["all"]["shelves"].items, ScrapWeap_Maghome)
insertTable(SuburbsDistributions["all"]["shelvesmag"].items, ScrapWeap_Maghome)
insertTable(SuburbsDistributions["all"]["sidetable"].items, ScrapWeap_Maghome)
insertTable(SuburbsDistributions["poststorage"]["all"].items, ScrapWeap_Maggarage)
insertTable(SuburbsDistributions["cornerstore"]["shelvesmag"].items, ScrapWeap_Maggarage)
insertTable(SuburbsDistributions["garage"]["metal_shelves"].items, ScrapWeap_Maggarage)
insertTable(SuburbsDistributions["garagestorage"]["other"].items, ScrapWeap_Maggarage)
insertTable(SuburbsDistributions["all"]["postbox"].items, ScrapWeap_Maggarage)

--TOOLS
insertTable(SuburbsDistributions["garage"]["metal_shelves"].items, ScrapWeap_garage)
insertTable(SuburbsDistributions["toolstore"]["shelves"].items, ScrapWeap_toolstore1)
insertTable(SuburbsDistributions["toolstore"]["counter"].items, ScrapWeap_toolstore2)
insertTable(SuburbsDistributions["shed"]["other"].items, ScrapWeap_shed)
insertTable(SuburbsDistributions["storageunit"]["all"].items, ScrapWeap_storageunit)
insertTable(SuburbsDistributions["Toolbox"].items, ScrapWeap_Toolbox)

--TRASH
table.insert(SuburbsDistributions["all"]["bin"].items, "Base.TinCanEmpty,");
table.insert(SuburbsDistributions["all"]["bin"].items, 5);
table.insert(SuburbsDistributions["all"]["bin"].items, "Base.MetalPipe,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.5);
table.insert(SuburbsDistributions["all"]["bin"].items, "Base.LeadPipe,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.5);
table.insert(SuburbsDistributions["all"]["bin"].items, "Base.MetalBar,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.5);
table.insert(SuburbsDistributions["all"]["bin"].items, "SWeapons.File,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.1);
table.insert(SuburbsDistributions["all"]["bin"].items, "SWeapons.WeaponMag1,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.1);
table.insert(SuburbsDistributions["all"]["bin"].items, "SWeapons.WeaponMag2,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.1);
table.insert(SuburbsDistributions["all"]["bin"].items, "SWeapons.WeaponMag3,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.1);
table.insert(SuburbsDistributions["all"]["bin"].items, "SWeapons.WeaponMag4,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.1);
table.insert(SuburbsDistributions["all"]["bin"].items, "SWeapons.WeaponMag5,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.1);
table.insert(SuburbsDistributions["all"]["bin"].items, "SWeapons.WeaponMag6,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.1);
table.insert(SuburbsDistributions["all"]["bin"].items, "SWeapons.WeaponMag7,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.1);
table.insert(SuburbsDistributions["all"]["bin"].items, "SWeapons.WeaponMag8,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.1);
table.insert(SuburbsDistributions["all"]["bin"].items, "SWeapons.WeaponMag9,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.1);
table.insert(SuburbsDistributions["all"]["bin"].items, "SWeapons.WeaponMag10,");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.1);


--##################################################################################
-- # Print Tables
--##################################################################################

local function printTable(room, container)
	for k, v in pairs (SuburbsDistributions[room][container]["items"]) do
		print("\t", k..": "..v)
	end
end

local function printInnerTabler(room, container)
	for i,d in ipairs(SuburbsDistributions[room][container]["procList"])do
		print(i)
		for k, v in pairs(d) do
			print("\t", k..": "..v)
		end
	end
end

