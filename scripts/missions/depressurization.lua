local mod = mod_loader.mods[modApi.currentMod]
--local path = mod.resourcePath

for i = 0, 3 do
	modApi:appendAsset("img/combat/tile_icon/tile_truelch_push_"..tostring(i)..".png", mod.resourcePath.."img/combat/tile_icon/tile_truelch_push_"..tostring(i)..".png")
		Location["combat/tile_icon/tile_truelch_push_"..tostring(i)..".png"] = Point(-27,2)
end

-------------------
----- MISSION -----
-------------------

Mission_Carrier_Depressurization = Mission_Infinite:new{
	Name = "Depressurization",

	Environment = "Env_Depressurization",

	--MapTags = {"depressurization"},

	TurnLimit = 4,

	UseBonus = true,
	BonusPool = {BONUS_GRID, BONUS_MECHS, BONUS_KILL_FIVE, BONUS_SELFDAMAGE, BONUS_DEBRIS, BONUS_BLOCK, BONUS_PACIFIST},
}


---------------
----- ENV -----
---------------

Env_Depressurization = Env_Attack:new{
	Name = "Depressurization",
	Text = "Chasms will attract aligned units.", --charge or just push?
	--CombatName = "DEPRESSURIZATION", --where is that located?
	CombatIcon = "combat/tile_icon/tile_truelch_push_0.png",
	--StratText = "TREMORS", --where is that located?
	--What's the stuff below?
	--Removals = 2,
	--Instant = true,
}

--What to do with tile that are aligned with multiple chasms?
function Env_Depressurization:MarkBoard() --/scripts/advanced/missions/sand/mission_wind.lua
	--That's a lot of loops!
	for j = 0, Board:GetSize().y - 1 do
		for i = 0, Board:GetSize().x - 1 do
			local curr = Point(i, j)
			if Board:GetTerrain(curr) == TERRAIN_CHASM then
				for dir = DIR_START, DIR_END do
					for k = 0, 7 do
						local curr2 = curr + DIR_VECTORS[dir]*k
						local pawn = Board:GetPawn(curr2)
						local dir2 = GetDirection(curr - curr2)

						LOG("dir: "..tostring(dir).." -> dir2: "..tostring(dir2))

						local image = "advanced/combat/tile_icon/tile_wind_"..tostring(dir2)..".png"

						if pawn ~= nil and not pawn:IsGuarding() then
							Board:MarkSpaceImage(space, image, GL_Color(255, 226, 88, 0.75))
							Board:MarkSpaceDesc(space, "wind") --tmp
						end
					end
				end
			end
		end
	end
end

function Env_Depressurization:Start()
	LOG("[TRUELCH] Env_Depressurization:Start()")
	--self.Indices = {}
	--self.LastIndices = {}
end

function Env_Depressurization:IsEffect()
	LOG("[TRUELCH] Env_Depressurization:IsEffect()")
	return true
end


function Env_RandomWind:Plan()
	LOG("[TRUELCH] Env_Depressurization:Plan()")
end


--Charge or just push?
--If I do charge, I need to do some extra checks
--I need to make sure units won't move in sync so they don't bump each other in the chasm tile lol
function Env_Depressurization:ApplyEffect()
	LOG("[TRUELCH] Env_Depressurization:ApplyEffect()")
	local effect = SkillEffect()

	effect:AddSound("/props/wind_mission")
	effect.iOwner = ENV_EFFECT

	for j = 0, Board:GetSize().y - 1 do
		for i = 0, Board:GetSize().x - 1 do
			local curr = Point(i, j)
			--Maybe there's a way to extract all the tiles of chasm type?
			if Board:GetTerrain(curr) == TERRAIN_CHASM then
				for dir = DIR_START, DIR_END do
					for k = 0, 7 do
						local curr2 = curr + DIR_VECTORS[dir]*k
						local pawn = Board:GetPawn(curr2)
						local dir2 = GetDirection(curr - curr2)

						--V1: just a single push
						local damage = SpaceDamage()
						damage.loc = curr
						damage.iPush = dir2
						damage.sAnimation = "windpush_"..dir2 --does it work with all directions?
						--TODO: delay. I'm not sure to understand what they did in mission_wind for that

						if pawn ~= nil then
							damage.fDelay = 0.2 --not what I want to do, but that's just a reminder I need to do something here
						end

						--V2: CHAAAARGE!!
					end
				end
			end
		end
	end

	Board:AddEffect(effect)

	return false--no more to do
end

--[[
function Env_Depressurization:GetAttackEffect(location, effect) --When instant, passes in effect
	local damage = SpaceDamage(location)
	if location ~= Point(0,0) then --Could be better
		damage.iTerrain = TERRAIN_HOLE
		--damage.fDelay = 0.2
		effect:AddDamage(damage)
	else
		damage.iCrack = EFFECT_CREATE
		effect:AddDamage(damage)
		damage.iDamage = 1
		effect:AddDamage(damage)
	end
	effect:AddBurst(location, "Emitter_Crack_Start2", DIR_NONE)
	effect:AddScript(string.format("AddCustomWaterfall(%s)", location:GetString()))
	return effect
end
]]