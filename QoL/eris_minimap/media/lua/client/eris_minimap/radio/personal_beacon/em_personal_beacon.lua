----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_personal_beacon
--
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading EM_PERSONAL_BEACON ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_personal_beacon = {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_personal_beacon.transponders = {
	makeshift_transponder = {
		name = "Crafted GPS Transponder",
		scanner = false,
		scannerEnabled = false,
		maxBattery = 300000,
		battery = 300000,
		channel = 100000,
		range = 20000,
	},
	mastercrafted_transponder = {
		name = "Master Crafted GPS Transponder",
		scanner = true,
		scannerEnabled = false,
		maxBattery = 400000,
		battery = 400000,
		channel = 100000,
		range = 25000,
	},
	personal_transponder = {
		name = "PubTech GPS Transponder",
		scanner = false,
		scannerEnabled = false,
		maxBattery = 200000,
		battery = 200000,
		channel = 100000,
		range = 20000,
	},
	premium_transponder = {
		name = "ETech GPS Transponder",
		scanner = true,
		scannerEnabled = false,
		maxBattery = 500000,
		battery = 500000,
		channel = 100000,
		range = 30000,
	},
};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_personal_beacon.toggleScanner = function(_enabled, _item)
	_item:getModData()["scannerEnabled"] = _enabled;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_personal_beacon.viewDevice = function(_plObj, _item)
	if em_core.personal_beacon_infoBox then em_core.personal_beacon_infoBox:close(); end;
	em_core.personal_beacon_infoBox = em_personal_beacon_infoBox:new(_item, getMouseX(), getMouseY());
	em_core.personal_beacon_infoBox:initialise();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_personal_beacon.doItemName = function(_item)
	if not _item:getModData()["initialised"] then
		em_personal_beacon.initialiseItem(_item);
	end;
	_item:setName(_item:getModData()["name"] .." ["..(_item:getModData()["channel"] / 1000).."MHz]");
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_personal_beacon.insertBattery = function(_plObj, _item, _battery)
	_item:getModData()["battery"] = (_battery:getUsedDelta() * _item:getModData()["maxBattery"]);
	_item:setUsedDelta(_item:getModData()["battery"] / _item:getModData()["maxBattery"]);
	_plObj:getInventory():DoRemoveItem(_battery);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_personal_beacon.removeBattery = function(_plObj, _item)
	local battery = InventoryItemFactory.CreateItem("Base.Battery");
	battery:setUsedDelta(_item:getModData()["battery"] / _item:getModData()["maxBattery"]);
	_item:getModData()["battery"] = 0;
	_item:setUsedDelta(0);
	_plObj:getInventory():AddItem(battery);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_personal_beacon.createBatteryInsertMenu = function(_plObj, _item, _context)
	local playerBatteryList = _plObj:getInventory():getItemsFromType("Battery");
	if not playerBatteryList:isEmpty() then
		local addedSubmenu = false;
		local contextAdd = _context:addOption(em_translationData.label_insert_battery, item);
		local subcontextAdd = _context:getNew(_context);
		_context:addSubMenu(contextAdd, subcontextAdd);
		for i = 0, playerBatteryList:size() - 1 do
			local battery = playerBatteryList:get(i);
			if battery:getUsedDelta() > 0 then
				local batteryStr = " (" .. math.floor(battery:getUsedDelta() * 100).. "%)";
				subcontextAdd:addOption(battery:getName() .. batteryStr, _plObj, em_personal_beacon.insertBattery, _item, battery);
				addedSubmenu = true;
			end;
		end;
		if not addedSubmenu then _context:removeLastOption(); end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_personal_beacon.initialiseItem = function(_item)
	if em_personal_beacon.transponders[_item:getType()] then
		if not _item:getModData()["initialised"] then
			for key, value in pairs(em_personal_beacon.transponders[_item:getType()]) do
				_item:getModData()[key] = value;
			end;
			_item:getModData()["initialised"] = true;
		end;
		em_personal_beacon.doItemName(_item);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_personal_beacon.createMenu = function(_plID, _context, _items)
	local plObj = getPlayer(_plID);
	for i, items in ipairs(_items) do
		local item = nil;
		if not instanceof(items, "InventoryItem") then item = items.items[1]; else item = items; end;
		if item:getContainer() == plObj:getInventory() and item:getModule() == "em_beacon" then
			if not item:getModData()["initialised"] then
				em_personal_beacon.initialiseItem(item);
			end;
			if item:getModData()["battery"] > 0 then
				local contextRemoveBattery = _context:addOption(em_translationData.label_remove_battery .. " (" .. math.floor((item:getModData()["battery"] / item:getModData()["maxBattery"]) * 10000) / 100 .. "%)", plObj, em_personal_beacon.removeBattery, item);
			else
				em_personal_beacon.createBatteryInsertMenu(plObj, item, _context);
			end;
			if item:getModData()["scanner"] then
				if item:getModData()["scannerEnabled"] then
					local contextToggleScanner = _context:addOption(em_translationData.label_disable_scanner, false, em_personal_beacon.toggleScanner, item);
				else
					local contextToggleScanner = _context:addOption(em_translationData.label_enable_scanner, true, em_personal_beacon.toggleScanner, item);
				end;
			end;
			local contextEditBeacon = _context:addOption(em_translationData.label_view_device, plObj, em_personal_beacon.viewDevice, item);
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function init()
	Events.OnFillInventoryObjectContextMenu.Add(em_personal_beacon.createMenu);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.OnGameStart.Add(init);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------