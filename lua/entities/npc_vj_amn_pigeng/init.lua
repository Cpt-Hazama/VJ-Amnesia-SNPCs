AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/amnesia/engineer.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 200
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
	"monsters/engi/engineer_foot_01.wav",
	"monsters/engi/engineer_foot_02.wav",
	"monsters/engi/engineer_foot_03.wav",
	"monsters/engi/engineer_foot_04.wav",
	"monsters/engi/engineer_foot_05.wav",
}
ENT.SoundTbl_Run = {
	"monsters/engi/engineer_foot_01.wav",
	"monsters/engi/engineer_foot_02.wav",
	"monsters/engi/engineer_foot_03.wav",
	"monsters/engi/engineer_foot_04.wav",
	"monsters/engi/engineer_foot_05.wav",
}
ENT.SoundTbl_Idle = {
	"monsters/engi/engineer_amb_idle_01.wav",
	"monsters/engi/engineer_amb_idle_02.wav",
	"monsters/engi/engineer_amb_idle_03.wav",
	"monsters/engi/engineer_amb_idle_04.wav",
}
ENT.SoundTbl_Alert = {
	"monsters/engi/engineer_amb_hunt_01.wav",
	"monsters/engi/engineer_amb_hunt_02.wav",
	"monsters/engi/engineer_amb_notice_01.wav",
	"monsters/engi/engineer_amb_notice_02.wav",
	"monsters/engi/engineer_amb_notice_03.wav",
}
ENT.SoundTbl_Investigate = {
	"monsters/engi/engineer_amb_enable_01.wav",
	"monsters/engi/engineer_amb_enable_02.wav",
	"monsters/engi/engineer_amb_alert_01.wav",
	"monsters/engi/engineer_amb_alert_02.wav",
	"monsters/engi/engineer_amb_alert_03.wav",
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
	"monsters/engi/engineer_vomitattack_01.wav",
	"monsters/engi/engineer_vomitattack_02.wav",
}

ENT.Enemy_Type = 0
ENT.Tracks = {
	[1] = "music/engineer_search.wav",
	[2] = "music/engineer_attack.wav",
	[3] = "music/ui_terror_meter.wav",
}

-- ENT.AnimTbl_Run = {ACT_RUN_RELAXED}
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/