/*--------------------------------------------------
	=============== Autorun File ===============
	*** Copyright (c) 2012-2018 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
------------------ Addon Information ------------------
local PublicAddonName = "Amneisa SNPCs"
local AddonName = "Amneisa"
local AddonType = "SNPC"
local AutorunFile = "autorun/vj_amnesia_autorun.lua"
-------------------------------------------------------

local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua","GAME")
if VJExists == true then
	include('autorun/vj_controls.lua')

	VJ_AMN_TRACKS = {
		[1] = {
			{Class="npc_vj_amn_grunt",Track="music/search_grunt.wav"},
			{Class="npc_vj_amn_brute",Track="music/search_brute.wav"},
			{Class="npc_vj_amn_suitor",Track="music/search_suitor.wav"},
			{Class="npc_vj_amn_kaernk",Track=false},
			{Class="npc_vj_amn_pig",Track="music/wretch_search.wav"},
			{Class="npc_vj_amn_pigeng",Track="music/engineer_search.wav"},
			{Class="npc_vj_amn_pigtes",Track="music/tesla_search.wav"}
		},
		[2] = {
			{Class="npc_vj_amn_grunt",Track="music/att_grunt.wav"},
			{Class="npc_vj_amn_brute",Track="music/att_brute.wav"},
			{Class="npc_vj_amn_suitor",Track="music/att_suitor.wav"},
			{Class="npc_vj_amn_kaernk",Track="music/att_kaernk.wav"},
			{Class="npc_vj_amn_pig",Track="music/wretch_attack.wav"},
			{Class="npc_vj_amn_pigeng",Track="music/engineer_attack.wav"},
			{Class="npc_vj_amn_pigtes",Track="music/tesla_attack.wav"}
		}
	}

	function Amn_GetTrack(class,id)
		for _,v in pairs(VJ_AMN_TRACKS[id]) do
			if v && v.Class == class then
				return v.Track
			end
		end
		return false
	end

	if CLIENT then
		hook.Add("PlayerDeath","VJ_AmnSpawnMusic",function(ply)
			if ply.VJ_AmnesiaTracks then
				for _,v in SortedPairs(ply.VJ_AmnesiaTracks) do
					if v && IsValid(v.channel) then
						v.channel:Stop()
					end
				end
			end
			table.Empty(self.VJ_AmnesiaTracks)
		end)

		hook.Add("Think","VJ_AmnThink",function()
			local ply = LocalPlayer()
			if ply.VJ_AmnesiaTracks == nil or #ply.VJ_AmnesiaTracks <= 0 then
				ply.VJ_AmnesiaTracks = {}

				local function CreateTrack(song,ID,class)
					if song == false or song == nil then print("Song was false") return end
					sound.PlayFile("sound/" .. song,"noplay noblock",function(soundchannel,errorID,errorName)
						if IsValid(soundchannel) then
							soundchannel:Play()
							soundchannel:EnableLooping(true)
							soundchannel:SetVolume(0)
							soundchannel:SetPlaybackRate(1)
							-- print("Added " .. #ply.VJ_AmnesiaTracks)
							table.insert(ply.VJ_AmnesiaTracks,{ID=ID,class=class,channel=soundchannel})
						end
					end)
				end

				local class = "npc_vj_amn_grunt"
				CreateTrack(Amn_GetTrack(class,1),1,class)
				CreateTrack(Amn_GetTrack(class,2),2,class)

				local class = "npc_vj_amn_brute"
				CreateTrack(Amn_GetTrack(class,1),1,class)
				CreateTrack(Amn_GetTrack(class,2),2,class)

				local class = "npc_vj_amn_suitor"
				CreateTrack(Amn_GetTrack(class,1),1,class)
				CreateTrack(Amn_GetTrack(class,2),2,class)

				local class = "npc_vj_amn_kaernk"
				CreateTrack(Amn_GetTrack(class,1),1,class)
				CreateTrack(Amn_GetTrack(class,2),2,class)

				local class = "npc_vj_amn_pig"
				CreateTrack(Amn_GetTrack(class,1),1,class)
				CreateTrack(Amn_GetTrack(class,2),2,class)

				local class = "npc_vj_amn_pigeng"
				CreateTrack(Amn_GetTrack(class,1),1,class)
				CreateTrack(Amn_GetTrack(class,2),2,class)

				local class = "npc_vj_amn_pigtes"
				CreateTrack(Amn_GetTrack(class,1),1,class)
				CreateTrack(Amn_GetTrack(class,2),2,class)
			end

			local function StopTrack(song,vol)
				if vol then
					if IsValid(song) && song:GetState() == 1 then
						song:SetVolume(0)
					end
					return
				end
				song:Stop()
			end

			ply.VJ_AmnesiaTracks = ply.VJ_AmnesiaTracks or {}
			ply.VJ_AmnesiaTrack = ply.VJ_AmnesiaTrack or NULL
			ply.VJ_AmnesiaTrackID = ply.VJ_AmnesiaTrackID or 0
			ply.VJ_AmnesiaTrackLastID = ply.VJ_AmnesiaTrackLastID or -1
			ply.VJ_AmnesiaTrackEntity = ply.VJ_AmnesiaTrackEntity or NULL
			ply.VJ_AmnesiaTrackEntityResetT = ply.VJ_AmnesiaTrackEntityResetT or 0

			if !IsValid(ply.VJ_AmnesiaTrackEntity) or CurTime() > ply.VJ_AmnesiaTrackEntityResetT then
				ply.VJ_AmnesiaTrackID = 0
				ply.VJ_AmnesiaTrackLastID = -1
				ply:SetNW2Int("VJ_AmnesiaTrack",0)
				if IsValid(ply.VJ_AmnesiaTrack) && ply.VJ_AmnesiaTrack:GetState() == 1 then
					ply.VJ_AmnesiaTrack:SetVolume(0)
				end
				for _,v in RandomPairs(ents.FindByClass("npc_vj_amn_*")) do
					if v.VJ_AmnesiaMonster && v:GetNW2Entity("Enemy") == ply then
						ply.VJ_AmnesiaTrackEntity = v
						ply.VJ_AmnesiaTrackEntityResetT = CurTime() +25
						break
					end
				end
			end

			local ent = ply.VJ_AmnesiaTrackEntity
			local enemy = IsValid(ent) && ent:GetNW2Entity("Enemy")
			local trackID = ply:GetNW2Int("VJ_AmnesiaTrack")
			if IsValid(ent) && enemy == ply then
				ply.VJ_AmnesiaTrackEntityResetT = CurTime() +25
			end

			if ply.VJ_AmnesiaTrackID != trackID && trackID != ply.VJ_AmnesiaTrackLastID then
				ply.VJ_AmnesiaTrackLastID = ply.VJ_AmnesiaTrackID
				ply.VJ_AmnesiaTrackID = trackID
				if IsValid(ply.VJ_AmnesiaTrack) && ply.VJ_AmnesiaTrack:GetState() == 1 then
					ply.VJ_AmnesiaTrack:SetVolume(0)
				end
				if trackID == 0 then
					return
				end
				for _,v in ipairs(ply.VJ_AmnesiaTracks) do
					if v.class == ent:GetClass() && v.ID == trackID && IsValid(v.channel) then
						v.channel:SetVolume(0.75)
						ply.VJ_AmnesiaTrack = v.channel
						break
					end
				end
			end
		end)
	end

	local vCat = "Amnesia: The Dark Descent"
	VJ.AddNPC("(Gamemode) Artifact Mode","sent_vj_amn_gamemode",vCat)
	VJ.AddNPC("(Gamemode) Bot","npc_vj_amn_bot",vCat)

	VJ.AddNPC("Kaernk","npc_vj_amn_kaernk",vCat)
	VJ.AddNPC("Servant Grunt","npc_vj_amn_grunt",vCat)
	VJ.AddNPC("Servant Brute","npc_vj_amn_brute",vCat)
	VJ.AddNPC("Suitor","npc_vj_amn_suitor",vCat)

	VJ.AddNPC("Pigman Wretch","npc_vj_amn_pig",vCat)
	VJ.AddNPC("Pigman Engineer","npc_vj_amn_pigeng",vCat)
	VJ.AddNPC("Pigman Tesla","npc_vj_amn_pigtes",vCat)

	VJ.AddParticle("particles/door_explosion.pcf",{"door_pound_core","door_exposion_chunks"})

	function Amn_FindHiddenNavArea(trCheck,water)
		local tbl = {}
		if !navmesh then return tbl end
		local function VisToPlayers(area)
			for _,v in pairs(player.GetAll()) do
				if area:IsVisible(v:EyePos()) then
					return true
				end
			end
			return false
		end
		local navAreas = navmesh.GetAllNavAreas()
		for _,v in pairs(navAreas) do
			if !IsValid(v) then continue end
			if VisToPlayers(v) then continue end
			if water && !v:IsUnderwater() then continue end
			for _,vec in pairs(v:GetHidingSpots()) do
				if trCheck then
					local tr = util.TraceHull({
						start = vec,
						endpos = vec +Vector(0,0,82),
						obbmins = Vector(-18,-18,0),
						obbmaxs = Vector(18,18,82)
					})
					if tr.Hit then continue end
				end
				table.insert(tbl,vec)
			end
		end
		return VJ_PICK(tbl)
	end

	function Amn_FindRandomNavArea()
		local tbl = {}
		if !navmesh then return tbl end
		local navAreas = navmesh.GetAllNavAreas()
		for _,v in pairs(navAreas) do
			if !IsValid(v) then continue end
			for _,vec in pairs(v:GetHidingSpots()) do
				table.insert(tbl,vec)
			end
		end
		return VJ_PICK(tbl)
	end

	VJ.AddConVar("vj_amn_gm_count", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
	VJ.AddConVar("vj_amn_gm_itemcount", 8, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
	
-- !!!!!! DON'T TOUCH ANYTHING BELOW THIS !!!!!! -------------------------------------------------------------------------------------------------------------------------
	AddCSLuaFile(AutorunFile)
	VJ.AddAddonProperty(AddonName,AddonType)
else
	if (CLIENT) then
		chat.AddText(Color(0,200,200),PublicAddonName,
		Color(0,255,0)," was unable to install, you are missing ",
		Color(255,100,0),"VJ Base!")
	end
	timer.Simple(1,function()
		if not VJF then
			if (CLIENT) then
				VJF = vgui.Create("DFrame")
				VJF:SetTitle("ERROR!")
				VJF:SetSize(790,560)
				VJF:SetPos((ScrW()-VJF:GetWide())/2,(ScrH()-VJF:GetTall())/2)
				VJF:MakePopup()
				VJF.Paint = function()
					draw.RoundedBox(8,0,0,VJF:GetWide(),VJF:GetTall(),Color(200,0,0,150))
				end

				local VJURL = vgui.Create("DHTML",VJF)
				VJURL:SetPos(VJF:GetWide()*0.005, VJF:GetTall()*0.03)
				VJURL:Dock(FILL)
				VJURL:SetAllowLua(true)
				VJURL:OpenURL("https://sites.google.com/site/vrejgaming/vjbasemissing")
			elseif (SERVER) then
				timer.Create("VJBASEMissing",5,0,function() print("VJ Base is Missing! Download it from the workshop!") end)
			end
		end
	end)
end
