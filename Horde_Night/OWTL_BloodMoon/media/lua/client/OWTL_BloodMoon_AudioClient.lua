OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.Audio = OWTL_BloodMoon.Audio or {}

local constants = OWTL_BloodMoon.Constants

-- Adds an event handler only when the event exists. This keeps the file safe in
-- test or unusual load contexts.
local function addEvent(event, handler)
    if event and event.Add then
        event.Add(handler)
    end
end

-- Prints only when the sandbox debug option is enabled.
local function debugLog(message)
    if OWTL_BloodMoon.Sandbox and OWTL_BloodMoon.Sandbox.IsDebugLoggingEnabled() then
        print("[OWTL_BloodMoon] " .. tostring(message))
    end
end

-- Translates a cue key like OWTL_BloodMoonStartCue into a PZ sound id.
local function getSoundId(cueName)
    if not cueName or not constants or not constants.SOUND_CUES then
        return nil
    end

    return constants.SOUND_CUES[cueName]
end

-- Plays one sound id for one player object. Returns true when it actually
-- issued a playSound call.
local function playForPlayer(player, soundId)
    if not player or not soundId or not player.playSound then
        return false
    end

    player:playSound(soundId)
    return true
end

-- Plays a named Blood Moon cue for all local players, with getPlayer() as a
-- fallback. Split-screen can have up to four local players.
function OWTL_BloodMoon.Audio.PlayLocalCue(cueName)
    local soundId = getSoundId(cueName)
    if not soundId then
        debugLog("unknown sound cue " .. tostring(cueName))
        return false
    end

    local played = false
    if getSpecificPlayer then
        for index = 0, 3 do
            local player = getSpecificPlayer(index)
            if playForPlayer(player, soundId) then
                played = true
            end
        end
    end

    if not played then
        played = playForPlayer(getPlayer and getPlayer() or nil, soundId)
    end

    if played then
        debugLog("played local cue " .. tostring(cueName) .. " as " .. tostring(soundId))
    end
    return played
end

-- Convenience wrapper for the start cue.
function OWTL_BloodMoon.Audio.PlayStartCue()
    return OWTL_BloodMoon.Audio.PlayLocalCue("OWTL_BloodMoonStartCue")
end

-- Convenience wrapper for the end cue.
function OWTL_BloodMoon.Audio.PlayEndCue()
    return OWTL_BloodMoon.Audio.PlayLocalCue("OWTL_BloodMoonEndCue")
end

-- Receives server commands sent by State.dispatchLocalCue and plays the
-- requested local sound on each client.
local function onServerCommand(module, command, args)
    if module ~= "OWTL_BloodMoon" or command ~= "PlayCue" then
        return
    end

    OWTL_BloodMoon.Audio.PlayLocalCue(args and args.cue)
end

addEvent(Events.OnServerCommand, onServerCommand)
