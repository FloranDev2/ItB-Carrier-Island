local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath

-- mission
Mission_Carrier_Rookies = Mission_Infinite:new{
	Name = "Rookies",
	Objectives = Objective("Protect the Rookies and make him kill an enemy", 2), --I won't do 2 separate objectives because if the Rookie dies, his gained experience was for nothing
	--MapTags = {"train"},
	TurnLimit = 4,
	UseBonus = false,
	Rookie = -1,
}

function Mission_Carrier_Rookies:GetMechPawn()
	--local mechList = {}

end

function Mission_Carrier_Rookies:StartMission()
	--[[
	local train = PAWN_FACTORY:CreatePawn(self.TrainPawn)
	self.Train = train:GetId()
	Board:AddPawn(train, Point(4, 6))
	]]
	
end

function Mission_Carrier_Rookies:IsRookieAlive()
	return Board:IsPawnAlive(self.Rookie)
end	

function Mission_Carrier_Rookies:UpdateObjectives()
	--TODO	
	Game:AddObjective("Protect the Rookies and make him kill an enemy", OBJ_STANDARD)
end

function Mission_Carrier_Rookies:GetCompletedObjectives()
	if self:IsRookieAlive() then
		return self.Objectives
	else
		return self.Objectives:Failed()
	end
end

function Mission_Carrier_Rookies:UpdateMission()
end