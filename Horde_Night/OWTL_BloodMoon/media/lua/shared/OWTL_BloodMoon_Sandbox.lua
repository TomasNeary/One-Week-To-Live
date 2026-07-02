OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.Sandbox = OWTL_BloodMoon.Sandbox or {}

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

local function getSandboxTable()
    if SandboxVars and SandboxVars.OWTL_BloodMoon then
        return SandboxVars.OWTL_BloodMoon
    end

    return defaults
end

local function getNumber(name)
    local value = getSandboxTable()[name]
    if value == nil then
        value = defaults[name]
    end

    return tonumber(value) or defaults[name]
end

local function getBoolean(name)
    local value = getSandboxTable()[name]
    if value == nil then
        return defaults[name] == true
    end

    return value == true
end

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
