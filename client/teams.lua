local function CaptureOutfit()
    local ped = PlayerPedId()
    return {
        torso = GetPedDrawableVariation(ped,3),
        ttorso = GetPedTextureVariation(ped,3),
        mask = GetPedDrawableVariation(ped,1),
        tmask = GetPedTextureVariation(ped,1),
        pants = GetPedDrawableVariation(ped,4),
        tpants = GetPedTextureVariation(ped,4),
        jacket = GetPedDrawableVariation(ped,11),
        tjacket = GetPedTextureVariation(ped,11),
        shoes = GetPedDrawableVariation(ped,6),
        tshoes = GetPedTextureVariation(ped,6),
        undershirt = GetPedDrawableVariation(ped,8),
        tundershirt = GetPedTextureVariation(ped,8),
        bag = GetPedDrawableVariation(ped,5),
        tbag = GetPedTextureVariation(ped,5),
        hat = GetPedPropIndex(ped,0),
        that = GetPedPropTextureIndex(ped,0),
    }
end

RegisterNetEvent("Pug:client:SetTeamOutfitMale", function(data)
    local teamId = data.teamId
    Config.FrameworkFunctions.TriggerCallback("Pug:Teams:GetProfile", function(ok, payload)
        if not ok or not payload or not payload.team then return end

        local team = payload.team
        local pack = {}
        if team.outfit_json and team.outfit_json ~= "" then
            local ok2, decoded = pcall(json.decode, team.outfit_json)
            if ok2 and type(decoded) == "table" then pack = decoded end
        end

        pack.male = CaptureOutfit()
        TriggerServerEvent("Pug:Teams:UpdateMeta", teamId, { outfit_json = json.encode(pack) })
        PaintBallNotify(Config.Translations.menu.saved_team_outfit_male, "success")
    end, teamId)
end)

RegisterNetEvent("Pug:client:SetTeamOutfitFemale", function(data)
    local teamId = data.teamId
    Config.FrameworkFunctions.TriggerCallback("Pug:Teams:GetProfile", function(ok, payload)
        if not ok or not payload or not payload.team then return end

        local team = payload.team
        local pack = {}
        if team.outfit_json and team.outfit_json ~= "" then
            local ok2, decoded = pcall(json.decode, team.outfit_json)
            if ok2 and type(decoded) == "table" then pack = decoded end
        end

        pack.female = CaptureOutfit()
        TriggerServerEvent("Pug:Teams:UpdateMeta", teamId, { outfit_json = json.encode(pack) })
        PaintBallNotify(Config.Translations.menu.saved_team_outfit_female, "success")
    end, teamId)
end)


-- open teams list
RegisterNetEvent("Pug:client:OpenTeamsMenu", function()
    Config.FrameworkFunctions.TriggerCallback("Pug:Teams:GetMine", function(rows)
        local menu = {}
        local hasTeam = rows and #rows > 0

        menu[#menu+1] = {
            title       = Config.Translations.menu.team_info_title,
            description = Config.Translations.menu.team_info_desc,
            icon        = "fa-solid fa-circle-question",
            iconColor   = "#38bdf8",
            event       = "Pug:client:OpenTeamInfo"
        }

        if not hasTeam then
            menu[#menu+1] = {
                title = Config.Translations.menu.create_team_title,
                description = Config.Translations.menu.create_team_desc,
                icon        = "fa-solid fa-plus",
                iconColor   = "#22c55e",
                event       = "Pug:client:CreateTeam"
            }


            menu[#menu+1] = {
                title = Config.Translations.menu.no_team_title,
                description = Config.Translations.menu.no_team_desc,
                icon        = "fa-solid fa-circle-info",
                iconColor   = "#64748b"
            }
        else
            local t = rows[1]
            local tag   = t.tag and ("[" .. t.tag .. "] ") or ""
            local label = tag .. (t.name or ("Team " .. t.id))

            local myCid = Config.FrameworkFunctions.GetPlayerIdCitizenId and Config.FrameworkFunctions.GetPlayerIdCitizenId() or ""
            local owner = (t.owner_cid == myCid)
            local roleLabel = owner and Config.Translations.menu.role_owner or Config.Translations.menu.role_member
            local desc = roleLabel .. " • " .. (Config.Translations.menu.members_label):format(t.member_count or 1)

            menu[#menu+1] = {
                title       = label,
                description = desc,
                icon        = "fa-solid fa-people-group",
                iconColor   = t.color_hex or "#0ea5e9",
                event       = "Pug:client:ManageTeam",
                args        = { teamId = t.id }
            }
        end

        PugCreateMenu("pb_teams", Config.Translations.menu.teams_menu_title, menu, "pb_hub")
    end)
end)

RegisterNetEvent("Pug:client:OpenTeamInfo", function()
    local menu = {
        {
            title = Config.Translations.menu.team_info_how_title,
            description = Config.Translations.menu.team_info_how_desc,
            icon = "fa-solid fa-people-group",
            iconColor = "#0ea5e9"
        },
        {
            title = Config.Translations.menu.team_info_color_title,
            description = Config.Translations.menu.team_info_color_desc,
            icon = "fa-solid fa-palette",
            iconColor = "#22c55e"
        },
        {
            title = Config.Translations.menu.team_info_outfits_title,
            description = Config.Translations.menu.team_info_outfits_desc,
            icon = "fa-solid fa-shirt",
            iconColor = "#a855f7"
        },
        {
            title = Config.Translations.menu.team_info_rules_title,
            description = Config.Translations.menu.team_info_rules_desc,
            icon = "fa-solid fa-triangle-exclamation",
            iconColor = "#f59e0b"
        },
    }

    if Config.Menu ~= "ox_lib" then
        menu[#menu+1] = {
            title = Config.Translations.menu.go_back,
            icon = "fa-solid fa-arrow-left",
            iconColor = "#64748b",
            event = "Pug:client:OpenTeamsMenu"
        }
    end

    PugCreateMenu(
        "pb_team_info",
        Config.Translations.menu.team_info_header,
        menu,
        "pb_teams"
    )
end)


-- create team

RegisterNetEvent("Pug:client:CreateTeam", function()
    local dlg = PugInputDialog(Config.Translations.menu.create_team_header, {
        { type = "input", name = "name", label = Config.Translations.menu.create_team_name, isRequired = true },
        { type = "input", name = "tag", label = Config.Translations.menu.create_team_tag },
        { type = "input", name = "color_hex", label = Config.Translations.menu.create_team_color },
        { type = "input", name = "logo_url", label = Config.Translations.menu.create_team_logo }
    })
    if not dlg then return end

    local data = {
        name      = dlg[1],
        tag       = dlg[2],
        color_hex = dlg[3],
        logo_url  = dlg[4]
    }

    TriggerServerEvent("Pug:Teams:Create", data)
end)

RegisterNetEvent("Pug:Teams:CreateResult", function(ok, result)
    if not ok then
        PaintBallNotify((Config.Translations.menu.failed_create_team):format(tostring(result)), "error")
        return
    end

    PaintBallNotify(Config.Translations.menu.created_team, "success")
    TriggerEvent("Pug:client:OpenTeamsMenu")
end)

-- main team menu

RegisterNetEvent("Pug:client:ManageTeam", function(data)
    local teamId = data.teamId

    Config.FrameworkFunctions.TriggerCallback("Pug:Teams:GetProfile", function(ok, payload)
        if not ok or not payload then
            PaintBallNotify(Config.Translations.menu.failed_load_team, "error")
            return
        end

        local team    = payload.team
        local members = payload.members or {}

        local viewerIsOwner = false
        local viewerInTeam  = false

        for _, m in ipairs(members) do
            if m.isYou then
                viewerInTeam = true
                if m.isOwner then
                    viewerIsOwner = true
                end
            end
        end

        local title = (team.tag and ("[" .. team.tag .. "] ") or "") .. (team.name or ("Team " .. team.id))

        local menu = {}

        menu[#menu+1] = {
            title       = title,
            description = (Config.Translations.menu.members_label):format(#members),
            icon        = "fa-solid fa-people-group",
            iconColor   = team.color_hex or "#0ea5e9"
        }

        if viewerIsOwner then
            menu[#menu+1] = {
                title = Config.Translations.menu.manage_members_title,
                description = Config.Translations.menu.manage_members_desc,
                icon        = "fa-solid fa-users-gear",
                iconColor   = team.color_hex or "#0ea5e9",
                event       = "Pug:client:OpenTeamMembers",
                args        = { teamId = team.id }
            }

            menu[#menu+1] = {
                title = Config.Translations.menu.edit_team_title,
                description = Config.Translations.menu.edit_team_desc,
                icon        = "fa-solid fa-pen-to-square",
                iconColor   = "#eab308",
                event       = "Pug:client:EditTeamMeta",
                args        = { teamId = team.id, team = team }
            }

            menu[#menu+1] = {
                title = Config.Translations.menu.invite_player_title,
                description = Config.Translations.menu.invite_player_desc,
                icon        = "fa-solid fa-user-plus",
                iconColor   = "#22c55e",
                event       = "Pug:client:InviteToTeam",
                args        = { teamId = team.id }
            }

            menu[#menu+1] = {
                title = Config.Translations.menu.set_team_outfit_male_title,
                description = Config.Translations.menu.set_team_outfit_male_desc,
                icon = "fa-solid fa-person",
                iconColor = "#3b82f6",
                event = "Pug:client:SetTeamOutfitMale",
                args = { teamId = team.id, team = team }
            }

            menu[#menu+1] = {
                title = Config.Translations.menu.set_team_outfit_female_title,
                description = Config.Translations.menu.set_team_outfit_female_desc,
                icon = "fa-solid fa-person-dress",
                iconColor = "#ec4899",
                event = "Pug:client:SetTeamOutfitFemale",
                args = { teamId = team.id, team = team }
            }

        else
            menu[#menu+1] = {
                title       = "View Members",
                description = "See who is in this team.",
                icon        = "fa-solid fa-user-group",
                iconColor   = "#94a3b8",
                event       = "Pug:client:OpenTeamMembers",
                args        = { teamId = team.id }
            }
        end

        if viewerInTeam then
            menu[#menu+1] = {
                title = Config.Translations.menu.leave_team_title,
                description = Config.Translations.menu.leave_team_desc,
                icon        = "fa-solid fa-door-open",
                iconColor   = "#ef4444",
                event       = "Pug:client:LeaveTeam",
                args        = { teamId = team.id }
            }
        end

        PugCreateMenu("pb_team_" .. team.id, title, menu, "pb_teams")
    end, teamId)
end)

-- edit meta

RegisterNetEvent("Pug:client:EditTeamMeta", function(data)
    local team = data.team or {}
    local dlg = PugInputDialog(Config.Translations.menu.edit_team_header, {
        { type = "input", name = "name", label = Config.Translations.menu.edit_team_field_name, default = team.name or "", isRequired = true },
        { type = "input", name = "tag", label = Config.Translations.menu.edit_team_field_tag, default = team.tag or "" },
        { type = "input", name = "color_hex", label = Config.Translations.menu.edit_team_field_color, default = team.color_hex or "" },
        { type = "input", name = "logo_url", label = Config.Translations.menu.edit_team_field_logo, default = team.logo_url or "" }
    })

    if not dlg then return end

    local updates = {
        name      = dlg[1],
        tag       = dlg[2],
        color_hex = dlg[3],
        logo_url  = dlg[4]
    }

    if updates.tag and updates.tag ~= "" then
        updates.tag = tostring(updates.tag):gsub("%s+", ""):sub(1, 4)
    end


    TriggerServerEvent("Pug:Teams:UpdateMeta", data.teamId, updates)
end)

RegisterNetEvent("Pug:Teams:UpdateMetaResult", function(ok, msg)
    if not ok then
        PaintBallNotify((Config.Translations.menu.failed_update_team):format(tostring(msg)), "error")
        return
    end

    PaintBallNotify(Config.Translations.menu.updated_team, "success")
end)

-- invite

RegisterNetEvent("Pug:client:InviteToTeam", function(data)
    local dlg = PugInputDialog(Config.Translations.menu.invite_player_dialog_header, {
        { type = "number", name = "id", label = Config.Translations.menu.invite_player_id_label, isRequired = true }
    })
    if not dlg then return end

    local id = tonumber(dlg[1])
    if not id then return end

    TriggerServerEvent("Pug:Teams:InvitePlayer", data.teamId, id)
end)

RegisterNetEvent("Pug:Teams:InviteResult", function(ok, msg)
    if not ok then
        PaintBallNotify((Config.Translations.menu.failed_send_invite):format(tostring(msg)), "error")
    else
        PaintBallNotify(Config.Translations.menu.invite_sent, "success")
    end
end)

RegisterNetEvent("Pug:Teams:InviteReceived", function(data)
    local tag      = data.teamTag and ("[" .. data.teamTag .. "] ") or ""
    local teamName = tag .. (data.teamName or ("Team " .. tostring(data.teamId)))
    local inviter  = data.inviterName or ("Player " .. tostring(data.inviterId or "?"))

    local menu = {
        {
            title = (Config.Translations.menu.join_team_title):format(teamName),
            description = (Config.Translations.menu.join_team_desc):format(inviter),
            icon        = "fa-solid fa-check",
            iconColor   = "#22c55e",
            event       = "Pug:client:AcceptTeamInvite",
            args        = { teamId = data.teamId }
        },
        {
            title = Config.Translations.menu.decline_title,
            description = Config.Translations.menu.decline_desc,
            icon        = "fa-solid fa-xmark",
            iconColor   = "#ef4444",
            event       = "Pug:client:DeclineTeamInvite",
            args        = { teamId = data.teamId }
        }
    }

    PugCreateMenu("pb_team_invite_" .. data.teamId, Config.Translations.menu.team_invite_title, menu)
end)

RegisterNetEvent("Pug:client:AcceptTeamInvite", function(data)
    TriggerServerEvent("Pug:Teams:AcceptInvite", data.teamId)
end)

RegisterNetEvent("Pug:client:DeclineTeamInvite", function(data)
    TriggerServerEvent("Pug:Teams:DeclineInvite", data.teamId)
end)

RegisterNetEvent("Pug:Teams:AcceptInviteResult", function(ok, msg)
    if not ok then
        PaintBallNotify((Config.Translations.menu.failed_join_team):format(tostring(msg)), "error")
    else
        PaintBallNotify(Config.Translations.menu.joined_team, "success")
        TriggerEvent("Pug:client:OpenTeamsMenu")
    end
end)

-- members list + per-member actions

RegisterNetEvent("Pug:client:OpenTeamMembers", function(data)
    local teamId = data.teamId

    Config.FrameworkFunctions.TriggerCallback("Pug:Teams:GetProfile", function(ok, payload)
        if not ok or not payload then
            PaintBallNotify("Failed to load members.", "error")
            return
        end

        local team    = payload.team
        local members = payload.members or {}
        local viewerIsOwner = false

        for _, m in ipairs(members) do
            if m.isYou and m.isOwner then
                viewerIsOwner = true
                break
            end
        end

        local baseTitle = (team.tag and ("[" .. team.tag .. "] ") or "") .. (team.name or ("Team " .. team.id))
        local title = (Config.Translations.menu.members_menu_title):format(baseTitle)

        local menu = {}

        for _, m in ipairs(members) do
            local label = m.name or m.citizenid
            if m.isOwner then
                label = label .. Config.Translations.menu.member_owner_suffix
            elseif m.isYou then
                label = label .. Config.Translations.menu.member_you_suffix
            end

            local row = {
                title       = label,
                description = m.citizenid,
                icon        = "fa-solid fa-user",
                iconColor   = "#94a3b8"
            }

            if viewerIsOwner and not m.isOwner then
                row.event = "Pug:client:ManageTeamMember"
                row.args  = { teamId = team.id, member = m }
            end

            menu[#menu+1] = row
        end

        PugCreateMenu("pb_team_members_" .. team.id, title, menu, "pb_team_" .. team.id)
    end, teamId)
end)

RegisterNetEvent("Pug:client:ManageTeamMember", function(data)
    local teamId = data.teamId
    local m      = data.member or {}
    local name   = m.name or m.citizenid or "Member"

    local menu = {
        {
            title = Config.Translations.menu.promote_member_title,
            description = (Config.Translations.menu.promote_member_desc):format(name),
            icon        = "fa-solid fa-crown",
            iconColor   = "#facc15",
            event       = "Pug:client:PromoteTeamMember",
            args        = { teamId = teamId, citizenid = m.citizenid }
        },
        {
            title = Config.Translations.menu.kick_member_title,
            description = (Config.Translations.menu.kick_member_desc):format(name),
            icon        = "fa-solid fa-user-slash",
            iconColor   = "#ef4444",
            event       = "Pug:client:KickTeamMember",
            args        = { teamId = teamId, citizenid = m.citizenid }
        },
        {
            title = Config.Translations.menu.back_title,
            description = Config.Translations.menu.back_desc,
            icon        = "fa-solid fa-arrow-left",
            iconColor   = "#64748b",
            event       = "Pug:client:OpenTeamMembers",
            args        = { teamId = teamId }
        }
    }

    PugCreateMenu("pb_team_member_" .. tostring(teamId) .. "_" .. tostring(m.citizenid or ""), name, menu, "pb_team_members_" .. teamId)
end)

RegisterNetEvent("Pug:client:KickTeamMember", function(data)
    TriggerServerEvent("Pug:Teams:KickMember", data.teamId, data.citizenid)
end)

RegisterNetEvent("Pug:client:PromoteTeamMember", function(data)
    TriggerServerEvent("Pug:Teams:SetOwner", data.teamId, data.citizenid)
end)

RegisterNetEvent("Pug:Teams:KickMemberResult", function(ok, msg)
    if not ok then
        PaintBallNotify((Config.Translations.menu.failed_kick_member):format(tostring(msg)), "error")
    else
        PaintBallNotify(Config.Translations.menu.member_removed, "success")
    end
end)

RegisterNetEvent("Pug:Teams:SetOwnerResult", function(ok, msg)
    if not ok then
        PaintBallNotify((Config.Translations.menu.failed_transfer_owner):format(tostring(msg)), "error")
    else
        PaintBallNotify(Config.Translations.menu.owner_transferred, "success")
    end
end)

-- leave team

RegisterNetEvent("Pug:client:LeaveTeam", function(data)
    TriggerServerEvent("Pug:Teams:Leave", data.teamId)
end)

RegisterNetEvent("Pug:Teams:LeaveResult", function(ok, msg)
    if not ok then
        PaintBallNotify((Config.Translations.menu.failed_leave_team):format(tostring(msg)), "error")
    else
        PaintBallNotify(Config.Translations.menu.left_team, "success")
        TriggerEvent("Pug:client:OpenTeamsMenu")
    end
end)
