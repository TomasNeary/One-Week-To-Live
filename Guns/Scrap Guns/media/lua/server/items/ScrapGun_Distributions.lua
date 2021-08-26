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
local ScrapGun_MagBase = {
	"SGuns.AirGunMag", 0.2,
	"SGuns.GrenadeMag", 0.2,
	"SGuns.ScrapGunMag", 0.2,
	"SGuns.SalvagedGunMag", 0.1,
}

-- House Books
local ScrapGun_Maghome = { 
	"SGuns.AirGunMag", 0.2,
	"SGuns.GrenadeMag", 0.2,
	"SGuns.ScrapGunMag", 0.2,
	"SGuns.SalvagedGunMag", 0.1,
}

--Garage
local ScrapGun_Maggarage = { 
	"SGuns.AirGunMag", 0.2,
	"SGuns.GrenadeMag", 0.2,
	"SGuns.ScrapGunMag", 0.2,
	"SGuns.SalvagedGunMag", 0.1,
}

-- TOOLS

local ScrapGun_garage = {
  "SGuns.AirTank",2,
}
local ScrapGun_toolstore1 = {
  "SGuns.AirTank",4,
}
local ScrapGun_toolstore2 = {
  "SGuns.AirTank",4,
}
local ScrapGun_shed = {
  "SGuns.AirTank",2,
}
local ScrapGun_Toolbox = {
  "SGuns.AirGunMag", 0.2,
	"SGuns.GrenadeMag", 0.2,
	"SGuns.ScrapGunMag", 0.2,
	"SGuns.SalvagedGunMag", 0.1,
}
--##################################################################################
-- Base Distribution Table Modifications
--##################################################################################

--MAGS
insertTable(SuburbsDistributions["bookstore"]["other"].items, ScrapGun_MagBase)
insertTable(SuburbsDistributions["gigamart"]["shelvesmag"].items, ScrapGun_MagBase)
insertTable(SuburbsDistributions["all"]["shelves"].items, ScrapGun_Maghome)
insertTable(SuburbsDistributions["all"]["shelvesmag"].items, ScrapGun_Maghome)
insertTable(SuburbsDistributions["all"]["sidetable"].items, ScrapGun_Maghome)
insertTable(SuburbsDistributions["poststorage"]["all"].items, ScrapGun_Maggarage)
insertTable(SuburbsDistributions["cornerstore"]["shelvesmag"].items, ScrapGun_Maggarage)
insertTable(SuburbsDistributions["garage"]["metal_shelves"].items, ScrapGun_Maggarage)
insertTable(SuburbsDistributions["garagestorage"]["other"].items, ScrapGun_Maggarage)
insertTable(SuburbsDistributions["all"]["postbox"].items, ScrapGun_Maggarage)

--TOOLS
insertTable(SuburbsDistributions["garage"]["metal_shelves"].items, ScrapGun_garage)
insertTable(SuburbsDistributions["toolstore"]["shelves"].items, ScrapGun_toolstore1)
insertTable(SuburbsDistributions["toolstore"]["counter"].items, ScrapGun_toolstore2)
insertTable(SuburbsDistributions["shed"]["other"].items, ScrapGun_shed)
insertTable(SuburbsDistributions["Toolbox"].items, ScrapGun_Toolbox)


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

