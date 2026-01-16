local mod = mod_loader.mods[modApi.currentMod]

------------------
----- ASSETS -----
------------------

modApi:appendAsset("img/units/mission/carrier_omniconveyor_control.png",  mod.resourcePath.."img/units/mission/carrier_omniconveyor_control.png")
modApi:appendAsset("img/units/mission/carrier_omniconveyor_controld.png", mod.resourcePath.."img/units/mission/carrier_omniconveyor_controld.png")

local a = ANIMS
a.carrier_omniconveyor_control = a.trapped_bldg:new{Image = "units/mission/carrier_omniconveyor_control.png"}
a.carrier_omniconveyor_controld = a.trapped_bldgd:new{Image = "units/mission/carrier_omniconveyor_controld.png"}


--------------------------
----- PAWN AND SKILL -----
--------------------------

Carrier_Omniconveyor_Control = {
	Name = "Omni-conveyor Control",
	Image = "carrier_omniconveyor_control",
	Health = 2,
	MoveSpeed = 0,
	SkillList = {"Carrier_Omni_Skill"},
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Pushable = false,
	NonGrid = true,
	Corporate = true,
	IgnoreSmoke = true,
}
AddPawn("Carrier_Omniconveyor_Control") 

Carrier_Omni_Skill = Skill:new{
	Name = "Change direction",
	Description = "Change the direction of all omni-conveyors.",
	Class = "Unique",
	Icon = "weapons/structure_terraform.png", --tmp
	Power = 0, --is it necessary?
}

function Carrier_Omni_Skill:GetTargetArea(point)
	local ret = PointList()

	--LOG("Carrier_Omni_Skill:GetTargetArea(point: "..point:GetString()..")")

	--Version 1: target adjacent to determine direction
	--it won't work if the pawn is on the edge of the map.
	for dir = DIR_START, DIR_END do
		local curr = point + DIR_VECTORS[dir]
		ret:push_back(curr)
	end

	--Version 2: kinda like the Wind weapon
	

	return ret
end

--TODO: add some preview
function Carrier_Omni_Skill:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	ret:AddScript(string.format("GetCurrentMission().truelch_omniconveyor_dir = GetDirection(%s - %s)", p2:GetString(), p1:GetString()))
	return ret
end


-------------------
----- MISSION -----
-------------------

Mission_Carrier_Omniconveyors = Mission_Infinite:new{
	Name = "Omniconveyor",

	Environment = "Env_OmniBelt",

	--MapTags = {"omnibelt"},

	Objectives = Objective("Protect the Omni-conveyor Control", 1), --Should I do an id or the name directly?

	UseBonus = true,
	BonusPool = {BONUS_GRID, BONUS_MECHS, BONUS_KILL_FIVE, BONUS_SELFDAMAGE, BONUS_DEBRIS, BONUS_BLOCK, BONUS_PACIFIST},

	BuildingId = -1,
}

function Mission_Carrier_Omniconveyors:StartMission()
	local control = PAWN_FACTORY:CreatePawn("Carrier_Omniconveyor_Control")
	self.BuildingId = control:GetId()

	local point = Point(0, 0)
	list = {}
	for j = 1, 6 do
		for i = 1, 6 do
			local curr = Point(i, j)
			if not Board:IsBlocked(curr, PATH_PROJECTILE) then
				--TODO: check if it's in the Belts list of points
				list[#list+1] = curr
			end
		end
	end

	if #list > 0 then
		local point = list[math.random(#list)] --it may spawn on a belt with this lol
		Board:AddPawn(control, point)
		Board:SetTerrain(control:GetSpace(), TERRAIN_ROAD) --make sure it's not on sand or something 
		Board:SetCracked(control:GetSpace(), false)
	end
end

function Mission_Carrier_Omniconveyors:UpdateObjectives()
	local status = OBJ_STANDARD --OBJ_COMPLETE
	local buildingAlive = Board:IsPawnAlive(self.BuildingId)
	if not buildingAlive then
		status = OBJ_FAILED
	end
	
	Game:AddObjective("Protect the Omni-Conveyor Control Building", status)
end

function Mission_Carrier_Omniconveyors:GetCompletedObjectives()
	if Board:IsPawnAlive(self.BuildingId) then
		return self.Objectives
	else
		return self.Objectives:Failed()
	end
end

--[[
function Mission_Carrier_Omniconveyors:UpdateMission()
end
]]

---------------
----- ENV -----
---------------

Env_OmniBelt = Environment:new{
	Image = "env_lightning", --tmp
	Name = "Omni-Conveyor",
	Text = "Unit on this tile will be moved according to the direction given by the Omni-Conveyor Control.",
	StratText = "OMNI-CONVEYOR",

	CombatIcon = "combat/tile_icon/tile_conveyor.png", --TODO
	CombatName = "OMNI-CONVEYOR",

	Belts = nil,

	--Instant = true, --?!
}

function Env_OmniBelt:IsValidTarget(p)
	local tile = Board:GetTerrain(p)
	
	return Board:IsValid(p) and 
			not Board:IsPod(p) and 
			not Board:IsBuilding(p) and 
			not (tile == TERRAIN_MOUNTAIN)
end

function Env_OmniBelt:IsBelt(p)
	if self.Belts == nil then return false end

	for i, v in ipairs(self.Belts) do
		if v == p then return true end
	end
	
	return false
end

function Env_OmniBelt:GetDir(p)
	local m = GetCurrentMission()
	if m == nil or self.Belts == nil then
		LOG("[A] Env_OmniBelt:GetDir("..p:GetString()..") -> DIR_NONE")
		return DIR_NONE
	else
		LOG("[B] Env_OmniBelt:GetDir("..p:GetString()..") -> "..tostring(m.truelch_omniconveyor_dir))
		return m.truelch_omniconveyor_dir
	end
end

function Env_OmniBelt:CheckBelts()
	for i, v in ipairs(self.Belts) do
		if Board:IsTerrain(v, TERRAIN_HOLE) or Board:IsTerrain(v, TERRAIN_WATER) or Board:IsCracked(v) then
			Board:SetTerrainIcon(v, "")
			Board:SetCustomTile(v, "")
			table.remove(self.Belts, i)
			i = i - 1
		end
	end
end

function Env_OmniBelt:AddBelt(p)
	--LOG("Env_OmniBelt:AddBelt(p: "..p:GetString()..")")
	self.Belts = self.Belts or {}
	
	self.Belts[#self.Belts+1] = p
	Board:ClearSpace(p)
	Board:BlockSpawn(p, BLOCKED_PERM)
end

function Env_OmniBelt:MarkBoard()
	self:CheckBelts()

	--local dir = DIR_NONE
	local dir = 0
	local m = GetCurrentMission()
	if m ~= nil and m.truelch_omniconveyor_dir ~= nil then
		--LOG("[TRUELCH] [A] dir: "..tostring(dir))
		dir = m.truelch_omniconveyor_dir

		for i, v in ipairs(self.Belts) do
			Board:SetCustomTile(v, "conveyor"..dir..".png")
			Board:MarkSpaceDesc(v, "TRUELCH_OMNICONVEYOR")
			Board:SetTerrainIcon(v, "arrow_"..dir)
		end
	else
		--LOG("[TRUELCH] [B] mission or dir doesn't exist!")

		for i, v in ipairs(self.Belts) do
			--Don't do the stuff below
			--[[
			Board:SetCustomTile(v, "")
			--Board:MarkSpaceDesc(v, "belt")
			Board:SetTerrainIcon(v, "")
			]]

			Board:SetCustomTile(v, "conveyor0.png")
			Board:MarkSpaceDesc(v, "TRUELCH_OMNICONVEYOR")
			Board:SetTerrainIcon(v, "arrow_0")
		end
	end
end

--???
function Env_OmniBelt:IsEffect()
	return true
end

function Env_OmniBelt:ApplyBelts()
	--LOG("[TRUELCH] Env_Belt:ApplyBelts()")

	local dir = DIR_NONE
	local m = GetCurrentMission()
	if m ~= nil and m.truelch_omniconveyor_dir ~= nil then
		LOG("[TRUELCH] mission exists!")
		dir = m.truelch_omniconveyor_dir
	else
		LOG("[TRUELCH] mission or dir doesn't exist!")
		return false --forgot to put false
	end

	self:CheckBelts()
	
	local effect = SkillEffect()
	effect:AddSound("/props/conveyor_belt")
	
	for i, v in ipairs(self.Belts) do
		local damage = SpaceDamage(v, 0, dir)
		damage.sAnimation = "Conveyor_"..dir
		effect:AddDamage(damage)
		
		if Board:IsPawnSpace(v) then
			effect:AddDelay(0.2)
		end
	end
	
	effect.iOwner = ENV_EFFECT
	Board:AddEffect(effect)	

	return false--no more to do
end

function Env_OmniBelt:ApplyEffect()
	--LOG("[TRUELCH] Env_OmniBelt:ApplyEffect()")
	return self:ApplyBelts()
end


function Env_OmniBelt:Start()
	self.Belts = {}	
	local hash = function(point) return point.x + point.y*10 end
	
	local quarters = self:GetQuarters()
	local destinations = {}
	
	for i,choices in ipairs(quarters) do
		local path = {}
		local valid_choices = {}
		
		for index,point in ipairs(choices) do
			if self:IsValidTarget(point) then
				valid_choices[#valid_choices+1] = point
			end
		end
		
		if #valid_choices > 0 then
			path[#path+1] = random_element(valid_choices)
			local length = random_int(3)
			for count = 1, length do
				local pot = {}
				for i = DIR_START, DIR_END do
					if self:IsValidTarget(path[#path] + DIR_VECTORS[i], path) then
						pot[#pot+1] = path[#path] + DIR_VECTORS[i]
					end
				end
				
				if #pot == 0 then break end
				
				path[#path+1] = random_element(pot)
			end
						
			if #path > 1 then							
				local final_dir = GetDirection(path[#path] - path[#path-1])
				local final_dest = path[#path] + DIR_VECTORS[final_dir]
				if not Board:IsValid(final_dest) or destinations[hash(final_dest)] ~= nil then
					path = reverse_table(path)
					final_dir = GetDirection(path[#path] - path[#path-1])		
					final_dest = path[#path] + DIR_VECTORS[final_dir]
				end
						
				self:AddBelt(path[#path])
				destinations[hash(final_dest)] = true
				
				for i = #path - 1, 1, -1 do
					self:AddBelt(path[i], GetDirection(path[i+1]-path[i]))
				end
				
			elseif #path > 0 then
				local choices = {}
				for dir = DIR_START, DIR_END do
					local dest = path[1] + DIR_VECTORS[dir]
					if Board:IsValid(dest) and destinations[hash(dest)] == nil then
						choices[#choices+1] = dir
					end
				end
				
				if #choices > 0 then
					local choice = random_element(choices)
					self:AddBelt(path[1])
					destinations[hash(path[1] + DIR_VECTORS[choice])] = true
				end
			end
		end
	end
	
	self:MarkBoard()
end

