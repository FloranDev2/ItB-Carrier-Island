local mod = mod_loader.mods[modApi.currentMod]

modApi:appendAsset("img/units/mission/carrier_omniconveyor_control.png",  mod.resourcePath.."img/units/mission/carrier_omniconveyor_control.png")
modApi:appendAsset("img/units/mission/carrier_omniconveyor_controld.png", mod.resourcePath.."img/units/mission/carrier_omniconveyor_controld.png")

local a = ANIMS
a.carrier_omniconveyor_control = a.trapped_bldg:new{Image = "units/mission/carrier_omniconveyor_control.png"}
a.carrier_omniconveyor_controld = a.trapped_bldgd:new{Image = "units/mission/carrier_omniconveyor_controld.png"}

Carrier_Omniconveyor_Control = Trapped_Building:new{
	Image = "carrier_omniconveyor_control",
	SkillList = {--[["Naut_Trapped_Explode"]]}
}



Mission_Carrier_Omniconveyor = Mission_Auto:new{
	Name = "Omniconveyor",
	--EasyObjective = Objective("Incinerate 1 Vek", 1),
	Objectives = Objective("Protect the Omni-Conveyor Control Building", 1),

	BonusPool = {BONUS_GRID, BONUS_MECHS, BONUS_KILL_FIVE, BONUS_SELFDAMAGE, BONUS_DEBRIS, BONUS_BLOCK, BONUS_PACIFIST},
}

