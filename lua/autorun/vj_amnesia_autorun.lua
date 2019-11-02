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

	local vCat = "Amnesia: The Dark Descent"
	VJ.AddNPC("Kaernk","npc_vj_amn_kaernk",vCat)
	VJ.AddNPC("Servant Grunt","npc_vj_amn_grunt",vCat)
	VJ.AddNPC("Servant Brute","npc_vj_amn_brute",vCat)
	VJ.AddNPC("Suitor","npc_vj_amn_suitor",vCat)

	VJ.AddNPC("Pigman Wretch","npc_vj_amn_pig",vCat)
	VJ.AddNPC("Pigman Engineer","npc_vj_amn_pigeng",vCat)
	VJ.AddNPC("Pigman Tesla","npc_vj_amn_pigtes",vCat)

	VJ.AddParticle("particles/door_explosion.pcf",{"door_pound_core","door_exposion_chunks"})
	
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
