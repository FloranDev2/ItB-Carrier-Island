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

	MapTags = {"depressurization"}, --maps with some NON ALIGNED chasms

	TurnLimit = 4,

	UseBonus = true,
	BonusPool = {BONUS_GRID, BONUS_MECHS, BONUS_KILL_FIVE, BONUS_SELFDAMAGE, BONUS_DEBRIS, BONUS_BLOCK--[[, BONUS_PACIFIST]]},
}


---------------
----- ENV -----
---------------

Env_Depressurization = Env_Attack:new{
	Image = "env_lightning", --tmp
	Name = "Depressurization",

	CombatName = "DEPRESSURIZATION", --during mission, the text above the ENV icon, which are left to Attack Order
	Text = "Chasms will attract aligned units.", --the text when you hover your mouse above the icon

	CombatIcon = "combat/tile_icon/tile_truelch_push_0.png",
	StratText = "DEPRESSURIZATION", --on briefing preview

	--What's the stuff below?
	--Instant = true, --idk what it is
}

function Env_Depressurization:MarkSpace(space, active)
	for dir = DIR_START, DIR_END do
		local dir2 = (dir+2)%4
		for k = 1, 7 do
			local curr = space + DIR_VECTORS[dir]*k
			local pawn = Board:GetPawn(curr)			
			Board:MarkSpaceDesc(curr, "TRUELCH_DEPRESSURIZATION")
			if pawn ~= nil and not pawn:IsGuarding() and not pawn:IsFlying() then
				Board:MarkSpaceDesc(curr, "TRUELCH_DEPRESSURIZATION", EFFECT_DEADLY)
			end

			Board:MarkSpaceImage(curr, "combat/tile_icon/tile_truelch_push_"..tostring(dir2)..".png", GL_Color(255, 226, 88, 0.75))
			if active then
				Board:MarkSpaceImage(curr, "combat/tile_icon/tile_truelch_push_"..tostring(dir2)..".png", GL_Color(255, 150, 150, 0.75))
			end

			if not Board:IsValid(curr) or Board:IsBlocked(curr, PATH_PROJECTILE) then
				break
			end
		end
	end
end

function Env_Depressurization:GetAttackEffect(location)
	--LOG("[TRUELCH] Env_Depressurization:GetAttackEffect(location: "..location:GetString()..")")

	local effect = SkillEffect()

	effect:AddSound("/props/wind_mission")

	--We need to be looking for a chasm

	--What if we found multiple chasms? -> use the first found
	--What if we find none? --> do nothing
	for dir = DIR_START, DIR_END do
		for k = 1, 7 do
			local curr = location + DIR_VECTORS[dir]*k
			local dir2 = GetDirection(location - curr)
			local pawn = Board:GetPawn(curr)

			--I actually want the wind effect to be played on all tiles on this direction (until I find an obstacle?)
			local damage = SpaceDamage(curr, 0)
			damage.sAnimation = "windpush_"..dir2
			effect:AddDamage(damage)

			if pawn ~= nil then
				--LOG("[TRUELCH] GetAttackEffect -> curr: "..curr:GetString())
				--V1: push
				--[[
				local damage = SpaceDamage(curr, 0, dir2)
				effect:AddDamage(damage)
				]]

				--V2: charge
				effect:AddCharge(Board:GetSimplePath(curr, location), NO_DELAY) --FULL_DELAY --NO_DELAY
				break

			elseif not Board:IsValid(curr) or Board:IsBlocked(curr, PATH_PROJECTILE) then
				--LOG("[TRUELCH] GetAttackEffect -> BREAK")
				break
			end
		end
	end

	--LOG("[TRUELCH] GetAttackEffect -> RETURN")

	return effect
end

--We select all chasms
function Env_Depressurization:SelectSpaces()
	local ret = {}
	for j = 0, Board:GetSize().y - 1 do
		for i = 0, Board:GetSize().x - 1 do
			local curr = Point(i, j)
			if Board:GetTerrain(curr) == TERRAIN_HOLE then
				ret[#ret+1] = curr
			end
		end
	end
	return ret
end
