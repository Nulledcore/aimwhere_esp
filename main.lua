local surface = require('gamesense/surface')
local font = surface.create_font("Tahoma", 13, 800, 0x080)

local aw = {
    toggle = ui.new_checkbox("lua", "a", "[AW] Enable"),
    box = ui.new_checkbox("lua", "a", "[AW] Box"),
    box_outline = ui.new_checkbox("lua", "a", "[AW] Box Outline"),
    healthstyle = ui.new_combobox("lua", "a", "[AW] Health", {"None", "Bar", "Number", "Both"}),
    name = ui.new_checkbox("lua", "a", "[AW] Show Name"),
    weapon = ui.new_combobox("lua", "a", "[AW] Show Weapon + ammo", {"None", "Bar", "Number", "Both"}),
    headspot = ui.new_checkbox("lua", "a", "[AW] Headspot"),
    chams_team_check = ui.new_checkbox("lua", "a", "[AW] Team Chams"),
    xhair = ui.new_checkbox("lua", "a", "[AW] Xhair"),
    conditions = ui.new_checkbox("lua", "a", "[AW] Scoped condition"),
}

local weapons = {
    [1] = "DEagle",
    [2] = "Elite",
    [3] = "FiveseveN",
    [4] = "Glock",
    [7] = "AK47",
    [8] = "AUG",
    [9] = "AWP",
    [10] = "FAMAS",
    [11] = "G3SG1",
    [13] = "GalilAR",
    [14] = "M249",
    [16] = "M4A4",
    [17] = "MAC10",
    [19] = "P90",
    [23] = "MP5SD",
    [24] = "UMP45",
    [25] = "XM1014",
    [26] = "PPBizon",
    [27] = "MAG7",
    [28] = "Negev",
    [29] = "SawedOff",
    [30] = "Tec9",
    [31] = "Taser",
    [32] = "Hkp2000",
    [33] = "MP7",
    [34] = "MP9",
    [35] = "Nova",
    [36] = "P250",
    [38] = "SCAR20",
    [39] = "SG553",
    [40] = "SSG08",
    [41] = "Knife",
    [42] = "Knife ct",
    [43] = "Flashbang",
    [44] = "HEGrenade",
    [45] = "Smokegrenade",
    [46] = "Molotov",
    [47] = "Decoy",
    [48] = "Incgrenade",
    [49] = "C4",
    [59] = "Knife t",
    [60] = "M4a1 silencer",
    [61] = "Usp silencer",
    [63] = "CZ75auto",
    [64] = "Revolver",
    [500] = "knife Bayonet",
    [505] = "knife Flip Knife",
    [506] = "knife Gut Knife",
    [507] = "knife Karambit",
    [508] = "knife M9 Bayonet",
    [509] = "knife Huntsman Knife",
    [512] = "knife Falchion Knife",
    [514] = "knife Bowie Knife",
    [515] = "knife Butterfly Knife",
    [516] = "knife Shadow Daggers",
    [519] = "knife Ursus Knife",
    [520] = "knife Navaja Knife",
    [522] = "knife Stiletto Knife",
    [523] = "knife Talon Knife",
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

local ammo = {
    [1] = 7, -- Deagle
    [2] = 30, -- Duals
    [3] = 20, -- five seven
    [4] = 20, -- glock
    [7] = 30, -- ak
    [8] = 30, -- aug
    [9] = 10,  -- awp
    [10] = 25, -- famas
    [11] = 20, -- t auto
    [13] = 35, -- galil
    [14] = 100, -- ms249
    [16] = 30, -- m4a4
    [17] = 30,-- mac 10
    [19] = 50,-- p90
    [23] = 30, -- mp5-sd
    [24] = 25,-- ump
    [25] = 7,-- xm1014
    [26] = 64,-- bizon
    [27] = 5,-- mag7
    [28] = 150, -- negev
    [29] = 7, -- sawed off
    [30] = 18, -- tec9
    [32] = 13, -- p2k
    [33] = 30, -- mp7
    [34] = 30, -- mp9
    [35] = 8, -- nova
    [36] = 13, -- p250
    [38] = 20, -- ct auto
    [39] = 30, -- sg553
    [40] = 10, -- scout
    [60] = 20, -- m4a1s
    [61] = 12, -- usps
    [63] = 12, -- cz75
    [64] = 8, -- revolvo
}

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
    if not ui.get(aw.toggle) then return end
    if ui.get(aw.xhair) then
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
                if ui.get(aw.box) then
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or team_check(enemy)
                    surface.draw_outlined_rect(bbox[1], bbox[2], width, height, color[1], color[2], color[3], 255)
                    if ui.get(aw.box_outline) then
                        surface.draw_outlined_rect(bbox[1]-1, bbox[2]-1, width+2, height+2, 0,0,0,175)
                        surface.draw_outlined_rect(bbox[1]+1, bbox[2]+1, width-2, height-2, 0,0,0,175)
                    end
                end

                if ui.get(aw.headspot) then
                    local head_spot = {entity.hitbox_position(enemy, 0)}
                    local x,y = renderer.world_to_screen(head_spot[1], head_spot[2], head_spot[3])
                    if x == nil or y == nil then return end
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {unpack(team_check(enemy))}
                    renderer.rectangle(x-1, y-1, 5, 5, 0, 0, 0, 175)
                    renderer.rectangle(x, y, 3, 3, color[1], color[2], color[3], color[4])
                end

                if ui.get(aw.chams_team_check) then -- I was lazy to write another method lol
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

                if ui.get(aw.healthstyle) then
                    local health = entity.get_prop(enemy, "m_iHealth")
                    local h, s, v = lerp(0, 1, 1, 120, 1, 1, health*0.01)
                    local hr, hg, hb = HSVToRGB(h/360, s, v)
                    local health_color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {hr, hg, hb, 255}
                    if ui.get(aw.healthstyle) == "Bar" or ui.get(aw.healthstyle) == "Both" then
                        renderer.rectangle(bbox[1]-6, bbox[2]-1, 4, height+2, 17, 17, 17, 175)
                        renderer.rectangle(bbox[1]-5, bbox[2]+height, 2, -(height*health/100), health_color[1], health_color[2], health_color[3], 255)
                    end
                    if ui.get(aw.healthstyle) == "Number" or ui.get(aw.healthstyle) == "Both" then
                        local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 255, 255, 255}
                        surface.draw_text(bbox[1]-(ui.get(aw.healthstyle) == "Both" and (health < 99 and (health < 10 and 34 or 40) or 48) or (health < 99 and (health < 10 and 28 or 34) or 42)), bbox[2], color[1], color[2], color[3], 255, font, string.format("%s HP", health))
                    end
                end

                if ui.get(aw.conditions) then
                    if entity.get_prop(enemy, "m_bIsScoped") ~= 0 then
                        local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 255, 0, 255}
                        local wide, tall = surface.get_text_size(font, "Scoped")
                        surface.draw_text(bbox[1] + (width/2)-wide/2, bbox[2]-(ui.get(aw.name) and 28 or 16), color[1], color[2], color[3], 255, font, "Scoped")
                    end
                end
                if ui.get(aw.name) then
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 255, 255, 255}
                    local name = entity.get_player_name(enemy)
                    if name == nil then return end
                    if name:len() > 15 then 
                        name = name:sub(0, 15)
                    end
                    local wide, tall = surface.get_text_size(font, name)
                    surface.draw_text(bbox[1] - wide / 2 + (width/2), bbox[2]-16, color[1], color[2], color[3], 255, font, name)
                end

                if ui.get(aw.weapon) then
                    local weapon_id = entity.get_prop(enemy, "m_hActiveWeapon")
                    if entity.get_prop(weapon_id, "m_iItemDefinitionIndex") ~= nil then
                        weapon_item_index = bit.band(entity.get_prop(weapon_id, "m_iItemDefinitionIndex"), 0xFFFF)
                    end
                    
                    local enemy_weapon = entity.get_player_weapon(enemy)
                    local current_ammo = entity.get_prop(enemy_weapon, "m_iClip1") or -1
                    local total_ammo = entity.get_prop(enemy_weapon, "m_iPrimaryReserveAmmoCount") or 0

                    if ui.get(aw.weapon) == "Number" or ui.get(aw.weapon) == "Both" then
                        local weapon_name = weapons[weapon_item_index]
                        if weapon_name == nil then return end
                        local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {255, 255, 255, 255}
                        if weapon_name:len() > 15 then 
                            weapon_name = weapon_name:sub(0, 15)
                        end

                        if (weapon_item_index == 31 or weapon_item_index == 41 or weapon_item_index == 42 or weapon_item_index == 43 or weapon_item_index == 44 or weapon_item_index == 45 or weapon_item_index == 46 or weapon_item_index == 47 or weapon_item_index == 48 or weapon_item_index == 49 or weapon_item_index == 59 or weapon_item_index >= 500) then
                            local wide, tall = surface.get_text_size(font, weapon_name:lower())
                            surface.draw_text(bbox[1] - wide / 2 + (width/2), bbox[4]+(ui.get(aw.weapon) == "Both" and ((weapon_item_index == 31 or weapon_item_index == 41 or weapon_item_index == 42 or weapon_item_index == 43 or weapon_item_index == 44 or weapon_item_index == 45 or weapon_item_index == 46 or weapon_item_index == 47 or weapon_item_index == 48 or weapon_item_index == 49 or weapon_item_index == 59 or weapon_item_index >= 500) and 2 or 6) or 2), color[1], color[2], color[3], 255, font, weapon_name:lower())
                        else
                            local wide, tall = surface.get_text_size(font, string.format("%s (%s/%s)", weapon_name:lower(), current_ammo, total_ammo))
                            surface.draw_text(bbox[1] - wide / 2 + (width/2), bbox[4]+(ui.get(aw.weapon) == "Both" and 6 or 2), color[1], color[2], color[3], 255, font, string.format("%s (%s/%s)", weapon_name:lower(), current_ammo, total_ammo))
                        end
    
                    end
                
                    if ui.get(aw.weapon) == "Bar" or ui.get(aw.weapon) == "Both" then
                        if not (weapon_item_index == 31 or weapon_item_index == 41 or weapon_item_index == 42 or weapon_item_index == 43 or weapon_item_index == 44 or weapon_item_index == 45 or weapon_item_index == 46 or weapon_item_index == 47 or weapon_item_index == 48 or weapon_item_index == 49 or weapon_item_index == 59 or weapon_item_index >= 500) then
                            local max_ammo = ammo[weapon_item_index] or 0
                            local ammo_percentage = math.min(1, max_ammo == 0 and 1 or current_ammo/max_ammo)
                            local bar_width = width * ammo_percentage
                            local bar_height = height * ammo_percentage
                            local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or {0, 150, 255, 255}
                            renderer.rectangle(bbox[1]-1, bbox[4]+2, width+2, 4, 0, 0, 0, 175)
                            renderer.rectangle(bbox[1], bbox[4]+3, bar_width, 2, color[1], color[2], color[3], 255)
                        end
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
