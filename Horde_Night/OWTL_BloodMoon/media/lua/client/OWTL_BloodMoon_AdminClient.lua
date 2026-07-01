OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.AdminClient = OWTL_BloodMoon.AdminClient or {}

local function addEvent(event, handler)
    if event and event.Add then
        event.Add(handler)
    end
end

local function requestStatus()
    local player = getPlayer()
    if not player then
        return
    end

    if sendClientCommand then
        sendClientCommand(player, "OWTL_BloodMoon", "Status", {})
    elseif OWTL_BloodMoon.State and OWTL_BloodMoon.State.GetStatusLines then
        local lines = OWTL_BloodMoon.State.GetStatusLines()
        for i = 1, #lines do
            player:Say(tostring(lines[i]))
        end
    end
end

local function sendAdminCommand(command, args)
    local player = getPlayer()
    if not player then
        return
    end

    if sendClientCommand then
        sendClientCommand(player, "OWTL_BloodMoon", command, args or {})
    end
end

local function splitWords(text)
    local words = {}
    if not text then
        return words
    end

    for word in string.gmatch(text, "%S+") do
        table.insert(words, word)
    end

    return words
end

function OWTL_BloodMoon.AdminClient.HandleChatCommand(text)
    if not text then
        return false
    end

    local words = splitWords(string.lower(text))
    if words[1] ~= "/owtl" and words[1] ~= "/owtlbloodmoon" then
        return false
    end

    local action = words[2] or "help"
    local subaction = words[3]

    if action == "status" or action == "schedule" then
        requestStatus()
        return true
    end

    if action == "active" or action == "hordes" then
        sendAdminCommand("Active", {})
        return true
    end

    if action == "force" and subaction == "warning" then
        sendAdminCommand("ForceWarning", {})
        return true
    end

    if action == "force" and subaction == "start" then
        sendAdminCommand("ForceStart", {})
        return true
    end

    if action == "force" and subaction == "end" then
        sendAdminCommand("ForceEnd", {})
        return true
    end

    if action == "setstage" or action == "stage" then
        sendAdminCommand("SetStage", { stage = tonumber(words[3]) or tonumber(words[2]) or 1 })
        return true
    end

    if action == "reset" then
        sendAdminCommand("Reset", {})
        return true
    end

    if action == "help" then
        sendAdminCommand("Help", {})
        return true
    end

    sendAdminCommand("Help", {})
    return true
end

local function patchChat()
    if OWTL_BloodMoon.AdminClient.chatPatched then
        return
    end
    if not ISChat or not ISChat.onCommandEntered then
        return
    end

    local originalOnCommandEntered = ISChat.onCommandEntered

    ISChat.onCommandEntered = function(self)
        local text = nil
        if self and self.textEntry and self.textEntry.getText then
            text = self.textEntry:getText()
        end

        if OWTL_BloodMoon.AdminClient.HandleChatCommand(text) then
            if self and self.textEntry and self.textEntry.setText then
                self.textEntry:setText("")
            end
            return
        end

        return originalOnCommandEntered(self)
    end

    OWTL_BloodMoon.AdminClient.chatPatched = true
end

addEvent(Events.OnGameStart, patchChat)
addEvent(Events.OnCreatePlayer, patchChat)
