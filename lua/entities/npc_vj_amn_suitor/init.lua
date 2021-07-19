AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/amnesia/suitor.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 180
ENT.SightDistance = 20
ENT.InvestigateSoundDistance = 25

ENT.VJ_NPC_Class = {"CLASS_AMNESIA_SERVANT"} -- NPCs with the same class with be allied to each other

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Sneak = {
	"monsters/suitor/chains_monster_man_sneak_soft_1.wav",
	"monsters/suitor/chains_monster_man_sneak_soft_2.wav",
	"monsters/suitor/chains_monster_man_sneak_soft_3.wav",
}
ENT.SoundTbl_Walk_Chain = {
	"monsters/suitor/chains_monster_man_walk_soft_1.wav",
	"monsters/suitor/chains_monster_man_walk_soft_2.wav",
	"monsters/suitor/chains_monster_man_walk_soft_3.wav",
}
ENT.SoundTbl_Walk = {
	"monsters/suitor/metal_walk01.wav",
	"monsters/suitor/metal_walk02.wav",
	"monsters/suitor/metal_walk03.wav",
}
ENT.SoundTbl_Run_Chain = {
	"monsters/suitor/chains_monster_man_run_soft_1.wav",
	"monsters/suitor/chains_monster_man_run_soft_2.wav",
	"monsters/suitor/chains_monster_man_run_soft_3.wav",
}
ENT.SoundTbl_Run = {
	"monsters/suitor/metal_run01.wav",
	"monsters/suitor/metal_run02.wav",
	"monsters/suitor/metal_run03.wav",
}
ENT.SoundTbl_Idle = {
	"monsters/suitor/amb_idle01.wav",
	"monsters/suitor/amb_idle02.wav",
	"monsters/suitor/amb_idle03.wav",
	"monsters/suitor/amb_idle04.wav",
	"monsters/suitor/amb_idle05.wav",
	"monsters/suitor/amb_idle_scratch01.wav",
	"monsters/suitor/amb_idle_scratch02.wav",
	"monsters/suitor/amb_idle_scratch03.wav",
	"monsters/suitor/amb_idle_scratch04.wav",
	"monsters/suitor/amb_idle_whimp01.wav",
	"monsters/suitor/amb_idle_whimp02.wav",
}
ENT.SoundTbl_CombatIdle = {
	"monsters/suitor/amb_hunt01.wav",
	"monsters/suitor/amb_hunt02.wav",
	"monsters/suitor/amb_hunt03.wav",
}
ENT.SoundTbl_Alert = {
	"monsters/suitor/enabled01.wav",
	"monsters/suitor/enabled02.wav",
	"monsters/suitor/enabled03.wav",
}
ENT.SoundTbl_Investigate = {
	"monsters/suitor/amb_alert01.wav",
	"monsters/suitor/amb_alert02.wav",
	"monsters/suitor/amb_alert03.wav",
	"monsters/suitor/notice01.wav",
	"monsters/suitor/notice02.wav",
	"monsters/suitor/notice03.wav",
	"monsters/suitor/notice_long01.wav",
	"monsters/suitor/notice_long02.wav",
}
ENT.SoundTbl_NormalAttack = {
	"monsters/suitor/attack_claw01.wav",
	"monsters/suitor/attack_claw02.wav",
}
ENT.SoundTbl_LaunchAttack = {
	"monsters/suitor/attack_launch01.wav",
	"monsters/suitor/attack_launch02.wav",
}
ENT.SoundTbl_MeleeAttackExtra = {
	"monsters/suitor/attack_claw_hit01.wav",
	"monsters/suitor/attack_claw_hit02.wav",
	"monsters/suitor/attack_claw_hit03.wav",
}

ENT.Enemy_Type = 0
ENT.Tracks = {
	[1] = "music/search_suitor.wav",
	[2] = "music/att_suitor.wav",
	[3] = "music/ui_terror_meter.wav",
}
ENT.LastHeardEntity = NULL
ENT.LastHeardT = CurTime()
ENT.LastSeenEnemyTimeUntilReset = 5.5
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInvestigate(argent)
	if argent:IsNPC() || argent:IsPlayer() then
		self.LastHeardEntity = argent
		self:SetEnemy(self.LastHeardEntity)
		self.LastHeardT = CurTime() +5
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("EntityEmitSound","VJ_Amnesia_SuitorSounds",function(data)
	local ent = data.Entity
	if IsValid(ent) then
		if (SERVER) && data.SoundLevel >= 60 then
			for _,v in pairs(ents.FindByClass("npc_vj_amn_suitor")) do
				v:OnSoundDetected(data,ent)
			end
		end
		-- if ent:IsNPC() && self:Disposition(ent) != D_LI then
			-- if string.EndsWith(data.OriginalSoundName,"stepleft") or string.EndsWith(data.OriginalSoundName,"stepright") then
				-- return false
			-- end
		-- end
	end
end)
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnSoundDetected(data,ent)
	if ent != self && self:GetPos():Distance(ent:GetPos()) < (self.InvestigateSoundDistance * data.SoundLevel) then
		if IsValid(self:GetEnemy()) then return end
		if ent:IsNPC() || ent:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 0 || ent:GetClass() == "prop_physics" then
			if self.NextInvestigateSoundMove < CurTime() then
				self:CustomOnInvestigate(ent)
				if self:Visible(ent) then
					self:SetLastPosition(ent:GetPos())
					self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH")
				else
					self:SetLastPosition(ent:GetPos())
					self:VJ_TASK_GOTO_LASTPOS("TASK_WALK_PATH")
				end
				self:PlaySoundSystem("InvestigateSound")
				self.NextInvestigateSoundMove = CurTime() + 2
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	if IsValid(self.LastHeardEntity) then
		self.SightDistance = 500
	else
		self.SightDistance = 0
	end
	-- if !IsValid(self:GetEnemy()) then
		-- for _,v in pairs(ents.FindInSphere(self:GetPos(),1000)) do
			-- if (v:IsNPC() && v != self && self:Disposition(v) != D_LI) || v:IsPlayer() || v:GetClass() == "prop_physics" then
				-- if (v:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 0 && !v:Crouching() && v:GetMoveType() != MOVETYPE_NOCLIP && v:GetVelocity():Length() > 0) or v:IsNPC() && v:IsMoving() or v:GetClass() == "prop_physics" && v:GetPhysicsObject():GetVelocity():Length() > 25 then
					-- if self.NextInvestigateSoundMove < CurTime() then
						-- if self:Visible(v) then
							-- self:SetLastPosition(v:GetPos())
							-- self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH")
						-- else
							-- self:SetLastPosition(v:GetPos())
							-- self:VJ_TASK_GOTO_LASTPOS("TASK_WALK_PATH")
						-- end
						-- self:CustomOnInvestigate(v)
						-- self:PlaySoundSystem("InvestigateSound")
						-- self.NextInvestigateSoundMove = CurTime() + 2
					-- end
				-- end
			-- end
		-- end
	-- end
	if CurTime() > self.LastHeardT then
		self:SetEnemy(NULL)
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/