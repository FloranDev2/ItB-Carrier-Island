local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath

Mission_Carrier_Depressurization = Mission_Infinite:new{
	Name = "Depressurization",

	Environment = "Env_Nautilus_Crumbling",

	--MapTags = {"train"},

	TurnLimit = 4,

	UseBonus = true,
	BonusPool = {BONUS_GRID, BONUS_MECHS, BONUS_KILL_FIVE, BONUS_SELFDAMAGE, BONUS_DEBRIS, BONUS_BLOCK, BONUS_PACIFIST},
}

function Env_Carrier_Depressurization:IsValidTarget(space)
local tile = Board:GetTerrain(space)

	return Board:IsValid(space) and
		not Board:IsBuilding(space) and
		tile ~= TERRAIN_HOLE and
		tile ~= TERRAIN_MOUNTAIN and
		tile ~= TERRAIN_RUBBLE
end