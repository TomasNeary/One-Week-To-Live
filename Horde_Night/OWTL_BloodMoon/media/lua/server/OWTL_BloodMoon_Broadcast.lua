OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.Broadcast = OWTL_BloodMoon.Broadcast or {}

local constants = OWTL_BloodMoon.Constants
local originalFillBroadcast = nil

local function debugLog(message)
    if OWTL_BloodMoon.Sandbox and OWTL_BloodMoon.Sandbox.IsDebugLoggingEnabled() then
        print("[OWTL_BloodMoon] " .. tostring(message))
    end
end

local function getWorldAgeHours(gameTime)
    local source = gameTime or getGameTime()
    if source and source.getWorldAgeHours then
        return source:getWorldAgeHours()
    end

    if source and source.getNightsSurvived and source.getTimeOfDay then
        return (source:getNightsSurvived() * 24) + source:getTimeOfDay()
    end

    return 0
end

local function isWarningBroadcastActive(data, worldAgeHours)
    if not data or data.enabled == false or data.isActive == true then
        return false
    end

    if not data.warningWorldHour or not data.nextBloodMoonStartWorldHour then
        return false
    end

    return worldAgeHours >= data.warningWorldHour and worldAgeHours < data.nextBloodMoonStartWorldHour
end

local function getSeverity(stage)
    local numericStage = math.max(1, math.floor(tonumber(stage) or 1))
    if numericStage >= 5 then
        return "EXTREME"
    end
    if numericStage >= 3 then
        return "SEVERE"
    end
    return "ELEVATED"
end

local function getWarningLines(data)
    local stage = math.max(1, math.floor(tonumber(data and data.hordeStage) or 1))
    local zombieCount = OWTL_BloodMoon.GetStageZombieCount(stage)
    local severity = getSeverity(stage)

    return {
        "Automated Emergency Broadcast System.",
        "RED LUNAR ANOMALY forecast tonight at 21:00. Threat level " .. severity .. ".",
        "Blood Moon stage " .. tostring(stage) .. " migration estimate: " .. tostring(zombieCount) .. " infected.",
        "Shelter before nightfall. Remain indoors until 06:00.",
    }
end

local function addWarningLines(broadcast, lines)
    if not broadcast or not broadcast.AddRadioLine or not RadioLine or not RadioLine.new then
        return
    end

    local color = { r = 1.0, g = 0.18, b = 0.18 }
    if WeatherChannel and WeatherChannel.AddFuzz then
        WeatherChannel.AddFuzz(color, broadcast, 6)
    end

    for i = 1, #lines do
        broadcast:AddRadioLine(RadioLine.new(tostring(lines[i]), color.r, color.g, color.b))
    end

    if WeatherChannel and WeatherChannel.AddFuzz then
        WeatherChannel.AddFuzz(color, broadcast)
    end
end

function OWTL_BloodMoon.Broadcast.FillBroadcast(gameTime, broadcast)
    if originalFillBroadcast then
        originalFillBroadcast(gameTime, broadcast)
    end

    if not OWTL_BloodMoon.State or not OWTL_BloodMoon.State.Ensure then
        return
    end

    local data = OWTL_BloodMoon.State.Ensure()
    local worldAgeHours = getWorldAgeHours(gameTime)
    if not isWarningBroadcastActive(data, worldAgeHours) then
        return
    end

    addWarningLines(broadcast, getWarningLines(data))
    debugLog("added emergency broadcast warning for stage " .. tostring(data.hordeStage))
end

local function installBroadcastHook()
    if OWTL_BloodMoon.Broadcast.installed then
        return
    end
    if not WeatherChannel or not WeatherChannel.FillBroadcast then
        return
    end

    originalFillBroadcast = WeatherChannel.FillBroadcast
    WeatherChannel.FillBroadcast = OWTL_BloodMoon.Broadcast.FillBroadcast
    OWTL_BloodMoon.Broadcast.installed = true
end

installBroadcastHook()
