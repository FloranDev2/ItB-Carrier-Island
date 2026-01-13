local mod = mod_loader.mods[modApi.currentMod]
local path = mod.resourcePath

-- sprites and animations
modApi:appendAsset("img/units/mission/raillayer.png",path.."img/units/mission/raillayer.png")
modApi:appendAsset("img/units/mission/raillayer_a.png",path.."img/units/mission/raillayer_a.png")
modApi:appendAsset("img/units/mission/raillayer_damaged.png",path.."img/units/mission/raillayer_damaged.png")
modApi:appendAsset("img/units/mission/raillayer_broken.png",path.."img/units/mission/raillayer_broken.png")

local a = ANIMS

a.nautilus_train_drill = 				a.BaseUnit:new{ Image = "units/mission/raillayer.png", PosX = -46, PosY = -2 }
a.nautilus_train_drilla = 				a.BaseUnit:new{ Image = "units/mission/raillayer_a.png", PosX = -46, PosY = -2, NumFrames = 4 } 
a.nautilus_train_drill_broken = 		a.BaseUnit:new{ Image = "units/mission/raillayer.png", PosX = -46, PosY = -2 }
a.nautilus_train_drill_damaged = 		a.BaseUnit:new{ Image = "units/mission/raillayer_damaged.png", PosX = -46, PosY = -2 }
a.nautilus_train_drill_damaged_broken = a.BaseUnit:new{ Image = "units/mission/raillayer_broken.png", PosX = -46, PosY = -2 }

-- mission
Mission_Carrier_Jambon = Mission_Infinite:new{
	Name = "Jambon",
	Objectives = Objective("Protect the Jambon", 2),
	--MapTags = {"train"},
	Train = -1,
	TrainLoc = Point(-1,-1),
	TurnLimit = 3,
	TrainStopped = false,
	UseBonus = false,
	TrainPawn = "Nautilus_Drilltrain_Pawn",
	TrainDamaged = "Nautilus_Drilltrain_Damaged",
}

function Mission_Carrier_Jambon:StartMission()
	local train = PAWN_FACTORY:CreatePawn(self.TrainPawn)
	self.Train = train:GetId()
	Board:AddPawn(train,Point(4,6))
	
	for i = 0, 7 do
		local order = {4,3,5}
		local mCount = 0
		for _,j in ipairs(order) do
			local curr = Point(j,i)
			Board:SetCustomTile(curr,"")
			if j == 4 then Board:SetCustomTile(curr,"ground_pod_block.png") end
			local obstacle = true

			for j = DIR_START, DIR_END do
				local adj = curr + DIR_VECTORS[j]
				local ort = adj + DIR_VECTORS[(j+1)%4]
				if Board:IsBlocked(ort, PATH_PROJECTILE) or i > 4 then -- and Board:IsBlocked(adj, PATH_GROUND) then
					obstacle = false
				end
			end
			
			local choices = {true,false,false}
			choice = random_removal(choices)
			if choice or mCount > 1 then -- remove some obstacles
				obstacle = false
				mCount = 0
			else
				mCount = mCount + 1
			end
			
			if obstacle then
				Board:SetTerrain(curr,TERRAIN_MOUNTAIN)
			else
				Board:SetTerrain(curr,0)
			end
		end
	end
	
	
end

function Mission_Carrier_Jambon:IsTrainAlive()
	return Board:IsPawnAlive(self.Train)
end	

function Mission_Carrier_Jambon:UpdateObjectives()
	local status1 = not self.TrainStopped and OBJ_STANDARD or OBJ_FAILED
	
	if status1 == OBJ_FAILED then
		local status2 = self:IsTrainAlive() and OBJ_STANDARD or OBJ_FAILED
		
		if status2 == OBJ_FAILED then
			Game:AddObjective("Protect the Jambon", status2, REWARD_REP, 2)
		else
			Game:AddObjective("Protect the damaged Jambon", status2, REWARD_REP, 2, 1)
		end
	else
		Game:AddObjective("Protect the Jambon",status1, REWARD_REP, 2)
	end
end

function Mission_Carrier_Jambon:GetCompletedObjectives()
	if self:IsTrainAlive() then
		if self.TrainStopped then
			return Objective("Protect the damaged Jambon", 1, 2)
		else
			return self.Objectives
		end
	end
	
	return self.Objectives:Failed()
end

function Mission_Carrier_Jambon:StopTrain()
	local trainPawn = Board:GetPawn(self.Train)
	if trainPawn then Board:RemovePawn(trainPawn) end
	
	local train = PAWN_FACTORY:CreatePawn(self.TrainDamaged)
	self.Train = train:GetId()
	Board:AddPawn(train,self.TrainLoc)
	self.TrainStopped = true
end

function Mission_Carrier_Jambon:UpdateMission()
	local trainPawn = Board:GetPawn(self.Train)
		
	if not self:IsTrainAlive() then
		if not self.TrainStopped then
			self:StopTrain()
			return
		end
	end
	
	if trainPawn == nil then
		return
	end
	
	self.TrainLoc = trainPawn:GetSpace()
	
	if self.TrainStopped then
		trainPawn:SetActive(false)
	end
end