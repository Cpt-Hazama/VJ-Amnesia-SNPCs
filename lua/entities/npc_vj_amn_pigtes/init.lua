AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/amnesia/tesla.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 400
ENT.VJ_NPC_Class = {"CLASS_AMNESIA_PIGMAN"} -- NPCs with the same class with be allied to each other

ENT.VJC_Data = {
	CameraMode = 1, -- Sets the default camera mode | 1 = Third Person, 2 = First Person
	ThirdP_Offset = Vector(0, 25, -30), -- The offset for the controller when the camera is in third person
	FirstP_Bone = "Bip001_Head", -- If left empty, the base will attempt to calculate a position for first person
	FirstP_Offset = Vector(10, 0, 5), -- The offset for the controller when the camera is in first person
	FirstP_ShrinkBone = true, -- Should the bone shrink? Useful if the bone is obscuring the player's view
}

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Walk = {
	"monsters/tesla/tesla_biped_walk_01.wav",
	"monsters/tesla/tesla_biped_walk_02.wav",
	"monsters/tesla/tesla_biped_walk_03.wav",
	"monsters/tesla/tesla_biped_walk_04.wav",
	"monsters/tesla/tesla_biped_walk_05.wav",
}
ENT.SoundTbl_Run = {
	"monsters/tesla/tesla_foot_stomp_01.wav",
	"monsters/tesla/tesla_foot_stomp_02.wav",
	"monsters/tesla/tesla_foot_stomp_03.wav",
	"monsters/tesla/tesla_foot_stomp_04.wav",
	"monsters/tesla/tesla_foot_stomp_05.wav",
}
ENT.SoundTbl_Idle = {
	"monsters/tesla/tesla_amb_idle_01.wav",
	"monsters/tesla/tesla_amb_idle_02.wav",
	"monsters/tesla/tesla_amb_idle_03.wav",
	"monsters/tesla/tesla_amb_idle_04.wav",
	"monsters/tesla/tesla_amb_idle_05.wav",
	"monsters/tesla/tesla_amb_idle_06.wav",
	"monsters/tesla/tesla_amb_idle_07.wav",
}
ENT.SoundTbl_Alert = {
	"monsters/tesla/tesla_amb_hunt_01.wav",
	"monsters/tesla/tesla_amb_hunt_02.wav",
	"monsters/tesla/tesla_amb_hunt_03.wav",
	"monsters/tesla/tesla_amb_notice_01.wav",
	"monsters/tesla/tesla_amb_notice_02.wav",
	"monsters/tesla/tesla_amb_notice_03.wav",
}
ENT.SoundTbl_Investigate = {
	"monsters/tesla/tesla_amb_enabled_01.wav",
	"monsters/tesla/tesla_amb_enabled_02.wav",
	"monsters/tesla/tesla_amb_enabled_03.wav",
	"monsters/tesla/tesla_amb_alert_01.wav",
	"monsters/tesla/tesla_amb_alert_02.wav",
	"monsters/tesla/tesla_amb_alert_03.wav",
	"monsters/tesla/tesla_amb_alert_04.wav",
	"monsters/tesla/tesla_amb_alert_05.wav",
}
ENT.SoundTbl_NormalAttack = {
	"monsters/shared/pig_attack01.wav",
	"monsters/shared/pig_attack02.wav",
	"monsters/shared/pig_attack03.wav",
}
ENT.SoundTbl_LaunchAttack = {
	"monsters/shared/pig_attack01.wav",
	"monsters/shared/pig_attack02.wav",
	"monsters/shared/pig_attack03.wav",
}
ENT.SoundTbl_MeleeAttackExtra = {
	"monsters/shared/pig_attack_hit01.wav",
	"monsters/shared/pig_attack_hit02.wav",
	"monsters/shared/pig_attack_hit03.wav",
}
ENT.SoundTbl_Vomit = {
	"monsters/tesla/tesla_vomitattack_01.wav",
	"monsters/tesla/tesla_vomitattack_02.wav",
}

ENT.Enemy_Type = 0
ENT.Tracks = {
	[1] = "music/tesla_search.wav",
	[2] = "music/tesla_attack.wav",
	[3] = "music/ui_terror_meter.wav",
}
ENT.NextFlickerT = CurTime() +2

ENT.AnimTbl_Walk = {ACT_RUN_RELAXED}
ENT.AnimTbl_Run = {ACT_RUN_STIMULATED}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	self.GodMode = self:GetNoDraw()
	self.Bleeds = !self:GetNoDraw()
	self.HasMeleeAttack = !self:GetNoDraw()
	
	if self:GetNoDraw() then
		self.AnimTbl_Run = {ACT_WALK}
		self.HasSounds = false
		self.Glow:Fire("TurnOff","",0)
	else
		self.AnimTbl_Run = {ACT_RUN_STIMULATED}
		self.HasSounds = true
		self.Glow:Fire("TurnOn","",0)
	end

	if CurTime() > self.NextFlickerT && !self.MeleeAttacking then
		self:SetNoDraw(true)
		VJ_EmitSound(self,"monsters/tesla/tesla_teleport_0"..math.random(1,4)..".wav",70,100)
		local time = math.random(2,4)
		timer.Simple(time,function()
			if IsValid(self) then
				self:SetNoDraw(false)
				VJ_EmitSound(self,"monsters/tesla/tesla_teleport_0"..math.random(1,4)..".wav",75,100)
			end
		end)
		self.NextFlickerT = CurTime() +time *2
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/