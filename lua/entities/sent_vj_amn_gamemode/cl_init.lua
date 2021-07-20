include('shared.lua')

if SERVER then return end

net.Receive("vj_amn_sound",function(len,ply)
	local ply = net.ReadEntity()
	local snd = net.ReadString()
	if IsValid(ply) then ply:EmitSound(snd) end
end)

surface.CreateFont("VJ_Amnesia",{
	font = "The Black Bible",
	size = 40,
})

ENT.PlayerMusic = {}

function ENT:Initialize()
	hook.Add("HUDPaint","VJ_Amnesia_HUD",function()
		if !IsValid(self) then
			hook.Remove("HUDPaint","VJ_Amnesia_HUD")
			return
		end

		local ply = LocalPlayer()

		local monsters = self:GetNW2Int("MonsterCount")
		local items = self:GetNW2Int("ItemCount")
		local remaining = self:GetNW2Int("Remaining")
		local players = 0
		local players_alive = 0
		for _,v in pairs(ents.GetAll()) do
			if v:IsPlayer() or v.VJ_AmnesiaBot then
				players = players +1
				if (v:IsPlayer() && v:GetMoveType() != MOVETYPE_OBSERVER) or v.VJ_AmnesiaBot then
					if v:IsPlayer() && GetConVar("ai_ignoreplayers"):GetInt() == 1 then continue end
					players_alive = players_alive +1
				end
			end
		end

		local smooth = 8
		local bposX = 10
		local bposY = 10
		local bX = 270
		local bY = 120
		draw.RoundedBox(smooth,bposX,bposY,bX,bY,Color(0,0,0,200))

		draw.SimpleText("Monsters - " .. monsters,"VJ_Amnesia",bposX +10,bposY +5,Color(255,0,0))
		draw.SimpleText("Artifacts - " .. remaining .. "/" .. items,"VJ_Amnesia",bposX +10,bposY +40,Color(192,189,0))
		draw.SimpleText("Players - " .. players_alive .. "/" .. players,"VJ_Amnesia",bposX +10,bposY +75,Color(0,163,192))
	end)
end

function ENT:Draw()
	return false
end

function ENT:OnRemove()
	for _,v in pairs(self.PlayerMusic) do
		if v.Music then
			v.Music:Stop()
		end
	end
end

function ENT:Think()
	for _,v in pairs(player.GetAll()) do
		local found = false
		for _,ply in pairs(self.PlayerMusic) do
			if ply.Player == v then
				found = true
				break
			end
		end
		if !found then
			local index = #self.PlayerMusic +1
			self.PlayerMusic[index] = {Player = v,Music = nil}
			sound.PlayFile("sound/music/background.mp3","noplay noblock",function(soundchannel,errorID,errorName)
				if IsValid(soundchannel) then
					soundchannel:Play()
					soundchannel:EnableLooping(true)
					soundchannel:SetVolume(0.7)
					soundchannel:SetPlaybackRate(1)
					self.PlayerMusic[index].Music = soundchannel
				end
			end)
		end
	end
end