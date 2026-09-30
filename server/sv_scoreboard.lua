-- filename: server/sv_scoreboard.lua
-- [REPAIRED]: Reconstructed missing scoreboard file; handles kill events, score
--             tracking, kill streaks, UAV, win-condition checking, and the
--             in-match scoreboard command.

-----------------------------------------------------------------------
-- Weapon progression list for Gun Game mode
-- [REPAIRED]: Flattened from Config.Weapons.categories at runtime.
-----------------------------------------------------------------------
local GunGameWeapons = nil

local function BuildGunGameList()
    if GunGameWeapons then return GunGameWeapons end
    GunGameWeapons = {}
    if not Config.Weapons or not Config.Weapons.categories then return GunGameWeapons end
    for _, cat in ipairs(Config.Weapons.categories) do
        if cat.enabled and cat.items then
            for _, w in ipairs(cat.items) do
                GunGameWeapons[#GunGameWeapons+1] = w
            end
        end
    end
    return GunGameWeapons
end

-----------------------------------------------------------------------
-- Per-player killstreak counters (reset on death, per match)
-----------------------------------------------------------------------
local KillStreaks = {}  -- [srcId] = { streak=0, hadUav=false, hadSpecial=false }

local function GetStreak(src)
    if not KillStreaks[src] then
        KillStreaks[src] = { streak = 0, hadUav = false, hadSpecial = false }
    end
    return KillStreaks[src]
end

local function ResetStreak(src)
    KillStreaks[src] = { streak = 0, hadUav = false, hadSpecial = false }
end

-----------------------------------------------------------------------
-- Helper: find which lobby a source belongs to and their team
-----------------------------------------------------------------------
local function GetLobbyAndTeam(src)
    local lid = PlayerLobby and PlayerLobby[src]
    if not lid then return nil, nil, nil end
    local lobby = Lobbies and Lobbies[lid]
    if not lobby then return nil, nil, nil end
    local team = nil
    if lobby.redteam  and lobby.redteam[src]  then team = 'redteam'
    elseif lobby.blueteam and lobby.blueteam[src] then team = 'blueteam'
    elseif lobby.ffa      and lobby.ffa[src]      then team = 'ffa'
    end
    return lid, lobby, team
end

-----------------------------------------------------------------------
-- Identify the game-mode key ("tdm", "ffa", etc.) from a mode string
-----------------------------------------------------------------------
local function GetModeKey(modeStr)
    modeStr = modeStr or ""
    if modeStr:find("Team_DeathMatch")    then return "tdm"
    elseif modeStr:find("Hold_Your_Own")  then return "hyo"
    elseif modeStr:find("Capture")        then return "ctf"
    elseif modeStr:find("Gun_Game")       then return "gg"
    elseif modeStr:find("One_In_The")     then return "oitc"
    elseif modeStr:find("Kill_Confirmed") then return "kc"
    else                                       return "ffa"
    end
end

-----------------------------------------------------------------------
-- Win-condition check after every kill / score change
-----------------------------------------------------------------------
local function CheckWinCondition(lid, lobby)
    if not lobby or not lobby.started then return end
    local sc = MatchScores and MatchScores[lid]
    if not sc then return end

    local modeKey = GetModeKey(lobby.mode)
    local isFFA   = (modeKey == "ffa" or modeKey == "gg" or modeKey == "oitc")
    local isTDM   = (modeKey == "tdm")
    local isHYO   = (modeKey == "hyo")
    local isCTF   = (modeKey == "ctf")
    local isKC    = (modeKey == "kc")

    if isFFA then
        -- First to Config.MaxFFAScore wins
        local limit = Config.MaxFFAScore or 15
        for src, score in pairs(sc.ffaScores or {}) do
            if score >= limit then
                EndMatch(lid, src, 'score')
                return
            end
        end
    elseif isTDM then
        if (sc.redScore or 0) >= (Config.MaxTDMScore or 15) then
            EndMatch(lid, 'redteam', 'score')
        elseif (sc.blueScore or 0) >= (Config.MaxTDMScore or 15) then
            EndMatch(lid, 'blueteam', 'score')
        end
    elseif isHYO then
        -- Count remaining lives per team
        local redLives, blueLives = 0, 0
        for src in pairs(lobby.redteam  or {}) do redLives  = redLives  + (sc.lives[src] or 0) end
        for src in pairs(lobby.blueteam or {}) do blueLives = blueLives + (sc.lives[src] or 0) end
        if redLives  <= 0 and blueLives > 0 then EndMatch(lid, 'blueteam', 'lives') end
        if blueLives <= 0 and redLives  > 0 then EndMatch(lid, 'redteam',  'lives') end
        if redLives  <= 0 and blueLives <= 0 then EndMatch(lid, 'tie', 'lives') end
    elseif isCTF then
        if (sc.kcRed  or sc.ctfRed  or 0) >= 3 then EndMatch(lid, 'redteam',  'capture') end
        if (sc.kcBlue or sc.ctfBlue or 0) >= 3 then EndMatch(lid, 'blueteam', 'capture') end
    elseif isKC then
        if (sc.kcRed  or 0) >= (Config.MaxKCScore or 15) then EndMatch(lid, 'redteam',  'kc') end
        if (sc.kcBlue or 0) >= (Config.MaxKCScore or 15) then EndMatch(lid, 'blueteam', 'kc') end
    end
end

-----------------------------------------------------------------------
-- Kill event handler
-- [REPAIRED]: Receives kill reports from client.lua (obfuscated); validates,
--             updates scores, broadcasts kill feed, handles killstreaks.
-----------------------------------------------------------------------
RegisterNetEvent("Pug:SV:PlayerKilledInPaintball", function(data)
    local killer = source
    if not data then return end

    local victim   = tonumber(data.victim)
    local weapon   = tostring(data.weapon or "")
    local headshot = data.headshot == true

    if not victim or victim == killer then return end

    local lid, lobby, killerTeam = GetLobbyAndTeam(killer)
    if not lid or not lobby or not lobby.started then return end

    local sc = MatchScores and MatchScores[lid]
    if not sc then return end

    local _, _, victimTeam = GetLobbyAndTeam(victim)

    -- Friendly-fire protection (same team can't score kills)
    if killerTeam and victimTeam and killerTeam == victimTeam then return end

    local modeKey = GetModeKey(lobby.mode)
    local isFFA   = (modeKey == "ffa" or modeKey == "gg" or modeKey == "oitc")

    -- Update scores
    if isFFA then
        sc.ffaScores[killer] = (sc.ffaScores[killer] or 0) + 1
    elseif killerTeam == 'redteam' then
        sc.redScore = (sc.redScore or 0) + 1
    elseif killerTeam == 'blueteam' then
        sc.blueScore = (sc.blueScore or 0) + 1
    end

    -- Hold Your Own: consume a life from the victim
    if modeKey == "hyo" then
        sc.lives[victim] = math.max(0, (sc.lives[victim] or 0) - 1)
    end

    -- Gun Game: advance killer's weapon
    if modeKey == "gg" then
        local weapons = BuildGunGameList()
        local idx = (sc.ggWeapons[killer] or 1) + 1
        if idx > #weapons then
            EndMatch(lid, killer, 'gg_complete')
            return
        end
        sc.ggWeapons[killer] = idx
        local nextWeapon = weapons[idx]
        TriggerClientEvent("Pug:paintball:GunGameWeaponChange", killer, nextWeapon)
    end

    -- OITC: give victim 0 bullets, killer gets +1 bullet (handled client-side via notify)
    if modeKey == "oitc" then
        TriggerClientEvent("Pug:paintball:OITCKill", killer)
    end

    -- Kill streaks
    if Config.EnableKillStreaks then
        local streak = GetStreak(killer)
        streak.streak = streak.streak + 1

        -- UAV killstreak
        if streak.streak >= (Config.UavKillstreak or 3) and not streak.hadUav then
            streak.hadUav = true
            local killerCoords = GetEntityCoords(GetPlayerPed(killer))
            for _, src in ipairs(lobby.all or {}) do
                TriggerClientEvent("Pug:client:AcivateUavPaintball", src, killerCoords, killer)
            end
            TriggerClientEvent("Pug:client:PlayPaintballClientSound", killer, "uaventeringao", 0.05)
            -- Sound for opponents
            for src in pairs(lobby.redteam  or {}) do if src ~= killer then TriggerClientEvent("Pug:client:PlayPaintballClientSound", src, "enemyuav", 0.05) end end
            for src in pairs(lobby.blueteam or {}) do if src ~= killer then TriggerClientEvent("Pug:client:PlayPaintballClientSound", src, "enemyuav", 0.05) end end
        end

        -- Special weapon killstreak
        if streak.streak >= (Config.SpecialWeaponKillsStreak or 5) and not streak.hadSpecial then
            streak.hadSpecial = true
            TriggerClientEvent("Pug:paintball:GiveSpecialWeapon", killer, Config.SpecailWeaponItem or "weapon_minigun")
        end
    end

    -- Reset victim's killstreak
    ResetStreak(victim)

    -- Kill feed broadcast
    local killerName = GetPlayerFullName(killer)
    local victimName = GetPlayerFullName(victim)
    local killerColor = (killerTeam == 'redteam') and "#ef4444"
                     or (killerTeam == 'blueteam') and "#3b82f6"
                     or "#eab308"
    local victimColor = (victimTeam == 'redteam') and "#ef4444"
                     or (victimTeam == 'blueteam') and "#3b82f6"
                     or "#eab308"

    local feedData = {
        killer      = killerName,
        victim      = victimName,
        weapon      = weapon,
        killerColor = killerColor,
        victimColor = victimColor,
        headshot    = headshot,
    }
    for _, src in ipairs(lobby.all or {}) do
        TriggerClientEvent("Pug:client:PaintballKillFeed", src, feedData)
    end

    -- Award kill XP immediately (partial — full match XP awarded on match end)
    if AwardKillXP then
        AwardKillXP(killer, headshot, modeKey)
    end

    -- Check win condition
    CheckWinCondition(lid, lobby)
end)

-----------------------------------------------------------------------
-- Kill Confirmed tag collection event
-- [REPAIRED]: Increments team KC score when a player picks up a kill tag.
-----------------------------------------------------------------------
RegisterNetEvent("Pug:SV:KCTagCollected", function(team, confirmedBy)
    local source = source
    local lid, lobby = GetLobbyAndTeam(source)
    if not lid or not lobby or not lobby.started then return end

    local sc = MatchScores[lid]
    if not sc then return end

    if team == 'redteam' then
        sc.kcRed = (sc.kcRed or 0) + 1
    elseif team == 'blueteam' then
        sc.kcBlue = (sc.kcBlue or 0) + 1
    end

    -- Award confirm XP
    if AwardKillXP then AwardKillXP(source, false, "kc_confirm") end

    CheckWinCondition(lid, lobby)
end)

-----------------------------------------------------------------------
-- Scoreboard command (during match)
-- [REPAIRED]: Registered using Config.ScoreBoardCommand; sends current scores.
-----------------------------------------------------------------------
RegisterCommand(Config.ScoreBoardCommand or "pballboard", function(source, args)
    if source == 0 then return end
    local lid, lobby, team = GetLobbyAndTeam(source)
    if not lid or not lobby or not lobby.started then
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
            Config.Translations.error.not_in_match or "You are not in a match.", "error", 2000)
        return
    end
    local sc = MatchScores[lid] or {}
    TriggerClientEvent("Pug:paintball:ShowScoreboard", source, {
        redScore  = sc.redScore  or 0,
        blueScore = sc.blueScore or 0,
        mode      = lobby.mode,
        map       = lobby.map,
        time      = lobby.time,
    })
end, false)

-----------------------------------------------------------------------
-- FFA UAV — always-on during FFA modes
-- [REPAIRED]: Broadcasts all FFA player positions each second when Config.UavAlwaysOnDuringFFA = true.
-----------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Wait(3000)
        if not Config.UavAlwaysOnDuringFFA then goto continue end
        local ffaModes = {}
        if Config.GameModes then
            for k in pairs({ Gun_Game = true, Free_For_All = true, One_In_The_Chamber = true }) do
                if Config.GameModes[k] then
                    ffaModes[Config.GameModes[k].name] = true
                end
            end
        end
        for lid, lobby in pairs(Lobbies or {}) do
            if lobby.started and ffaModes[lobby.mode] then
                for src in pairs(lobby.ffa or {}) do
                    local ped = GetPlayerPed(src)
                    if ped and ped ~= 0 then
                        local coords = GetEntityCoords(ped)
                        for other in pairs(lobby.ffa) do
                            if other ~= src then
                                TriggerClientEvent("Pug:client:AcivateUavPaintball", other, coords, src)
                            end
                        end
                    end
                end
            end
        end
        ::continue::
    end
end)
