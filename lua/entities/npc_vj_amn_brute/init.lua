AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/cpthazama/amnesia/brute.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 300
ENT.VJ_NPC_Class = {"CLASS_AMNESIA_SERVANT"} -- NPCs with the same class with be allied to each other

	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Walk = {
	"monsters/brute/metal_walk01.wav",
	"monsters/brute/metal_walk02.wav",
	"monsters/brute/metal_walk03.wav",
	"monsters/brute/metal_walk04.wav",
	"monsters/brute/metal_walk05.wav",
	"monsters/brute/metal_walk06.wav",
	"monsters/brute/metal_walk07.wav",
	"monsters/brute/metal_walk08.wav",
}
ENT.SoundTbl_Run = {
	"monsters/brute/metal_run01.wav",
	"monsters/brute/metal_run02.wav",
	"monsters/brute/metal_run03.wav",
	"monsters/brute/metal_run04.wav",
	"monsters/brute/metal_run05.wav",
	"monsters/brute/metal_run06.wav",
	"monsters/brute/metal_run07.wav",
	"monsters/brute/metal_run08.wav",
}
ENT.SoundTbl_Idle = {
	"monsters/brute/amb_idle01.wav",
	"monsters/brute/amb_idle02.wav",
	"monsters/brute/amb_idle03.wav",
	"monsters/brute/amb_idle04.wav",
	"monsters/brute/amb_idle05.wav",
	"monsters/brute/amb_idle_scratch01.wav",
	"monsters/brute/amb_idle_scratch02.wav",
	"monsters/brute/amb_idle_scratch03.wav",
	"monsters/brute/amb_idle_scratch04.wav",
	"monsters/brute/amb_idle_whimp01.wav",
	"monsters/brute/amb_idle_whimp02.wav",
}
ENT.SoundTbl_CombatIdle = {
	"monsters/brute/amb_hunt01.wav",
	"monsters/brute/amb_hunt02.wav",
	"monsters/brute/amb_hunt03.wav",
}
ENT.SoundTbl_Alert = {
	"monsters/brute/enabled01.wav",
	"monsters/brute/enabled02.wav",
	"monsters/brute/enabled03.wav",
}
ENT.SoundTbl_Investigate = {
	"monsters/brute/amb_alert01.wav",
	"monsters/brute/amb_alert02.wav",
	"monsters/brute/amb_alert03.wav",
	"monsters/brute/notice01.wav",
	"monsters/brute/notice02.wav",
	"monsters/brute/notice_long01.wav",
	"monsters/brute/notice_long02.wav",
}
ENT.SoundTbl_NormalAttack = {
	"monsters/brute/attack_claw01.wav",
	"monsters/brute/attack_claw02.wav",
	"monsters/brute/attack_claw03.wav",
}
ENT.SoundTbl_LaunchAttack = {
	"monsters/brute/attack_launch01.wav",
	"monsters/brute/attack_launch02.wav",
	"monsters/brute/attack_launch03.wav",
}
ENT.SoundTbl_MeleeAttackExtra = {
	"monsters/brute/attack_claw_hit01.wav",
	"monsters/brute/attack_claw_hit02.wav",
	"monsters/brute/attack_claw_hit03.wav",
}

ENT.Enemy_Type = 0
ENT.Tracks = {
	[1] = "music/search_brute.wav",
	[2] = "music/att_brute.wav",
	[3] = "music/ui_terror_meter.wav",
}
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/