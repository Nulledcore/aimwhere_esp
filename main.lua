local surface = require('gamesense/surface')
local font = surface.create_font("Verdana", 12, 800, 0x080)

local awhere = {
    toggle = ui.new_checkbox("lua", "a", "[Aimwhere V2] Enable"),
    box = ui.new_checkbox("lua", "a", "[Aimwhere V2] Box"),
    box_outline = ui.new_checkbox("lua", "a", "[Aimwhere V2] Box Outline"),
    healthstyle = ui.new_combobox("lua", "a", "[Aimwhere V2] Health", {"None", "Bar", "Text", "Both"}),
    name = ui.new_checkbox("lua", "a", "[Aimwhere V2] Show Name"),
    weapon = ui.new_checkbox("lua", "a", "[Aimwhere V2] Show Weapon"),
    headspot = ui.new_checkbox("lua", "a", "[Aimwhere V2] Headspot"),
    chams_team_check = ui.new_checkbox("lua", "a", "[Aimwhere V2] Team Chams"),
    xhair = ui.new_checkbox("lua", "a", "[Aimwhere V2] Xhair"),
}

local weapons = {
    [1] = "Desert Eagle",
    [2] = "Dual Berettas",
    [3] = "Five-SeveN",
    [4] = "Glock-18",
    [7] = "AK-47",
    [8] = "AUG",
    [9] = "AWP",
    [10] = "FAMAS",
    [11] = "G3SG1",
    [13] = "Galil AR",
    [14] = "M249",
    [16] = "M4A4",
    [17] = "MAC-10",
    [19] = "P90",
    [23] = "MP5-SD",
    [24] = "UMP-45",
    [25] = "XM1014",
    [26] = "PP-Bizon",
    [27] = "MAG-7",
    [28] = "Negev",
    [29] = "Sawed-Off",
    [30] = "Tec-9",
    [31] = "Taser",
    [32] = "P2000",
    [33] = "MP7",
    [34] = "MP9",
    [35] = "Nova",
    [36] = "P250",
    [38] = "SCAR-20",
    [39] = "SG 553",
    [40] = "SSG 08",
    [41] = "Knife",
    [42] = "Knife ct",
    [43] = "Flashbang",
    [44] = "HE Grenade",
    [45] = "Smoke",
    [46] = "Molotov",
    [47] = "Decoy",
    [48] = "Incendiary",
    [49] = "C4",
    [59] = "Knife t",
    [60] = "M4A1-S",
    [61] = "USP-S",
    [63] = "CZ75-Auto",
    [64] = "R8 Revolver",
    [500] = "Bayonet",
    [505] = "Flip Knife",
    [506] = "Gut Knife",
    [507] = "Karambit",
    [508] = "M9 Bayonet",
    [509] = "Huntsman Knife",
    [512] = "Falchion Knife",
    [514] = "Bowie Knife",
    [515] = "Butterfly Knife",
    [516] = "Shadow Daggers",
    [519] = "Ursus Knife",
    [520] = "Navaja Knife",
    [522] = "Siletto Knife",
    [523] = "Talon Knife",
}

local function localplayer()
    local real_lp = entity.get_local_player()
    if entity.is_alive(real_lp) then
        return real_lp
    else
        local obvserver = entity.get_prop(real_lp, "m_hObserverTarget")
        return obvserver ~= nil and obvserver <= 64 and obvserver or nil
    end
end

local function collect_players()
    local results = {}
    local lp_origin = {entity.get_origin(localplayer())}

    for i=1, 64 do
        if entity.is_alive(i) then
            local player_origin = {entity.get_origin(i)}
            if player_origin[1] ~= nil and lp_origin[1] ~= nil then
                table.insert(results, {i})
            end
        end
    end
    return results
end

local function HSVToRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
        elseif i == 1 then r, g, b = q, v, p
        elseif i == 2 then r, g, b = p, v, t
        elseif i == 3 then r, g, b = p, q, v
        elseif i == 4 then r, g, b = t, p, v
        elseif i == 5 then r, g, b = v, p, q
    end
  
    return r * 255, g * 255, b * 255
end

local function lerp(h1, s1, v1, h2, s2, v2, t)
    local h = (h2 - h1) * t + h1
    local s = (s2 - s1) * t + s1
    local v = (v2 - v1) * t + v1
    return h, s, v
end

local function vis_check(enemy, team)
    local hitbox_position = {entity.hitbox_position(enemy, "pelvis")}
    local eye_pos = {client.eye_position()}
    local fraction, v_hit = client.trace_line(entity.get_local_player(), eye_pos[1], eye_pos[2], eye_pos[3], hitbox_position[1], hitbox_position[2], hitbox_position[3])
    if (v_hit == enemy or fraction == 1) then
        if team == 3 then
            --print("3")
            return {50, 255, 50, 255}
            
        elseif team == 2 then
            --print("2")
            return {255, 200, 0, 255}

        end
    else
        if team == 3 then
            --print("3.1")
            return {0, 100, 255, 255}
        elseif team == 2 then
            --print("2.1")
            return {255, 50, 0, 255}
        end
    end
end

local function team_check(enemy)
    local return_clr
    if entity.get_prop(enemy, "m_iTeamNum") == 2 then
        return_clr = vis_check(enemy, 2)
    elseif entity.get_prop(enemy, "m_iTeamNum") == 3 then
        return_clr = vis_check(enemy, 3)
    end

    return return_clr
end

local function draw_main_esp()
    if not ui.get(awhere.toggle) then return end
    if ui.get(awhere.xhair) then
        local x,y = client.screen_size()
        renderer.rectangle(x/2-1, y/2, 1, 15, 255, 0, 0, 255)
        renderer.rectangle(x/2-1, y/2-15, 1, 25, 255, 0, 0, 255)
        renderer.rectangle(x/2, y/2, 15, 1, 255, 0, 0, 255)
        renderer.rectangle(x/2-15, y/2, 25, 1, 255, 0, 0, 255)

    
        renderer.rectangle(x/2-1, y/2, 1, 10, 255, 255, 255, 255)
        renderer.rectangle(x/2-1, y/2-10, 1, 10, 255, 255, 255, 255)
        renderer.rectangle(x/2, y/2, 10, 1, 255, 255, 255, 255)
        renderer.rectangle(x/2-10, y/2, 10, 1, 255, 255, 255, 255)

    end



    local enemies = collect_players()
    for i=1, #enemies do
        local enemy = unpack(enemies[i])
        if entity.is_enemy(enemy) then
            local bbox = {entity.get_bounding_box(enemy)}
            if bbox[1] ~= nil or bbox[2] ~= nil or bbox[3] ~= nil or bbox[4] ~= nil or bbox[5] ~= 0 then
                local height, width = bbox[4]-bbox[2], bbox[3]-bbox[1]
                if ui.get(awhere.box) then
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or team_check(enemy)
                    surface.draw_outlined_rect(bbox[1], bbox[2], width, height, color[1], color[2], color[3], 255)
                    if ui.get(awhere.box_outline) then
                        surface.draw_outlined_rect(bbox[1]-1, bbox[2]-1, width+2, height+2, 0,0,0,200)
                        surface.draw_outlined_rect(bbox[1]+1, bbox[2]+1, width-2, height-2, 0,0,0,200)
                    end
                end

                if ui.get(awhere.headspot) then
                    local head_spot = {entity.hitbox_position(enemy, 0)}
                    local x,y = renderer.world_to_screen(head_spot[1], head_spot[2], head_spot[3])
                    if x == nil or y == nil then return end
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {unpack(team_check(enemy))}
                    renderer.rectangle(x-1, y-1, 5, 5, 0, 0, 0, 200)
                    renderer.rectangle(x, y, 3, 3, color[1], color[2], color[3], color[4])
                end

                if ui.get(awhere.chams_team_check) then -- I was lazy to write another method lol
                    local _, vis_cham_clr = ui.reference("visuals", "colored models", "player")
                    local _, invis_cham_clr = ui.reference("visuals", "colored models", "player behind wall")
                    local return_vis_clr
                    local return_invis_clr
                    if entity.get_prop(enemy, "m_iTeamNum") == 2 then
                        return_vis_clr = {255, 200, 0, 255}
                        return_invis_clr = {255, 50, 0, 255}
                    elseif entity.get_prop(enemy, "m_iTeamNum") == 3 then
                        return_vis_clr = {50, 255, 50, 255}
                        return_invis_clr = {0, 100, 255, 255}
                    end
                    ui.set(vis_cham_clr, return_vis_clr[1], return_vis_clr[2], return_vis_clr[3], return_vis_clr[4])
                    ui.set(invis_cham_clr, return_invis_clr[1], return_invis_clr[2], return_invis_clr[3], return_invis_clr[4])
                end

                if ui.get(awhere.healthstyle) then
                    local health = entity.get_prop(enemy, "m_iHealth")
                    local h, s, v = lerp(0, 1, 1, 120, 1, 1, health*0.01)
                    local hr, hg, hb = HSVToRGB(h/360, s, v)
                    local health_color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {hr, hg, hb, 255}
                    if ui.get(awhere.healthstyle) == "Bar" or ui.get(awhere.healthstyle) == "Both" then
                        renderer.rectangle(bbox[1]-6, bbox[2]-1, 4, height+2, 17, 17, 17, 200)
                        renderer.rectangle(bbox[1]-5, bbox[2]+height, 2, -(height*health/100), health_color[1], health_color[2], health_color[3], 255)
                    end
                    if ui.get(awhere.healthstyle) == "Text" or ui.get(awhere.healthstyle) == "Both" then
                        local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 255, 255, 255}
                        surface.draw_text(bbox[1]-(ui.get(awhere.healthstyle) == "Both" and (health < 99 and (health < 10 and 31 or 37) or 45) or (health < 99 and (health < 10 and 28 or 32) or 40)), bbox[2], color[1], color[2], color[3], 255, font, string.format("%s HP", health))
                    end
                end


                if ui.get(awhere.name) then
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 255, 255, 255}
                    local name = entity.get_player_name(enemy)
                    if name == nil then return end
                    if name:len() > 15 then 
                        name = name:sub(0, 15)
                    end
                    local wide, tall = surface.get_text_size(font, name)
                    surface.draw_text(bbox[1] - wide / 2 + (width/2), bbox[2]-16, color[1], color[2], color[3], 255, font, name)
                end

                if ui.get(awhere.weapon) then
                    local weapon_id = entity.get_prop(enemy, "m_hActiveWeapon")
                    if entity.get_prop(weapon_id, "m_iItemDefinitionIndex") ~= nil then
                        weapon_item_index = bit.band(entity.get_prop(weapon_id, "m_iItemDefinitionIndex"), 0xFFFF)
                    end
                    local weapon_name = weapons[weapon_item_index]
                    if weapon_name == nil then return end
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 255, 255, 255}
                    if weapon_name:len() > 15 then 
                        weapon_name = weapon_name:sub(0, 15)
                    end
                    local wide, tall = surface.get_text_size(font, weapon_name:lower())
                    surface.draw_text(bbox[1] - wide / 2 + (width/2), bbox[4]+2, color[1], color[2], color[3], 255, font, weapon_name:lower())
                    local player_resource = entity.get_all("CCSPlayerResource")[1]
                    if player_resource == nil then end
                    local c4_holder = entity.get_prop(player_resource, "m_iPlayerC4")
                    if c4_holder == enemy and not weapon_item_index == 49 then
                        local wide, tall = surface.get_text_size(font, "c4")
                        surface.draw_text(bbox[1] + (width/2) - wide, bbox[4]+12, color[1], color[2], color[3], 255, font, "c4")
                    end
                end

            end
        end
    end
end

client.set_event_callback("paint", function()
    if localplayer() == nil then
        return
    end
    draw_main_esp()
end)
