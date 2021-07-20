AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/player/kleiner.mdl"}
local testList = player_manager.AllValidModels()
for _,v in pairs(testList) do
	table.insert(ENT.Model,v)
end
ENT.StartHealth = 100
ENT.HullType = HULL_HUMAN
ENT.Behavior = VJ_BEHAVIOR_PASSIVE
ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"} -- NPCs with the same class with be allied to each other
ENT.FriendsWithAllPlayerAllies = true
-- ENT.IdleAlwaysWander = true
ENT.FollowPlayer = false

ENT.BloodColor = "Red"
ENT.BecomeEnemyToPlayer = false
ENT.HasMeleeAttack = false
ENT.CombatFaceEnemy = false
ENT.DisableWeapons = true
ENT.Weapon_NoSpawnMenu = true -- If set to true, the NPC weapon setting in the spawnmenu will not be applied for this SNPC
ENT.HasGrenadeAttack = false -- Should the SNPC have a grenade attack?

ENT.AlertFriendsOnDeath = false
ENT.DisableCallForBackUpOnDamageAnimation = true
ENT.CallForBackUpOnDamage = false

ENT.AnimTbl_IdleStand = {ACT_HL2MP_IDLE}
ENT.AnimTbl_Walk = {ACT_HL2MP_RUN}
ENT.AnimTbl_Run = {ACT_HL2MP_RUN}
ENT.AnimTbl_TakingCover = {ACT_HL2MP_IDLE_CROUCH}
ENT.AnimTbl_MoveToCover = {ACT_HL2MP_WALK_CROUCH}
ENT.AnimTbl_ScaredBehaviorStand = {ACT_HL2MP_IDLE_CROUCH}
ENT.AnimTbl_AlertFriendsOnDeath = {nil}

ENT.FootStepTimeRun = 0.3
ENT.FootStepTimeWalk = 0.5

ENT.CurrentItem = NULL
ENT.CurrentCheckPos = Vector(0,0,0)
ENT.NextCheckPosT = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetSightDirection()
	return self:GetAttachment(self:LookupAttachment("eyes")).Ang:Forward()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	if self:GetModel() == "models/error.mdl" then
		self:Remove()
	end
	self.AnimTbl_ScaredBehaviorStand = {ACT_HL2MP_IDLE_CROUCH}
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
	self:SetArrivalActivity(ACT_HL2MP_IDLE)
	if !IsValid(self:GetEnemy()) then
		if !IsValid(self.CurrentItem) then
			-- self.IdleAlwaysWander = true
			if CurTime() > self.NextCheckPosT then
				local checkPos = Amn_FindRandomNavArea()
				self.CurrentCheckPos = checkPos != false && checkPos or self:GetPos()
				self:SetLastPosition(self.CurrentCheckPos)
				self:VJ_TASK_GOTO_LASTPOS("TASK_WALK_PATH")
				self.NextCheckPosT = CurTime() +self:GetPathTimeToGoal() +math.Rand(5,10)
			end
			for _,v in pairs(ents.FindInSphere(self:GetPos(),350)) do
				if v.VJ_AmnesiaItem then
					self.CurrentItem = v
					-- self.IdleAlwaysWander = false
					break
				end
			end
		else
			self:SetLastPosition(self.CurrentItem:GetPos())
			self:VJ_TASK_GOTO_LASTPOS("TASK_WALK_PATH")
			if self.CurrentItem:GetPos():Distance(self:GetPos()) <= 100 then
				self.CurrentItem:Use(self)
			end
		end
	end

	local x = 0
	local y = 0
	if self:Between(30,-30) then
		x = 1
		y = 0
	elseif self:Between(70,30) then
		x = 1
		y = 1
	elseif self:Between(120,70) then
		x = 0
		y = 1
	elseif self:Between(150,120) then
		x = -1
		y = 1
	elseif !self:Between(150,-150) then
		x = -1
		y = 0
	elseif self:Between(-110,-150) then
		x = -1
		y = -1
	elseif self:Between(-70,-110) then
		x = 0
		y = -1
	elseif self:Between(-30,-70) then
		x = 1
		y = -1
	end

	self:SetPoseParameter("move_x",x)
	self:SetPoseParameter("move_y",y)
	if self:IsMoving() then
		if self:GetPos():Distance(self:GetCurWaypointPos()) > 75 then
			self:FaceCertainPosition(self:GetCurWaypointPos())
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Between(a,b)
	local waypoint = self:GetCurWaypointPos()
	local ang = (waypoint -self:GetPos()):Angle()
	local dif = math.AngleDifference(self:GetAngles().y,ang.y)
	return dif < a && dif > b
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FootStepSoundCode(CustomTbl)
	if self.HasSounds == false or self.HasFootStepSound == false or self.MovementType == VJ_MOVETYPE_STATIONARY then return end
	if self:IsOnGround() && self:GetGroundEntity() != NULL then
		if self:IsMoving() && CurTime() > self.FootStepT && self:GetInternalVariable("m_flMoveWaitFinished") <= 0 then
			self:CustomOnFootStepSound()
			local CurSched = self.CurrentSchedule
			if self.DisableFootStepOnRun == false && ((VJ_HasValue(self.AnimTbl_Run,self:GetMovementActivity())) or (CurSched != nil  && CurSched.MoveType == 1)) /*(VJ_HasValue(VJ_RunActivites,self:GetMovementActivity()) or VJ_HasValue(self.CustomRunActivites,self:GetMovementActivity()))*/ then
				self:FootStep()
				self.FootStepT = CurTime() + self.FootStepTimeRun
				return
			elseif self.DisableFootStepOnWalk == false && (VJ_HasValue(self.AnimTbl_Walk,self:GetMovementActivity()) or (CurSched != nil  && CurSched.MoveType == 0)) /*(VJ_HasValue(VJ_WalkActivites,self:GetMovementActivity()) or VJ_HasValue(self.CustomWalkActivites,self:GetMovementActivity()))*/ then
				self:FootStep()
				self.FootStepT = CurTime() + self.FootStepTimeWalk
				return
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.FootSteps = {
	[MAT_ANTLION] = {
		"physics/flesh/flesh_impact_hard1.wav",
		"physics/flesh/flesh_impact_hard2.wav",
		"physics/flesh/flesh_impact_hard3.wav",
		"physics/flesh/flesh_impact_hard4.wav",
		"physics/flesh/flesh_impact_hard5.wav",
		"physics/flesh/flesh_impact_hard6.wav",
	},
	[MAT_BLOODYFLESH] = {
		"physics/flesh/flesh_impact_hard1.wav",
		"physics/flesh/flesh_impact_hard2.wav",
		"physics/flesh/flesh_impact_hard3.wav",
		"physics/flesh/flesh_impact_hard4.wav",
		"physics/flesh/flesh_impact_hard5.wav",
		"physics/flesh/flesh_impact_hard6.wav",
	},
	[MAT_CONCRETE] = {
		"player/footsteps/concrete1.wav",
		"player/footsteps/concrete2.wav",
		"player/footsteps/concrete3.wav",
		"player/footsteps/concrete4.wav",
	},
	[MAT_DIRT] = {
		"player/footsteps/dirt1.wav",
		"player/footsteps/dirt2.wav",
		"player/footsteps/dirt3.wav",
		"player/footsteps/dirt4.wav",
	},
	[MAT_FLESH] = {
		"physics/flesh/flesh_impact_hard1.wav",
		"physics/flesh/flesh_impact_hard2.wav",
		"physics/flesh/flesh_impact_hard3.wav",
		"physics/flesh/flesh_impact_hard4.wav",
		"physics/flesh/flesh_impact_hard5.wav",
		"physics/flesh/flesh_impact_hard6.wav",
	},
	[MAT_GRATE] = {
		"player/footsteps/metalgrate1.wav",
		"player/footsteps/metalgrate2.wav",
		"player/footsteps/metalgrate3.wav",
		"player/footsteps/metalgrate4.wav",
	},
	[MAT_ALIENFLESH] = {
		"physics/flesh/flesh_impact_hard1.wav",
		"physics/flesh/flesh_impact_hard2.wav",
		"physics/flesh/flesh_impact_hard3.wav",
		"physics/flesh/flesh_impact_hard4.wav",
		"physics/flesh/flesh_impact_hard5.wav",
		"physics/flesh/flesh_impact_hard6.wav",
	},
	[74] = { -- Snow
		"player/footsteps/sand1.wav",
		"player/footsteps/sand2.wav",
		"player/footsteps/sand3.wav",
		"player/footsteps/sand4.wav",
	},
	[MAT_PLASTIC] = {
		"physics/plaster/drywall_footstep1.wav",
		"physics/plaster/drywall_footstep2.wav",
		"physics/plaster/drywall_footstep3.wav",
		"physics/plaster/drywall_footstep4.wav",
	},
	[MAT_METAL] = {
		"player/footsteps/metal1.wav",
		"player/footsteps/metal2.wav",
		"player/footsteps/metal3.wav",
		"player/footsteps/metal4.wav",
	},
	[MAT_SAND] = {
		"player/footsteps/sand1.wav",
		"player/footsteps/sand2.wav",
		"player/footsteps/sand3.wav",
		"player/footsteps/sand4.wav",
	},
	[MAT_FOLIAGE] = {
		"player/footsteps/grass1.wav",
		"player/footsteps/grass2.wav",
		"player/footsteps/grass3.wav",
		"player/footsteps/grass4.wav",
	},
	[MAT_COMPUTER] = {
		"physics/plaster/drywall_footstep1.wav",
		"physics/plaster/drywall_footstep2.wav",
		"physics/plaster/drywall_footstep3.wav",
		"physics/plaster/drywall_footstep4.wav",
	},
	[MAT_SLOSH] = {
		"player/footsteps/slosh1.wav",
		"player/footsteps/slosh2.wav",
		"player/footsteps/slosh3.wav",
		"player/footsteps/slosh4.wav",
	},
	[MAT_TILE] = {
		"player/footsteps/tile1.wav",
		"player/footsteps/tile2.wav",
		"player/footsteps/tile3.wav",
		"player/footsteps/tile4.wav",
	},
	[85] = { -- Grass
		"player/footsteps/grass1.wav",
		"player/footsteps/grass2.wav",
		"player/footsteps/grass3.wav",
		"player/footsteps/grass4.wav",
	},
	[MAT_VENT] = {
		"player/footsteps/duct1.wav",
		"player/footsteps/duct2.wav",
		"player/footsteps/duct3.wav",
		"player/footsteps/duct4.wav",
	},
	[MAT_WOOD] = {
		"player/footsteps/wood1.wav",
		"player/footsteps/wood2.wav",
		"player/footsteps/wood3.wav",
		"player/footsteps/wood4.wav",
		"player/footsteps/woodpanel1.wav",
		"player/footsteps/woodpanel2.wav",
		"player/footsteps/woodpanel3.wav",
		"player/footsteps/woodpanel4.wav",
	},
	[MAT_GLASS] = {
		"physics/glass/glass_sheet_step1.wav",
		"physics/glass/glass_sheet_step2.wav",
		"physics/glass/glass_sheet_step3.wav",
		"physics/glass/glass_sheet_step4.wav",
	}
}
--
function ENT:FootStep()
	if self.HasSounds == false or self.HasFootStepSound == false or self.MovementType == VJ_MOVETYPE_STATIONARY then return end
	if !self:IsOnGround() then return end
	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() +Vector(0,0,-150),
		filter = {self}
	})
	if tr.Hit && self.FootSteps[tr.MatType] then
		VJ_EmitSound(self,VJ_PICK(self.FootSteps[tr.MatType]),self.FootStepSoundLevel,self:VJ_DecideSoundPitch(self.FootStepPitch1,self.FootStepPitch2))
	end
	if self:WaterLevel() > 0 && self:WaterLevel() < 3 then
		VJ_EmitSound(self,"player/footsteps/wade" .. math.random(1,8) .. ".wav",self.FootStepSoundLevel,self:VJ_DecideSoundPitch(self.FootStepPitch1,self.FootStepPitch2))
	end
end