-- filename: server/sv_lobby.lua
-- [REPAIRED]: Entire file reconstructed — handles lobby lifecycle, team joining,
--             game start/end, wager payouts, host migration, and all lobby callbacks.

-----------------------------------------------------------------------
-- State
-----------------------------------------------------------------------
Lobbies      = {}   -- [lobbyId] = { ...lobby data }
PlayerLobby  = {}   -- [sourceId] = lobbyId   (which lobby a player is currently in)
LobbyCounter = 0

-----------------------------------------------------------------------
-- Internal helpers
-----------------------------------------------------------------------

local function NextLobbyId()
    LobbyCounter = LobbyCounter + 1
    return LobbyCounter
end

-- Returns the lobby a player is currently in, or nil.
local function GetPlayerLobby(src)
    local lid = PlayerLobby[src]
    return lid and Lobbies[lid], lid
end

-- Returns the first started Config.Arenas key (for random map selection).
local function PickRandomMap()
    local keys = {}
    for k in pairs(Config.Arenas or {}) do keys[#keys+1] = k end
    if #keys == 0 then return "Unknown" end
    return keys[math.random(#keys)]
end

-- Returns a readable display name for a game mode name string.
local function GetDefaultMode()
    for _, gm in pairs(Config.GameModes or {}) do
        return gm.name
    end
    return "Team_DeathMatch"
end

-- Broadcast a UI-refresh notification to all members of a lobby.
local function NotifyLobbyDirty(lobbyId)
    local lobby = Lobbies[lobbyId]
    if not lobby then return end
    local all = lobby.all or {}
    for _, src in ipairs(all) do
        TriggerClientEvent("Pug:client:LobbyDirty", src, lobbyId)
    end
end

-- Rebuild the flat `all` membership list and display arrays from team tables.
local function RebuildLobbyMeta(lobby)
    local all = {}
    local playsred  = {}
    local playsblue = {}
    local playsdisp = {}

    for src, d in pairs(lobby.redteam or {}) do
        all[#all+1] = src
        playsred[#playsred+1] = d.name or GetPlayerName(src) or tostring(src)
    end
    for src, d in pairs(lobby.blueteam or {}) do
        all[#all+1] = src
        playsblue[#playsblue+1] = d.name or GetPlayerName(src) or tostring(src)
    end
    for src, d in pairs(lobby.ffa or {}) do
        all[#all+1] = src
        playsdisp[#playsdisp+1] = d.name or GetPlayerName(src) or tostring(src)
    end

    lobby.all          = all
    lobby.playsred     = playsred
    lobby.playsblue    = playsblue
    lobby.PlayersDisplay = playsdisp
    lobby.redT         = #playsred
    lobby.blueT        = #playsblue
    lobby.players      = #all
    lobby.playersffa   = #playsdisp
end

-- Remove a source from every team table in a lobby.
local function RemoveSrcFromLobby(lobby, src)
    if lobby.redteam  then lobby.redteam[src]  = nil end
    if lobby.blueteam then lobby.blueteam[src] = nil end
    if lobby.ffa      then lobby.ffa[src]      = nil end
end

-----------------------------------------------------------------------
-- Wager helpers
-----------------------------------------------------------------------

-- [REPAIRED]: Deducts wager from a player using the framework money abstraction.
local function TakeWagerFromPlayer(src, amount)
    if not amount or amount <= 0 then return true end
    local player = Config.FrameworkFunctions.GetPlayer(src)
    if not player then return false end
    local currency = Config.Currency or "bank"
    local balance  = (player.PlayerData.money and player.PlayerData.money[currency]) or 0
    if balance < amount then return false end
    player.RemoveMoney(currency, amount)
    return true
end

local function GiveWagerToPlayer(src, amount)
    if not amount or amount <= 0 then return end
    local player = Config.FrameworkFunctions.GetPlayer(src)
    if not player then return end
    player.AddMoney(Config.Currency or "bank", amount)
end

-- Collect wagers from all lobby members, return total collected.
local function CollectWagers(lobby)
    if not Config.EnableWager or not lobby.amount or lobby.amount <= 0 then
        return 0
    end
    local total = 0
    for src in pairs(lobby.redteam  or {}) do
        if TakeWagerFromPlayer(src, lobby.amount) then total = total + lobby.amount end
    end
    for src in pairs(lobby.blueteam or {}) do
        if TakeWagerFromPlayer(src, lobby.amount) then total = total + lobby.amount end
    end
    for src in pairs(lobby.ffa      or {}) do
        if TakeWagerFromPlayer(src, lobby.amount) then total = total + lobby.amount end
    end
    return total
end

-- Distribute winnings from the pot to the winning team members.
local function DistributeWinnings(lobby, winnerTeam, pot)
    if pot <= 0 then return end

    -- Business cut (QB-Core only, when enabled)
    if Config.PaintballIsABusiness and Framework == "QBCore" then
        local businessCut = math.floor(pot * 0.15)
        pot = pot - businessCut
        -- award to business job account via QBCore money system
        local biz = Config.PaintballBusinessName or "paintball"
        local ok, err = pcall(function()
            exports["qb-management"]:AddMoney(biz, businessCut)
        end)
        if not ok and Config.Debug then
            print("[pug-paintball] Business payout failed: " .. tostring(err))
        end
    end

    local winners = (winnerTeam == 'redteam') and lobby.redteam
                 or (winnerTeam == 'blueteam') and lobby.blueteam
                 or (winnerTeam == 'ffa')      and lobby.ffa
                 or {}

    local count = 0
    for _ in pairs(winners) do count = count + 1 end
    if count == 0 then return end

    local share = math.floor(pot / count)
    for src in pairs(winners) do
        GiveWagerToPlayer(src, share)
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", src,
            Config.Translations.success and Config.Translations.success.wager_won
                or ("You won $" .. tostring(share) .. "!"),
            "success", 4000)
    end
end

-----------------------------------------------------------------------
-- Match score tracking (also used by sv_scoreboard.lua)
-----------------------------------------------------------------------
MatchScores = {}   -- [lobbyId] = { redScore=0, blueScore=0, ffaScores={[src]=0}, ggWeapons={[src]=0}, lives={[src]=n} }

local function InitMatchScores(lobbyId, lobby)
    local lives = {}
    local ggIdx = {}
    for src in pairs(lobby.redteam  or {}) do lives[src] = lobby.life or Config.MaxLives ggIdx[src] = 1 end
    for src in pairs(lobby.blueteam or {}) do lives[src] = lobby.life or Config.MaxLives ggIdx[src] = 1 end
    for src in pairs(lobby.ffa      or {}) do lives[src] = lobby.life or Config.MaxLives ggIdx[src] = 1 end
    MatchScores[lobbyId] = {
        redScore   = 0,
        blueScore  = 0,
        ffaScores  = {},
        lives      = lives,
        ggWeapons  = ggIdx,
        kcRed      = 0,
        kcBlue     = 0,
        kcFfa      = 0,
    }
end

-----------------------------------------------------------------------
-- Match end
-----------------------------------------------------------------------
-- [REPAIRED]: Distributes wagers, awards XP, and resets lobby back to pre-game state.
function EndMatch(lobbyId, winnerTeam, reason)
    local lobby = Lobbies[lobbyId]
    if not lobby or not lobby.started then return end

    lobby.started = false
    if lobby.timerThread then
        lobby.timerThread = nil
    end

    local scores  = MatchScores[lobbyId] or {}
    local allAtEnd = {}
    for _, src in ipairs(lobby.all or {}) do allAtEnd[#allAtEnd+1] = src end

    -- Show the end-of-match scoreboard and remove every player from the arena.
    -- DisableKeys (false) displays the NUI scoreboard and locks combat controls
    -- for ~10 s. removeFromArena waits 4 s internally before fading and teleporting.
    for _, src in ipairs(allAtEnd) do
        PaintballReviveGrace[src] = os.time() + 30 -- may still be dead from the final kill
        TriggerClientEvent("Pug:client:DisableKeys", src, false)
        TriggerClientEvent("Pug:paintball:removeFromArena", src)
    end

    -- Award XP via sv_ranks.lua (available at runtime)
    if AwardMatchXP then
        local modeKey = "ffa"
        local mode = lobby.mode or ""
        if mode:find("Team_DeathMatch")   or mode:find("TDM")   then modeKey = "tdm"
        elseif mode:find("Hold_Your_Own") or mode:find("HYO")   then modeKey = "hyo"
        elseif mode:find("Capture")       or mode:find("CTF")   then modeKey = "ctf"
        elseif mode:find("Gun_Game")      or mode:find("GG")    then modeKey = "gg"
        elseif mode:find("One_In_The")    or mode:find("OITC")  then modeKey = "oitc"
        elseif mode:find("Kill_Confirmed") or mode:find("KC")   then modeKey = "kc"
        end

        for src in pairs(lobby.redteam  or {}) do
            AwardMatchXP(src, (winnerTeam == 'redteam') and 'win' or 'loss', modeKey, scores)
        end
        for src in pairs(lobby.blueteam or {}) do
            AwardMatchXP(src, (winnerTeam == 'blueteam') and 'win' or 'loss', modeKey, scores)
        end
        for src in pairs(lobby.ffa      or {}) do
            AwardMatchXP(src, (winnerTeam == src) and 'win' or 'loss', modeKey, scores)
        end
    end

    -- Distribute wager from the pre-collected pot
    if lobby.pot and lobby.pot > 0 then
        DistributeWinnings(lobby, winnerTeam, lobby.pot)
    end

    -- Clean CTF state
    if CTFCleanup then CTFCleanup(lobbyId) end

    MatchScores[lobbyId] = nil

    -- Close menus for all nearby players (lobby NPC area)
    for _, src in ipairs(lobby.all or {}) do
        TriggerClientEvent("Pug:client:CloseAllPaintballMenuWhenStart", src)
    end

    NotifyLobbyDirty(lobbyId)

    -- Refresh the in-world DUI leaderboard so it shows updated stats immediately
    for _, src in ipairs(allAtEnd) do
        TriggerClientEvent("Pug:client:RefreshLeaderboardPaintball", src)
    end

    if Config.Debug then
        print(("[pug-paintball] Match ended. Lobby=%d Winner=%s Reason=%s"):format(
            lobbyId, tostring(winnerTeam), tostring(reason)))
    end
end

-----------------------------------------------------------------------
-- Match start
-----------------------------------------------------------------------
-- [REPAIRED]: Validates lobby, handles wager collection, assigns spawn indices,
--             fires per-player start events, and starts the match timer thread.
function StartMatch(lobbyId)
    local lobby = Lobbies[lobbyId]
    if not lobby or lobby.started then return end

    -- Validate player count requirements
    local redCount  = 0
    local blueCount = 0
    local ffaCount  = 0
    for _ in pairs(lobby.redteam  or {}) do redCount  = redCount  + 1 end
    for _ in pairs(lobby.blueteam or {}) do blueCount = blueCount + 1 end
    for _ in pairs(lobby.ffa      or {}) do ffaCount  = ffaCount  + 1 end

    local isFFA = false
    for _, gm in pairs(Config.GameModes or {}) do
        if (gm.name == lobby.mode) then
            if gm.name == (Config.GameModes["Gun_Game"] and Config.GameModes["Gun_Game"].name)
            or gm.name == (Config.GameModes["Free_For_All"] and Config.GameModes["Free_For_All"].name)
            or gm.name == (Config.GameModes["One_In_The_Chamber"] and Config.GameModes["One_In_The_Chamber"].name) then
                isFFA = true
            end
            break
        end
    end

    if Config.RequirePlayersOnBothTeams and not isFFA then
        if redCount < 1 or blueCount < 1 then
            local host = lobby.host
            if host then
                TriggerClientEvent("Pug:client:PaintballNotifyEvent", host,
                    Config.Translations.error.need_players_on_both_teams or "Need players on both teams.", "error", 3000)
            end
            return
        end
    end

    -- Require at least one player to be on a team before the match can start
    local totalPlayers = redCount + blueCount + ffaCount
    if totalPlayers < 1 then
        local host = lobby.host
        if host then
            TriggerClientEvent("Pug:client:PaintballNotifyEvent", host,
                Config.Translations.error.choose_team_first or "You need to join a team first.", "error", 3000)
        end
        return
    end

    if totalPlayers < (Config.MinTeamPlayersToRewardXP or 1) then
        if Config.Debug then
            print("[pug-paintball] Not enough players to reward XP – continuing anyway.")
        end
    end

    -- Collect wagers before marking started (so players can't leave mid-collect)
    lobby.pot = CollectWagers(lobby)
    lobby.started = true

    RebuildLobbyMeta(lobby)
    InitMatchScores(lobbyId, lobby)

    -- Assign per-player spawn indices
    local redIdx  = 1
    local blueIdx = 1
    local ffaIdx  = 1
    for src, d in pairs(lobby.redteam  or {}) do d.placement = redIdx;  redIdx  = redIdx  + 1 end
    for src, d in pairs(lobby.blueteam or {}) do d.placement = blueIdx; blueIdx = blueIdx + 1 end
    for src, d in pairs(lobby.ffa      or {}) do d.placement = ffaIdx;  ffaIdx  = ffaIdx  + 1 end

    -- Notify all players to close lobby menus
    for _, src in ipairs(lobby.all) do
        TriggerClientEvent("Pug:client:CloseAllPaintballMenuWhenStart", src)
    end

    -- Resolve the arena key (e.g. "Jpark") to the actual interior/set map ID
    -- (e.g. "Set_Dystopian_02") that the client uses for Config.RedTeamSpawns lookups.
    local arenaData  = Config.Arenas and Config.Arenas[lobby.map]
    local actualMapId = (arenaData and arenaData.map) or lobby.map

    -- Build weapon progression list for Gun_Game mode
    local isGunGame = lobby.mode == (Config.GameModes["Gun_Game"] and Config.GameModes["Gun_Game"].name)
    local weaponList = {}
    if isGunGame then
        for _, v in pairs(Config.WeaponItems or {}) do
            weaponList[#weaponList + 1] = v.name
        end
        table.sort(weaponList)
    end

    local allPlayers = lobby.all or {}
    local matchMinutes = lobby.time or 15
    local livesCount   = lobby.life or Config.MaxLives or 7

    -- Fire joinedTeam (sets playerTeam + placement on client) then BeginPaintballMatch
    local function fireMatchStart(src, team, placement)
        TriggerClientEvent("Pug:paintball:joinedTeam", src, team, placement)
        TriggerClientEvent("Pug:paintball:BeginPaintballMatch", src,
            actualMapId,    -- map
            livesCount,     -- lives
            lobby.mode,     -- gameMode
            allPlayers,     -- playerList (length used for spawn-slot assignment)
            weaponList,     -- RndomWeapons array (gun game progression)
            matchMinutes,   -- matchTimer in minutes
            0,              -- redScore
            0,              -- blueScore
            0               -- ffaScore
        )
    end

    for src, d in pairs(lobby.redteam  or {}) do fireMatchStart(src, "redteam", d.placement) end
    for src, d in pairs(lobby.blueteam or {}) do fireMatchStart(src, "blueteam", d.placement) end
    for src, d in pairs(lobby.ffa      or {}) do fireMatchStart(src, "ffa",      d.placement) end

    -- Initialise CTF flags if mode is CTF (pass actual map ID directly)
    if CTFInitMatch then
        CTFInitMatch(lobbyId, actualMapId)
    end

    -- Start match timer
    local timeLimitSecs = (lobby.time or 15) * 60
    Citizen.CreateThread(function()
        local elapsed = 0
        while Lobbies[lobbyId] and Lobbies[lobbyId].started do
            Wait(1000)
            elapsed = elapsed + 1
            if elapsed >= timeLimitSecs then
                -- Time expired — determine winner by score
                local sc = MatchScores[lobbyId]
                local winner = 'tie'
                if sc then
                    if isFFA then
                        local best, bestScore = nil, -1
                        for src, score in pairs(sc.ffaScores or {}) do
                            if score > bestScore then bestScore = score; best = src end
                        end
                        winner = best or 'tie'
                    else
                        if (sc.redScore or 0) > (sc.blueScore or 0) then winner = 'redteam'
                        elseif (sc.blueScore or 0) > (sc.redScore or 0) then winner = 'blueteam'
                        end
                    end
                end
                EndMatch(lobbyId, winner, 'timeout')
                return
            end
        end
    end)

    if Config.Debug then
        print(("[pug-paintball] Match started. Lobby=%d Map=%s Mode=%s Players=%d"):format(
            lobbyId, tostring(lobby.map), tostring(lobby.mode), totalPlayers))
    end
end

-----------------------------------------------------------------------
-- Lobby cleanup on player disconnect
-----------------------------------------------------------------------
-- [REPAIRED]: Removes disconnected player from their lobby; migrates host if needed.
function CleanupPlayerFromLobbies(src)
    local lobbyId = PlayerLobby[src]
    if not lobbyId then return end

    PlayerLobby[src] = nil
    local lobby = Lobbies[lobbyId]
    if not lobby then return end

    RemoveSrcFromLobby(lobby, src)
    RebuildLobbyMeta(lobby)

    if lobby.started and #(lobby.all or {}) == 0 then
        EndMatch(lobbyId, nil, 'empty')
        Lobbies[lobbyId] = nil
        if MatchScores[lobbyId] then MatchScores[lobbyId] = nil end
        if CTFCleanup then CTFCleanup(lobbyId) end
        return
    end

    -- Host migration
    if lobby.host == src then
        -- Pick a new host from remaining members
        local newHost = nil
        for _, remaining in ipairs(lobby.all or {}) do
            newHost = remaining; break
        end
        if newHost then
            lobby.host = newHost
            TriggerClientEvent("Pug:client:DoLobbyHostLoop", newHost)
            TriggerClientEvent("Pug:client:StopLobbyHostLoop", src)
            -- Notify old host's stop
            NotifyLobbyDirty(lobbyId)
        else
            -- Empty lobby — destroy it
            Lobbies[lobbyId] = nil
            if MatchScores[lobbyId] then MatchScores[lobbyId] = nil end
            if CTFCleanup then CTFCleanup(lobbyId) end
        end
    else
        NotifyLobbyDirty(lobbyId)
    end
end

-----------------------------------------------------------------------
-- Callbacks
-----------------------------------------------------------------------

-- [REPAIRED]: Returns the lobby ID the requesting player is currently in.
Config.FrameworkFunctions.CreateCallback("Pug:Lobby:GetMine", function(source, cb)
    cb(PlayerLobby[source])
end)

-- [REPAIRED]: Returns a summary list of all open lobbies for the browser UI.
Config.FrameworkFunctions.CreateCallback("Pug:Lobby:List", function(source, cb)
    local list = {}
    for id, lobby in pairs(Lobbies) do
        list[#list+1] = {
            id      = id,
            name    = lobby.name,
            map     = lobby.map,
            mode    = lobby.mode,
            locked  = lobby.locked,
            red     = lobby.redT   or 0,
            blue    = lobby.blueT  or 0,
            players = lobby.players or 0,
        }
    end
    cb(list)
end)

-- [REPAIRED]: Validates a passcode before allowing a player to view a locked lobby.
Config.FrameworkFunctions.CreateCallback("Pug:Lobby:Gate", function(source, cb, lobbyId, passcode)
    local lobby = Lobbies[lobbyId]
    if not lobby then
        cb(false, Config.Translations.error.lobby_no_longer_exists or "Lobby not found.")
        return
    end
    if not lobby.locked then
        cb(true)
        return
    end
    if tostring(lobby.passcode) == tostring(passcode) then
        cb(true)
    else
        cb(false, Config.Translations.error.incorrect_passcode or "Incorrect passcode.")
    end
end)

-- [REPAIRED]: Returns full lobby details for the lobby view UI, including the
--             requesting player's rank data injected from sv_ranks.lua.
Config.FrameworkFunctions.CreateCallback("Pug:SVCB:GetLobbyDetails", function(source, cb, args)
    local lobbyId = args and args.lobbyId
    if not lobbyId then cb(nil) return end
    local lobby = Lobbies[lobbyId]
    if not lobby then cb(nil) return end

    RebuildLobbyMeta(lobby)

    -- Determine this player's team
    local myTeam = nil
    if lobby.redteam  and lobby.redteam[source]  then myTeam = 'redteam'
    elseif lobby.blueteam and lobby.blueteam[source] then myTeam = 'blueteam'
    elseif lobby.ffa      and lobby.ffa[source]      then myTeam = 'ffa'
    end

    -- Rank data from sv_ranks.lua (available at runtime)
    local myXP, myLevel, myPrestige, myXPInto, myXPNext, myRank = 0, 1, 0, 0, 45, 0
    if GetPlayerRankData then
        local cid = GetPlayerCID(source)
        local rd  = GetPlayerRankData(cid)
        if rd then
            myXP       = rd.xp       or 0
            myLevel    = rd.level    or 1
            myPrestige = rd.prestige or 0
            myXPInto   = rd.xpIntoLevel or 0
            myXPNext   = rd.xpForNext   or 45
        end
    end
    if GetGlobalRankPosition then
        myRank = GetGlobalRankPosition(GetPlayerCID(source)) or 0
    end

    cb({
        id             = lobbyId,
        name           = lobby.name,
        host           = lobby.host,
        map            = lobby.map,
        mode           = lobby.mode,
        weapon         = lobby.weapon,
        time           = lobby.time,
        amount         = lobby.amount,
        life           = lobby.life,
        started        = lobby.started,
        locked         = lobby.locked,
        redT           = lobby.redT  or 0,
        blueT          = lobby.blueT or 0,
        players        = lobby.players or 0,
        playersffa     = lobby.playersffa or 0,
        playsred       = lobby.playsred   or {},
        playsblue      = lobby.playsblue  or {},
        PlayersDisplay = lobby.PlayersDisplay or {},
        all            = lobby.all or {},
        myTeam         = myTeam,
        myXP           = myXP,
        myLevel        = myLevel,
        myPrestige     = myPrestige,
        myXPIntoLevel  = myXPInto,
        myXPForNext    = myXPNext,
        myRank         = myRank,
    })
end)

-- [REPAIRED]: Returns whether the lobby the caller is in currently has a running match.
Config.FrameworkFunctions.CreateCallback("Pug:serverCB:Checkongoinggame", function(source, cb)
    local lobbyId = PlayerLobby[source]
    if not lobbyId then cb(false) return end
    local lobby = Lobbies[lobbyId]
    cb(lobby ~= nil and lobby.started == true)
end)

-- [REPAIRED]: Returns a list of active players in a lobby for the spectate menu.
Config.FrameworkFunctions.CreateCallback("Pug:SVCB:Specatateplayers", function(source, cb, lobbyId)
    local lid = lobbyId or PlayerLobby[source]
    if not lid then cb(nil) return end
    local lobby = Lobbies[lid]
    if not lobby or not lobby.started then cb(nil) return end

    local info = {}
    local function addTeam(team)
        for src, d in pairs(team or {}) do
            info[#info+1] = {
                id   = src,
                name = d.name or GetPlayerName(src) or tostring(src),
            }
        end
    end
    addTeam(lobby.redteam)
    addTeam(lobby.blueteam)
    addTeam(lobby.ffa)
    cb(#info > 0 and info or nil)
end)

-- [REPAIRED]: Returns the member list of a lobby (for the kick-player menu).
Config.FrameworkFunctions.CreateCallback("Pug:Lobby:GetMembers", function(source, cb, lobbyId)
    local lid = lobbyId or PlayerLobby[source]
    if not lid then cb({}) return end
    local lobby = Lobbies[lid]
    if not lobby then cb({}) return end

    local members = {}
    local function addTeam(team, teamName)
        for src, d in pairs(team or {}) do
            members[#members+1] = {
                id     = src,
                name   = d.name or GetPlayerName(src) or tostring(src),
                team   = teamName,
                isHost = (src == lobby.host),
            }
        end
    end
    addTeam(lobby.redteam,  "redteam")
    addTeam(lobby.blueteam, "blueteam")
    addTeam(lobby.ffa,      "ffa")
    cb(members)
end)

-----------------------------------------------------------------------
-- Lobby creation
-----------------------------------------------------------------------
-- [REPAIRED]: Creates a new lobby entry in-memory with default settings.
RegisterNetEvent("Pug:Lobby:Create", function(data)
    local source = source
    if not data or not data.name or data.name == "" then
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
            Config.Translations.menu.must_enter_lobby_name or "Enter a lobby name.", "error", 3000)
        return
    end

    -- One lobby per player
    if PlayerLobby[source] then
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
            Config.Translations.error.already_in_lobby or "You are already in a lobby.", "error", 3000)
        return
    end

    local id   = NextLobbyId()
    local name = tostring(data.name):sub(1, 32)
    local pass = (data.passcode and data.passcode ~= "") and tostring(data.passcode) or nil

    Lobbies[id] = {
        id        = id,
        name      = name,
        host      = source,
        map       = PickRandomMap(),
        mode      = GetDefaultMode(),
        weapon    = Config.HostOnlyCanControllWeaponSelect and "weapon_pistol" or "weapon_unarmed",
        time      = Config.GameTimerLimitOptions and Config.GameTimerLimitOptions[1] or 15,
        amount    = Config.MinWager or 0,
        life      = Config.MaxLives or 7,
        started   = false,
        locked    = pass ~= nil,
        passcode  = pass,
        redteam   = {},
        blueteam  = {},
        ffa       = {},
        all       = { source },
        playsred  = {},
        playsblue = {},
        PlayersDisplay = {},
        redT      = 0,
        blueT     = 0,
        players   = 1,
        playersffa = 0,
        pot       = 0,
    }

    PlayerLobby[source] = id

    -- Start the host proximity loop on the creating client
    TriggerClientEvent("Pug:client:DoLobbyHostLoop", source)

    if Config.Debug then
        print(("[pug-paintball] Lobby #%d created by %d: %s"):format(id, source, name))
    end
end)

-----------------------------------------------------------------------
-- Team joining / leaving
-----------------------------------------------------------------------
-- [REPAIRED]: Joins a player to their chosen team; auto-creates lobby entry if
--             they are not yet in one (e.g. joining an unlocked lobby directly).
RegisterNetEvent("Pug:paintball:JoinTeam", function(team, lobbyId)
    local source = source
    local lid = lobbyId or PlayerLobby[source]
    if not lid then
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
            Config.Translations.error.you_are_not_in_lobby or "No lobby found.", "error", 3000)
        return
    end

    local lobby = Lobbies[lid]
    if not lobby then
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
            Config.Translations.error.lobby_no_longer_exists or "Lobby no longer exists.", "error", 3000)
        return
    end

    if lobby.started then
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
            Config.Translations.error.active_game or "Match already running.", "error", 3000)
        return
    end

    -- Register in lobby if new arrival
    if not PlayerLobby[source] then
        PlayerLobby[source] = lid
    end

    -- Remove from any current team first
    RemoveSrcFromLobby(lobby, source)

    local pName = GetPlayerFullName(source)

    if team == 'redteam' then
        local count = 0; for _ in pairs(lobby.redteam) do count = count + 1 end
        if count >= (Config.MaxTeam or 12) then
            TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
                Config.Translations.error.team_full or "Team is full.", "error", 3000)
            return
        end
        lobby.redteam[source] = { name = pName }

    elseif team == 'blueteam' then
        local count = 0; for _ in pairs(lobby.blueteam) do count = count + 1 end
        if count >= (Config.MaxTeam or 12) then
            TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
                Config.Translations.error.team_full or "Team is full.", "error", 3000)
            return
        end
        lobby.blueteam[source] = { name = pName }

    elseif team == 'ffa' then
        local count = 0; for _ in pairs(lobby.ffa) do count = count + 1 end
        if count >= 24 then
            TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
                Config.Translations.error.team_full or "FFA is full.", "error", 3000)
            return
        end
        lobby.ffa[source] = { name = pName }
    end

    RebuildLobbyMeta(lobby)
    NotifyLobbyDirty(lid)
end)

-- [REPAIRED]: Leaves the player's current team (keeps them in the lobby as a spectator).
RegisterNetEvent("Pug:paintball:Leave", function(team)
    local source = source
    local lid    = PlayerLobby[source]
    if not lid then return end
    local lobby  = Lobbies[lid]
    if not lobby then return end

    RemoveSrcFromLobby(lobby, source)
    RebuildLobbyMeta(lobby)
    NotifyLobbyDirty(lid)
end)

-- [REPAIRED]: Removes a player from an active match (surrender via radial menu).
RegisterNetEvent("Pug:paintball:RemovePlayer", function(team)
    local source = source
    local lid    = PlayerLobby[source]
    if not lid then return end
    local lobby  = Lobbies[lid]
    if not lobby then return end

    RemoveSrcFromLobby(lobby, source)
    PlayerLobby[source] = nil
    RebuildLobbyMeta(lobby)

    TriggerClientEvent("Pug:paintball:removeFromArena", source)

    -- If this was the last player in an active match, dissolve the lobby
    if lobby.started and #(lobby.all or {}) == 0 then
        EndMatch(lid, nil, 'empty')
        Lobbies[lid] = nil
        if MatchScores[lid] then MatchScores[lid] = nil end
        if CTFCleanup then CTFCleanup(lid) end
        return
    end

    NotifyLobbyDirty(lid)
end)

-- Leave the lobby entirely (not just the team)
RegisterNetEvent("Pug:Lobby:LeaveLobby", function()
    local source = source
    local lid    = PlayerLobby[source]
    if not lid then return end
    local lobby  = Lobbies[lid]

    PlayerLobby[source] = nil
    if not lobby then return end

    RemoveSrcFromLobby(lobby, source)
    RebuildLobbyMeta(lobby)

    TriggerClientEvent("Pug:client:StopLobbyHostLoop", source)

    if lobby.host == source then
        -- Migrate host
        local newHost = nil
        for _, m in ipairs(lobby.all or {}) do
            if m ~= source then newHost = m break end
        end
        if newHost then
            lobby.host = newHost
            TriggerClientEvent("Pug:client:DoLobbyHostLoop", newHost)
        else
            Lobbies[lid] = nil
            if MatchScores[lid] then MatchScores[lid] = nil end
            return
        end
    end

    NotifyLobbyDirty(lid)
end)

-----------------------------------------------------------------------
-- Lobby management events (host-only)
-----------------------------------------------------------------------

-- [REPAIRED]: Shuts down the lobby and removes all members.
RegisterNetEvent("Pug:Lobby:Shutdown", function()
    local source = source
    local lid    = PlayerLobby[source]
    if not lid then return end
    local lobby  = Lobbies[lid]
    if not lobby then return end
    if lobby.host ~= source then return end

    for _, src in ipairs(lobby.all or {}) do
        PlayerLobby[src] = nil
        TriggerClientEvent("Pug:client:StopLobbyHostLoop", src)
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", src,
            Config.Translations.error.lobby_no_longer_exists or "Lobby was shut down.", "error", 3000)
    end
    Lobbies[lid] = nil
    if MatchScores[lid] then MatchScores[lid] = nil end
    if CTFCleanup then CTFCleanup(lid) end
end)

-- [REPAIRED]: Sets or clears a lobby passcode.
RegisterNetEvent("Pug:Lobby:SetPasscode", function(lobbyId, pass)
    local source = source
    local lid    = lobbyId or PlayerLobby[source]
    if not lid then return end
    local lobby  = Lobbies[lid]
    if not lobby or lobby.host ~= source then return end

    if pass and pass ~= "" then
        lobby.passcode = tostring(pass)
        lobby.locked   = true
    else
        lobby.passcode = nil
        lobby.locked   = false
    end
    NotifyLobbyDirty(lid)
end)

-- [REPAIRED]: Kicks a player from the lobby (host-only).
RegisterNetEvent("Pug:Lobby:KickPlayer", function(lobbyId, targetId)
    local source  = source
    local lid     = lobbyId or PlayerLobby[source]
    if not lid then return end
    local lobby   = Lobbies[lid]
    if not lobby or lobby.host ~= source then return end
    targetId = tonumber(targetId)
    if not targetId or targetId == source then return end

    RemoveSrcFromLobby(lobby, targetId)
    PlayerLobby[targetId] = nil
    RebuildLobbyMeta(lobby)

    TriggerClientEvent("Pug:client:StopLobbyHostLoop", targetId)
    TriggerClientEvent("Pug:client:PaintballNotifyEvent", targetId,
        Config.Translations.error.kicked_from_lobby or "You were kicked from the lobby.", "error", 4000)
    NotifyLobbyDirty(lid)
end)

-- [REPAIRED]: Sets match time limit.
RegisterNetEvent("Pug:SV:SetMatchTime", function(minutes)
    local source = source
    local lid    = PlayerLobby[source]
    local lobby  = lid and Lobbies[lid]
    if not lobby or lobby.host ~= source or lobby.started then return end
    lobby.time = tonumber(minutes) or lobby.time
    NotifyLobbyDirty(lid)
end)

-- [REPAIRED]: Sets lives per player (Hold Your Own / OITC).
RegisterNetEvent("Pug:SV:SetlivesOfPlayers", function(amount)
    local source = source
    local lid    = PlayerLobby[source]
    local lobby  = lid and Lobbies[lid]
    if not lobby or lobby.host ~= source or lobby.started then return end
    local n = tonumber(amount)
    if n and n >= 1 and n <= (Config.MaxLives or 7) then
        lobby.life = n
    end
    NotifyLobbyDirty(lid)
end)

-- [REPAIRED]: Sets the wager amount for the match.
RegisterNetEvent("Pug:SV:SetWagerOfLobby", function(amount)
    local source = source
    local lid    = PlayerLobby[source]
    local lobby  = lid and Lobbies[lid]
    if not lobby or lobby.host ~= source or lobby.started then return end
    local n = tonumber(amount)
    if n and n >= (Config.MinWager or 0) and n <= (Config.MaxWager or 25000) then
        lobby.amount = n
    end
    NotifyLobbyDirty(lid)
end)

-- [REPAIRED]: Sets the arena map for the lobby.
RegisterNetEvent("Pug:SV:SetArenaMap", function(arenaMap)
    local source = source
    local lid    = PlayerLobby[source]
    local lobby  = lid and Lobbies[lid]
    if not lobby or lobby.host ~= source or lobby.started then return end

    if arenaMap == 'random' then
        lobby.map = PickRandomMap()
    elseif Config.Arenas and Config.Arenas[arenaMap] then
        lobby.map = arenaMap
    end
    NotifyLobbyDirty(lid)
end)

-- [REPAIRED]: Sets the weapon for all players in the lobby (host-only gate enforced client-side).
RegisterNetEvent("Pug:server:SetAllPlayersWeapons", function(weapon)
    local source = source
    local lid    = PlayerLobby[source]
    local lobby  = lid and Lobbies[lid]
    if not lobby or lobby.host ~= source then return end
    if not Config.WeaponItems or not Config.WeaponItems[weapon] then return end
    lobby.weapon = weapon

    -- Broadcast new weapon to all lobby members
    for _, src in ipairs(lobby.all or {}) do
        TriggerClientEvent("Pug:client:LobbyDirty", src, lid)
    end
end)

-- [REPAIRED]: Sets the game mode for the lobby.
RegisterNetEvent("Pug:server:ChoseGameMode", function(mode)
    local source = source
    local lid    = PlayerLobby[source]
    local lobby  = lid and Lobbies[lid]
    if not lobby or lobby.host ~= source or lobby.started then return end
    lobby.mode = mode
    NotifyLobbyDirty(lid)
end)

-- [REPAIRED]: Transfers lobby host role to another player (must be in same lobby).
RegisterNetEvent("Pug:server:MakePlayerGameHost", function(targetId)
    local source   = source
    local lid      = PlayerLobby[source]
    local lobby    = lid and Lobbies[lid]
    targetId = tonumber(targetId)
    if not lobby or lobby.host ~= source or lobby.started then return end
    if not targetId then return end
    -- Verify target is in this lobby
    if PlayerLobby[targetId] ~= lid then
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
            Config.Translations.error.player_not_in_lobby or "Player is not in this lobby.", "error", 3000)
        return
    end
    lobby.host = targetId
    TriggerClientEvent("Pug:client:StopLobbyHostLoop", source)
    TriggerClientEvent("Pug:client:DoLobbyHostLoop",   targetId)
    NotifyLobbyDirty(lid)
end)

-- [REPAIRED]: Host proximity check — migrate host when they walk away.
RegisterNetEvent("Pug:paintball:HostTooFar", function()
    local source = source
    local lid    = PlayerLobby[source]
    local lobby  = lid and Lobbies[lid]
    if not lobby or lobby.host ~= source or lobby.started then return end

    -- Find next eligible host (first redteam member, else blueteam, else ffa)
    local newHost = nil
    for src in pairs(lobby.redteam  or {}) do if src ~= source then newHost = src break end end
    if not newHost then
        for src in pairs(lobby.blueteam or {}) do if src ~= source then newHost = src break end end
    end
    if not newHost then
        for src in pairs(lobby.ffa      or {}) do if src ~= source then newHost = src break end end
    end

    if newHost then
        lobby.host = newHost
        TriggerClientEvent("Pug:client:StopLobbyHostLoop", source)
        TriggerClientEvent("Pug:client:DoLobbyHostLoop",   newHost)
        NotifyLobbyDirty(lid)
    end
end)

-- [REPAIRED]: Server-side game start handler; fired by client.lua after the host
--             clicks Start in the lobby menu.
RegisterNetEvent("Pug:paintball:startGame", function()
    local source = source
    local lid    = PlayerLobby[source]
    local lobby  = lid and Lobbies[lid]
    if not lobby then return end
    if lobby.host ~= source then
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
            Config.Translations.error.need_to_be_lobby_host or "Only the host can start.", "error", 3000)
        return
    end
    if lobby.started then return end
    if Config.RequireAdminToStartGame and not IsAdmin(source) then
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
            Config.Translations.error.not_admin or "Not authorised to start.", "error", 3000)
        return
    end
    StartMatch(lid)
end)
