OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.State = OWTL_BloodMoon.State or {}

local constants = OWTL_BloodMoon.Constants

local function addEvent(event, handler)
    if event and event.Add then
        event.Add(handler)
    end
end

local function debugLog(message)
    if OWTL_BloodMoon.Sandbox and OWTL_BloodMoon.Sandbox.IsDebugLoggingEnabled() then
        print("[OWTL_BloodMoon] " .. tostring(message))
    end
end

local function dispatchLocalCue(cueName)
    if not cueName then
        return
    end

    if isServer and isServer() and sendServerCommand then
        sendServerCommand("OWTL_BloodMoon", "PlayCue", { cue = cueName })
        debugLog("sent cue " .. tostring(cueName) .. " to clients")
        return
    end

    if OWTL_BloodMoon.Audio and OWTL_BloodMoon.Audio.PlayLocalCue then
        OWTL_BloodMoon.Audio.PlayLocalCue(cueName)
        debugLog("played cue " .. tostring(cueName) .. " locally")
    end
end

local function getCurrentWorldAgeHours()
    local gameTime = getGameTime()
    if gameTime and gameTime.getWorldAgeHours then
        return gameTime:getWorldAgeHours()
    end

    if gameTime and gameTime.getNightsSurvived and gameTime.getTimeOfDay then
        return (gameTime:getNightsSurvived() * 24) + gameTime:getTimeOfDay()
    end

    return 0
end

local function getCurrentWorldDay()
    local gameTime = getGameTime()
    local worldAgeHours = getCurrentWorldAgeHours()

    if gameTime and gameTime.getWorldAgeHours then
        return math.floor(worldAgeHours / 24)
    end

    if gameTime and gameTime.getNightsSurvived then
        return gameTime:getNightsSurvived()
    end

    return 0
end

local function getCurrentHour()
    local gameTime = getGameTime()
    if gameTime and gameTime.getTimeOfDay then
        return math.floor(gameTime:getTimeOfDay())
    end

    if gameTime and gameTime.getHour then
        return gameTime:getHour()
    end

    return 0
end

local function getStartWorldHour(day)
    return (day * 24) + constants.START_HOUR
end

local function getEndWorldHour(day)
    local endDay = day
    if constants.END_HOUR <= constants.START_HOUR then
        endDay = day + 1
    end

    return (endDay * 24) + constants.END_HOUR
end

local function getWarningWorldHour(startWorldHour)
    return startWorldHour - (constants.WARNING_LEAD_DAYS * 24)
end

local function getNextDawnWorldHour(worldAgeHours)
    local day = math.floor(worldAgeHours / 24)
    local hour = worldAgeHours - (day * 24)

    if hour >= constants.END_HOUR then
        day = day + 1
    end

    return (day * 24) + constants.END_HOUR
end

local function getRootData()
    local gameTime = getGameTime()
    if not gameTime then
        return nil
    end

    local modData = gameTime:getModData()
    if not modData then
        return nil
    end

    modData[constants.GAME_TIME_DATA_KEY] = modData[constants.GAME_TIME_DATA_KEY] or {}
    return modData[constants.GAME_TIME_DATA_KEY]
end

local function getIntervalDays()
    if OWTL_BloodMoon.Sandbox.IsFixedInterval() then
        return OWTL_BloodMoon.Sandbox.GetFixedInterval()
    end

    local minDays = OWTL_BloodMoon.Sandbox.GetMinRandomInterval()
    local maxDays = OWTL_BloodMoon.Sandbox.GetMaxRandomInterval()
    return ZombRand(minDays, maxDays + 1)
end

function OWTL_BloodMoon.State.CountActiveGroups(data)
    if not data or not data.activeHordeGroups then
        return 0
    end

    local count = 0
    for _ in pairs(data.activeHordeGroups) do
        count = count + 1
    end
    return count
end

function OWTL_BloodMoon.State.EventHadHordeGroup(data)
    if not data then
        return false
    end

    return data.eventHadHordeGroup == true
        or OWTL_BloodMoon.State.CountActiveGroups(data) > 0
        or (tonumber(data.activeHordeCount) or 0) > 0
        or (tonumber(data.queuedHordeCount) or 0) > 0
end

local function initializeSchema(data)
    data.schemaVersion = data.schemaVersion or constants.DATA_VERSION
    data.enabled = OWTL_BloodMoon.Sandbox.IsEnabled()
    data.hordeStage = data.hordeStage or 1
    data.isActive = data.isActive or false
    data.warningIssued = data.warningIssued or false
    data.eventHadHordeGroup = data.eventHadHordeGroup or false
    data.activeHordeGroups = data.activeHordeGroups or {}
    data.activeHordeCount = data.activeHordeCount or 0
    data.queuedHordeCount = data.queuedHordeCount or 0
    data.lastWarningWorldHour = data.lastWarningWorldHour or nil
    data.lastStartedWorldHour = data.lastStartedWorldHour or nil
    data.lastEndedWorldHour = data.lastEndedWorldHour or nil
    data.lastCheckedDay = data.lastCheckedDay or getCurrentWorldDay()
    data.lastCheckedHour = data.lastCheckedHour or getCurrentHour()
    data.lastCheckedWorldHour = data.lastCheckedWorldHour or math.floor(getCurrentWorldAgeHours())
    data.lastTransition = data.lastTransition or "initialized"

    if data.nextBloodMoonDay and not data.nextBloodMoonStartWorldHour then
        data.nextBloodMoonStartWorldHour = getStartWorldHour(data.nextBloodMoonDay)
    end
    if data.nextBloodMoonDay and not data.nextBloodMoonEndWorldHour then
        data.nextBloodMoonEndWorldHour = getEndWorldHour(data.nextBloodMoonDay)
    end
    if data.nextBloodMoonStartWorldHour and not data.warningWorldHour then
        data.warningWorldHour = getWarningWorldHour(data.nextBloodMoonStartWorldHour)
    end
end

function OWTL_BloodMoon.State.ScheduleNext(data, baseWorldHour)
    if not data then
        data = getRootData()
    end
    if not data then
        return nil
    end

    local interval = getIntervalDays()
    local baseHour = baseWorldHour or getCurrentWorldAgeHours()
    local baseDay = math.floor(baseHour / 24)
    local eventDay = baseDay + interval
    local startWorldHour = getStartWorldHour(eventDay)
    local endWorldHour = getEndWorldHour(eventDay)
    local warningWorldHour = getWarningWorldHour(startWorldHour)

    data.nextBloodMoonDay = eventDay
    data.nextBloodMoonStartHour = constants.START_HOUR
    data.nextBloodMoonStartWorldHour = startWorldHour
    data.nextBloodMoonEndDay = math.floor(endWorldHour / 24)
    data.nextBloodMoonEndHour = constants.END_HOUR
    data.nextBloodMoonEndWorldHour = endWorldHour
    data.warningDay = eventDay - constants.WARNING_LEAD_DAYS
    data.warningHour = constants.START_HOUR
    data.warningWorldHour = warningWorldHour
    data.warningIssued = false
    data.lastScheduledInterval = interval
    data.lastTransition = "scheduled"

    debugLog("scheduled Blood Moon day " .. tostring(eventDay) .. " startWorldHour " .. tostring(startWorldHour) .. " interval " .. tostring(interval))
    return data
end

function OWTL_BloodMoon.State.ResetScheduler()
    local data = getRootData()
    if not data then
        return nil
    end

    data.schemaVersion = constants.DATA_VERSION
    data.hordeStage = 1
    data.isActive = false
    data.warningIssued = false
    data.eventHadHordeGroup = false
    data.activeHordeGroups = {}
    data.activeHordeCount = 0
    data.queuedHordeCount = 0
    data.eventStartDay = nil
    data.eventStartWorldHour = nil
    data.eventEndWorldHour = nil
    data.lastWarningWorldHour = nil
    data.lastStartedWorldHour = nil
    data.lastEndedWorldHour = nil
    data.lastTransition = "reset"

    OWTL_BloodMoon.State.ScheduleNext(data, getCurrentWorldAgeHours())
    debugLog("scheduler reset")
    return data
end

function OWTL_BloodMoon.State.Ensure()
    local data = getRootData()
    if not data then
        return nil
    end

    initializeSchema(data)

    if not OWTL_BloodMoon.Sandbox.IsEnabled() then
        data.enabled = false
        data.lastTransition = "disabled"
        return data
    end

    data.enabled = true
    if not data.nextBloodMoonDay then
        OWTL_BloodMoon.State.ScheduleNext(data, getCurrentWorldAgeHours())
    end

    return data
end

function OWTL_BloodMoon.State.IssueWarning(data, reason)
    if not data then
        data = OWTL_BloodMoon.State.Ensure()
    end
    if not data then
        return nil
    end

    data.warningIssued = true
    data.lastWarningDay = getCurrentWorldDay()
    data.lastWarningHour = getCurrentHour()
    data.lastWarningWorldHour = math.floor(getCurrentWorldAgeHours())
    data.lastTransition = reason or "warning"

    debugLog("warning issued reason=" .. tostring(reason or "warning"))
    return data
end

function OWTL_BloodMoon.State.StartBloodMoon(data, reason)
    if not data then
        data = OWTL_BloodMoon.State.Ensure()
    end
    if not data then
        return nil
    end

    local worldAgeHours = getCurrentWorldAgeHours()

    data.isActive = true
    data.warningIssued = true
    data.eventHadHordeGroup = false
    data.activeHordeGroups = {}
    data.activeHordeCount = 0
    data.queuedHordeCount = 0
    if reason == "admin-forced-start" then
        data.eventStartDay = getCurrentWorldDay()
        data.eventStartWorldHour = math.floor(worldAgeHours)
        data.eventEndWorldHour = getNextDawnWorldHour(worldAgeHours)
    else
        data.eventStartDay = data.nextBloodMoonDay or getCurrentWorldDay()
        data.eventStartWorldHour = data.nextBloodMoonStartWorldHour or math.floor(worldAgeHours)
        data.eventEndWorldHour = data.nextBloodMoonEndWorldHour or getEndWorldHour(data.eventStartDay)
    end
    data.lastStartedDay = getCurrentWorldDay()
    data.lastStartedHour = getCurrentHour()
    data.lastStartedWorldHour = math.floor(worldAgeHours)
    data.lastTransition = reason or "started"

    dispatchLocalCue("OWTL_BloodMoonStartCue")
    debugLog("Blood Moon started reason=" .. tostring(reason or "started"))
    return data
end

function OWTL_BloodMoon.State.EndBloodMoon(data, reason)
    if not data then
        data = OWTL_BloodMoon.State.Ensure()
    end
    if not data then
        return nil
    end

    local hadGroup = OWTL_BloodMoon.State.EventHadHordeGroup(data)

    data.isActive = false
    data.lastEndedDay = getCurrentWorldDay()
    data.lastEndedHour = getCurrentHour()
    data.lastEndedWorldHour = math.floor(getCurrentWorldAgeHours())
    data.lastEventAdvancedStage = hadGroup

    if hadGroup then
        data.hordeStage = (tonumber(data.hordeStage) or 1) + 1
    end

    data.eventHadHordeGroup = false
    data.activeHordeGroups = {}
    data.activeHordeCount = 0
    data.queuedHordeCount = 0
    data.lastTransition = reason or "ended"

    OWTL_BloodMoon.State.ScheduleNext(data, getCurrentWorldAgeHours())
    dispatchLocalCue("OWTL_BloodMoonEndCue")
    debugLog("Blood Moon ended reason=" .. tostring(reason or "ended") .. " advancedStage=" .. tostring(hadGroup))
    return data
end

function OWTL_BloodMoon.State.SetStage(stage)
    local data = OWTL_BloodMoon.State.Ensure()
    if not data then
        return nil
    end

    data.hordeStage = math.max(1, math.floor(tonumber(stage) or 1))
    data.lastTransition = "stage-set"
    debugLog("stage set to " .. tostring(data.hordeStage))
    return data
end

function OWTL_BloodMoon.State.MarkHordeGroupAllocated(groupId, count, queuedCount)
    local data = OWTL_BloodMoon.State.Ensure()
    if not data then
        return nil
    end

    local id = tostring(groupId or ("group-" .. tostring(OWTL_BloodMoon.State.CountActiveGroups(data) + 1)))
    local activeCount = math.max(0, math.floor(tonumber(count) or 0))
    local queued = math.max(0, math.floor(tonumber(queuedCount) or 0))

    data.activeHordeGroups[id] = {
        id = id,
        activeCount = activeCount,
        queuedCount = queued,
        allocatedWorldHour = math.floor(getCurrentWorldAgeHours()),
    }
    data.activeHordeCount = (tonumber(data.activeHordeCount) or 0) + activeCount
    data.queuedHordeCount = (tonumber(data.queuedHordeCount) or 0) + queued
    data.eventHadHordeGroup = true
    data.lastTransition = "horde-group-marked"

    debugLog("horde group marked id=" .. tostring(id) .. " active=" .. tostring(activeCount) .. " queued=" .. tostring(queued))
    return data
end

function OWTL_BloodMoon.State.GetActiveHordeLines()
    local data = OWTL_BloodMoon.State.Ensure()
    if not data then
        return { "OWTL Blood Moon: state unavailable" }
    end

    local lines = {
        "OWTL Blood Moon active horde status",
        "groups=" .. tostring(OWTL_BloodMoon.State.CountActiveGroups(data)) .. " activeCount=" .. tostring(data.activeHordeCount) .. " queuedCount=" .. tostring(data.queuedHordeCount),
        "eventHadHordeGroup=" .. tostring(OWTL_BloodMoon.State.EventHadHordeGroup(data)),
    }

    for id, group in pairs(data.activeHordeGroups) do
        table.insert(lines, tostring(id) .. " active=" .. tostring(group.activeCount or 0) .. " queued=" .. tostring(group.queuedCount or 0))
    end

    return lines
end

function OWTL_BloodMoon.State.Tick()
    local data = OWTL_BloodMoon.State.Ensure()
    if not data then
        return nil
    end

    local worldAgeHours = getCurrentWorldAgeHours()
    data.lastCheckedDay = getCurrentWorldDay()
    data.lastCheckedHour = getCurrentHour()
    data.lastCheckedWorldHour = math.floor(worldAgeHours)

    if not OWTL_BloodMoon.Sandbox.IsEnabled() then
        data.enabled = false
        return data
    end

    if data.isActive == true then
        local endWorldHour = data.eventEndWorldHour or data.nextBloodMoonEndWorldHour
        if endWorldHour and worldAgeHours >= endWorldHour then
            return OWTL_BloodMoon.State.EndBloodMoon(data, "ended-at-dawn")
        end
        return data
    end

    if data.warningIssued ~= true and data.warningWorldHour and worldAgeHours >= data.warningWorldHour then
        OWTL_BloodMoon.State.IssueWarning(data, "warning-time")
    end

    if data.nextBloodMoonStartWorldHour and worldAgeHours >= data.nextBloodMoonStartWorldHour then
        if data.nextBloodMoonEndWorldHour and worldAgeHours >= data.nextBloodMoonEndWorldHour then
            data.lastTransition = "missed-event-window"
            OWTL_BloodMoon.State.ScheduleNext(data, worldAgeHours)
            debugLog("missed Blood Moon window; scheduled next event")
            return data
        end
        OWTL_BloodMoon.State.StartBloodMoon(data, "started-at-21")
    end

    return data
end

function OWTL_BloodMoon.State.GetStatusLines()
    local data = OWTL_BloodMoon.State.Ensure()
    if not data then
        return { "OWTL Blood Moon: state unavailable" }
    end

    return {
        "OWTL Blood Moon status",
        "enabled=" .. tostring(data.enabled) .. " active=" .. tostring(data.isActive),
        "worldDay=" .. tostring(getCurrentWorldDay()) .. " hour=" .. tostring(getCurrentHour()) .. " worldHour=" .. tostring(math.floor(getCurrentWorldAgeHours())),
        "stage=" .. tostring(data.hordeStage) .. " stageZombies=" .. tostring(OWTL_BloodMoon.GetStageZombieCount(data.hordeStage)),
        "nextDay=" .. tostring(data.nextBloodMoonDay) .. " startHour=" .. tostring(data.nextBloodMoonStartHour) .. " startWorldHour=" .. tostring(data.nextBloodMoonStartWorldHour),
        "endDay=" .. tostring(data.nextBloodMoonEndDay) .. " endHour=" .. tostring(data.nextBloodMoonEndHour) .. " endWorldHour=" .. tostring(data.nextBloodMoonEndWorldHour),
        "warningDay=" .. tostring(data.warningDay) .. " warningHour=" .. tostring(data.warningHour) .. " warningWorldHour=" .. tostring(data.warningWorldHour) .. " warningIssued=" .. tostring(data.warningIssued),
        "serverCap=" .. tostring(OWTL_BloodMoon.Sandbox.GetServerHordeCap()) .. " groupCap=" .. tostring(OWTL_BloodMoon.Sandbox.GetGroupHordeCap()),
        "activeGroups=" .. tostring(OWTL_BloodMoon.State.CountActiveGroups(data)) .. " activeCount=" .. tostring(data.activeHordeCount) .. " queuedCount=" .. tostring(data.queuedHordeCount) .. " eventHadGroup=" .. tostring(OWTL_BloodMoon.State.EventHadHordeGroup(data)),
        "schemaVersion=" .. tostring(data.schemaVersion) .. " lastTransition=" .. tostring(data.lastTransition),
    }
end

local function onInit()
    OWTL_BloodMoon.State.Ensure()
end

local function onTick()
    OWTL_BloodMoon.State.Tick()
end

addEvent(Events.OnGameStart, onInit)
addEvent(Events.OnServerStarted, onInit)
addEvent(Events.OnInitGlobalModData, onInit)
addEvent(Events.EveryTenMinutes, onTick)
addEvent(Events.EveryHours, onTick)
