OWTL_Player = OWTL_Player or {}
OWTL_Player.Sandbox = OWTL_Player.Sandbox or {}

local constants = OWTL_Player.Constants

-- Reads one sandbox option. SandboxVars is the usual live table; the
-- SandboxOptions fallback helps in contexts where the live table is not ready.
local function getSandboxValue(optionName, defaultValue)
    if SandboxVars and SandboxVars.OWTL_Player and SandboxVars.OWTL_Player[optionName] ~= nil then
        return SandboxVars.OWTL_Player[optionName]
    end

    if SandboxOptions and SandboxOptions.getInstance then
        local sandbox = SandboxOptions:getInstance()
        if sandbox and sandbox.getOptionByName then
            local option = sandbox:getOptionByName("OWTL_Player." .. optionName)
            if option and option.getValue then
                local ok, value = pcall(function() return option:getValue() end)
                if ok and value ~= nil then
                    return value
                end
            end
        end
    end

    return defaultValue
end

-- Converts the sandbox value into one of the supported death-drop constants.
-- Unknown values fall back to backpack-only so bad config cannot break death.
function OWTL_Player.Sandbox.GetDeathDropMode()
    local value = tonumber(getSandboxValue("DeathDropMode", constants.DEATH_DROP_BACKPACK_ONLY))
    if value == constants.DEATH_DROP_ALL or value == constants.DEATH_DROP_KEEP_INVENTORY then
        return value
    end
    return constants.DEATH_DROP_BACKPACK_ONLY
end

-- Returns true only when the sandbox option is explicitly true. The default is
-- false, so death penalties are opt-in.
function OWTL_Player.Sandbox.AreDeathPenaltiesEnabled()
    return getSandboxValue("DeathPenaltiesEnabled", false) == true
end
