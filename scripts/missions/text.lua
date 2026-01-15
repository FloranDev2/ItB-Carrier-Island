--Inspired from tatu's Candy:
Global_Texts["TipTitle_Env_OmniBelt"] = "Omni-Conveyor"
Global_Texts["TipText_Env_OmniBelt"] = "Any unit on this tile will be pushed to the direction you chosed with the Omniconveyor Controller."

--TODO: depressurization env
--[[
Global_Texts["TipTitle_Env_OmniBelt"] = "Omni-Conveyor"
Global_Texts["TipText_Env_OmniBelt"] = "Any unit on this tile will be pushed to the direction you chosed with the Omniconveyor Controller."
]]

merge_table(TILE_TOOLTIPS, {
	TRUELCH_OMNICONVEYOR = {"Omni-Conveyor", "Unit on this tile will be pushed."},
})

