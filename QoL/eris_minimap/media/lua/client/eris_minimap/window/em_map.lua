----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- em_map
--
-- PZ map version: v40_43
--
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

print("[ Loading EM_MAP ]");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_map = em_map or {communitymap_areas = {}};
em_map.communitymap_areas = em_map.communitymap_areas or {};
em_map.custom_areas = em_map.custom_areas or {};
em_map.vanilla_areas = em_map.vanilla_areas or {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local small, medium, large = UIFont.NewSmall, UIFont.NewMedium, UIFont.NewLarge;

em_map.vanilla_areas["Knox County"]				= {font = large,	x1 = 9450,	y1 = 9450,	x2 = 9450,	y2 = 9450,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Dixie"]					= {font = medium,	x1 = 11430,	y1 = 8770,	x2 = 11890,	y2 = 8980,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["March Ridge"]				= {font = medium,	x1 = 9760,	y1 = 12560,	x2 = 10530,	y2 = 13310,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Muldraugh"]				= {font = medium,	x1 = 10580,	y1 = 8770,	x2 = 11120,	y2 = 10700,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Riverside"]				= {font = medium,	x1 = 6210,	y1 = 5360,	x2 = 6210,	y2 = 5360,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Rural Town"]				= {font = medium,	x1 = 7070,	y1 = 8150,	x2 = 7540,	y2 = 8580,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Rosewood"]				= {font = medium,	x1 = 8200,	y1 = 11510,	x2 = 8200,	y2 = 11510,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Valley Station"]			= {font = medium,	x1 = 12150,	y1 = 4500,	x2 = 15010,	y2 = 6710,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["West Point"]				= {font = medium,	x1 = 9900,	y1 = 6570,	x2 = 12250,	y2 = 7470,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Scenic Grove"]			= {font = small,	x1 = 5400,	y1 = 6020,	x2 = 5470,	y2 = 6020,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Rosewood Prison"]			= {font = small,	x1 = 7580,	y1 = 11760,	x2 = 7850,	y2 = 11990,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Crossroads Mall"]			= {font = small,	x1 = 13520,	y1 = 5640,	x2 = 14060,	y2 = 6000,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Country Club"]			= {font = small,	x1 = 5640,	y1 = 6000,	x2 = 6370,	y2 = 6770,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["East Campgrounds"]		= {font = small,	x1 = 12330,	y1 = 8850,	x2 = 12330,	y2 = 8850,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["West Campgrounds"]		= {font = small,	x1 = 4560,	y1 = 7800,	x2 = 4560,	y2 = 7800,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["West Hunting Lodge"]		= {font = small,	x1 = 4570,	y1 = 8560,	x2 = 4560,	y2 = 8560,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["West Highway Stop"]		= {font = small,	x1 = 3740,	y1 = 8570,	x2 = 3740,	y2 = 8570,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["South Highway Stop"]		= {font = small,	x1 = 10080,	y1 = 10960,	x2 = 10080,	y2 = 10960,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Northwest Highway Stop"]	= {font = small,	x1 = 3660,	y1 = 5870,	x2 = 3660,	y2 = 5870,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Rural Highway Stop"]		= {font = small,	x1 = 5490,	y1 = 9640,	x2 = 5490,	y2 = 9640,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["North Highway Stop"]		= {font = small,	x1 = 11610,	y1 = 8350,	x2 = 11610,	y2 = 8350,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["McCoy Logging Co."]		= {font = small,	x1 = 10260,	y1 = 9240,	x2 = 10390,	y2 = 9460,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["McCoy Lumber Mill"]		= {font = small,	x1 = 10270,	y1 = 9500,	x2 = 10390,	y2 = 9720,	r = 0, g = 0, b = 0, a = 0};
em_map.vanilla_areas["Muldraugh Railyard"]		= {font = small,	x1 = 11490,	y1 = 9590,	x2 = 11940,	y2 = 10250,	r = 0, g = 0, b = 0, a = 0};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

em_mapTiles = em_mapTiles or {};
em_mapTiles_invalid = em_mapTiles_invalid or {};

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- local callback_chain_load_community_minimapTile;

-- if em_map.callback_chain_load_community_minimapTile ~= nil then
	-- callback_chain_load_community_minimapTile = em_map.callback_chain_load_community_minimapTile;
-- end

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------

-- function em_map:callback_chain_load_community_minimapTile(_index)
	-- self.mapTiles[_index] = getTexture("media/textures/mapTiles/cell_" .. _index .. ".png");
	-- if not self.mapTiles[_index] and callback_chain_load_community_minimapTile ~= nil then
		-- callback_chain_load_community_minimapTile(self, _index);
	-- end;
-- end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------load_minimapTile

function em_map:load_minimapTile(_index)
	if self.communityMaps then
		self:callback_chain_load_community_minimapTile(_index);
	end;
	if not self.mapTiles[_index] then
		self.mapTiles[_index] = getTexture("media/textures/mapTiles/cell_" .. _index .. ".png");
	end;
	if not self.mapTiles[_index] then
		self.mapTiles_invalid[_index] = true;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------storeMapTiles

function em_map:storeMapTiles()
	em_mapTiles, em_mapTiles_invalid = self.mapTiles, self.mapTiles_invalid;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------loadMapTiles

function em_map:loadMapTiles()
	self.mapTiles, self.mapTiles_invalid = em_mapTiles, em_mapTiles_invalid;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------queue_loadTile

function em_map:queue_loadTile(_index)
	table.insert(self.tileQueue, _index);
	self.tileQueueIndex[_index] = true;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------process_queuedTiles

function em_map:process_queuedTiles()
	local loadTile = em_map.load_minimapTile;
	for i = 1, math.min(em_settings.rate_settings.tile_loadingRate.value, #self.tileQueue) do
		loadTile(self, table.remove(self.tileQueue));
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------initGrid

--see affine.lua with credit to Minh Ngo
--https://github.com/markandgo/simple-transform/

function em_map:initGrid()
	local grid = {};
	local mt;
	local __call = function(self,x,y)
		return 	self[1][1]*x + self[1][2]*y + self[1][3],
				self[2][1]*x + self[2][2]*y + self[2][3]
	end;
	local __mul = function(a,b)
		local t = setmetatable({},mt);
		for i = 1,3 do
			t[i] = {};
			for j = 1,3 do
				t[i][j] = a[i][1]*b[1][j] + a[i][2]*b[2][j] + a[i][3]*b[3][j];
			end;
		end;
		return t;
	end;
	mt = {__call = __call, __mul = __mul};
	grid.trans = function(dx,dy)
		local t = setmetatable({},mt)
		t[1] = { 1, 0, dx};
		t[2] = { 0, 1, dy};
		t[3] = { 0, 0, 1};
		return t;
	end;
	grid.rotate = function(theta)
		local t = setmetatable({},mt)
		t[1] = {math.cos(theta),-math.sin(theta), 0};
		t[2] = {math.sin(theta), math.cos(theta), 0};
		t[3] = {0, 0, 1};
		return t;
	end;
	grid.scale = function(sx,sy)
		local t = setmetatable({},mt)
		t[1] = { sx, 0, 0};
		t[2] = { 0, sy, 0};
		t[3] = { 0, 0, 1};
		return t;
	end;
	grid.shear = function(kx,ky)
		local t = setmetatable({},mt)
		t[1] = { 1, kx, 0};
		t[2] = { ky, 1, 0};
		t[3] = { 0, 0, 1};
		return t;
	end;
	grid.inverse = function(u)
		local t = setmetatable({},mt);
		local a = u[1][1];
		local b = u[1][2];
		local c = u[2][1];
		local d = u[2][2];
		local det = a*d - b*c;
		assert(det ~= 0, 'transformation is not invertible!');
		local f1 = ( d * u[1][3] + (-b) * u[2][3])/det;
		local f2 = (-c * u[1][3] +   a  * u[2][3])/det;
		t[1] = { d/det, -b/det, -f1};
		t[2] = {-c/det,  a/det, -f2};
		t[3] = { 0, 0, 1};
		return t;
	end;
	grid.polar = function(x,y)
		local r     = (x^2 + y^2)^0.5;
		local theta = math.atan2(y,x);
		return r,theta;
	end;
	grid.cart = function(r,theta)
		return r*math.cos(theta),r*math.sin(theta);
	end;
	self.gridObj = grid;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateBounds

function em_map:updateBounds()
	local transform = self.transforms.imapTransform;
	local window = em_core.window;
	local vpb = self.vpBounds;
	local x1, y1 = window:getX(), window:getY();
	local x2, y2 = x1 + window:getWidth(), y1;
	local x3, y3 = x1, y1 + window:getHeight();
	local x4, y4 = x1 + window:getWidth(), y1 + window:getHeight();
	x1, y1 = transform(x1, y1);
	x2, y2 = transform(x2, y2);
	x3, y3 = transform(x3, y3);
	x4, y4 = transform(x4, y4);
	vpb.x1, vpb.y1 = self:getCoordsInsideWorld(math.floor(math.min(x1, x2, x3, x4)+self.vpCenterXInWorld), math.floor(math.min(y1, y2, y3, y4)+self.vpCenterYInWorld));
	vpb.x2, vpb.y2 = self:getCoordsInsideWorld(math.floor(math.max(x1, x2, x3, x4)+self.vpCenterXInWorld), math.floor(math.max(y1, y2, y3, y4)+self.vpCenterYInWorld));
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------setVPCenter

function em_map:setVPCenter(_vpX, _vpY)
	if self.vpCenterXInWorld ~= _vpX or self.vpCenterYInWorld ~= _vpY then
		self.vpCenterXInWorld = _vpX;
		self.vpCenterYInWorld = _vpY;
		self.cellX, self.cellY = math.floor(_vpX / 300), math.floor(_vpY / 300);
		self.cellRX, self.cellRY = (_vpX / 300) % 1, (_vpY / 300) % 1;
		self.cellOffsetX, self.cellOffsetY = (-300 * self.cellRX), (-300 * self.cellRY);
		self:updateBounds();
		em_settings.map_settings.vpCenterXInWorld = self.vpCenterXInWorld;
		em_settings.map_settings.vpCenterYInWorld = self.vpCenterYInWorld;
		em_settings:save();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------rotateXY

function em_map:rotateXY(_xVal, _yVal, _xOrigin, _yOrigin, _rads)
	local xVal, yVal = _xVal - _xOrigin, _yVal - _yOrigin;
	local xResult = (xVal) * math.cos(_rads) - (yVal) * math.sin(_rads);
	local yResult = (xVal) * math.sin(_rads) + (yVal) * math.cos(_rads);
	return xResult + _xOrigin, yResult + _yOrigin;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------zoomMap

function em_map:zoomMap(_mod)
	local map_settings = em_settings.map_settings;
	local zoomLevel, minZoom, maxZoom = map_settings.zoomLevel, 0.1, 7;
	local zoomStep = math.floor((zoomLevel + (_mod * 0.1)) * 100 + 0.5) / 100;
	local vpX, vpY = self.vpCenterXInWorld, self.vpCenterYInWorld;
	local mX, mY = self.mX, self.mY;
	map_settings.zoomLevel = zoomStep < minZoom and minZoom or zoomStep > maxZoom and maxZoom or zoomStep;
	em_settings:save();
	if em_settings.map_settings.zoomLevel < 0.8 then self:updateGridLines(); else self.gridLines = {}; end;
	self:update();
	if em_settings.context_settings.mapZoomFollowMouse.enabled then
		self:setVPCenter(self.vpCenterXInWorld + (mX - self.mX), self.vpCenterYInWorld + (mY - self.mY));
		self.target_xOffset, self.target_yOffset = self.vpCenterXInWorld, self.vpCenterYInWorld;
		self:update();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------getCoordsInsideWorld

function em_map:getCoordsInsideWorld(_x, _y)
	local minX, minY = self.worldMinX * 300, self.worldMinY * 300;
	local maxX, maxY = (self.worldMaxX + 1) * 300, (self.worldMaxY + 1) * 300;
	local x, y = _x, _y;
	if x < minX then x = minX + 1; end; if x > maxX then x = maxX - 1; end;
	if y < minY then y = minY + 1; end; if y > maxY then y = maxY - 1; end;
	return x, y;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateCoordinates

function em_map:updateCoordinates()
	if em_core.window.minimap.mouseOver and not em_core.window.minimap.dragging then
		self.mX, self.mY = self.transforms.imapTransform(getMouseX(), getMouseY());
		self.mX, self.mY = self:getCoordsInsideWorld(math.floor(self.mX+self.vpCenterXInWorld), math.floor(self.mY+self.vpCenterYInWorld));
	else
		self.mX, self.mY = math.floor(self.vpCenterXInWorld), math.floor(self.vpCenterYInWorld);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------doMapTint

function em_map:doMapTint()
	local mapTint = em_settings.color_settings.mapTint;
	local gtObj = GameTime:getInstance();
	local night = gtObj:getNight();
	local ambient = gtObj:getAmbient();
	mapTint.color.r = 0.75 + (ambient / 4) - (night / 4);
	mapTint.color.g = 0.75 + (ambient / 4) - (night / 4);
	mapTint.color.b = 0.75 + (night / 4);
	self.mapTint.r, self.mapTint.g, self.mapTint.b = mapTint.color.r, mapTint.color.g, mapTint.color.b;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------undoMapTint

function em_map:undoMapTint()
	self.mapTint.r, self.mapTint.g, self.mapTint.b = 1, 1, 1;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------doAnimateMoveStep

function em_map:doAnimateMoveStep()
	local vpX, vpY = self.vpCenterXInWorld, self.vpCenterYInWorld;
	local toMoveX = self.target_xOffset - vpX;
	local toMoveY = self.target_yOffset - vpY;
	if toMoveX ~= 0 or toMoveY ~= 0 then
		local moveX = toMoveX * em_settings.rate_settings.map_flickRate.value;
		local moveY = toMoveY * em_settings.rate_settings.map_flickRate.value;
		if moveX > -1 and moveX < 1 then moveX = toMoveX; end;
		if moveY > -1 and moveY < 1 then moveY = toMoveY; end;
		vpX, vpY = vpX + moveX, vpY + moveY;
		self:setVPCenter(vpX, vpY);
		em_core.mapIconMetaGroup:update();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------dragMap

function em_map:dragMap(_x, _y, _forceUnlock, _canUnlock)
	local zoomLevel = em_settings.map_settings.zoomLevel;
	local doDrag = false;
	if em_core.minimap:getFollowIcon() then
		if _canUnlock then
			if em_settings.context_settings.unlockOnDrag.enabled or _forceUnlock then
				if _x > 80 / zoomLevel or _y > 80 / zoomLevel or _forceUnlock then
					em_core.minimap:clearFollowIcon();
					doDrag = true;
				end;
			end;
		end;
	else
		doDrag = true;
	end;
	if doDrag then
		local vpX, vpY = self.vpCenterXInWorld, self.vpCenterYInWorld;
		local rotationXY = math.rad(-em_settings.map_settings.rotationXY);
		local xOffset, yOffset = self:rotateXY(0.5 * (_x / zoomLevel), 0.5 * (_y / zoomLevel), 0, 0, rotationXY);
		local targetX, targetY = (self.target_xOffset - xOffset), (self.target_yOffset - yOffset);
		self.target_xOffset, self.target_yOffset = self:getCoordsInsideWorld(targetX, targetY);
		if math.max(math.abs(self.target_xOffset - vpX), math.abs(self.target_yOffset - vpY)) > 300 then em_core.update(); end;
	end;
	self:quickupdate();
	em_core.mapIconMetaGroup:update();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateMapOffset

function em_map:updateMapOffset()
	local icon = em_core.minimap:getFollowIcon();
	if icon then
		self:setVPCenter(icon.x, icon.y);
		self.target_xOffset, self.target_yOffset = self.vpCenterXInWorld, self.vpCenterYInWorld;
	else
		self:doAnimateMoveStep();
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateGridLines

function em_map:updateGridLines()
	self.gridLines = {};
	if em_settings.map_settings.zoomLevel < 0.8 and em_settings.context_settings.gridToggle.enabled then
		local x, y, x1, y1, x2, y2 = 0, 0, 0, 0;
		local gridSize = 1500;
		local mapTransform = self.transforms.mapTransform;
		local drawTexture = em_core.window.minimap.drawTextureAllPoint;
		local zX, zY = self.vpCenterXInWorld % gridSize, self.vpCenterYInWorld % gridSize;
		local xx, yy = 1, 1;
		for i = 1, 50 do
			x, y = (i * gridSize) - zX - 21000, zY - 21000;
			x1, y1 = mapTransform(x, y);
			x2, y2 = mapTransform(x, 60000 + y);
			self.gridLines[i.."1"] = {
				x1 =x1, y1 =y1,
				x2 =x2, y2 =y2,
				x3 =x2 + 1, y3 =y2 + 1,
				x4 =x1 + 1, y4 =y1 + 1,
			};
			x, y = zX - 21000, (i * gridSize) - zY - 21000;
			x1, y1 = mapTransform(x, y);
			x2, y2 = mapTransform(60000 + x, y);
			self.gridLines[i.."2"] = {
				x1 =x1, y1 =y1,
				x2 =x2, y2 =y2,
				x3 =x2 + 1, y3 =y2 + 1,
				x4 =x1 + 1, y4 =y1 + 1,
			};
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateWindowData

function em_map:updateWindowData()
	self.cellSize = 300 * em_settings.map_settings.zoomLevel;
	self.maxDim = math.max(em_core.window.minimap:getWidth(), em_core.window.minimap:getHeight());
	if em_settings.map_settings.viewMode == 1 then
		self.index_splitPoint = math.max(1,math.min((self.world_maxDim/2)+2,math.ceil(self.maxDim/self.cellSize/2)+2));
	else
		self.index_splitPoint = math.max(1,math.min((self.world_maxDim/2)+6,math.ceil(self.maxDim/self.cellSize/2)+6));
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------quickupdateViewPortData

function em_map:quickupdateViewPortData()
	self:updateMapOffset();
	self:updateWindowData();
	self:updateTransforms();
	self:updateGridLines();
	self:updateCoordinates();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateViewPortData

function em_map:updateViewPortData()
	self:updateMapOffset();
	self:updateWindowData();
	self:updateTransforms();
	self:updateGridLines();
	self:updateCoordinates();
	self:updateTransparency();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateTransparency

function em_map:updateTransparency()
	self.mapTint.a = em_settings.map_settings.transparencyLevel;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------doMapTransform

function em_map:doMapTransform(_transform, _drawX, _drawY)
	local rect = {};
	rect.x1, rect.y1 = _transform(_drawX, _drawY);
	rect.x2, rect.y2 = _transform(_drawX + 300, _drawY);
	rect.x3, rect.y3 = _transform(_drawX, _drawY + 300);
	rect.x4, rect.y4 = _transform(_drawX + 300, _drawY + 300);
	return rect;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------updateTransforms

function em_map:updateTransforms()
	self.transforms.trans = self.gridObj.trans(self.vpcenterX, self.vpcenterY);
	if em_settings.map_settings.viewMode > 1 then
		self.transforms.scale = self.gridObj.scale(em_settings.map_settings.zoomLevel * 1.32, em_settings.map_settings.zoomLevel * 0.66);
		self.transforms.rotate = self.gridObj.rotate(math.rad(45));
		self.transforms.mapTransform = self.transforms.trans * self.transforms.scale * self.transforms.rotate;
		em_settings.map_settings.rotationXY = 45;
	else
		self.transforms.scale = self.gridObj.scale(em_settings.map_settings.zoomLevel, em_settings.map_settings.zoomLevel);
		self.transforms.mapTransform = self.transforms.trans * self.transforms.scale;
		em_settings.map_settings.rotationXY = 0;
	end;
	self.transforms.imapTransform = self.gridObj.inverse(self.transforms.mapTransform);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------render

function em_map:render()
	local drawTexture = em_core.minimap.drawTextureAllPoint;
	local r, g, b, a = self.mapTint.r, self.mapTint.g, self.mapTint.b, self.mapTint.a;
	for _, tile in pairs(self.mapDraw) do
		drawTexture(
			em_core.minimap, tile.mapTexture,
			tile.rect.x1, tile.rect.y1, tile.rect.x2, tile.rect.y2,
			tile.rect.x4, tile.rect.y4, tile.rect.x3, tile.rect.y3,
			r, g, b, a
		);
	end;
	self:renderGridLines();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------renderGrid

function em_map:renderGridLines()
	local drawTexture = em_core.minimap.drawTextureAllPoint;
	local mapGridTint = em_settings.color_settings.mapGridTint.color;
	local r, g, b, a = mapGridTint.r, mapGridTint.g, mapGridTint.b, mapGridTint.a
	for lineID, line in pairs(self.gridLines) do
		drawTexture(
			em_core.minimap, nil,
			line.x1, line.y1, line.x2, line.y2,
			line.x4, line.y4, line.x3, line.y3,
			r, g, b, a
		);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------quickupdate

function em_map:quickupdate()
	self:quickupdateViewPortData();
	local mapTransform = self.transforms.mapTransform;
	local doMapTransform = em_map.doMapTransform;
	local cellOffsetX, cellOffsetY = self.cellOffsetX, self.cellOffsetY;
	local ccX, ccY = self.cellX, self.cellY;
	for _, mapCell in pairs(self.mapDraw) do
		mapCell.rect = doMapTransform(
			self, mapTransform,
			cellOffsetX + mapCell.dpX + ((mapCell.ccX - ccX) * 300),
			cellOffsetY + mapCell.dpY + ((mapCell.ccY - ccY) * 300)
		);
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------update

function em_map:update()
	if em_settings.context_settings.mapDayNightCycle.enabled then self:doMapTint(); else self:undoMapTint(); end;
	self.mapDraw = {};
	self:updateViewPortData();
	local cellX, cellY, cellXY = 0, 0, "0_0";
	local mapTransform = self.transforms.mapTransform;
	local doMapTransform = em_map.doMapTransform;
	local queue_loadTile = em_map.queue_loadTile;
	local cellOffsetX, cellOffsetY = self.cellOffsetX, self.cellOffsetY;
	local center_cellX, center_cellY = self.cellX, self.cellY;
	for x = 0-self.index_splitPoint, 0+self.index_splitPoint do
		for y = 0+self.index_splitPoint, 0-self.index_splitPoint, -1 do
			local mapCell = {};
			cellX, cellY = center_cellX + x, center_cellY + y;
			cellXY = cellX .. "_" .. cellY;
			mapCell.ccX = center_cellX;
			mapCell.ccY = center_cellY;
			mapCell.dpX = 300 * x;
			mapCell.dpY = 300 * y;
			mapCell.rect = doMapTransform(self, mapTransform, cellOffsetX + mapCell.dpX, cellOffsetY + mapCell.dpY);
			if self.mapTiles[cellXY] then 
				mapCell.mapTexture = self.mapTiles[cellXY];
				self.mapDraw[cellXY] = mapCell;
			elseif not self.mapTiles_invalid[cellXY] then
				if cellX < self.worldMinX or cellX > self.worldMaxX or cellY < self.worldMinY or cellY > self.worldMaxY then
					self.mapTiles_invalid[cellXY] = true;
				else
					mapCell.mapTexture = self.loadingTile;
					self.mapDraw[cellXY] = mapCell;
					if not self.tileQueueIndex[cellXY] then
						queue_loadTile(self, cellXY);
					end;
				end;
			end;
		end;
	end;
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------initialise

function em_map:initialise()
	self:loadMapTiles();
	self:initGrid();
	self:updateViewPortData();
	self:updateBounds();
	if em_core.minimap:getFollowIcon() then self:setVPCenter(getSpecificPlayer(0):getX(),getSpecificPlayer(0):getY()); end;
	self.vpCenterXInWorld, self.vpCenterYInWorld = self:getCoordsInsideWorld(self.vpCenterXInWorld, self.vpCenterYInWorld);
	self.target_xOffset = self.vpCenterXInWorld;
	self.target_yOffset = self.vpCenterYInWorld;
	self:update();
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------new

function em_map:new()
	local mapTint = em_settings.color_settings.mapTint;
	local o = {};

	setmetatable(o, self)

	self.__index = self;

	o.gridobj = nil;
	o.transforms = {};

	o.mapDraw = {};
	o.mapTiles = {};
	o.mapTiles_invalid = {};

	o.gridLines = {};

	o.tileQueue = {};
	o.tileQueueIndex = {};

	o.loadingTile = getTexture("media/textures/map/loading.png");
	o.calibrateTile = getTexture("media/textures/map/calibration2X.png");

	o.mX = 0;
	o.mY = 0;

	o.vpcenterX = em_core.window:getAbsoluteX() + (em_core.window:getWidth() / 2);
	o.vpcenterY = em_core.window:getAbsoluteY() + (em_core.window:getHeight() / 2);

	o.worldObj = getWorld();
	o.metagridObj = o.worldObj:getMetaGrid();

	o.worldMinX = o.metagridObj:getMinX();
	o.worldMinY = o.metagridObj:getMinY();
	o.worldMaxX = o.metagridObj:getMaxX();
	o.worldMaxY = o.metagridObj:getMaxY();
	o.world_maxDim = math.max(o.worldMaxX - o.worldMinX + 1, o.worldMaxY - o.worldMinY + 1);

	local setVPX = em_settings.map_settings.vpCenterXInWorld;
	local setVPY = em_settings.map_settings.vpCenterYInWorld;

	if setVPX == 0 then setVPX = (o.worldMinX + ((o.worldMaxX - o.worldMinX) + 1) / 2) * 300; end;
	if setVPY == 0 then setVPY = (o.worldMinY + ((o.worldMaxY - o.worldMinY) + 1) / 2) * 300; end;

	o.vpBounds = {x1 = 0, y1 = 0, x2 = 0, y2 = 0};

	o.vpCenterXInWorld = setVPX;
	o.vpCenterYInWorld = setVPY;

	o.target_xOffset = o.vpCenterXInWorld;
	o.target_yOffset = o.vpCenterYInWorld;

	o.cellX, o.cellY = math.floor(setVPX / 300), math.floor(setVPY / 300);
	o.cellRX, o.cellRY = (setVPX / 300) % 1, (setVPY / 300) % 1;
	o.cellOffsetX, o.cellOffsetY = (-300 * o.cellRX), (-300 * o.cellRY);

	o.mapTint = mapTint.enabled and mapTint.color or {r = 1, g = 1, b = 1, a = 1};

	o.communityMaps = em_map.callback_chain_load_community_minimapTile and true or false;
	o.communityMapReplacesVanilla = em_map.communityMapReplacesVanilla or false;

	o.custom_areas = em_map.custom_areas or {};

	return o;

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------