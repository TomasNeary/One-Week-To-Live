OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.State = OWTL_BloodMoon.State or {}

local constants = OWTL_BloodMoon.Constants

-- Registers an event handler if the PZ event exists in the current runtime.
local function addEvent(event, handler)
    if event and event.Add then
        event.Add(handler)
    end
end

-- Debug logging is centralized so noisy prints are controlled by one sandbox
-- option.
local function debugLog(message)
    if OWTL_BloodMoon.Sandbox and OWTL_BloodMoon.Sandbox.IsDebugLoggingEnabled() then
        print("[OWTL_BloodMoon] " .. tostring(message))
    end
end

-- Plays a cue locally in single-player, or sends a server command so connected
-- clients play it in multiplayer.
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

-- Returns absolute world age in hours. Scheduler math uses this so events that
-- cross midnight can be compared with simple >= checks.
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

-- Converts world age to a whole day number, with getNightsSurvived as fallback.
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

-- Returns the current whole hour of day for status/debug output.
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

-- Converts a day number into the absolute world hour when a Blood Moon starts.
local function getStartWorldHour(day)
    return (day * 24) + constants.START_HOUR
end

-- Converts a day number into the absolute world hour when a Blood Moon ends.
-- END_HOUR is before START_HOUR, so the end is usually on the following day.
local function getEndWorldHour(day)
    local endDay = day
    if constants.END_HOUR <= constants.START_HOUR then
        endDay = day + 1
    end

    return (endDay * 24) + constants.END_HOUR
end

-- Calculates when the warning window begins before the event start.
local function getWarningWorldHour(startWorldHour)
    return startWorldHour - (constants.WARNING_LEAD_DAYS * 24)
end

-- For admin-forced starts, computes the next dawn-like end time from now.
local function getNextDawnWorldHour(worldAgeHours)
    local day = math.floor(worldAgeHours / 24)
    local hour = worldAgeHours - (day * 24)

    if hour >= constants.END_HOUR then
        day = day + 1
    end

    return (day * 24) + constants.END_HOUR
end

-- Ensures the world-level Blood Moon save table exists in GameTime modData.
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

-- Chooses the number of days until the next event, using fixed or random
-- sandbox settings.
local function getIntervalDays()
    if OWTL_BloodMoon.Sandbox.IsFixedInterval() then
        return OWTL_BloodMoon.Sandbox.GetFixedInterval()
    end

    local minDays = OWTL_BloodMoon.Sandbox.GetMinRandomInterval()
    local maxDays = OWTL_BloodMoon.Sandbox.GetMaxRandomInterval()
    return ZombRand(minDays, maxDays + 1)
end

-- Counts active horde group records in saved state.
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

-- Returns true if the current/last event had any real horde activity. The stage
-- only advances when this is true.
function OWTL_BloodMoon.State.EventHadHordeGroup(data)
    if not data then
        return false
    end

    return data.eventHadHordeGroup == true
        or OWTL_BloodMoon.State.CountActiveGroups(data) > 0
        or (tonumber(data.activeHordeCount) or 0) > 0
        or (tonumber(data.queuedHordeCount) or 0) > 0
end

-- Fills missing fields in saved state. This allows old saves to keep working
-- when new fields are added.
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

-- Schedules the next Blood Moon relative to baseWorldHour or the current time.
-- It stores both day/hour display values and absolute world-hour values.
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

-- Clears runtime event state and immediately schedules a fresh future event.
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

-- Main state accessor. It creates schema fields, honors the enabled sandbox
-- option, and schedules an event if none exists yet.
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

-- Marks the warning as issued and records when/why it happened.
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

-- Transitions the scheduler into active mode, initializes horde counters, plays
-- the start cue, and asks the horde module to spawn zombies.
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
    if OWTL_BloodMoon.Horde and OWTL_BloodMoon.Horde.StartEvent then
        OWTL_BloodMoon.Horde.StartEvent(data)
    end
    debugLog("Blood Moon started reason=" .. tostring(reason or "started"))
    return data
end

-- Transitions out of active mode, advances stage if a horde existed, clears
-- horde state, schedules the next event, and plays the end cue.
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

    if OWTL_BloodMoon.Horde and OWTL_BloodMoon.Horde.EndEvent then
        OWTL_BloodMoon.Horde.EndEvent()
    end
    OWTL_BloodMoon.State.ScheduleNext(data, getCurrentWorldAgeHours())
    dispatchLocalCue("OWTL_BloodMoonEndCue")
    debugLog("Blood Moon ended reason=" .. tostring(reason or "ended") .. " advancedStage=" .. tostring(hadGroup))
    return data
end

-- Admin helper that forces the horde stage to a positive integer.
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

-- Adds or replaces one horde group summary in saved state. This is a lightweight
-- record of the live horde registry.
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

-- Rebuilds saved horde summaries from the live horde registry. The live zombie
-- objects stay in Horde.Registry; saved state only stores simple values.
function OWTL_BloodMoon.State.ReplaceActiveHordeGroups(groups, activeCount, queuedCount)
    local data = OWTL_BloodMoon.State.Ensure()
    if not data then
        return nil
    end

    data.activeHordeGroups = {}
    for id, group in pairs(groups or {}) do
        data.activeHordeGroups[id] = {
            id = id,
            playerCount = group.players and #group.players or 0,
            playerNames = group.playerNames or {},
            targetX = group.targetX,
            targetY = group.targetY,
            targetZ = group.targetZ,
            requestedCount = group.requestedCount or 0,
            activeCount = group.activeCount or 0,
            queuedCount = group.queuedCount or 0,
            currentTargetPlayerName = group.currentTargetPlayerName,
            allocatedWorldHour = group.allocatedWorldHour,
        }
    end

    data.activeHordeCount = math.max(0, math.floor(tonumber(activeCount) or 0))
    data.queuedHordeCount = math.max(0, math.floor(tonumber(queuedCount) or 0))
    data.eventHadHordeGroup = OWTL_BloodMoon.State.CountActiveGroups(data) > 0
    data.lastTransition = "horde-registry-synced"

    return data
end

-- Builds chat/status lines describing saved horde state, plus live registry
-- lines when the horde module is loaded.
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
        table.insert(lines, tostring(id)
            .. " players=" .. tostring(group.playerCount or 0)
            .. " active=" .. tostring(group.activeCount or 0)
            .. " queued=" .. tostring(group.queuedCount or 0)
            .. " currentTarget=" .. tostring(group.currentTargetPlayerName or "none")
            .. " target=" .. tostring(math.floor(tonumber(group.targetX) or 0)) .. "," .. tostring(math.floor(tonumber(group.targetY) or 0)) .. "," .. tostring(group.targetZ or 0))
    end

    if OWTL_BloodMoon.Horde and OWTL_BloodMoon.Horde.GetReportLines then
        local registryLines = OWTL_BloodMoon.Horde.GetReportLines()
        for i = 1, #registryLines do
            table.insert(lines, registryLines[i])
        end
    end

    return lines
end

-- Scheduler tick. It issues warnings, starts events, ends events, and skips a
-- missed event window if time has already passed it.
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

-- Builds human-readable scheduler status lines for admin chat commands.
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

-- Startup hook: make sure the state table exists as soon as game/global modData
-- is available.
local function onInit()
    OWTL_BloodMoon.State.Ensure()
end

-- Periodic hook: advance the scheduler using current world time.
local function onTick()
    OWTL_BloodMoon.State.Tick()
end

addEvent(Events.OnGameStart, onInit)
addEvent(Events.OnServerStarted, onInit)
addEvent(Events.OnInitGlobalModData, onInit)
addEvent(Events.EveryTenMinutes, onTick)
addEvent(Events.EveryHours, onTick)
