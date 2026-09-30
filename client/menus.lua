local function CheckMatchingGameModeMenus(LbyMode, GMode)
    if Config.GameModes[GMode] and LbyMode == Config.GameModes[GMode].name then return true end
    return false
end

local function IsFreeForAllGameModeMenus(LbyMode)
    return Config.GameModes["Gun_Game"] and LbyMode == Config.GameModes["Gun_Game"].name
        or Config.GameModes["Free_For_All"] and LbyMode == Config.GameModes["Free_For_All"].name
        or Config.GameModes["One_In_The_Chamber"] and LbyMode == Config.GameModes["One_In_The_Chamber"].name
end

local PB_LAST_ENTITY = nil
local function PB_ViewLobby(entity)
    local e = entity or PB_LAST_ENTITY
    TriggerEvent("Pug:client:OpenPaintballHUB", { args = { entity = e } })
end


local camera = nil
function waitForContextMenu()
    local maxAttempts = 40
    local attemptInterval = 1
    local counter = 0

    while true do
        Wait(attemptInterval)
        SetEntityLocallyInvisible(PlayerPedId())
        if Config.Menu == "lation_ui" and not exports.lation_ui:getOpenMenu() or Config.Menu == "ox_lib" and not lib.getOpenContextMenu() then
            counter = counter + 1
            if counter >= maxAttempts then
				RemoveCamera()
                break
            end
        else
            counter = 0
        end
    end
end

function CreateCameraNPC(entity, offset)
    if not Config.PlayCameraAnimationOnPed then return end
    if camera then return end 
    local offset = offset or {0.0,0.0,0.0}
    SetPedTalk(entity)
    PlayAmbientSpeech1(entity, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
    CreateThread(function() waitForContextMenu() end)
    if not DoesEntityExist(entity) then return end
    local coords = GetOffsetFromEntityInWorldCoords(entity, offset[1], 1.3 + offset[1], 0.60 + offset[1])
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    SetCamCoord(cam, coords.x, coords.y, coords.z)
    SetCamRot(cam, 0.0, 0.0, GetEntityHeading(entity) - 180, 0)
    SetCamFov(cam, 60.0)
    camera = cam
end

function RemoveCamera()
    if camera then
        local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        local coords = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamCoord(cam, coords.x, coords.y, coords.z)
        SetCamRot(cam, rot.x, rot.y, rot.z, 2)
        SetCamFov(cam, GetGameplayCamFov())
        SetCamActive(cam, true)
        SetCamActiveWithInterp(cam, camera, 800, 1, 1)
        CreateThread(function()
            Wait(800)
            RenderScriptCams(false, true, 500, true, true)
            DestroyCam(camera, true)
            DestroyCam(cam, true)
            camera = nil
        end)
    end
end

local function PB_ViewLobby(entity)
    local e = entity or PB_LAST_ENTITY
    if entity then PB_LAST_ENTITY = entity end  -- ✅ remember it immediately

    Config.FrameworkFunctions.TriggerCallback('Pug:Lobby:GetMine', function(myLobbyId)
        if myLobbyId then
            TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = myLobbyId, entity = e } })
        else
            TriggerEvent("Pug:client:OpenPaintballHUB", { args = { entity = e } })
        end
    end)
end

-- Utility to resolve a lobbyId for this action
local function PB_GetTargetLobbyId(cb, maybeArgs)
    local lid = maybeArgs and maybeArgs.lobbyId
    if lid then cb(lid) return end
    -- fall back to "the lobby I'm currently in"
    Config.FrameworkFunctions.TriggerCallback('Pug:Lobby:GetMine', function(myLobbyId)
        cb(myLobbyId)
    end)
end


-- === Client-side host anchor (no server storage) ===
local PB_IsHost   = false
local PB_LoopOn  = false
local PB_Anchor  = nil
local PB_MaxDist = 50.0

local function PB_StopLoop()
    PB_IsHost  = false
    PB_LoopOn  = false
    PB_Anchor  = nil
end

local function GetWeaponCategories()
    return Config.Weapons and Config.Weapons.categories or {}
end

RegisterNetEvent("Pug:client:StopLobbyHostLoop", PB_StopLoop)

RegisterNetEvent("Pug:client:DoLobbyHostLoop", function()
    -- reset anchor to current position every time we become host
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    PB_Anchor = vec3(pos.x, pos.y, pos.z)
    PB_IsHost = true
    if PB_LoopOn then return end
    PB_LoopOn = true
    local WasInMatch
    CreateThread(function()
        while PB_LoopOn do
            if not PB_IsHost or not PB_Anchor then break end
            if not isInMatch then
                if WasInMatch then WasInMatch = false Wait(10000) end
                local p = PlayerPedId()
                local c = GetEntityCoords(p)
                local dx, dy, dz = c.x - PB_Anchor.x, c.y - PB_Anchor.y, c.z - PB_Anchor.z
                local d2 = dx*dx + dy*dy + dz*dz

                if d2 >= PB_MaxDist then
                    -- tell server to hand off; server will stop our loop and start the next host's loop
                    TriggerServerEvent("Pug:paintball:HostTooFar")
                    Wait(1500) -- debounce so we don't spam during handoff
                end
            else
                Wait(2000)
                WasInMatch = true
            end

            Wait(2000) -- light polling; cheap and only runs for the host
        end
        PB_StopLoop()
    end)
end)

RegisterNetEvent('Pug:client:CloseAllPaintballMenuWhenStart',function()
    if #(GetEntityCoords(PlayerPedId()) - vector3(Config.PedLocation.x,Config.PedLocation.y,Config.PedLocation.z)) <= 50.0 then
        PugCloseMenu()
    end
end)

-- ========== LOBBY BROWSER UI (NEW) ==========
-- Open a browser to list all lobbies, join one (with passcode if locked), or create a new one


-- === Live Lobby Refresh ===
local CURRENT_LOBBY_ID = nil
local PB_REFRESH_COOLDOWN = false

-- Called by server whenever lobby data changes
RegisterNetEvent('Pug:client:LobbyDirty', function(lobbyId)
    -- Only refresh if we're viewing this exact lobby
    if CURRENT_LOBBY_ID ~= lobbyId then return end

    -- If using ox_lib, only refresh when the context menu is open
    if lib and lib.getOpenContextMenu and not lib.getOpenContextMenu() then return end

    -- Debounce to avoid spammy redraws
    if PB_REFRESH_COOLDOWN then return end
    PB_REFRESH_COOLDOWN = true
    CreateThread(function()
        -- Small delay to batch multiple updates
        Wait(100)
        TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = lobbyId, entity = PB_LAST_ENTITY } })
        Wait(150)
        PB_REFRESH_COOLDOWN = false
    end)
end)


RegisterNetEvent('Pug:client:OpenPaintballHUB', function(data)
    local e = (data and data.args and data.args.entity) or PB_LAST_ENTITY

    -- ✅ persist the first entity we ever get
    if data and data.args and data.args.entity then
        PB_LAST_ENTITY = data.args.entity
    end

    if camera then RemoveCamera() end
    if e then CreateCameraNPC(e, {-0.11, 0.0, 0.0}) end

    Config.FrameworkFunctions.TriggerCallback('Pug:Lobby:GetMine', function(myLobbyId)
        if myLobbyId then
            TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = myLobbyId, entity = e } })
            return
        else
            Config.FrameworkFunctions.TriggerCallback('Pug:Lobby:List', function(list)
                local menu = {}

                -- View Teams Setup
                menu[#menu+1] = {
                    title = Config.Translations.menu.team_hub_title,
                    description = Config.Translations.menu.team_hub_description,
                    icon = "fa-solid fa-people-group",
                    iconColor = "#bac522ff",
                    event = "Pug:client:OpenTeamsMenu"
                }

                -- Create Lobby button
                menu[#menu+1] = {
                    title = Config.Translations.menu.create_lobby_title,
                    description = Config.Translations.menu.create_lobby_description,
                    icon = "fa-solid fa-circle-plus",
                    iconColor = "#22c55e",
                    event = "Pug:client:CreateLobby"
                }

                -- Existing lobbies
                if list and #list > 0 then
                    for _, L in ipairs(list) do
                        local playersStr = (IsFreeForAllGameModeMenus(L.mode) and (tostring(L.players) .. "/24"))
                            or (tostring(L.red) .. "/" .. tostring(Config.MaxTeam) .. " vs " .. tostring(L.blue) .. "/" .. tostring(Config.MaxTeam))
                        local lockBadge = L.locked and "🔒" or "🔓"
                        local title = string.format(
                            Config.Translations.menu.lobby_list_title,
                            L.id,
                            L.name or L.map,
                            lockBadge
                        )
                        local desc = string.format(
                            Config.Translations.menu.lobby_list_desc,
                            L.mode,
                            L.map,
                            playersStr
                        )


                        menu[#menu+1] = {
                            title = title,
                            description = desc,
                            icon = L.locked and "fa-solid fa-lock" or "fa-solid fa-lock-open",
                            iconColor = L.locked and "#ef4444" or "#22c55e",
                            event = "Pug:client:EnterLobby",
                            args  = { lobbyId = L.id, locked = L.locked }
                        }
                    end
                else
                    menu[#menu+1] = {
                        title = Config.Translations.menu.no_lobbies_title,
                        description = Config.Translations.menu.no_lobbies_description,
                        icon = "fa-regular fa-face-smile",
                        disabled = true
                    }
                end

                if Config.Menu ~= "ox_lib" then
                    menu[#menu+1] = { title = Config.Translations.menu.close_back, event = " ", disabled = false }
                end

                PugCreateMenu("pb_hub", Config.Translations.menu.paintball_lobbies_title, menu)
            end)
        end
    end)
end)

RegisterNetEvent("Pug:client:CreateLobby", function()
    local dlg = PugInputDialog(Config.Translations.menu.create_lobby_header, {
        { type='input', name='name', label=Config.Translations.menu.lobby_name_label },
        { type='input', name='pass', label=Config.Translations.menu.lobby_pass_label },
    })
    if not dlg then return end

    local name = (dlg[1] ~= "" and dlg[1]) or nil
    local pass = (dlg[2] ~= "" and dlg[2]) or nil
    if not name then
        PaintBallNotify(Config.Translations.menu.must_enter_lobby_name, 'error')
        return
    end

    -- Send create request
    TriggerServerEvent("Pug:Lobby:Create", { name = name, passcode = pass })

    -- After short delay, reopen the hub with same entity for camera zoom
    Wait(200)
    TriggerEvent("Pug:client:OpenPaintballHUB", { args = { entity = PB_LAST_ENTITY } })
end)



-- REPLACE only the locked branch inside this event
RegisterNetEvent("Pug:client:EnterLobby", function(args)
    local lobbyId, locked = args.lobbyId, args.locked
    local passcode = nil

    if locked then
        local dlg = PugInputDialog(Config.Translations.menu.lobby_locked_title, {
            { type='input', name='pass', label=Config.Translations.menu.enter_passcode_label, isRequired=true }
        })
        if not dlg then return end
        passcode = dlg[1]

        Config.FrameworkFunctions.TriggerCallback("Pug:Lobby:Gate", function(ok, msg)
            if not ok then
                PaintBallNotify(msg or Config.Translations.error.incorrect_passcode, 'error')
                return
            end
            TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = lobbyId, entity = PB_LAST_ENTITY } })
        end, lobbyId, passcode)
    else
        
        TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = lobbyId, entity = PB_LAST_ENTITY } })
    end
end)

local function asDescription(v)
    if v == nil then return "" end
    if type(v) == "string" then return v end
    if type(v) == "table" then
        -- join player names on new lines (what you do for ox_lib)
        local lines = {}
        for i, val in ipairs(v) do lines[i] = tostring(val) end
        return table.concat(lines, "\n")
    end
    return tostring(v)
end

RegisterNetEvent('Pug:client:ViewLobby', function(data)
    local hours = GetClockHours()
    if Config.RestrictPaintballToDayTimeOnly then
        if hours <= 8 or hours >= 21 then PaintBallNotify(Config.Translations.error.daytime_only, 'error') return end
    end
    if GetResourceState("ak47_ambulancejob") == 'started' then
        local PlayerID = GetPlayerServerId(PlayerId())
        if exports['ak47_ambulancejob']:IsPlayerDead(PlayerID) or exports['ak47_ambulancejob']:IsPlayerDown(PlayerID) then
            PaintBallNotify(Config.Translations.error.cannot_join_down, 'error')
            return
        end
    end
    if GetResourceState("wasabi_ambulance") == 'started' then
        local PlayerID = GetPlayerServerId(PlayerId())
        if exports.wasabi_ambulance:isPlayerDead(PlayerID) then
            PaintBallNotify(Config.Translations.error.cannot_join_down, 'error')
            return
        end
    end

    if data and data.data then data.args = data.data end
    if data and data.args and data.args.entity then
        PB_LAST_ENTITY = data.args.entity
    end

    if isInMatch then
        TriggerEvent("Pug:client:MenuChooseGun")
        PaintBallNotify(Config.Translations.error.active_game, 'error')
        return
    end

    local targetLobbyId = data and data.args and data.args.lobbyId

    -- NEW: remember which lobby we're viewing (used by auto-refresh)
    CURRENT_LOBBY_ID = targetLobbyId
    Config.FrameworkFunctions.TriggerCallback('Pug:SVCB:GetLobbyDetails', function(lobby)
        if not lobby then
            PaintBallNotify(Config.Translations.error.lobby_no_longer_exists, "error")
            TriggerEvent("Pug:client:OpenPaintballHUB", { args = { entity = PB_LAST_ENTITY } })
            return
        end
        local players = "0"
        local FFAPlayers = " "
        if IsFreeForAllGameModeMenus(lobby.mode) then
            if lobby.playersffa ~= nil then
                if tonumber(lobby.playersffa) >= 1 then
                    players = tonumber(lobby.playersffa)
                end
            end
        else
            players = tonumber(lobby.redT + lobby.blueT)
        end

        local myId = GetPlayerServerId(PlayerId())
        local isJoined = false
        for _, v in ipairs(lobby.all or {}) do
            if tonumber(v) == myId then
                isJoined = true
                break
            end
        end

        if Config.HostOnlyCanControllWeaponSelect and lobby.weapon then
            ChosenWeapon = lobby.weapon
        end

        local playerTeam = lobby.myTeam  -- 'redteam' | 'blueteam' | 'ffa' | nil

        local Join = Config.Translations.menu.join

        local RedPlayers = ' '
        local BluePlayers = ' '
        if lobby.PlayersDisplay and (#lobby.PlayersDisplay) >= 1 then
            FFAPlayers = lobby.PlayersDisplay
            if Config.Menu == "ox_lib" and type(FFAPlayers) == "table" then
                FFAPlayers = table.concat(FFAPlayers, "\n")
            end
        end

        if lobby.playsred then
            if (#lobby.playsred) >= 1 then
                if lobby.playsred ~= '0/'..Config.MaxTeam then
                    RedPlayers = (#lobby.playsred) .. '/'..Config.MaxTeam
                end
            end
            if Config.Menu == "ox_lib" and type(lobby.playsred) == "table" then
                lobby.playsred = table.concat(lobby.playsred, "\n")
            end
        else
            lobby.playsred = '0' ..'/'..Config.MaxTeam
        end

        if lobby.playsblue then
            if (#lobby.playsblue) >= 1 then
                if lobby.playsblue ~= '0/'..Config.MaxTeam then
                    BluePlayers = (#lobby.playsblue) .. '/'..Config.MaxTeam
                end
            end
            if Config.Menu == "ox_lib" and type(lobby.playsblue) == "table" then
                lobby.playsblue = table.concat(lobby.playsblue, "\n")
            end
        else
            lobby.playsblue = '0' ..'/'..Config.MaxTeam
        end

        local redCount  = (type(lobby.playsred)  == "table" and #lobby.playsred)  or 0
        local blueCount = (type(lobby.playsblue) == "table" and #lobby.playsblue) or 0
        local redFull   = redCount  >= (Config.MaxTeam or 12)
        local blueFull  = blueCount >= (Config.MaxTeam or 12)
        local ffaCount  = tonumber(players) or 0
        local ffaFull   = ffaCount >= 24

        local isHost = lobby.host and (tonumber(lobby.host) == tonumber(myId))
        local canEdit = isHost and (not lobby.started)
        local canStart = canEdit

        local IconColors = {
            ["fa-solid fa-flag-checkered"] = "#22c55e",
            ["fa-solid fa-user-ninja"] = "#f59e0b",
            ["fa-solid fa-people-group-ffa"] = "#eab308",
            ["fa-solid fa-people-group-red"] = "#ef4444",
            ["fa-solid fa-people-group-blue"] = "#3b82f6",
            ["fa-solid fa-money-bill-1-wave"] = "#10b981",
            ["fa-solid fa-gun"] = "#9ca3af",
            ["fa-solid fa-map"] = "#fb923c",
            ["fa-solid fa-gamepad"] = "#8b5cf6",
            ["fa-solid fa-heart-pulse"] = "#f43f5e",
            ["fa-solid fa-user"] = "#06b6d4",
        }
        local function PB_IconColor(icon, variant)
            if variant and IconColors[icon.."-"..variant] then return IconColors[icon.."-"..variant] end
            return IconColors[icon] or "#ffffff"
        end

        local menu = {}
        local lobbyBadge = lobby.locked and "🔒" or "🔓"
        local lobbyTitle = (Config.Translations.menu.lobby_view_title):format(
            tostring(lobby.id or targetLobbyId or 1),
            lobby.name or lobby.map or "Lobby",
            lobbyBadge
        )

        -- ========= RANK / LEVEL HEADER (with progress bar) =========
        local myXP        = tonumber(lobby.myXP or 0) or 0
        local myRank      = tonumber(lobby.myRank or 0) or 0
        local myLevel     = tonumber(lobby.myLevel or 1) or 1
        local myPrestige  = tonumber(lobby.myPrestige or 0) or 0
        local xpIntoLevel = tonumber(lobby.myXPIntoLevel or 0) or 0
        local xpForNext   = tonumber(lobby.myXPForNext or 0) or 0

        local percent = 0
        if xpForNext > 0 and xpIntoLevel > 0 then
            percent = math.floor((xpIntoLevel / xpForNext) * 100)
            if percent < 0 then percent = 0 end
            if percent > 100 then percent = 100 end
        elseif xpForNext == 0 and myXP > 0 then
            -- max level: show 100%
            percent = 100
        end

        local rankText = (myRank and myRank > 0) and ("#" .. tostring(myRank)) or "-"
        local headerTitle = (Config.Translations.menu.rank_header_title):format(myPrestige, myLevel, rankText)
        local headerDesc = (Config.Translations.menu.rank_header_desc):format(xpIntoLevel, xpForNext, myXP)

        local imageName = Config.Leveling.Prestiges[myPrestige] and Config.Leveling.Prestiges[myPrestige].icon or "prestige_0"

        local imagePath = ('https://cfx-nui-pug-paintball/html_dui/prestige_icons/%s.png'):format(imageName)

        -- Uses your menu progress bar system (like fishing)
        menu[#menu+1] = {
            title       = headerTitle,
            description = headerDesc,
            icon        = imagePath,
            iconColor   = "#FACC15",
            colorScheme = "#FACC15",
            progress    = percent,
        }

        -- ========= EXISTING LOBBY OPTIONS (unchanged, just pushed after header) =========
        if lobby.host then
            LobbyHost = lobby.host
            menu[#menu+1] = {
                title = Config.Translations.menu.start,
                description = '✓',
                icon = "fa-solid fa-flag-checkered",
                iconColor = PB_IconColor("fa-solid fa-flag-checkered"),
                event = "Pug:client:RequestStart",
                disabled = tonumber(lobby.host) ~= tonumber(myId)
            }
        else
            LobbyHost = false
        end

        local AddN = " "

        menu[#menu+1] = {
            title = Config.Translations.menu.leave_lobby_title,
            description = Config.Translations.menu.leave_lobby_description,
            icon = "fa-solid fa-door-open",
            iconColor = "#ef4444",
            event = "Pug:client:LeaveLobby",
        }

        -- Host management (opens a submenu)
        if canEdit and lobby.host and lobby.host == myId then
            menu[#menu+1] = {
                title = Config.Translations.menu.manage_lobby_title,
                description = Config.Translations.menu.manage_lobby_description,
                icon = "fa-solid fa-gear",
                iconColor = "#06b6d4",
                arrow = true,
                event = "Pug:client:ManageLobby",
                args  = { lobbyId = targetLobbyId },
            }
        end


        if IsFreeForAllGameModeMenus(lobby.mode) then
            local titlePrefix = (playerTeam == 'ffa') and Config.Translations.menu.leave_prefix or Config.Translations.menu.join
            local disabled = lobby.started == true or (playerTeam ~= nil and playerTeam ~= 'ffa') or ffaFull
            menu[#menu+1] = {
                title = titlePrefix .. " " .. Config.Translations.menu.ffateam .. ' ' .. players .. "/24",
                description = FFAPlayers,
                icon = "fa-solid fa-people-group",
                iconColor = PB_IconColor("fa-solid fa-people-group", "ffa"),
                event = "Pug:paintball:joinRed", -- same event you already use to toggle/join
                args  = { lobbyId = targetLobbyId },
                disabled = disabled
            }
        else
            -- Make sure the counts in the title are strings too
            local redPlayersText  = tostring(RedPlayers or "")
            local bluePlayersText = tostring(BluePlayers or "")

            local redDesc  = asDescription(lobby.playsred)
            local blueDesc = asDescription(lobby.playsblue)

            -- RED row
            local redTitlePrefix =
                (playerTeam == 'redteam') and Config.Translations.menu.leave_prefix
                or Config.Translations.menu.join
            local redDisabled =
                lobby.started == true
                or (redFull and playerTeam ~= 'redteam')
                or (playerTeam == 'blueteam') -- must leave blue before joining red

            menu[#menu+1] = {
                title = redTitlePrefix .. " " .. Config.Translations.menu.redteam .. " " .. redPlayersText,
                description = redDesc,
                icon = "fa-solid fa-people-group",
                iconColor = PB_IconColor("fa-solid fa-people-group", "red"),
                event = "Pug:paintball:joinRed",
                args  = { lobbyId = targetLobbyId },
                disabled = redDisabled
            }

            -- BLUE row
            local blueTitlePrefix =
                (playerTeam == 'blueteam') and Config.Translations.menu.leave_prefix
                or Config.Translations.menu.join
            local blueDisabled =
                lobby.started == true
                or (blueFull and playerTeam ~= 'blueteam')
                or (playerTeam == 'redteam') -- must leave red before joining blue

            menu[#menu+1] = {
                title = blueTitlePrefix .. " " .. Config.Translations.menu.blueteam .. " " .. bluePlayersText,
                description = blueDesc,
                icon = "fa-solid fa-people-group",
                iconColor = PB_IconColor("fa-solid fa-people-group", "blue"),
                event = "Pug:paintball:joinBlue",
                args  = { lobbyId = targetLobbyId },
                disabled = blueDisabled
            }
        end

        local mapIcon = "fa-solid fa-map"
        local mapIconColor = PB_IconColor("fa-solid fa-map")
        local mapImage

        for key, arena in pairs(Config.Arenas) do
            if arena.name == lobby.map or key == lobby.map then
                mapIcon = "fas fa " .. (arena.icon or "map")
                mapIconColor = arena.iconColor or mapIconColor
                mapImage = arena.url or mapImage
                break
            end
        end

        local modeIcon = "fa-solid fa-gamepad"
        local modeIconColor = PB_IconColor("fa-solid fa-gamepad")


        for _, gm in pairs(Config.GameModes) do
            if gm.name == lobby.mode then
                modeIcon = gm.icon or modeIcon
                modeIconColor = gm.iconColor or modeIconColor
                break
            end
        end

        -- WEAPON ICON LOOKUP BASED ON CATEGORY
        local weaponIcon = "fa-solid fa-gun"
        local weaponIconColor = PB_IconColor("fa-solid fa-gun")

        if ChosenWeapon then
            local categories = GetWeaponCategories()
            for _, cat in ipairs(categories) do
                if cat.items then
                    for _, weaponName in ipairs(cat.items) do
                        if weaponName == ChosenWeapon then
                            weaponIcon = cat.icon or weaponIcon
                            weaponIconColor = cat.iconColor or weaponIconColor
                            break
                        end
                    end
                end
            end
        end

        menu[#menu+1] = {
            title = Config.Translations.menu.match_time_title,
            description = (Config.Translations.menu.match_time_option):format(tonumber(lobby.time or 15)),
            icon = "fa-solid fa-hourglass-half",
            iconColor = "#facc15",
            arrow = true,
            event = "Pug:client:ChooseMatchTime",
            disabled = not canStart
        }

        if Config.EnableWager then 
            menu[#menu+1] = {
                title = AddN..Config.Translations.menu.wager,
                description = '$'..lobby.amount,
                icon = "fa-solid fa-money-bill-1-wave",
                iconColor = PB_IconColor("fa-solid fa-money-bill-1-wave"),
                event = "Pug:client:SetWagerAmount",
                disabled = not canStart
            }
        end

        if not CheckMatchingGameModeMenus(lobby.mode, "Gun_Game") and not CheckMatchingGameModeMenus(lobby.mode, "One_In_The_Chamber") then
            menu[#menu+1] = {
                title = AddN..Config.Translations.menu.weapon,
                description = Config.WeaponItems[ChosenWeapon]["label"]..' ',
                icon = weaponIcon,
                iconColor = weaponIconColor,
                arrow = true,
                event = "Pug:client:MenuChooseGun",
                disabled = not canStart
            }
        end

        menu[#menu+1] = {
            title = AddN..Config.Translations.menu.map,
            description = lobby.map,
            icon = mapIcon,
            iconColor = mapIconColor,
            image = mapImage,
            arrow = true,
            event = "Pug:client:ChooseMap",
            disabled = not canStart
        }

        menu[#menu+1] = {
            title = AddN..Config.Translations.menu.mode,
            description = lobby.mode,
            icon = modeIcon,
            iconColor = modeIconColor,
            arrow = true,
            event = "Pug:client:ChoseGameModeMenu",
            disabled = not canStart
        }


        if CheckMatchingGameModeMenus(lobby.mode, "Hold_Your_Own") or CheckMatchingGameModeMenus(lobby.mode, "One_In_The_Chamber") then
            menu[#menu+1] = {
                title = AddN..Config.Translations.menu.lives,
                description = lobby.life..'/'..Config.MaxLives,
                icon = "fa-solid fa-heart-pulse",
                iconColor = PB_IconColor("fa-solid fa-heart-pulse"),
                event = "Pug:client:SetlivesOfPlayers",
                disabled = not canStart
            }
        end

        if Config.SpectateEnabled then
            if lobby.started then
                menu[#menu+1] = {
                    title = Config.Translations.menu.spectate,
                    description = players..'/'.. (Config.MaxTeam * 2),
                    icon = "fa-solid fa-user",
                    iconColor = PB_IconColor("fa-solid fa-user"),
                    arrow = true,
                    event = "Pug:client:SpectatePlayers",
                    args  = { lobbyId = targetLobbyId },
                    disabled = false
                }
            end
        end

        if Config.Menu ~= "ox_lib" then
            menu[#menu+1] = { title = Config.Translations.menu.close_back, description = "", event = " ", disabled = false }
        end

        if PB_LAST_ENTITY then
            CreateCameraNPC(PB_LAST_ENTITY, {-0.11, 0.0, 0.0})
        end

        PugCreateMenu("pb_lobby", lobbyTitle, menu)
    end, { lobbyId = targetLobbyId })
end)

RegisterNetEvent('Pug:client:ChooseMatchTime', function()
    if not LobbyHost or LobbyHost ~= GetPlayerServerId(PlayerId()) then
        PB_ViewLobby()
        PaintBallNotify(Config.Translations.error.need_to_be_lobby_host, 'error')
        return
    end

    Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:Checkongoinggame', function(gamestatus)
        if gamestatus then
            PaintBallNotify(Config.Translations.error.active_game, 'error')
            PB_ViewLobby()
            return
        end

        local menu = {}
        local options = Config.GameTimerLimitOptions

        for _, minutes in ipairs(options) do
            menu[#menu+1] = {
                title = (Config.Translations.menu.match_time_option):format(minutes),
                description = (Config.Translations.menu.match_time_option_description):format(minutes),
                icon = "fa-solid fa-hourglass-half",
                iconColor = "#facc15",
                event = "Pug:client:SetMatchTimeValue",
                args = minutes
            }
        end

        if Config.Menu ~= "ox_lib" then
            menu[#menu+1] = {
                title = Config.Translations.menu.close_back,
                description = "",
                event = "Pug:client:ViewLobby",
                args = { entity = PB_LAST_ENTITY }
            }
        end

        PugCreateMenu("pb_match_time", Config.Translations.menu.match_time_title, menu, "pb_lobby")
    end)
end)

RegisterNetEvent('Pug:client:SetMatchTimeValue', function(minutes)
    TriggerServerEvent('Pug:SV:SetMatchTime', minutes)
    PB_ViewLobby()
end)


RegisterNetEvent('Pug:client:ManageLobby', function(args)
    PB_GetTargetLobbyId(function(lobbyId)
        if not lobbyId then
            PaintBallNotify(Config.Translations.error.you_are_not_in_lobby, 'error')
            TriggerEvent("Pug:client:OpenPaintballHUB")
            return
        end

        if not LobbyHost or LobbyHost ~= GetPlayerServerId(PlayerId()) then
            PB_ViewLobby()
            PaintBallNotify(Config.Translations.error.need_to_be_lobby_host, 'error')
            return
        end

        local menu = {
            {
                title = Config.Translations.menu.transfer_host_title,
                description = Config.Translations.menu.transfer_host_description,
                icon = "fa-solid fa-user-shield",
                iconColor = "#06b6d4",
                event = "Pug:client:SetNewHostOfPaintball",
                args  = { lobbyId = lobbyId },
            },
            {
                title = Config.Translations.menu.shutdown_lobby_title,
                description = Config.Translations.menu.shutdown_lobby_description,
                icon = "fa-solid fa-power-off",
                iconColor = "#ef4444",
                event = "Pug:client:ShutdownLobby",
                args  = { lobbyId = lobbyId },
            },
            {
                title = Config.Translations.menu.set_passcode_title,
                description = Config.Translations.menu.set_passcode_description,
                icon = "fa-solid fa-lock",
                iconColor = "#f97316",
                event = "Pug:client:SetLobbyPasscode",
                args  = { lobbyId = lobbyId },
            },
            {
                title = Config.Translations.menu.kick_player_title,
                description = Config.Translations.menu.kick_player_description,
                icon = "fa-solid fa-user-minus",
                iconColor = "#f97316",
                arrow = true,
                event = "Pug:client:KickPlayerMenu",
                args  = { lobbyId = lobbyId },
            },
        }

        if Config.Menu ~= "ox_lib" then
            menu[#menu+1] = {
                title = Config.Translations.menu.close_back,
                description = "",
                event = "Pug:client:ViewLobby",
                args = { lobbyId = lobbyId, entity = PB_LAST_ENTITY },
            }
        end

        PugCreateMenu("pb_manage_lobby", Config.Translations.menu.manage_lobby_title, menu, "pb_lobby")
    end, args)
end)

RegisterNetEvent("Pug:client:KickPlayerMenu", function(args)
    PB_GetTargetLobbyId(function(lobbyId)
        if not lobbyId then
            PaintBallNotify(Config.Translations.error.lobby_no_longer_exists, "error")
            TriggerEvent("Pug:client:OpenPaintballHUB")
            return
        end

        if not LobbyHost or LobbyHost ~= GetPlayerServerId(PlayerId()) then
            PB_ViewLobby()
            PaintBallNotify(Config.Translations.error.need_to_be_lobby_host, 'error')
            return
        end

        Config.FrameworkFunctions.TriggerCallback('Pug:Lobby:GetMembers', function(members)
            local menu = {}
            local hasKickable = false

            if members and #members > 0 then
                for _, m in ipairs(members) do
                    if not m.isHost then
                        hasKickable = true
                        menu[#menu+1] = {
                            title = ("%s [ID: %d]"):format(m.name, m.id),
                            description = ("Team: %s"):format(m.team),
                            icon = "fa-solid fa-user-minus",
                            iconColor = "#ef4444",
                            arrow = true,
                            event = "Pug:client:ConfirmKickPlayer",
                            args = { lobbyId = lobbyId, targetId = m.id, name = m.name }
                        }
                    end
                end
            end

            if not hasKickable then
                menu[#menu+1] = {
                    title = Config.Translations.menu.no_players_to_kick_title,
                    description = Config.Translations.menu.no_players_to_kick_description,
                    icon = "fa-regular fa-face-smile",
                    disabled = true
                }
            end

            if Config.Menu ~= "ox_lib" then
                menu[#menu+1] = {
                    title = Config.Translations.menu.close_back,
                    description = "",
                    event = "Pug:client:ManageLobby",
                    args = { lobbyId = lobbyId },
                }
            end

            PugCreateMenu("pb_kick_list", Config.Translations.menu.kick_player_title, menu, "pb_manage_lobby")
        end, lobbyId)
    end, args)
end)

RegisterNetEvent("Pug:client:ConfirmKickPlayer", function(args)
    PB_GetTargetLobbyId(function(lobbyId)
        if not lobbyId or not args or not args.targetId then
            PB_ViewLobby()
            return
        end

        local name = args.name or ("ID "..tostring(args.targetId))
        local title = (Config.Translations.menu.kick_confirm_title):format(name)

        local menu = {
            {
                title = (Config.Translations.menu.kick_confirm_description):format(name),
                description = Config.Translations.menu.kick_confirm_body,
                icon = "fa-solid fa-triangle-exclamation",
                iconColor = "#f97316",
                disabled = true,
            },
            {
                title = Config.Translations.menu.kick_yes_title,
                description = (Config.Translations.menu.kick_yes_description):format(name),
                icon = "fa-solid fa-user-minus",
                iconColor = "#ef4444",
                event = "Pug:client:DoKickPlayer",
                args = { lobbyId = lobbyId, targetId = args.targetId },
            },
            {
                title = Config.Translations.menu.kick_no_title,
                description = Config.Translations.menu.kick_no_description,
                icon = "fa-solid fa-arrow-left",
                iconColor = "#9ca3af",
                event = "Pug:client:KickPlayerMenu",
                args = { lobbyId = lobbyId },
            },
        }

        if Config.Menu ~= "ox_lib" then
            menu[#menu+1] = {
                title = Config.Translations.menu.close_back,
                description = "",
                event = "Pug:client:KickPlayerMenu",
                args = { lobbyId = lobbyId },
            }
        end

        PugCreateMenu("pb_kick_confirm", title, menu, "pb_kick_list")
    end, args)
end)

RegisterNetEvent("Pug:client:DoKickPlayer", function(args)
    PB_GetTargetLobbyId(function(lobbyId)
        if not lobbyId or not args or not args.targetId then
            PB_ViewLobby()
            return
        end

        if not LobbyHost or LobbyHost ~= GetPlayerServerId(PlayerId()) then
            PB_ViewLobby()
            PaintBallNotify(Config.Translations.error.need_to_be_lobby_host, 'error')
            return
        end

        TriggerServerEvent("Pug:Lobby:KickPlayer", lobbyId, tonumber(args.targetId))
        PB_ViewLobby()
    end, args)
end)


RegisterNetEvent("Pug:client:SetLobbyPasscode", function(args)
    PB_GetTargetLobbyId(function(lobbyId)
        if not lobbyId then
            PaintBallNotify(Config.Translations.error.lobby_no_longer_exists, "error")
            TriggerEvent("Pug:client:OpenPaintballHUB")
            return
        end

        if not LobbyHost or LobbyHost ~= GetPlayerServerId(PlayerId()) then
            PB_ViewLobby()
            PaintBallNotify(Config.Translations.error.need_to_be_lobby_host, 'error')
            return
        end

        local dlg = PugInputDialog(Config.Translations.menu.set_passcode_header, {
            { type = 'input', name = 'pass', label = Config.Translations.menu.passcode_label }
        })

        if not dlg then
            PB_ViewLobby()
            return
        end

        local pass = dlg[1] or ""
        TriggerServerEvent("Pug:Lobby:SetPasscode", lobbyId, pass)
        PB_ViewLobby()
    end, args)
end)

RegisterNetEvent("Pug:client:LeaveLobby", function()
    TriggerServerEvent("Pug:Lobby:LeaveLobby")
end)

RegisterNetEvent("Pug:client:ShutdownLobby", function(args)
    PB_GetTargetLobbyId(function(lobbyId)
        if not lobbyId then
            PaintBallNotify(Config.Translations.error.lobby_no_longer_exists, "error")
            TriggerEvent("Pug:client:OpenPaintballHUB")
            return
        end

        if not LobbyHost or LobbyHost ~= GetPlayerServerId(PlayerId()) then
            PB_ViewLobby()
            PaintBallNotify(Config.Translations.error.need_to_be_lobby_host, 'error')
            return
        end

        local menu = {
            {
                title = Config.Translations.menu.shutdown_confirm_title,
                description = Config.Translations.menu.shutdown_confirm_description,
                icon = "fa-solid fa-triangle-exclamation",
                iconColor = "#ef4444",
                disabled = true,
            },
            {
                title = Config.Translations.menu.shutdown_yes_title,
                description = Config.Translations.menu.shutdown_yes_description,
                icon = "fa-solid fa-power-off",
                iconColor = "#ef4444",
                event = "Pug:client:ConfirmShutdownLobby",
                args = { lobbyId = lobbyId },
            },
            {
                title = Config.Translations.menu.shutdown_no_title,
                description = Config.Translations.menu.shutdown_no_description,
                icon = "fa-solid fa-arrow-left",
                iconColor = "#9ca3af",
                event = "Pug:client:ManageLobby",
                args = { lobbyId = lobbyId },
            },
        }

        if Config.Menu ~= "ox_lib" then
            menu[#menu+1] = {
                title = Config.Translations.menu.close_back,
                description = "",
                event = "Pug:client:ManageLobby",
                args = { lobbyId = lobbyId },
            }
        end

        PugCreateMenu("pb_shutdown_lobby_confirm", Config.Translations.menu.shutdown_lobby_title, menu, "pb_lobby")
    end, args)
end)

RegisterNetEvent("Pug:client:ConfirmShutdownLobby", function(args)
    TriggerServerEvent("Pug:Lobby:Shutdown")
    Wait(200)
    TriggerEvent("Pug:client:OpenPaintballHUB")
end)

-- REPLACE the input portions of this event
RegisterNetEvent('Pug:client:SetlivesOfPlayers', function()
    if not LobbyHost or LobbyHost ~= GetPlayerServerId(PlayerId()) then
        PB_ViewLobby() PaintBallNotify(Config.Translations.error.need_to_be_lobby_host, 'error') return
    end

    Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:Checkongoinggame', function(gamestatus)
        if gamestatus then PaintBallNotify(Config.Translations.error.active_game, 'error'); PB_ViewLobby(); return end

        local dlg = PugInputDialog(Config.Translations.menu.arena_lives, {
            { type='number', name='price', label=Config.Translations.menu.player_lives, isRequired=true }
        })
        if not dlg then PaintBallNotify(Config.Translations.error.no_lives_entered, 'error'); PB_ViewLobby(); return end

        local amount = tonumber(dlg[1] or 0)
        if amount and amount <= Config.MaxLives then
            TriggerServerEvent('Pug:SV:SetlivesOfPlayers', amount)
            PB_ViewLobby()
        else
            PB_ViewLobby()
            PaintBallNotify(Config.Translations.error.max_lives_set..Config.MaxLives, 'error')
        end
    end)
end)


RegisterNetEvent('Pug:client:SetWagerAmount', function()
    if not LobbyHost or LobbyHost ~= GetPlayerServerId(PlayerId()) then
        PB_ViewLobby()
        PaintBallNotify(Config.Translations.error.need_to_be_lobby_host, 'error')
        return
    end

    Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:Checkongoinggame', function(gamestatus)
        if gamestatus then
            PaintBallNotify(Config.Translations.error.active_game, 'error')
            PB_ViewLobby()
            return
        end

        local dlg = PugInputDialog(
            Config.Translations.menu.arena_wager,
            {{
                type = 'number',
                name = 'price',
                label = Config.Translations.menu.wager,
                isRequired = true
            }}
        )

        if not dlg then
            PaintBallNotify(Config.Translations.error.no_wager, 'error')
            PB_ViewLobby()
            return
        end

        local amount = tonumber(dlg[1])
        if amount and amount <= Config.MaxWager and amount >= Config.MinWager then
            TriggerServerEvent('Pug:SV:SetWagerOfLobby', amount)
            PB_ViewLobby()
        else
            PB_ViewLobby()
            PaintBallNotify(
                Config.Translations.error.wager_cap .. Config.MinWager .. ' & ' .. Config.MaxWager,
                'error'
            )
        end
    end)
end)

RegisterNetEvent('Pug:client:MenuChooseGun', function()
    local menu = {}
    for idx, cat in ipairs(GetWeaponCategories()) do
        if cat.enabled and cat.items and #cat.items > 0 then
            menu[#menu+1] = {
                title = cat.title,
                description = cat.description or "",
                icon = cat.icon or "fa-solid fa-gun",
                iconColor = cat.iconColor or "#ffffff",
                arrow = true,
                event = "Pug:client:OpenWeaponCategory",
                args = idx
            }
        end
    end
    if Config.Menu ~= "ox_lib" then
        menu[#menu+1] = {
            title = " ",
            description = Config.Translations.menu.go_back,
            event = "Pug:client:ViewLobby",
            args = { entity = PB_LAST_ENTITY }
        }
    end
    PugCreateMenu("pb_weapon", Config.Translations.menu.weapon, menu, "pb_lobby")
end)

RegisterNetEvent('Pug:client:OpenWeaponCategory', function(categoryIndex)
    local categories = GetWeaponCategories()
    local cat = categories[categoryIndex]
    if not cat then return end

    local menu = {}
    for _, weapon in ipairs(cat.items or {}) do
        local item = Config.WeaponItems[weapon] or {}
        local imageName = item.name or weapon              -- e.g. "weapon_pistol"
        local imagePath = ('https://cfx-nui-pug-paintball/html/weapon_icons/%s.png'):format(imageName)

        menu[#menu+1] = {
            title       = item.label or weapon,           -- "Beretta M9", etc.
            image       = imagePath,                      -- use image path as description
            icon        = imagePath,                      -- use image path as icon
            description = item.description or "",         -- use image path as icon
            iconColor   = cat.iconColor or "#ffffff",   -- kept in case UI still uses it
            event       = "Pug:client:WeaponPicked",
            args        = weapon
        }

    end

    if Config.Menu ~= "ox_lib" then
        menu[#menu+1] = {
            title = " ",
            description = Config.Translations.menu.go_back,
            event = "Pug:client:MenuChooseGun",
            args = { entity = PB_LAST_ENTITY }
        }
    end

    PugCreateMenu(("pb_weapon_%s"):format(cat.key or categoryIndex), Config.Translations.menu.weapon, menu, "pb_weapon")
end)


RegisterNetEvent('Pug:client:WeaponPicked', function(weapon)
    if not weapon then return end
    if Config.HostOnlyCanControllWeaponSelect then 
        if LobbyHost == GetPlayerServerId(PlayerId()) then 
            TriggerServerEvent("Pug:server:SetAllPlayersWeapons", weapon)
            if not isInMatch then PB_ViewLobby() end
        else
            if not isInMatch then PaintBallNotify(Config.Translations.error.only_host_change_waapons, 'error') PB_ViewLobby() end
        end 
        return 
    end
    ChosenWeapon = weapon
    if isInMatch then GiveThePlayerTheWeapon() end
    local label = (Config.WeaponItems[weapon] and Config.WeaponItems[weapon].label) or weapon
    PaintBallNotify(label, 'success')
    if not isInMatch then PB_ViewLobby() end
end)

RegisterNetEvent('Pug:client:SpectatePlayers', function(args)
    local lobbyId = args and args.lobbyId or CURRENT_LOBBY_ID

    Config.FrameworkFunctions.TriggerCallback('Pug:SVCB:Specatateplayers', function(info)
        if info then
            local menu = {}

            for idx, v in ipairs(info) do
                menu[#menu+1] = {
                    title       = v.name or (Config.Translations.menu.spectate_player_title):format(tostring(v.id)),
                    description = (Config.Translations.menu.spectate_player_description):format(tostring(v.id)),
                    icon        = "fa-solid fa-user-ninja",
                    iconColor   = "#38bdf8",
                    event       = "Pug:client:StartSpectate",
                    args        = { id = v.id, lobbyId = lobbyId }
                }
            end
            if isSpectating then
                menu[#menu+1] = {
                    title       = Config.Translations.menu.exit_spectate_title,
                    description = Config.Translations.menu.exit_spectate_description,
                    icon        = "fa-solid fa-circle-xmark",
                    iconColor   = "#ef4444",
                    event       = "Pug:client:ExitSpectate"
                }
            end


            if Config.Menu ~= "ox_lib" then
                menu[#menu+1] = {
                    title       = Config.Translations.menu.close_back,
                    description = "",
                    icon        = "fa-solid fa-arrow-left",
                    iconColor   = "#9ca3af",
                    event       = "Pug:client:SpectatePlayers",
                    args        = { lobbyId = lobbyId }
                }
            end

            PugCreateMenu("pb_spectate", Config.Translations.menu.spectate, menu, "pb_lobby")
        else
            TriggerEvent("Pug:client:ExitSpectate")
        end
    end, lobbyId)
end)



RegisterNetEvent('Pug:client:ChooseMap', function()
    Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:Checkongoinggame', function(gamestatus)
        if gamestatus then
            PaintBallNotify(Config.Translations.error.active_game, 'error')
            PB_ViewLobby()
            return
        end

        local options = {}
        table.insert(options, {
            title = Config.Translations.menu.random,
            description = Config.Translations.menu.random_map_description,
            event = "Pug:client:SelectChosenMap",
            args = "random",
            icon = "fa-dice",
            iconColor = "#e91e63",
        })

        local keys = {}
        for k in pairs(Config.Arenas) do table.insert(keys, k) end
        table.sort(keys)

        for _, k in ipairs(keys) do
            local v = Config.Arenas[k]
            table.insert(options, {
                title = v.name,
                description = v.description,
                icon = "fas "..v.icon,
                iconColor = v.iconColor,
                image = v.url and v.url:gsub(" ", "%%20"),
                event = "Pug:client:SelectChosenMap",
                args = k
            })
        end

        if Config.Menu ~= "ox_lib" then
            table.insert(options, {
                title = " ",
                description = Config.Translations.menu.go_back,
                event = "Pug:client:ViewLobby",
                args = { entity = PB_LAST_ENTITY }
            })
        end

        PugCreateMenu("choose_map_menu", Config.Translations.menu.map, options, "pb_lobby")
    end)
end)

RegisterNetEvent('Pug:paintball:joinRed', function(args)
    PB_GetTargetLobbyId(function(lobbyId)
        if not lobbyId then
            PaintBallNotify(Config.Translations.error.you_are_not_in_lobby, 'error')
            TriggerEvent("Pug:client:OpenPaintballHUB")
            return
        end

        Config.FrameworkFunctions.TriggerCallback('Pug:SVCB:GetLobbyDetails', function(lobby)
            if not lobby then
                PaintBallNotify(Config.Translations.error.lobby_no_longer_exists, 'error')
                TriggerEvent("Pug:client:OpenPaintballHUB")
                return
            end

            if lobby.started then
                PaintBallNotify(Config.Translations.error.active_game, 'error')
                CreateThread(function()
                    TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = lobbyId, entity = PB_LAST_ENTITY } })
                end)
                return
            end

            local myTeam = lobby.myTeam  -- 'redteam' | 'blueteam' | 'ffa' | nil

            if myTeam == nil then
                -- weapon gate for non-FFA modes only
                local isFFA = CheckMatchingGameModeMenus(lobby.mode, "Gun_Game") or CheckMatchingGameModeMenus(lobby.mode, "One_In_The_Chamber")
                if not Config.HostOnlyCanControllWeaponSelect then
                    if not isFFA and ChosenWeapon == 'weapon_unarmed' then
                        PaintBallNotify(Config.Translations.error.need_to_choose_weapon, 'error')
                        CreateThread(function()
                            TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = lobbyId, entity = PB_LAST_ENTITY } })
                        end)
                        return
                    end
                end

                PugSoundPlay("jointeam", 0.08)
                local joinTeamName = IsFreeForAllGameModeMenus(lobby.mode) and 'ffa' or 'redteam'
                TriggerServerEvent('Pug:paintball:JoinTeam', joinTeamName, lobbyId)
                CreateThread(function()
                    TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = lobbyId, entity = PB_LAST_ENTITY } })
                end)
                return
            end

            isInMatch = false
            TriggerServerEvent('Pug:paintball:Leave', myTeam)
            CreateThread(function()
                TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = lobbyId, entity = PB_LAST_ENTITY } })
            end)
        end, { lobbyId = lobbyId })
    end, args)
end)


RegisterNetEvent('Pug:paintball:joinBlue', function(args)
    PB_GetTargetLobbyId(function(lobbyId)
        if not lobbyId then
            PaintBallNotify(Config.Translations.error.lobby_no_longer_exists, "error")
            TriggerEvent("Pug:client:OpenPaintballHUB")
            return
        end

        -- One callback: has my team + started flag
        Config.FrameworkFunctions.TriggerCallback('Pug:SVCB:GetLobbyDetails', function(lobby)
            if not lobby then
                PaintBallNotify(Config.Translations.error.lobby_no_longer_exists, "error")
                TriggerEvent("Pug:client:OpenPaintballHUB")
                return
            end

            if lobby.started then
                PaintBallNotify(Config.Translations.error.active_game, 'error')
                CreateThread(function()
                    TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = lobbyId, entity = PB_LAST_ENTITY } })
                end)
                return
            end

            local myTeam = lobby.myTeam -- 'redteam' | 'blueteam' | 'ffa' | nil

            if myTeam == nil then
                -- Only enforce weapon for non-FFA modes
                local isFFA = CheckMatchingGameModeMenus(lobby.mode, "Gun_Game") or CheckMatchingGameModeMenus(lobby.mode, "One_In_The_Chamber")
                if not Config.HostOnlyCanControllWeaponSelect then
                    if not isFFA and ChosenWeapon == 'weapon_unarmed' then
                        PaintBallNotify(Config.Translations.error.need_to_choose_weapon, 'error')
                        CreateThread(function()
                            TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = lobbyId, entity = PB_LAST_ENTITY } })
                        end)
                        return
                    end
                end

                TriggerEvent("InteractSound_CL:PlayOnOne", "jointeam", 0.08)
                TriggerServerEvent('Pug:paintball:JoinTeam', 'blueteam', lobbyId)
                CreateThread(function()
                    TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = lobbyId, entity = PB_LAST_ENTITY } })
                end)
                return
            end

            -- Already on a team → leave current
            isInMatch = false
            TriggerServerEvent('Pug:paintball:Leave', myTeam)
            CreateThread(function()
                TriggerEvent("Pug:client:ViewLobby", { args = { lobbyId = lobbyId, entity = PB_LAST_ENTITY } })
            end)
        end, { lobbyId = lobbyId })
    end, args)
end)



RegisterNetEvent('Pug:client:ChoseGameModeMenu', function()
    if isInMatch then
        PaintBallNotify(Config.Translations.error.active_game, 'error')
        return
    end

    Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:Checkongoinggame', function(gamestatus)
        if gamestatus then
            PaintBallNotify(Config.Translations.error.active_game, 'error')
            PB_ViewLobby()
            return
        end

        local sortedModes = {}
        for key, v in pairs(Config.GameModes) do
            sortedModes[#sortedModes+1] = {
                key = key,
                data = v
            }
        end

        table.sort(sortedModes, function(a, b)
            local nameA = a.data.name or ""
            local nameB = b.data.name or ""
            return nameA:lower() < nameB:lower()
        end)

        local menu = {}
        for _, mode in ipairs(sortedModes) do
            local v = mode.data
            menu[#menu+1] = {
                title       = v.name,
                description = v.description or "",
                icon        = v.icon or "fa-solid fa-gamepad",
                iconColor   = v.iconColor or "#ffffff",
                event       = "Pug:client:ChoseGameMode",
                args        = v.name
            }
        end

        if Config.Menu ~= "ox_lib" then
            menu[#menu+1] = {
                title = " ",
                description = Config.Translations.menu.go_back,
                event = "Pug:client:ViewLobby",
                args = { entity = PB_LAST_ENTITY }
            }
        end

        PugCreateMenu("pb_mode", Config.Translations.menu.mode, menu, "pb_lobby")
    end)
end)


RegisterNetEvent('Pug:client:ChoseGameMode', function(mode)
    if isInMatch then
        PaintBallNotify(Config.Translations.error.active_game, 'error')
        PB_ViewLobby()
    else
        Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:Checkongoinggame', function(gamestatus)
            if gamestatus then
                PaintBallNotify(Config.Translations.error.active_game, 'error')
                PB_ViewLobby()
            else
                TriggerServerEvent("Pug:server:ChoseGameMode",mode)
                PB_ViewLobby()
            end
        end)
    end
end)

-- REPLACE the input portions of this event
RegisterNetEvent("Pug:client:SetNewHostOfPaintball", function()
    if isInMatch then PaintBallNotify(Config.Translations.error.active_game, 'error'); return end

    Config.FrameworkFunctions.TriggerCallback('Pug:serverCB:Checkongoinggame', function(gamestatus)
        if gamestatus then PaintBallNotify(Config.Translations.error.active_game, 'error'); PB_ViewLobby(); return end

        local dlg = PugInputDialog(Config.Translations.menu.give_host, {
            { type='number', name='price', label=Config.Translations.menu.player_id, isRequired=true }
        })
        if not dlg then PaintBallNotify(Config.Translations.error.no_id_entered, 'error'); PB_ViewLobby(); return end

        local id = tonumber(dlg[1] or 0)
        if id and id > 0 then
            TriggerServerEvent('Pug:server:MakePlayerGameHost', id)
            PB_ViewLobby()
        else
            PB_ViewLobby()
            PaintBallNotify(Config.Translations.error.no_id_entered, 'error')
        end
    end)
end)

RegisterNetEvent('Pug:client:RequestStart', function()
    TriggerServerEvent('Pug:paintball:startGame')
end)

