OWTL_Player = OWTL_Player or {}
OWTL_Player.Sandbox = OWTL_Player.Sandbox or {}

local constants = OWTL_Player.Constants

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

function OWTL_Player.Sandbox.GetDeathDropMode()
    local value = tonumber(getSandboxValue("DeathDropMode", constants.DEATH_DROP_BACKPACK_ONLY))
    if value == constants.DEATH_DROP_ALL or value == constants.DEATH_DROP_KEEP_INVENTORY then
        return value
    end
    return constants.DEATH_DROP_BACKPACK_ONLY
end

function OWTL_Player.Sandbox.AreDeathPenaltiesEnabled()
    return getSandboxValue("DeathPenaltiesEnabled", false) == true
end
