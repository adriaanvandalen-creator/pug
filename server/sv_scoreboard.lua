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
    local key = GetPaintballModeKey(modeStr)
    if key ~= "ffa" or modeStr == (Config.GameModes.Free_For_All or {}).name then return key end
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
-- Scoreboard data (player rows + team scores) for the G / end-of-match board
-----------------------------------------------------------------------
local RankCache = {}  -- [src] = { level, prestige }, refreshed every match

local function GetStats(sc, src)
    sc.stats = sc.stats or {}
    if not sc.stats[src] then
        sc.stats[src] = { kills = 0, deaths = 0, score = 0 }
    end
    return sc.stats[src]
end

local function GetRankFor(src)
    if RankCache[src] then return RankCache[src] end
    local info = { level = 1, prestige = 0 }
    if GetPlayerCID and GetPlayerRankData then
        local ok, data = pcall(function() return GetPlayerRankData(GetPlayerCID(src)) end)
        if ok and data then
            info.level    = data.level    or 1
            info.prestige = data.prestige or 0
        end
    end
    RankCache[src] = info
    return info
end

local function BuildRows(sc, players)
    local rows = {}
    for src, d in pairs(players or {}) do
        local st   = GetStats(sc, src)
        local rank = GetRankFor(src)
        rows[#rows + 1] = {
            id        = src,
            name      = (type(d) == "table" and d.name) or GetPlayerFullName(src),
            kills     = st.kills,
            deaths    = st.deaths,
            score     = st.score,
            points    = st.kills * 100 + st.score * 50,
            level     = rank.level,
            prestige  = rank.prestige,
            livesLeft = (sc.lives and sc.lives[src]) or 0,
        }
    end
    table.sort(rows, function(a, b)
        if a.kills ~= b.kills then return a.kills > b.kills end
        return a.deaths < b.deaths
    end)
    return rows
end

local function GetTeamScores(lid, lobby, sc)
    local modeKey = GetModeKey(lobby.mode)
    if modeKey == "kc" then
        return sc.kcRed or 0, sc.kcBlue or 0
    elseif modeKey == "ctf" then
        local st = CTFState and CTFState[lid]
        return (st and st.redCaptures) or sc.ctfRed or 0, (st and st.blueCaptures) or sc.ctfBlue or 0
    end
    return sc.redScore or 0, sc.blueScore or 0
end

-- Sends the current rows + team scores to everyone in the lobby (or just `onlySrc`).
function BroadcastPaintballScoreboard(lid, onlySrc)
    local lobby = Lobbies and Lobbies[lid]
    local sc    = MatchScores and MatchScores[lid]
    if not lobby or not sc then return end

    local red, blue
    if next(lobby.ffa or {}) then
        local all = {}
        for src, d in pairs(lobby.ffa      or {}) do all[src] = d end
        for src, d in pairs(lobby.redteam  or {}) do all[src] = d end
        for src, d in pairs(lobby.blueteam or {}) do all[src] = d end
        red, blue = BuildRows(sc, all), {}
    else
        red, blue = BuildRows(sc, lobby.redteam), BuildRows(sc, lobby.blueteam)
    end
    local rScore, bScore = GetTeamScores(lid, lobby, sc)

    local targets = onlySrc and { onlySrc } or (lobby.all or {})
    for _, src in ipairs(targets) do
        TriggerClientEvent("Pug:Client:UpdatePaintballLeaderBoardPositions", src, red, blue, nil)
        TriggerClientEvent("Pug:client:UpdateTeamsScore", src, rScore, bScore)
    end
end

-- Called by sv_lobby.lua when a match starts: fresh ranks + names on the board right away.
function ResetPaintballScoreboard(lid)
    local lobby = Lobbies and Lobbies[lid]
    if not lobby then return end
    for _, src in ipairs(lobby.all or {}) do RankCache[src] = nil end
    BroadcastPaintballScoreboard(lid)
end

-- The client asks for the board (e.g. after a kill).
RegisterNetEvent("Pug:Server:UpdatePaintballLeaderBoard", function()
    local src = source
    local lid = PlayerLobby and PlayerLobby[src]
    if lid then BroadcastPaintballScoreboard(lid, src) end
end)

AddEventHandler("playerDropped", function()
    RankCache[source] = nil
end)

-----------------------------------------------------------------------
-- Kill event handler
-- [REPAIRED]: Receives kill reports from client.lua (obfuscated); validates,
--             updates scores, broadcasts kill feed, handles killstreaks.
-----------------------------------------------------------------------
local function ProcessKill(killer, data)
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

    -- Per-player stats for the scoreboard, pushed before anything below can end the match.
    local killerStats = GetStats(sc, killer)
    local victimStats = GetStats(sc, victim)
    killerStats.kills  = killerStats.kills  + 1
    victimStats.deaths = victimStats.deaths + 1
    BroadcastPaintballScoreboard(lid)

    -- Client-side kill rewards: Gun Game ladder, OITC ammo, UAV / special weapon offers.
    TriggerClientEvent("Pug:client:UpdatePlayersKillStreak", killer)

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
end

RegisterNetEvent("Pug:SV:PlayerKilledInPaintball", function(data)
    ProcessKill(source, data)
end)

-- What the client actually sends: the VICTIM reports who killed them.
RegisterNetEvent("Pug:server:PaintBallKillUpdate", function(killerSrc, weapon, headshot)
    local victim = source
    local lid, lobby = GetLobbyAndTeam(victim)
    if not lid or not lobby or not lobby.started then return end
    local sc = MatchScores and MatchScores[lid]
    if not sc then return end

    killerSrc = tonumber(killerSrc)
    local killerLid = killerSrc and killerSrc > 0 and GetLobbyAndTeam(killerSrc) or nil
    if killerLid ~= lid or killerSrc == victim then
        -- Fall, suicide or a non-player killer: only a death.
        local victimStats = GetStats(sc, victim)
        victimStats.deaths = victimStats.deaths + 1
        ResetStreak(victim)
        BroadcastPaintballScoreboard(lid)
        return
    end

    ProcessKill(killerSrc, { victim = victim, weapon = weapon, headshot = headshot == true })
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
    local confirmStats = GetStats(sc, source)
    confirmStats.score = confirmStats.score + 1
    BroadcastPaintballScoreboard(lid)

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
