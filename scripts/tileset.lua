-- create tileset
local tileset = easyEdit.tileset:add("Carrier_tileset_id", "lava") --lava???

tileset.name = "Airship" --"Subterranean" Name of tileset

-- appends all assets in the path relative to mod's resource path
tileset:appendAssets("img/tileset/")

-- display name of the climate in game, displays on island select screen
tileset:setClimate("Airship") --"Subterranean"

-- percentage chance of a mission having rain
tileset:setRainChance(0) --I'll keep this one!
tileset:setCrackChance(10) --Sounds nice too

-- percentage chance that a regular ground tile gets changed to the following
tileset:setEnvironmentChance{
	[TERRAIN_ACID] = 5,
	[TERRAIN_FOREST] = 10,
	[TERRAIN_SAND] = 10,
	[TERRAIN_ICE] = 5,
}

-- set custom tooltip text for various tile types
tileset:setTileTooltip{
	tile = "sand",
	title = "Exposed Valve",
	text = "If damaged, turns into Smoke. \nUnits in Smoke cannot attack or repair."
}

tileset:setTileTooltip{
	tile = "forest",
	title = "Ammo Dump",
	text = "If damaged, lights on Fire and deals 1 damage to the Unit on this tile."
}
tileset:setTileTooltip{
	tile = "forest_fire",
	title = "Ammo on Fire",
	text = "Lights units on Fire. This fire was started when a Ammo Dump was damaged."
}
