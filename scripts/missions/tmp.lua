
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