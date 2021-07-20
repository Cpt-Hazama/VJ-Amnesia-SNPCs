AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/amnesia/grunt.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 150
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.VJ_NPC_Class = {"CLASS_AMNESIA_SERVANT"} -- NPCs with the same class with be allied to each other
ENT.InvestigateSoundDistance = 16

ENT.VJC_Data = {
	CameraMode = 1, -- Sets the default camera mode | 1 = Third Person, 2 = First Person
	ThirdP_Offset = Vector(0, 25, -30), -- The offset for the controller when the camera is in third person
	FirstP_Bone = "bone0000", -- If left empty, the base will attempt to calculate a position for first person
	FirstP_Offset = Vector(5, 0, 5), -- The offset for the controller when the camera is in first person
	FirstP_ShrinkBone = true, -- Should the bone shrink? Useful if the bone is obscuring the player's view
}

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDistance = 50 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 80 -- How far does the damage go?

ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events

ENT.GeneralSoundPitch1 = 100

-- Custom
ENT.Enemy_Type = 0
	-- 1 = Grunt
	-- 2 = Brute
	-- 3 = Suitor
	-- 4 = Pig
	-- 5 = Pig Engie
	-- 6 = Pig Tesla
ENT.BaseDamage = 35
ENT.TrackLevel = 0.1
ENT.Tracks = {
	[1] = "music/search_grunt.wav",
	[2] = "music/att_grunt.wav",
	[3] = "music/ui_terror_meter.wav",
}
ENT.PreviousEnemies = {}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self.BaseDistance = self.MeleeAttackDistance
	self.HasLongAttack = true
	self.DoorToBreak = NULL
	self.tbl_ToStop = {}
	if self:GetModel() == "models/cpthazama/amnesia/grunt.mdl" then
		self.Enemy_Type = 1
		self.BaseDamage = 35
		if math.random(1,150) == 1 then
			self:SetSkin(1)
			local hp = 500
			self:SetHealth(hp)
			self:SetMaxHealth(hp)
			self.BaseDamage = 95
		end
		self.SoundTbl_Walk = {
			"monsters/grunt/leather_walk01.wav",
			"monsters/grunt/leather_walk02.wav",
			"monsters/grunt/leather_walk03.wav",
			"monsters/grunt/leather_walk04.wav",
		}
		self.SoundTbl_Run = {
			"monsters/grunt/leather_run01.wav",
			"monsters/grunt/leather_run02.wav",
			"monsters/grunt/leather_run03.wav",
			"monsters/grunt/leather_run04.wav",
		}
		self.SoundTbl_Idle = {
			"monsters/grunt/amb_idle01.wav",
			"monsters/grunt/amb_idle02.wav",
			"monsters/grunt/amb_idle03.wav",
			"monsters/grunt/amb_idle04.wav",
			"monsters/grunt/amb_idle05.wav",
			"monsters/grunt/amb_idle_scratch01.wav",
			"monsters/grunt/amb_idle_scratch02.wav",
			"monsters/grunt/amb_idle_scratch03.wav",
			"monsters/grunt/amb_idle_whimp01.wav",
			"monsters/grunt/amb_idle_whimp02.wav",
		}
		self.SoundTbl_CombatIdle = {
			"monsters/grunt/amb_hunt01.wav",
			"monsters/grunt/amb_hunt02.wav",
			"monsters/grunt/amb_hunt03.wav",
			"monsters/grunt/amb_hunt04.wav",
		}
		self.SoundTbl_Alert = {
			"monsters/grunt/enabled01.wav",
			"monsters/grunt/enabled02.wav",
			"monsters/grunt/enabled03.wav",
		}
		self.SoundTbl_Investigate = {
			"monsters/grunt/amb_alert01.wav",
			"monsters/grunt/amb_alert02.wav",
			"monsters/grunt/amb_alert03.wav",
			"monsters/grunt/notice01.wav",
			"monsters/grunt/notice02.wav",
			"monsters/grunt/notice03.wav",
			"monsters/grunt/notice04.wav",
			"monsters/grunt/notice_long01.wav",
			"monsters/grunt/notice_long02.wav",
			"monsters/grunt/notice_long03.wav",
		}
		self.SoundTbl_NormalAttack = {
			"monsters/grunt/attack_claw01.wav",
			"monsters/grunt/attack_claw02.wav",
			"monsters/grunt/attack_claw03.wav",
		}
		self.SoundTbl_LaunchAttack = {
			"monsters/grunt/attack_launch01.wav",
			"monsters/grunt/attack_launch02.wav",
			"monsters/grunt/attack_launch03.wav",
		}
		self.SoundTbl_MeleeAttackExtra = {
			"monsters/grunt/attack_claw_hit01.wav",
			"monsters/grunt/attack_claw_hit02.wav",
			"monsters/grunt/attack_claw_hit03.wav",
		}
	end
	if self:GetModel() == "models/cpthazama/amnesia/special.mdl" then
		self.Enemy_Type = 2
		self.BaseDamage = 95
	end
	if self:GetModel() == "models/cpthazama/amnesia/justine.mdl" then
		self.Enemy_Type = 3
		self.BaseDamage = 40
	end
	if self:GetModel() == "models/cpthazama/amnesia/p_wretch.mdl" then
		self.Enemy_Type = 4
		self.BaseDamage = 40
		self.HasLongAttack = false
	end
	if self:GetModel() == "models/cpthazama/amnesia/p_engi.mdl" then
		self.Enemy_Type = 5
		self.BaseDamage = 50
		self.HasLongAttack = false
	end
	if self:GetModel() == "models/cpthazama/amnesia/tesla.mdl" then
		self.Enemy_Type = 6
		self.BaseDamage = 95
		self.HasLongAttack = false
		self.Glow = ents.Create("light_dynamic")
		self.Glow:SetKeyValue("brightness","2")
		self.Glow:SetKeyValue("distance","500")
		self.Glow:SetLocalPos(self:GetPos() +self:OBBCenter())
		self.Glow:SetLocalAngles(self:GetAngles())
		self.Glow:Fire("Color", "0 105 255")
		self.Glow:SetParent(self)
		self.Glow:Spawn()
		self.Glow:Activate()
		self.Glow:Fire("TurnOn","",0)
		self:DeleteOnRemove(self.Glow)
	end
	-- for i = 1,128 do
	-- 	if self:GetBoneName(i) then
	-- 		print(self:GetBoneName(i))
	-- 	end
	-- end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAlert(ent)
	if !VJ_HasValue(self.PreviousEnemies,ent) then
		table.insert(self.PreviousEnemies,ent)
	end
	if math.random(1,4) == 1 then
		self:VJ_ACT_PLAYACTIVITY({ACT_SIGNAL1,ACT_SIGNAL2},true,false,true)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	-- print(key)
	if key == "walk" then
		self.SoundTbl_FootStep = self.SoundTbl_Walk
		self:FootStepSoundCode()
	end
	if key == "run" || key == "step" then
		self.SoundTbl_FootStep = self.SoundTbl_Run
		self:FootStepSoundCode()
	end
	if key == "walk_chain" then
		VJ_EmitSound(self,self.SoundTbl_Walk_Chain,60,100)
		VJ_EmitSound(self,self.SoundTbl_Sneak,75,100)
	end
	if key == "run_chain" then
		VJ_EmitSound(self,self.SoundTbl_Run_Chain,80,100)
	end
	if key == "melee" then
		self:MeleeAttackCode()
	end
	if key == "door_break" then
		if IsValid(self.DoorToBreak) then
			local door = self.DoorToBreak
			door:EmitSound("physics/wood/wood_furniture_break"..math.random(1,2)..".wav",82,100)
			VJ_EmitSound(self,self.SoundTbl_CombatIdle,70,100)
			ParticleEffect("door_pound_core",door:GetPos(),door:GetAngles(),nil)
			ParticleEffect("door_exposion_chunks",door:GetPos(),door:GetAngles(),nil)
			door:Remove()
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	self:SetNW2Entity("Enemy",self:GetEnemy())
	for _,v in pairs(player.GetAll()) do
		v.Amnesia_NextStatusChangeT = v.Amnesia_NextStatusChangeT or CurTime() +5
		v.Amnesia_RemoveFromTableT = v.Amnesia_RemoveFromTableT or CurTime() +1
		if CurTime() > v.Amnesia_RemoveFromTableT && VJ_HasValue(self.PreviousEnemies,v) then
			for i,n in pairs(self.PreviousEnemies) do
				if n == v then
					table.remove(self.PreviousEnemies,i)
				end
			end
		end
		if v == self:GetEnemy() then
			v:SetNW2Int("VJ_AmnesiaTrack",2)
			v.Amnesia_NextStatusChangeT = CurTime() +5
			v.Amnesia_RemoveFromTableT = CurTime() +15
		elseif VJ_HasValue(self.PreviousEnemies,v) then
			if CurTime() > v.Amnesia_NextStatusChangeT then
				v:SetNW2Int("VJ_AmnesiaTrack",1)
			end
		else
			if CurTime() > v.Amnesia_NextStatusChangeT then
				v:SetNW2Int("VJ_AmnesiaTrack",0)
			end
		end
	end
	if VJ_AnimationExists(self,ACT_OPEN_DOOR) then
		if !IsValid(self.DoorToBreak) then
			for _,v in pairs(ents.FindInSphere(self:GetPos(),50)) do
				if v:GetClass() == "prop_door_rotating" && v:Visible(self) then
					local anim = string.lower(v:GetSequenceName(v:GetSequence()))
					if string.find(anim,"idle") then
						self.DoorToBreak = v
						break
					end
				end
			end
		else
			if self:GetActivity() != ACT_OPEN_DOOR then
				local ang = self:GetAngles()
				self:SetAngles(Angle(ang.x,(self.DoorToBreak:GetPos() -self:GetPos()):Angle().y,ang.z))
				self:VJ_ACT_PLAYACTIVITY(ACT_OPEN_DOOR,true,false,false)
				VJ_EmitSound(self,self.SoundTbl_NormalAttack,70,100)
			end
		end
	end
	self:OnThink()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink() end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
	local time = self:GetPathTimeToGoal()
	if self.HasLongAttack && self.NearestPointToEnemyDistance > self.BaseDistance && time > 0.5 && time < 1 then
		self.MeleeAttackDistance = self.BaseDistance *1.55
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK2}
		self.MeleeAttackDamage = self.BaseDamage *1.35
		self.SoundTbl_BeforeMeleeAttack = self.SoundTbl_LaunchAttack
	else
		self.MeleeAttackDistance = self.BaseDistance
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1}
		self.MeleeAttackDamage = self.BaseDamage
		self.SoundTbl_BeforeMeleeAttack = self.SoundTbl_NormalAttack
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/