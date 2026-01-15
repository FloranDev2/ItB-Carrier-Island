--[[
Idea: the Rookie will steal exp when killing an enemy.
]]

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath

-- mission
Mission_Carrier_Rookies = Mission_Infinite:new{
	Name = "Rookies",
	Objectives = Objective("Protect the Rookie and kill 2 enemies with him", 2), --I won't do 2 separate objectives because if the Rookie dies, his gained experience was for nothing
	--MapTags = {"train"},
	TurnLimit = 4,

	BonusPool = {},
	UseBonus = false,

	truelch_rookie_id = -1, --test
	killCount = 0,
	killGoal = 2,
}

--Don't take Orbital / satellite mechs (or weird stuff like that that wouldn't behave as expected with my mission)
local ROOKIES_EXCLUDED_MECHS =
{
	"BomblingMech", --the bomblings take credit for the kills, so it's impossible for the bombling mech to kill
	"WallMech", --Hook Mech with grapple. No damage.
	"IgniteMech", --Meteor Mech
	"tatu_Satellite_Mech", --I think it'll be problematic
}

local function IsPawnValid(pawn)

	if _G[pawn] == nil or _G[pawn]["Class"] == nil or _G[pawn]["Class"] == "" or _G[pawn]["Class"] == "Science" or _G[pawn]["Class"] == "Cyborg" then
		return false
	end

	for _, excludedMech in pairs(ROOKIES_EXCLUDED_MECHS) do
		if pawn == excludedMech then
			LOG("excluded pawn: "..pawn)
			return false
		end
	end

	--LOG("pawn: "..pawn.." -> class: ".._G[pawn]["Class"])

	return true
end


function Mission_Carrier_Rookies:GetRandMechPawnType()
	--Init vars (and default values)
	local pawnType = "PunchMech"
	local mechList = {}

	--Important note: the pawn that we access below (for both versions) are table, not BoardPawn
	--Explanation: https://discord.com/channels/417639520507527189/418142041189646336/1460615314252234772

	for k, v in pairs(PawnList) do
		if IsPawnValid(v) then
			LOG("[TRUELCH] valid mech: "..v)
			mechList[#mechList+1] = v
		end
	end

	--Pick a random mech (if possible)
	if #mechList > 0 then
		pawnType = mechList[math.random(#mechList)]
	end

	--pawnType = "PierceMech" --FOR METALOCIF
	--pawnType = "truelch_HowitzerMech" --FOR ME FOR ME FOR-MI-DA-BLE

	return pawnType
end

function Mission_Carrier_Rookies:GetSpawnPos()
	local spawnPos = Point(0, 0)
	local list = {}

	for j = 1, 6 do
		for i = 1, 6 do
			local curr = Point(i, j)
			if not Board:IsBlocked(curr, PATH_PROJECTILE) then
				list[#list+1] = curr
			end
		end
	end

	if #list > 0 then
		spawnPos = list[math.random(#list)]
	end

	return spawnPos
end

function Mission_Carrier_Rookies:StartMission()
	local pawnType = self:GetRandMechPawnType()

	--Metalocif's approach
	local childPawnType = "Rookie_"..pawnType
	_G[childPawnType] = _G[pawnType]:new{ Corporate = true }
	--setmetatable(_G[childPawnType], {__index = _G[pawnType]}) --not needed

	local pawn = PAWN_FACTORY:CreatePawn(childPawnType)

	local pos = self:GetSpawnPos()
	Board:AddPawn(pawn, pos)
	self.truelch_rookie_id = pawn:GetId()

	self.killCount = 0
	self.killGoal = 2
end

function Mission_Carrier_Rookies:IsRookieAlive()
	return Board:IsPawnAlive(self.truelch_rookie_id)
end	

function Mission_Carrier_Rookies:UpdateObjectives()
	local m = GetCurrentMission()
	if m ~= nil then
		if self:IsRookieAlive() then
			local txt = "Protect the Rookie and make him kill two enemies (Kills: "..tostring(m.killCount).." / "..tostring(m.killGoal)..")"
			if m.killCount >= m.killGoal then
				Game:AddObjective(txt, OBJ_COMPLETE, REWARD_REP, 2)
			else
				Game:AddObjective(txt, OBJ_STANDARD, REWARD_REP, 2)
			end
		else
			--rookie is pepsi
			Game:AddObjective("Protect the Rookie and make him kill two enemies", OBJ_FAILED, REWARD_REP, 2)
		end		
	end
end

function Mission_Carrier_Rookies:GetCompletedObjectives()
	if self:IsRookieAlive() then
		if self.killCount >= self.killGoal then
			--return Objectives --will give you nothing
			return Objective("Protect the Rookie and make him kill two enemies", 2, 2)
		else
			return Objective("Protect the Rookie and make him kill two enemies", 1, 2)
		end
	else
		return self.Objectives:Failed()
	end
end

--[[
function Mission_Carrier_Rookies:UpdateMission()
end
]]


local EVENT_pawnKilled = function(mission, pawn)
	if pawn ~= nil and pawn:IsEnemy() and mission.lastShooterId ~= nil and mission.lastShooterId == mission.truelch_rookie_id then
		mission.killCount = mission.killCount + 1
	end
end

local function computeLastShooter(mission, pawn)
	if mission ~= nil and mission.truelch_rookie_id ~= nil and pawn ~= nil then --truelch_rookie_id actually allows me to check if it's this mission!
		mission.lastShooterId = pawn:GetId()
	end
end

local EVENT_skillEnd = function(mission, pawn, weaponId, p1, p2)
	computeLastShooter(mission, pawn)
end

local EVENT_finalEffectEnd = function(mission, pawn, weaponId, p1, p2, p3)
	computeLastShooter(mission, pawn)
end


modapiext.events.onPawnKilled:subscribe(EVENT_pawnKilled)
modapiext.events.onSkillEnd:subscribe(EVENT_skillEnd)
modapiext.events.onFinalEffectEnd:subscribe(EVENT_finalEffectEnd)