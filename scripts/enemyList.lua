
-- create enemy list
local enemyList = easyEdit.enemyList:add("Carrier_enemy_list_id")
local rst = easyEdit.enemyList:get("rst")

enemyList.name = "Carrier"

enemyList:copy(rst)
