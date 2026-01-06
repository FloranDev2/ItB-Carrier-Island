
local path = GetParentPath(...)
local dialog = require(path.."dialog")
local dialog_missions = require(path.."dialog_missions")

-- create personality
local personality = CreatePilotPersonality("Carrier_ceo_label", "Tom Harner") --Second argument is CEO name, don't change the first
personality:AddDialogTable(dialog)
personality:AddDialogTable(dialog_missions)

-- create ceo
local ceo = easyEdit.ceo:add("Carrier_ceo_id")
ceo:setPersonality(personality)
ceo:setPortrait("img/ceo/portrait.png")
ceo:setOffice("img/ceo/office.png", "img/ceo/office_small.png")
--ceo:setFinalMission("Mission_Train")
