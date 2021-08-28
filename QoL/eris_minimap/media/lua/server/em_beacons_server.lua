----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_beacons_server
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

if not isServer() then return; end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading EM_BEACONS_SERVER  ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_beacons_server = {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_beacons_server.OnDismantle = function(_items, _result, _player, _selectedItem)
	if _result then
		local success = 50 + (_player:getPerkLevel(Perks.Electricity)*5);
		for i=1,ZombRand(1,4) do
			local r = ZombRand(1,4);
			if r==1 then
				_player:getInventory():AddItem("Base.ElectronicsScrap");
			elseif r==2 then
				_player:getInventory():AddItem("Radio.ElectricWire");
			elseif r==3 then
				_player:getInventory():AddItem("Base.Aluminum");
			end;
		end;
		if ZombRand(0,100)< success then
			_player:getInventory():AddItem("Base.Amplifier");
		end;
		if ZombRand(0,100)< success then
			_player:getInventory():AddItem("Base.LightBulb");
		end;
		if ZombRand(0,100)< success then
			_player:getInventory():AddItem("Radio.RadioReceiver");
		end;
		em_personal_beacon.removeBattery(_player, _result);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_beacons_server.OnCreate = function(_items, _result, _player, _selectedItem)
	if _result then
		em_personal_beacon.initialiseItem(_result);
	end
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_beacons_server.OnGiveXP = function(_recipe, _ingredients, _result, _player)
	_player:getXp():AddXP(Perks.Electricity, _player:getPerkLevel(Perks.Electricity)*5);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

Events.OnClientCommand.Add(em_beacons_server.onClientCommand);

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
