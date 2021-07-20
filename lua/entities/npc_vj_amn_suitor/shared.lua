ENT.Base 			= "npc_vj_amn_grunt"
ENT.Type 			= "ai"
ENT.PrintName 		= ""
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Purpose 		= "Spawn it and fight with it!"
ENT.Instructions 	= "Click on the spawnicon to spawn it."
ENT.Category		= ""

if CLIENT then
	net.Receive("vj_amn_hud_blind",function(len,pl)
		local delete = net.ReadBool()
		local ent = net.ReadEntity()
		if !IsValid(ent) then delete = true end

		hook.Add("RenderScreenspaceEffects","VJ_Amn_HUDBlind_ScreenSpace",function()
			local tab = {
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 1,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 0.4,
                ["$pp_colour_colour"] = 0.1,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 1
			}
			DrawColorModify(tab)
		end)
		if delete == true then hook.Remove("RenderScreenspaceEffects","VJ_Amn_HUDBlind_ScreenSpace") end

		hook.Add("PreDrawHalos","VJ_Amn_HUDBlind_Halo",function()
            if IsValid(ent) then
                local tbEnemies = {}
                for _,v in SortedPairs(ents.GetAll()) do
                    if v:IsNPC() or v:IsPlayer() then
                        if v:IsNPC() && v.VJ_AmnesiaMonster then continue end
                        if v:GetVelocity():Length() > 0 && v:GetPos():Distance(ent:GetPos()) <= 725 then
                            if v:GetClass() != "obj_vj_bullseye" then
                                table.insert(tbEnemies,v)
                                v:SetNoDraw(false)
                            end
                        else
                            v:SetNoDraw(true)
                        end
                    end
                end
                for i,v in SortedPairs(tbEnemies) do
                    if v:GetVelocity():Length() <= 0 then
                        table.remove(tbEnemies,i)
                    end
                end
                halo.Add(tbEnemies,Color(255,0,0),4,4,3,true,true)
            end
		end)
		if delete == true then hook.Remove("PreDrawHalos","VJ_Amn_HUDBlind_Halo") end
	end)
end