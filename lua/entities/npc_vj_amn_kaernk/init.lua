AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/props_junk/watermelon01_chunk02c.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 50
ENT.SightDistance = 10
ENT.HullType = HULL_TINY
ENT.MovementType = VJ_MOVETYPE_STATIONARY
ENT.CanTurnWhileStationary = false
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.VJ_NPC_Class = {"CLASS_AMNESIA_SERVANT"} -- NPCs with the same class with be allied to each other

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.TimeUntilMeleeAttackDamage = 0.1 -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDistance = 50 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 80 -- How far does the damage go?
ENT.MeleeAttackDamage = 40
ENT.NextAnyAttackTime_Melee = 1.5

ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {}
ENT.SoundTbl_Idle = {}
ENT.SoundTbl_Alert = {}
ENT.SoundTbl_BeforeMeleeAttack = {
	"monsters/lurker/attack1.wav",
	"monsters/lurker/attack2.wav",
	"monsters/lurker/attack3.wav",
	"monsters/lurker/attack4.wav",
	"monsters/lurker/attack5.wav",
}
ENT.SoundTbl_MeleeAttackExtra = {}
ENT.SoundTbl_MeleeAttackMiss = {}
ENT.SoundTbl_Pain = {}
ENT.SoundTbl_Death = {}

ENT.GeneralSoundPitch1 = 100

ENT.LastHeardEntity = NULL
ENT.LastHeardT = CurTime()
ENT.LastSeenEnemyTimeUntilReset = 3.5
ENT.MoveNum = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetNoDraw(true)
	self:DrawShadow(false)
	-- if self:WaterLevel() < 1 then self:Remove() end
	timer.Simple(0.02,function()
		if IsValid(self) then
			local tr = util.TraceLine({
				start = self:GetPos() +self:GetUp() *7500,
				endpos = self:GetPos(),
				filter = self,
				mask = MASK_WATER
			})
			self:SetPos(tr.HitPos)
			if tr.MatType != 83 then
				self:Remove()
			end
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_AfterStartTimer()
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos() +Vector(0,0,5))
	effectdata:SetScale(10)
	util.Effect("watersplash",effectdata)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInvestigate(argent)
	if argent:IsNPC() || argent:IsPlayer() then
		if argent:WaterLevel() < 1 then return end
		self.LastHeardEntity = argent
		self:SetEnemy(self.LastHeardEntity)
		self.LastHeardT = CurTime() +3
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Water_MoveToLocation(ent)
	local pos = ent:GetPos()
	if self:VisibleVec(pos +Vector(0,0,5)) then
		self.MoveNum = self.MoveNum +1
		local dist = self:GetPos():Distance(pos)
		local push = dist *0.15
		local mOrder = self.MoveNum
		local speed = 0.075
		if IsValid(self:GetEnemy()) then
			speed = 0.03
		end
		self:SetAngles(Angle(0,((pos -self:GetPos()):Angle().y),0))
		for i = 1,dist *0.15 do
			timer.Simple(i *speed,function()
				if IsValid(self) && self.MoveNum == mOrder then
					if !IsValid(ent) then return end
					-- if ent:WaterLevel() < 1 then return end
					local tr = util.TraceLine({
						startpos = self:GetPos() +self:GetUp() *10,
						endpos = self:GetPos() +self:GetUp() *10 +self:GetForward() *(dist /push),
						filter = {self},
					})
					-- if tr.Hit then return end
					if math.random(1,3) == 1 then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos() +Vector(0,0,5))
					effectdata:SetScale(9)
					util.Effect("watersplash",effectdata)
					end
					self:SetPos(self:GetPos() +self:GetForward() *(dist /push))
				end
			end)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if IsValid(self.LastHeardEntity) then
		self.SightDistance = 1000
		self:Water_MoveToLocation(self.LastHeardEntity)
		if self.LastHeardEntity:WaterLevel() <= 0 then
			self.LastHeardEntity = NULL
			self:SetEnemy(NULL)
		end
	else
		self.SightDistance = 0
	end
	if !IsValid(self:GetEnemy()) then
		for _,v in pairs(ents.FindInSphere(self:GetPos(),1000)) do
			if (v:IsNPC() && v != self && self:Disposition(v) != D_LI) || v:IsPlayer() || v:GetClass() == "prop_physics" then
				if (v:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 0 && !v:Crouching() && v:GetMoveType() != MOVETYPE_NOCLIP && v:GetVelocity():Length() > 0) or v:IsNPC() && v:IsMoving() or v:GetClass() == "prop_physics" && IsValid(v:GetPhysicsObject()) && v:GetPhysicsObject():GetVelocity():Length() > 25 then
					if v:WaterLevel() < 1 then return end
					if self.NextInvestigateSoundMove < CurTime() then
						if self:Visible(v) then
							self:SetLastPosition(v:GetPos())
							self:Water_MoveToLocation(v)
						end
						self:CustomOnInvestigate(v)
						self:InvestigateSoundCode()
						self.NextInvestigateSoundMove = CurTime() + 2
					end
				end
			end
		end
	end
	for _,v in pairs(player.GetAll()) do
		v.Amnesia_NextStatusChangeT = v.Amnesia_NextStatusChangeT or CurTime() +5
		if self.LastHeardEntity == v then
			v:SetNWInt("VJ_AmnesiaTrack",2)
			v.Amnesia_NextStatusChangeT = CurTime() +5
		else
			if CurTime() > v.Amnesia_NextStatusChangeT then
				v:SetNWInt("VJ_AmnesiaTrack",1)
			end
		end
	end
	if CurTime() > self.LastHeardT then
		self:SetEnemy(NULL)
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/