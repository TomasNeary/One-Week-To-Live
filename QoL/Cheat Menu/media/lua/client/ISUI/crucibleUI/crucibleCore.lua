crucibleCore = {}

crucibleCore.categories = {
	"All",
	"Normal",
	"Weapon",
	"Food",
	"Literature",
	"Drainable",
	"Clothing",
	"Container",
	"WeaponPart",
	"Key",
	--"KeyRing",
	--"Moveable",
	"Radio",
	"AlarmClock"
}
crucibleCore.Wmod = 1 -- width/height modifiers, used during main window creation
crucibleCore.Hmod = 1

crucibleCore.amount = crucibleCore.amount or 1

function crucibleCore.scale(num,percentage, subt)
	if subt then
		return num - (num * percentage)
	else
		return num + (num * percentage)
	end
end

function crucibleCore.getItems()
	crucibleCore.items = {}
	for i = 1,#crucibleCore.categories do
		crucibleCore.items[crucibleCore.categories[i]] = {}
	end
	--crucibleCore.items["All"] = {}
	local items = getAllItems()
	local sz = items:size()
	for i = sz-1,0,-1 do
		local item = items:get(i)
		local invItem = instanceItem(item)
		
		if crucibleCore.items[item:getTypeString()] ~= nil and item:getDisplayName() ~= "Blooo" then
		
			table.insert(crucibleCore.items[item:getTypeString()], item)
			table.insert(crucibleCore.items["All"], item)
			
			if invItem then
				if invItem:getDisplayCategory() then
					crucibleCore.items[invItem:getDisplayCategory()] = crucibleCore.items[invItem:getDisplayCategory()] or {}
					table.insert(crucibleCore.items[invItem:getDisplayCategory()], item)
				end
			end
			
		end
	end
	
	crucibleCore.sort(function (a, b) return string.lower(a:getDisplayName()) < string.lower(b:getDisplayName()) end)
end

function crucibleCore.sort(func)
	for k,v in pairs(crucibleCore.items) do
		table.sort(crucibleCore.items[k], func) -- sort alphabetically
	end
end

function crucibleCore.resolveTexture(item,invItem)
	local tex = getTexture("Item_" .. item:getIcon()) or getTexture("media/textures/Item_" .. item:getIcon() .. ".png")
	if invItem ~= nil and tonumber(string.match(getCore():getVersionNumber(), "%d+")) >= 41 then
		if invItem:getIconsForTexture() then
			local txs = invItem:getIconsForTexture()
			tex = getTexture("media/textures/Item_" .. txs:get(1) .. ".png") or getTexture("Item_" .. txs:get(1))
		end
	end
	return tex or getTexture("media/inventory/Question_On.png")
end

--Events.OnLoad.Add(crucibleCore.makeWindow)