OWTL_BloodMoon = OWTL_BloodMoon or {}
OWTL_BloodMoon.Admin = OWTL_BloodMoon.Admin or {}

local function addEvent(event, handler)
    if event and event.Add then
        event.Add(handler)
    end
end

local function hasAdminAccess(player)
    if not player then
        return false
    end

    if not isClient() and not isServer() then
        return true
    end

    if player.getAccessLevel then
        local accessLevel = player:getAccessLevel()
        return accessLevel == "admin" or accessLevel == "Admin" or accessLevel == "moderator" or accessLevel == "overseer"
    end

    return false
end

local function sayLines(player, lines)
    if not player or not lines then
        return
    end

    for i = 1, #lines do
        player:Say(tostring(lines[i]))
    end
end

local function commandAllowed(player)
    if not hasAdminAccess(player) then
        sayLines(player, { "OWTL Blood Moon: admin access required" })
        return false
    end

    return true
end

function OWTL_BloodMoon.Admin.SendStatus(player)
    if not commandAllowed(player) then
        return
    end
    sayLines(player, OWTL_BloodMoon.State.GetStatusLines())
end

function OWTL_BloodMoon.Admin.SendActiveHordeStatus(player)
    if not commandAllowed(player) then
        return
    end
    sayLines(player, OWTL_BloodMoon.State.GetActiveHordeLines())
end

function OWTL_BloodMoon.Admin.ForceWarning(player)
    if not commandAllowed(player) then
        return
    end
    OWTL_BloodMoon.State.IssueWarning(nil, "admin-forced-warning")
    sayLines(player, OWTL_BloodMoon.State.GetStatusLines())
end

function OWTL_BloodMoon.Admin.ForceStart(player)
    if not commandAllowed(player) then
        return
    end
    OWTL_BloodMoon.State.StartBloodMoon(nil, "admin-forced-start")
    sayLines(player, OWTL_BloodMoon.State.GetStatusLines())
end

function OWTL_BloodMoon.Admin.ForceEnd(player)
    if not commandAllowed(player) then
        return
    end
    OWTL_BloodMoon.State.EndBloodMoon(nil, "admin-forced-end")
    sayLines(player, OWTL_BloodMoon.State.GetStatusLines())
end

function OWTL_BloodMoon.Admin.SetStage(player, stage)
    if not commandAllowed(player) then
        return
    end
    OWTL_BloodMoon.State.SetStage(stage)
    sayLines(player, OWTL_BloodMoon.State.GetStatusLines())
end

function OWTL_BloodMoon.Admin.ResetScheduler(player)
    if not commandAllowed(player) then
        return
    end
    OWTL_BloodMoon.State.ResetScheduler()
    sayLines(player, OWTL_BloodMoon.State.GetStatusLines())
end

function OWTL_BloodMoon.Admin.SendHelp(player)
    if not commandAllowed(player) then
        return
    end
    sayLines(player, {
        "OWTL commands: /owtl status, /owtl schedule, /owtl active",
        "/owtl force warning, /owtl force start, /owtl force end",
        "/owtl setstage <number>, /owtl reset",
    })
end

local function onClientCommand(module, command, player, args)
    if module ~= "OWTL_BloodMoon" then
        return
    end

    if command == "Status" or command == "Schedule" then
        OWTL_BloodMoon.Admin.SendStatus(player)
    elseif command == "Active" then
        OWTL_BloodMoon.Admin.SendActiveHordeStatus(player)
    elseif command == "ForceWarning" then
        OWTL_BloodMoon.Admin.ForceWarning(player)
    elseif command == "ForceStart" then
        OWTL_BloodMoon.Admin.ForceStart(player)
    elseif command == "ForceEnd" then
        OWTL_BloodMoon.Admin.ForceEnd(player)
    elseif command == "SetStage" then
        OWTL_BloodMoon.Admin.SetStage(player, args and args.stage)
    elseif command == "Reset" then
        OWTL_BloodMoon.Admin.ResetScheduler(player)
    elseif command == "Help" then
        OWTL_BloodMoon.Admin.SendHelp(player)
    end
end

addEvent(Events.OnClientCommand, onClientCommand)
