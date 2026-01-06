
local path = GetParentPath(...)
local pilot_dialog = require(path.."pilot_dialog")

local mod = modApi:getCurrentMod()
local resourcePath = mod.resourcePath

-- add pilot images
modApi:appendAsset("img/portraits/npcs/Carrier.png", resourcePath.."img/corp/pilot.png")
modApi:appendAsset("img/portraits/npcs/Carrier_2.png", resourcePath.."img/corp/pilot_2.png")
modApi:appendAsset("img/portraits/npcs/Carrier_blink.png", resourcePath.."img/corp/pilot_blink.png")

-- create personality
local personality = CreatePilotPersonality("Carrier_Pilot_Label")
personality:AddDialogTable(pilot_dialog)

-- add our personality to the global personality table
Personality["Carrier_pilot_personality_id"] = personality

-- create pilot
-- reference the personality we created
-- reference the pilot images we added
CreatePilot{
	Id = "Carrier_pilot_id",
	Personality = "Carrier_pilot_personality_id",
	Rarity = 0,
	Cost = 1,
	Portrait = "npcs/Carrier",
	Voice = "/voice/rust",
}

modApi:addPilotDrop{id = "Carrier_pilot_id", recruit = true }
