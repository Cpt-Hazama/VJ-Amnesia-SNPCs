/*--------------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
AddCSLuaFile()
if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end

ENT.Base 			= "base_gmodentity"
ENT.Type 			= "anim"
ENT.PrintName 		= "Gamemode Item"
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Purpose 		= "Gives a lot of health when taken."
ENT.Instructions 	= "Don't change anything."
ENT.Category		= "VJ Base - Amnesia"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.VJ_AmnesiaItem = true
---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end

function ENT:Initialize()
	self:SetModel(VJ_PICK({"models/props_junk/glassjug01.mdl","models/Gibs/HGIBS.mdl","models/props_c17/doll01.mdl","models/props_c17/lamp001a.mdl","models/props_junk/Shoe001a.mdl"}))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	-- timer.Simple(0.1,function() self:SetPos(Entity(1):GetPos() + Vector(0,0,15)) end)
	self:SetPos(self:GetPos() +Vector(0,0,(self:GetModel() == "models/props_c17/lamp001a.mdl" && 10 or 1)))
	self:SetMaterial("models/XQM/LightLinesRed_tool")

	self.Loop = CreateSound(self,"ambient/atmosphere/ambience6.wav")
	self.Loop:SetSoundLevel(60)
	self.Loop:Play()

	local StartLight1 = ents.Create("light_dynamic")
	StartLight1:SetKeyValue("brightness", "1")
	StartLight1:SetKeyValue("distance", "75")
	StartLight1:SetKeyValue("style", 5)
	StartLight1:SetLocalPos(self:GetPos() +self:OBBCenter())
	StartLight1:SetLocalAngles(self:GetAngles())
	StartLight1:Fire("Color", "255 0 0")
	StartLight1:SetParent(self)
	StartLight1:Spawn()
	StartLight1:Activate()
	StartLight1:SetParent(self)
	StartLight1:Fire("TurnOn", "", 0)
	self:DeleteOnRemove(StartLight1)
	
	local phys = self:GetPhysicsObject()
	if phys and IsValid(phys) then
		phys:Wake()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PhysicsCollide(data, physobj)
	self:EmitSound("physics/cardboard/cardboard_box_impact_soft"..math.random(1,5)..".wav")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Use(activator, caller)
	self:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1,7) .. ".wav", 65, 80)
	for _,v in pairs(ents.FindByClass("sent_vj_amn_gamemode")) do
		if IsValid(v) then
			v:SetNW2Int("Remaining",v:GetNW2Int("Remaining") -1)
			PrintMessage(HUD_PRINTCENTER,"An artifact has been picked up! " .. v:GetNW2Int("Remaining") .. "/" .. v:GetNW2Int("ItemCount") .. " artifacts remaining.")
			break
		end
	end
	for _,v in RandomPairs(ents.FindInSphere(self:GetPos(), 500)) do
		if v.VJ_AmnesiaMonster && !IsValid(v:GetEnemy()) then
			v:SetLastPosition(self:GetPos())
			v:VJ_TASK_GOTO_LASTPOS("TASK_WALK_PATH")
			VJ_EmitSound(v,v.SoundTbl_Alert,85,100)
			break -- Only force one to come investigate (balancing purposes)
		end
	end
	if activator:IsPlayer() then
		net.Start("vj_amn_sound")
			net.WriteEntity(activator)
			net.WriteString("monsters/grunt/enabled01.wav")
		net.Send(activator)
	end

	self:Remove()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTakeDamage(dmginfo)
	self:GetPhysicsObject():AddVelocity(dmginfo:GetDamageForce() * 0.1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRemove()
	self.Loop:Stop()
end