Events = Events or {}
SandboxVars = SandboxVars or {}
SuburbsDistributions = SuburbsDistributions or {}
Perks = Perks or { Woodwork = "Woodwork" }

local function event()
  local instance = {
    handlers = {},
  }

  local function normalizeHandler(selfOrHandler, maybeHandler)
    return maybeHandler or selfOrHandler
  end

  instance.Add = function(selfOrHandler, maybeHandler)
    local handler = normalizeHandler(selfOrHandler, maybeHandler)
    if handler then
      table.insert(instance.handlers, handler)
    end
  end

  instance.Remove = function(selfOrHandler, maybeHandler)
    local handler = normalizeHandler(selfOrHandler, maybeHandler)
    for index = #instance.handlers, 1, -1 do
      if instance.handlers[index] == handler then
        table.remove(instance.handlers, index)
      end
    end
  end

  instance.Trigger = function(_, ...)
    for _, handler in ipairs(instance.handlers) do
      handler(...)
    end
  end

  return instance
end

local function ensureEvent(name)
  Events[name] = Events[name] or event()
end

ensureEvent("OnGameStart")
ensureEvent("OnCreatePlayer")
ensureEvent("OnPlayerUpdate")
ensureEvent("OnTick")
ensureEvent("OnServerStarted")
ensureEvent("OnInitGlobalModData")
ensureEvent("EveryTenMinutes")
ensureEvent("EveryHours")

local currentPlayer = nil
local clientMode = false
local serverMode = false
local worldAgeHours = 0
local gameModData = {}
local nextRandomValue = nil

local gameTime = {
  getModData = function()
    return gameModData
  end,
  getWorldAgeHours = function()
    return worldAgeHours
  end,
  getNightsSurvived = function()
    return math.floor(worldAgeHours / 24)
  end,
  getTimeOfDay = function()
    return worldAgeHours - (math.floor(worldAgeHours / 24) * 24)
  end,
  getHour = function()
    return math.floor(worldAgeHours - (math.floor(worldAgeHours / 24) * 24))
  end,
}

local function makeKnownRecipes(initial)
  local values = {}
  for _, recipeName in ipairs(initial or {}) do
    values[recipeName] = true
  end

  return {
    values = values,
    contains = function(self, recipeName)
      return self.values[recipeName] == true
    end,
    add = function(self, recipeName)
      self.values[recipeName] = true
    end,
  }
end

local function makePlayer(options)
  options = options or {}
  local modData = options.modData or {}
  local knownRecipes = options.knownRecipes or makeKnownRecipes(options.recipes)
  local descriptor = {
    getForename = function()
      return options.forename
    end,
    getSurname = function()
      return options.surname
    end,
  }

  return {
    getModData = function()
      return modData
    end,
    getUsername = function()
      return options.username
    end,
    getOnlineID = function()
      return options.onlineId
    end,
    getDescriptor = function()
      return descriptor
    end,
    getKnownRecipes = function()
      return knownRecipes
    end,
    getPerkLevel = function(_, perk)
      if perk == Perks.Woodwork then
        return options.woodwork or 0
      end
      return 0
    end,
    getX = function()
      return options.x or 0
    end,
    getY = function()
      return options.y or 0
    end,
    getZ = function()
      return options.z or 0
    end,
    isDead = function()
      return options.dead == true
    end,
    _modData = modData,
    _knownRecipes = knownRecipes,
  }
end

function getPlayer()
  return currentPlayer
end

function getSpecificPlayer()
  return currentPlayer
end

function getNumActivePlayers()
  return currentPlayer and 1 or 0
end

function OWTL_SetTestPlayer(player)
  currentPlayer = player
end

function isClient()
  return clientMode
end

function isServer()
  return serverMode
end

function getGameTime()
  return gameTime
end

function ZombRand(min, _max)
  if nextRandomValue ~= nil then
    local value = nextRandomValue
    nextRandomValue = nil
    return value
  end
  return min
end

function getTimestampMs()
  return math.floor(worldAgeHours * 3600000)
end

function OWTL_ResetTestEnvironment()
  currentPlayer = nil
  clientMode = false
  serverMode = false
  worldAgeHours = 0
  gameModData = {}
  nextRandomValue = nil
  package.loaded["Items/SuburbsDistributions"] = nil
  SandboxVars = {}
  SuburbsDistributions = {}
  Perks = { Woodwork = "Woodwork" }
  OWTL_BloodMoon = nil
  OWTL_Player = nil
  OWTL_Traps = nil
  OWTL_Bows = nil
end

function OWTL_SetClientMode(value)
  clientMode = value == true
end

function OWTL_SetServerMode(value)
  serverMode = value == true
end

function OWTL_SetWorldAgeHours(value)
  worldAgeHours = tonumber(value) or 0
end

function OWTL_SetNextRandomValue(value)
  nextRandomValue = value
end

function OWTL_MakeTestPlayer(options)
  return makePlayer(options)
end

function OWTL_MakeKnownRecipes(initial)
  return makeKnownRecipes(initial)
end

function OWTL_MakeTestItem(modData)
  return {
    getModData = function()
      return modData
    end,
  }
end

return {
  event = event,
  setPlayer = OWTL_SetTestPlayer,
  setWorldAgeHours = OWTL_SetWorldAgeHours,
  makePlayer = makePlayer,
  makeKnownRecipes = makeKnownRecipes,
  reset = OWTL_ResetTestEnvironment,
}
