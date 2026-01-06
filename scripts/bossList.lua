
-- create boss list
local bossList = easyEdit.bossList:add("Carrier_boss_list_id")
local rst = easyEdit.bossList:get("rst")

bossList.name = "Carrier"

bossList:copy(rst)
