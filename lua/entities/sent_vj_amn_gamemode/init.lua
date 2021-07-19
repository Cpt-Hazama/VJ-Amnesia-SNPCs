AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

util.AddNetworkString("vj_amn_sound")
util.AddNetworkString("vj_amn_pick")

ENT.MaxMonsters = 7
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetPos(Entity(1):GetPos() +Vector(0,0,15))

	self:SetModel("models/props_junk/popcan01a.mdl")
	self:DrawShadow(false)
	self:SetNoDraw(true)
	self:SetNotSolid(true)
	for _,v in pairs(ents.FindByClass(self:GetClass())) do
		if IsValid(v) && v != self then
			PrintMessage(HUD_PRINTTALK,"Only one gamemode entity can be spawned at a time!")
			self:Remove()
			break
		end
	end
	if !navmesh then
		PrintMessage(HUD_PRINTTALK,"No Nav-Mesh detected! It is required for item/monster spawning!")
		self:Remove()
		return
	end

	self:SetNW2Int("ItemCount",0)
	self:SetNW2Int("MonsterCount",0)

	self.MonsterCount = math.Clamp(GetConVar("vj_amn_gm_count"):GetInt(),1,self.MaxMonsters)
	self.ItemCount = GetConVar("vj_amn_gm_itemcount"):GetInt()
	self.Threshold = math.Clamp(math.Round(self.ItemCount *0.1),1,self.ItemCount)
	self.Enhanced = false
	self.End = false
	self.Items = {}
	self.Monsters = {}
	self.MonsterClasses = {
		{Spawned = false, Class = "npc_vj_amn_kaernk"},
		{Spawned = false, Class = "npc_vj_amn_grunt"},
		{Spawned = false, Class = "npc_vj_amn_brute"},
		{Spawned = false, Class = "npc_vj_amn_suitor"},
		{Spawned = false, Class = "npc_vj_amn_pig"},
		{Spawned = false, Class = "npc_vj_amn_pigeng"},
		{Spawned = false, Class = "npc_vj_amn_pigtes"}
	}

	self:SetNW2Int("Remaining",self.ItemCount)

	for i = 1,self.ItemCount do
		local item = ents.Create("sent_vj_amn_item")
		item:SetPos(Amn_FindHiddenNavArea())
		item:Spawn()
		table.insert(self.Items,item)
		self:DeleteOnRemove(item)
		self:SetNW2Int("ItemCount",self:GetNW2Int("ItemCount") +1)
	end

	for i = 1,self.MonsterCount do
		local function PickMonster()
			local tbl = {}
			for i,v in pairs(self.MonsterClasses) do
				if v.Spawned == false then
					table.insert(tbl,v.Class)
				end
			end

			local selected = VJ_PICK(tbl)
			for _,v in pairs(self.MonsterClasses) do
				if v.Class == selected then
					v.Spawned = true
					break
				end
			end
			return selected
		end
		local selected = PickMonster()
		local monster = ents.Create(selected)
		if !IsValid(monster) then -- Kaernk probably couldn't spawn, try another monster
			monster = ents.Create(PickMonster())
		end
		local pos = Amn_FindHiddenNavArea(true,selected == "npc_vj_amn_kaernk")
		if pos == false then
			SafeRemoveEntity(monster)
			monster = ents.Create(PickMonster())
			pos = Amn_FindHiddenNavArea(true)
			if !IsValid(monster) then return end
		end
		monster:SetPos(pos)
		monster:SetAngles(Angle(0,math.random(0,360),0))
		monster:Spawn()
		monster.IdleAlwaysWander = true
		monster.VJ_NPC_Class = {"CLASS_AMNESIA_SERVANT"}
		table.insert(self.Monsters,monster)
		self:DeleteOnRemove(monster)
		self:SetNW2Int("MonsterCount",self:GetNW2Int("MonsterCount") +1)
		self:PlayerMsg("Monster " .. monster:GetName() .. " has appeared in the area!")
	end

	hook.Add("PlayerSpawn","VJ_Amn_PlayerSpawn",function(ply)
		if !IsValid(self) then
			hook.Remove("PlayerSpawn","VJ_Amn_PlayerSpawn")
			return
		end

		if ply:GetNW2Bool("Amn_Death") then
			local controlled = false
			for _,v in RandomPairs(self.Monsters) do
				if !v.VJ_IsBeingControlled then
					local obj = ents.Create("obj_vj_npccontroller")
					obj.VJCE_Player = ply
					obj:SetControlledNPC(v)
					obj:Spawn()
					obj:StartControlling()
					obj.VJC_Player_CanExit = false
					controlled = true
					break
				end
			end
			timer.Simple(0.02,function()
				if !controlled then
					local ent = VJ_PICK(self.Monsters)
					if !IsValid(ent) then
						for _,v in RandomPairs(player.GetAll()) do
							if v != ply then
								ent = v
								break
							end
						end
					end
					if !IsValid(ent) then return end
					ply:Spectate(ent:IsPlayer() && OBS_MODE_IN_EYE or OBS_MODE_CHASE)
					ply:SpectateEntity(ent)
					ply:StripWeapons()
					hook.Add("Think","Amn_Think",function()
						if !IsValid(ent) && IsValid(ply) then
							ply:KillSilent()
							ply:Respawn()
							hook.Remove("Think","Amn_Think")
						end
					end)
				end
			end)
		end
	end)

	hook.Add("PlayerDeath","VJ_Amn_PlayerDeath",function(ply)
		if !IsValid(self) then
			hook.Remove("PlayerDeath","VJ_Amn_PlayerDeath")
			for _,v in pairs(player.GetAll()) do
				v:SetNW2Bool("Amn_Death",false)
			end
			return
		end

		ply:SetNW2Bool("Amn_Death",true)
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayerNWSound(ply,snd)
    net.Start("vj_amn_sound")
		net.WriteString(snd)
    net.Send(ply)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayerMsg(msg)
	PrintMessage(HUD_PRINTTALK,msg)
	PrintMessage(HUD_PRINTCENTER,msg)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	local remaining = self:GetNW2Int("Remaining")
	local players_alive = 0
	for _,v in pairs(ents.GetAll()) do
		if (v:IsPlayer() && v:GetMoveType() != MOVETYPE_OBSERVER) or v.VJ_AmnesiaBot then
			if v:IsPlayer() then
				if math.random(1,2) == 1 then self:SetPos(v:GetPos()) end -- Prevent HUD from soft-locking
				v:StripWeapons()
				v:SetRunSpeed(v:GetWalkSpeed())
			end
			players_alive = players_alive +1
		end
	end

	if remaining <= self.Threshold && !self.Enhanced then
		for _,v in pairs(self.Monsters) do
			if IsValid(v) then
				v.FindEnemy_UseSphere = true
				v.FindEnemy_CanSeeThroughWalls = true
			end
		end
		self.Enhanced = true
	end

	if players_alive == 0 && !self.End then
		self:PlayerMsg("All Players have died, Monsters win!")
		self.End = true
		self:Remove()
	elseif remaining <= 0 && !self.End then
		self:PlayerMsg("All Artifacts have been found, Players win!")
		self.End = true
		self:Remove()
	end
	self:NextThink(CurTime() +0.01)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRemove()

end