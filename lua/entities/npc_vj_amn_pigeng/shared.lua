ENT.Base 			= "npc_vj_amn_grunt"
ENT.Type 			= "ai"
ENT.PrintName 		= ""
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Purpose 		= "Spawn it and fight with it!"
ENT.Instructions 	= "Click on the spawnicon to spawn it."
ENT.Category		= ""

if CLIENT then
	function ENT:Initialize()
		self.tbl_ToStop = {}
		self.TrackLevel = 50
		self.Tracks = {
			[1] = "music/engineer_search.wav",
			[2] = "music/engineer_attack.wav",
			[3] = "music/ui_terror_meter.wav",
		}
	end

	function ENT:StartTrack(ent,track)
		ent.VJ_AmnesiaTrack = CreateSound(ent,self.Tracks[track])
		ent.VJ_AmnesiaTrack:SetSoundLevel(self.TrackLevel)
		ent.VJ_AmnesiaTrackEntity = self
		ent.VJ_AmnesiaTrackOST = self.Tracks[track]
		ent.VJ_AmnesiaTrackT = CurTime()
		ent.VJ_AmnesiaTrackSlot = track
		if !VJ_HasValue(self.tbl_ToStop,ent) then table.insert(self.tbl_ToStop,ent) end
	end
	
	function ENT:PlayTrack(ent,track)
		if ent.VJ_AmnesiaTrackSlot != nil && ent.VJ_AmnesiaTrackSlot != track then
			ent.VJ_AmnesiaTrack:Stop()
			self:StartTrack(ent,track)
		end
		if ent.VJ_AmnesiaTrack == nil then
			self:StartTrack(ent,track)
		end
		if CurTime() > ent.VJ_AmnesiaTrackT then
			ent.VJ_AmnesiaTrack:Stop()
			ent.VJ_AmnesiaTrack:Play()
			ent.VJ_AmnesiaTrackT = CurTime() +SoundDuration(self.Tracks[track])
		end
	end
	
	function ENT:MusicSystem(ent)
		if ent:GetNWInt("VJ_AmnesiaTrack") then
			self:PlayTrack(ent,ent:GetNWInt("VJ_AmnesiaTrack"))
		end
	end

	function ENT:Think()
		for _,v in pairs(player.GetAll()) do
			self:MusicSystem(v)
		end
	end

	function ENT:OnRemove()
		for _,v in pairs(self.tbl_ToStop) do
			v.VJ_AmnesiaTrack:Stop()
			v.VJ_AmnesiaTrackT = 0
			v.VJ_AmnesiaTrackSlot = 0
		end
	end
end