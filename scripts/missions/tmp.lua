
	--Version 1: go through all pawns:
	--[[
	for k, v in pairs(_G) do
		if type(v) == "table" and v.GetIsPortrait then
			v.__Id = k
			mechList[mechList+1] = v
		end
	end
	]]

	--Version 2: go through the squads, then though the pawns:
	--[[
	for k, v in pairs(modApi.mod_squads) do
		LOG(save_table(v)) --here, it's v that we need
		--Then I need to go through 2 -> 4
	end
	]]

	--Version 3:


	local EVENT_modsLoaded = function()
	--I'm doing the debug here to not encounter some errors and have all the stuff available

	LOG("All mods have been loaded")

	--VERSION 1
	--[[
	for k, v in pairs(_G) do
		if type(v) == "table" and v.GetIsPortrait then
			v.__Id = k
			LOG("[TRUELCH] k: "..tostring(k)) --k: IceMech_Bonus

			local pawn = _G[k]

			if pawn ~= nil then
				LOG(" -> pawn exists!")

				LOG("pawn: "..tostring(pawn))
				LOG("pawn: "..save_table(pawn))

				--It is a table, not a BoardPawn, so the stuff below do an error:
				--if pawn:IsMech() then --error
				--	LOG(" -> it is a Mech!")
				--else
				--	LOG(" -> it is NOT a Mech!")
				--end
			else
				LOG(" -> pawn does NOT exist!")
			end
		end
	end
	]]

	--VERSION 2
	--[[
	for k, v in pairs(modApi.mod_squads) do
		LOG(save_table(v)) --here, it's v that we need
		--Then I need to go through 2 -> 4
	end
	]]

	--VERSION 3
	--https://discord.com/channels/417639520507527189/418142041189646336/1460624476226981888
	--Keifer is such the MVP

	for k, v in pairs(PawnList) do
		--LOG("k: "..tostring(k)) --1
		LOG("v: "..tostring(v)) --PunchMech

		LOG("save_table(_G[v]): "..save_table(_G[v])) --PunchMech

		local isValid = IsPawnValid(v)
		LOG(v.."-> is valid: "..tostring(isValid))

		--Result:
		--[[
		{ 
			["ImageOffset"] = 0, 
			["__Id"] = "PunchMech", 
			["MoveSpeed"] = 3, 
			["Class"] = "Prime", 
			["GetIsPortrait"] = , 
			["Name"] = "Combat Mech", 
			["__index"] = , 
			["Image"] = "MechPunch", 
			["Health"] = 3, 
			["SkillList"] = { 
			[1] = "Prime_Punchmech" 
		},
		]]

		--exclude science class?
		--[[
		if _G[v] ~= nil and _G[v]["Class"] ~= nil and _G[v]["Class"] ~= "Science" and _G[v]["Class"] ~= "Cyborg" then
			LOG("Class: ".._G[v]["Class"])
		end
		]]
	end
end

modApi.events.onModsLoaded:subscribe(EVENT_modsLoaded)


local rookiePawns = {}
local function createRookiePawns()
	LOG("function Mission_Carrier_Rookies:CreateRookiePawns()")
	for k, pawnType in pairs(PawnList) do
		if IsPawnValid(pawn) then
			local rookiePawn = {
				__Id = _G[pawnType]["__Id"].."_Rookie", --will this work??
				Name = _G[pawnType]["Name"],
				Image = _G[pawnType]["Image"],
				Class = _G[pawnType]["Class"],
				MoveSpeed = _G[pawnType]["MoveSpeed"],
				Health = _G[pawnType]["Health"],
				SkillList = { "Prime_Punchmech" }, --I'm lazy
				
				SoundLocation = "/mech/prime/punch_mech/", --I cannot get this info from the table
				DefaultTeam = TEAM_PLAYER,
				ImpactMaterial = IMPACT_METAL,
				Massive = true,

				--Add a corp pilot to it:
				Corporate = true, --this is the shit
				--PilotDesc = "Rookie Pilot", --useless
			}
			AddPawn(rookiePawn)
			rookiePawns[#rookiePawns+1] = rookiePawn
		end
	end
end

createRookiePawns()
LOG("[TRUELCH] rookiePawns: "..tostring(#rookiePawns))
for k, pawn in pairs(rookiePawns) do
	LOG("type(pawn): "..type(pawn))
end


function Mission_Carrier_Rookies:StartMission()
	local pawnType = self:GetRandMechPawnType()

	--BEFORE (Generic's approach)
	--_G[pawnType].Corporate = true

	--Metalocif's approach
	local childPawnType = "Rookie_"..pawnType
	_G[childPawnType] = _G[pawnType]:new{ Corporate = true }
	setmetatable(_G[childPawnType], {__index = _G[pawnType]})

	local pawn = PAWN_FACTORY:CreatePawn(pawnType)

	--AFTER (Generic's approach)
	--_G[pawnType].Corporate = nil

	local pos = self:GetSpawnPos()
	Board:AddPawn(pawn, pos)
	self.truelch_rookie_id = pawn:GetId()

	self.killCount = 0
	self.killGoal = 2
end

--[[
local flag = true
local EVENT_nextTurn = function(mission)
	LOG("[EVENT_nextTurn] Currently it is turn of team: "..Game:GetTeamTurn())
	if flag and Game:GetTeamTurn() == TEAM_PLAYER then
		--Board:GetPawn(mission.truelch_rookie_id):SetMech(true)
		flag = false
		LOG("Rookie is now a mech!")
	end
end
]]

--modApi.events.onNextTurn:subscribe(EVENT_nextTurn)




--idk when that happen, but I'm copying stuff from mission_wind.lua
--[[
function Env_RandomWind:Plan()

	self.WindDir = random_bool(2) and DIR_UP or DIR_DOWN
	if self.RandomWind then
		self.Indices = {}
		for i = 1, 2 do
			local new_index = random_int(5) + 1
			while list_contains(self.Indices, new_index) or list_contains(self.LastIndices,new_index) do
				new_index = random_int(5) + 1
			end
			self.Indices[#self.Indices+1] = new_index
		end
	else
		if #self.LastIndices == 0 then
			self.Indices = {6,7}
		else
			self.Indices[1] = self.Indices[1] - 2
			self.Indices[2] = self.Indices[2] - 2
		end
	end
	
	return false
end
]]

----------------------------------------------------------------


--Charge or just push?
--If I do charge, I need to do some extra checks
--I need to make sure units won't move in sync so they don't bump each other in the chasm tile lol
--ApplyEffect isn't used in tatu's milk so I guess it doesn't exist for attack env?
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


--Something went wrong in Plan Environment
--scripts/environments.lua:59: attempt to get length of field 'Locations' (a nil value)
function Env_RandomWind:Plan()
	LOG("[TRUELCH] Env_Depressurization:Plan()")
end


--What to do with tile that are aligned with multiple chasms?
function Env_Depressurization:MarkBoard() --/scripts/advanced/missions/sand/mission_wind.lua
	--That's a lot of loops!
	for j = 0, Board:GetSize().y - 1 do
		for i = 0, Board:GetSize().x - 1 do
			local curr = Point(i, j)
			if Board:GetTerrain(curr) == TERRAIN_CHASM then
				LOG("")
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
