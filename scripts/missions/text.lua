--Inspired from tatu's Candy:
Global_Texts["TipTitle_Env_OmniBelt"] = "Omni-Conveyor"
Global_Texts["TipText_Env_OmniBelt"] = "Any unit on this tile will be pushed to the direction you chosed with the Omniconveyor Controller."

Global_Texts["TipTitle_Env_Depressurization"] = "Depressurization"
Global_Texts["TipText_Env_Depressurization"] = "A unit aligned with a Chasm will be pulled towards it."


merge_table(TILE_TOOLTIPS, {
	TRUELCH_OMNICONVEYOR = {"Omni-Conveyor", "Unit on this tile will be pushed."},
	TRUELCH_DEPRESSURIZATION = {"Depressurization", "Units aligned with Chasms tiles will be attracted to them."},
})

