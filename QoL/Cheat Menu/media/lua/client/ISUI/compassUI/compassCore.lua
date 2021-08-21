require "ISUI/compassUI/compassMain"
require "ISUI/CheatCore"

compassCore = {}
compassCore.categories = {}
compassCore.Wmod = 0.70 -- width/height modifiers, used during main window creation
compassCore.Hmod = 1

function compassCore.makeWindow()
	if compassCore.mainWindow == nil then
		local sw = getCore():getScreenWidth()
		local sh = getCore():getScreenHeight()
		local w = (sw / 3.8) * compassCore.Wmod <= sw and (sw / 3.8) * compassCore.Wmod or sw -- window will not be larger than the display area
		local h = (sh / 1.3) * compassCore.Hmod <= sh and (sh / 1.3) * compassCore.Hmod or sh
		local window = compassUI:new(50,50, w,h) -- original design is scaled on getScreenWidth() / 3.8, old height is 1.3
		window:setVisible(true)
		window:addToUIManager()
		local mt = getmetatable(compassCore.debug)
		compassCore.mainWindow = window
		setmetatable(compassCore.mainWindow, mt)
	else
		compassCore.mainWindow:setVisible(true)
	end
end

function compassCore.removeWindow() -- unnecessary?
	local window = compassCore.mainWindow
	window:setVisible(false)
	window:removeFromUIManager()
end

function compassCore.scale(num,percentage, subt)
	if subt then
		return num - (num * percentage)
	else
		return num + (num * percentage)
	end
end

function compassCore.processJson(update)
	local mapFile = {}
	compassCore.locations = {}
	local mapString = ""
	local strm = update and getUrlInputStream("https://raw.githubusercontent.com/ethanwdp/Mod-Versions/master/PZ%20map%20locations") or getModFileReader("cheatmenu", "teleport_locations/maplocations.txt", true)
	
	while true do
		 local line = strm:readLine()
		 if line == nil then break else
			line = update and line:gsub("%p([%a_]+)%p%:","['%1'] =") or line -- formats JSON style syntax to lua. pattern replaces quotation marks with brackets, and replaces colons with the equals sign.
			mapString = mapString .. line .. "\r\n"
			table.insert(mapFile, line)
			--print(compassCore.mapLocations[#compassCore.mapLocations])
		end	
	end
	
	if update == true then
		local writeFile = getModFileWriter("cheatmenu", "teleport_locations/maplocations.txt", true, false)
		for i = 1,#mapFile do
			local map = mapFile[i]
			writeFile:write(map.."\r\n")
		end
		writeFile:close();
	end


	loadstring("compassCore.mapTbl = " .. mapString)()
	local a = compassCore.mapTbl -- i am lazy
	
	local inc = 0
	
	for i = 1,#a["areas"] do
		inc = inc+1
		local t = a["areas"][i]
		compassCore.locations[t["name"]] = t
		compassCore.locations[t["name"]]["pois"] = t["pois"]
	end
	setmetatable(compassCore.locations, { ["__index"] = {["size"] = inc + 1} })
	
	
	local customs = CheatCoreCM.readFile("cheatmenu", "teleport_locations/customlocations.txt")
	compassCore.locations["Custom"] = {}
	compassCore.locations["Custom"]["pois"] = loadstring("return " .. customs[1] or "{}")()
end

function compassCore:updateCustom()
	local proxy = {}
	local locations = self.locations["Custom"]["pois"]
	
	for i = 1,#locations do -- convert table to string
		local str = "{"
		for k,v in pairs(locations[i]) do
			str = str .. "['" .. k .. "'] = "  .. (type(v) == "string" and "'" .. v  .. "'" or v) .. ";"
		end
		str = str .. ( i == #locations and "}" or "}, ")
		table.insert(proxy, str)
	end
	local str = "{"
	for i = 1,#proxy do
		str = str .. proxy[i]
	end
	str = str .. "}"
	CheatCoreCM.writeFile({str}, "cheatmenu", "teleport_locations/customlocations.txt")
end

function compassCore:addCustom()
	local custom = {["name"] = "Custom Location"; ["x"] = getPlayer():getX(); ["y"] = getPlayer():getY()}
	table.insert(self.locations["Custom"]["pois"], custom)
	self:updateCustom()
end

function compassCore.sort(func)
	for k,v in pairs(compassCore.locations) do
		table.sort(compassCore.locations[k], func) -- sort alphabetically
	end
end


compassCore.processJson()

--Events.OnLoad.Add(compassCore.makeWindow)