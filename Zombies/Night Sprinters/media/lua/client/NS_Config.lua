require "EasyConfig/EasyConfig"


NS = NS or {}

NS.config = {
    rainsprinters = false,
}



NS.modId = "NightSprinters"
NS.name = "Night Sprinters settings" 

NS.menu = {
    rainsprinters = {
        type = "Tickbox",
        title = "Enables Rain Sprinters",
        tooltip = "",
    }
    
    
}

EasyConfig.addMod(NS.modId, NS.name, NS.config, NS.menu, "NIGHTSPRINTERS")



local function OnGameStart()
    SandboxVars.StartTime = 2 
end
Events.OnGameStart.Add(OnGameStart);