OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.Sandbox = OWTL_BloodMoon.Sandbox or {}

-- Defaults are used when SandboxVars is absent or missing a field. Keeping them
-- in one table makes each getter small and consistent.
local defaults = {
    Enabled = true,
    IntervalMode = 1,
    MinRandomInterval = 5,
    MaxRandomInterval = 7,
    FixedInterval = 7,
    ServerHordeCap = 300,
    GroupHordeCap = 120,
    DebugLogging = false,
}

-- Returns the Blood Moon sandbox table if Project Zomboid has created it.
-- Otherwise returns defaults, so tests and early load phases still work.
local function getSandboxTable()
    if SandboxVars and SandboxVars.OWTL_BloodMoon then
        return SandboxVars.OWTL_BloodMoon
    end

    return defaults
end

-- Reads a numeric sandbox option and falls back to the default if it cannot be
-- converted with tonumber().
local function getNumber(name)
    local value = getSandboxTable()[name]
    if value == nil then
        value = defaults[name]
    end

    return tonumber(value) or defaults[name]
end

-- Reads a boolean sandbox option. Only true counts as true; nil falls back to
-- the default.
local function getBoolean(name)
    local value = getSandboxTable()[name]
    if value == nil then
        return defaults[name] == true
    end

    return value == true
end

-- Public getters below hide the raw sandbox table from the rest of the mod.
-- Numeric values are clamped/floored so later code receives safe integers.
function OWTL_BloodMoon.Sandbox.IsEnabled()
    return getBoolean("Enabled")
end

function OWTL_BloodMoon.Sandbox.IsFixedInterval()
    return getNumber("IntervalMode") == 2
end

function OWTL_BloodMoon.Sandbox.GetMinRandomInterval()
    return math.max(1, math.floor(getNumber("MinRandomInterval")))
end

function OWTL_BloodMoon.Sandbox.GetMaxRandomInterval()
    return math.max(OWTL_BloodMoon.Sandbox.GetMinRandomInterval(), math.floor(getNumber("MaxRandomInterval")))
end

function OWTL_BloodMoon.Sandbox.GetFixedInterval()
    return math.max(1, math.floor(getNumber("FixedInterval")))
end

function OWTL_BloodMoon.Sandbox.GetServerHordeCap()
    return math.max(0, math.floor(getNumber("ServerHordeCap")))
end

function OWTL_BloodMoon.Sandbox.GetGroupHordeCap()
    return math.max(0, math.floor(getNumber("GroupHordeCap")))
end

function OWTL_BloodMoon.Sandbox.IsDebugLoggingEnabled()
    return getBoolean("DebugLogging")
end
