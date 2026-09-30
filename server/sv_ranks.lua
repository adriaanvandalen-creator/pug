-- filename: server/sv_ranks.lua
-- [REPAIRED]: Reconstructed missing ranks file; implements the XP formula from
--             Config.Leveling, per-kill XP awards, match-end stat persistence,
--             prestige handling, rank-up notifications, and the leaderboard callback.

-----------------------------------------------------------------------
-- XP formula helpers  (mirrors Config.Leveling.XPFormula)
-----------------------------------------------------------------------

-- Returns XP required to complete a single level (the cost to reach level+1).
local function GetXPForLevel(level)
    local f = Config.Leveling.XPFormula
    return (f.Base or 45) + (f.Linear or 11) * level + (f.Quadratic or 1) * level * level
end

-- Returns total XP cost to complete a full prestige (all 50 levels).
local function GetXPForFullPrestige()
    local total = 0
    for l = 1, (Config.Leveling.MaxLevel or 50) do
        total = total + GetXPForLevel(l)
    end
    return total
end

local FULL_PRESTIGE_XP = nil   -- lazy-cached

local function FullPrestigeXP()
    if not FULL_PRESTIGE_XP then
        FULL_PRESTIGE_XP = GetXPForFullPrestige()
    end
    return FULL_PRESTIGE_XP
end

-- [REPAIRED]: Converts raw total XP into { prestige, level, xpIntoLevel, xpForNext }.
-- Global so sv_ctf.lua can reference it for CTF capture rank-up checks.
function CalculateRankFromXP(totalXP)
    local xp         = math.max(0, totalXP or 0)
    local prestige   = 0
    local maxPres    = Config.Leveling.MaxPrestige or 10
    local maxLevel   = Config.Leveling.MaxLevel    or 50
    local fpXP       = FullPrestigeXP()

    while xp >= fpXP and prestige < maxPres do
        xp       = xp - fpXP
        prestige = prestige + 1
    end

    local level = 1
    for l = 1, maxLevel do
        local needed = GetXPForLevel(l)
        if xp >= needed then
            xp    = xp - needed
            level = l + 1
            if level > maxLevel then
                level = maxLevel
                xp    = 0
                break
            end
        else
            break
        end
    end

    local xpForNext = (level < maxLevel) and GetXPForLevel(level) or 0
    return {
        prestige     = prestige,
        level        = level,
        xpIntoLevel  = xp,
        xpForNext    = xpForNext,
    }
end

-----------------------------------------------------------------------
-- Upsert a player's rank row (create if missing)
-----------------------------------------------------------------------
local function EnsureRankRow(citizenid, name)
    if name then
        MySQL.query(
            "INSERT INTO paintball_ranks (citizenid, name) VALUES (?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name)",
            { citizenid, name }
        )
    else
        MySQL.query(
            "INSERT IGNORE INTO paintball_ranks (citizenid) VALUES (?)",
            { citizenid }
        )
    end
end

-----------------------------------------------------------------------
-- Public: GetPlayerRankData
-- Called by sv_lobby.lua when building Pug:SVCB:GetLobbyDetails response.
-----------------------------------------------------------------------
-- [REPAIRED]: Returns a populated rank data table; creates the DB row if absent.
function GetPlayerRankData(citizenid)
    if not citizenid then return nil end
    EnsureRankRow(citizenid)
    local rows = MySQL.query.await(
        "SELECT * FROM paintball_ranks WHERE citizenid = ? LIMIT 1",
        { citizenid }
    )
    if not rows or not rows[1] then
        return { xp=0, level=1, prestige=0, kills=0, deaths=0, wins=0, losses=0,
                 headshots=0, xpIntoLevel=0, xpForNext=GetXPForLevel(1) }
    end
    local row      = rows[1]
    local rankInfo = CalculateRankFromXP(row.xp or 0)
    return {
        xp          = row.xp       or 0,
        level       = rankInfo.level,
        prestige    = rankInfo.prestige,
        xpIntoLevel = rankInfo.xpIntoLevel,
        xpForNext   = rankInfo.xpForNext,
        kills       = row.kills    or 0,
        deaths      = row.deaths   or 0,
        wins        = row.wins     or 0,
        losses      = row.losses   or 0,
        headshots   = row.headshots or 0,
    }
end

-----------------------------------------------------------------------
-- Public: GetGlobalRankPosition
-- Called by sv_lobby.lua to inject 'myRank' into lobby details.
-----------------------------------------------------------------------
-- [REPAIRED]: Counts how many players have more XP (1-based rank position).
function GetGlobalRankPosition(citizenid)
    if not citizenid then return 0 end
    local rows = MySQL.query.await(
        "SELECT COUNT(*) AS cnt FROM paintball_ranks WHERE xp > COALESCE((SELECT xp FROM paintball_ranks WHERE citizenid = ?), -1)",
        { citizenid }
    )
    if rows and rows[1] then
        return (rows[1].cnt or 0) + 1
    end
    return 0
end

-----------------------------------------------------------------------
-- Per-kill XP award  (immediate, small)
-----------------------------------------------------------------------
-- [REPAIRED]: Called by sv_scoreboard.lua on every confirmed kill; awards
--             Kill and Headshot XP immediately and checks for level-up.
function AwardKillXP(source, headshot, modeKey)
    local cid = GetPlayerCID and GetPlayerCID(source)
    if not cid then return end

    local xpGain = Config.Leveling.XPRewards.Kill or 25
    if headshot then
        xpGain = xpGain + (Config.Leveling.XPRewards.HeadshotBonus or 10)
    end
    if modeKey == "kc_confirm" then
        xpGain = Config.Leveling.XPRewards.Confirm or 50
    end

    EnsureRankRow(cid, GetPlayerFullName(source))

    local before = MySQL.query.await(
        "SELECT xp, kills, headshots FROM paintball_ranks WHERE citizenid = ? LIMIT 1",
        { cid }
    )
    local bRow = (before and before[1]) or { xp = 0, kills = 0, headshots = 0 }

    local headshotInc = headshot and 1 or 0
    local killInc     = (modeKey ~= "kc_confirm") and 1 or 0
    local modeKillCol = (modeKey and modeKey ~= "kc_confirm") and (modeKey .. "_kills") or nil

    local setSQL = "xp = xp + ?, kills = kills + ?, headshots = headshots + ?"
    local params = { xpGain, killInc, headshotInc }

    if modeKillCol then
        setSQL  = setSQL .. ", `" .. modeKillCol .. "` = `" .. modeKillCol .. "` + ?"
        params[#params+1] = killInc
    end
    params[#params+1] = cid

    MySQL.query("UPDATE paintball_ranks SET " .. setSQL .. " WHERE citizenid = ?", params)

    -- Check for rank-up notification
    local newXP = (bRow.xp or 0) + xpGain
    local oldRank = CalculateRankFromXP(bRow.xp or 0)
    local newRank = CalculateRankFromXP(newXP)

    if newRank.level > oldRank.level or newRank.prestige > oldRank.prestige then
        TriggerClientEvent("Pug:client:PaintballRankUp", source, {
            oldLevel    = oldRank.level,
            newLevel    = newRank.level,
            oldPrestige = oldRank.prestige,
            newPrestige = newRank.prestige,
            xp          = newXP,
        })
        TriggerClientEvent("Pug:client:PlayPaintballClientSound", source, "rankup", 0.05)
    end
end

-----------------------------------------------------------------------
-- Match-end XP + stat persistence
-----------------------------------------------------------------------
-- [REPAIRED]: Called by sv_lobby.lua EndMatch for each participant; persists full
--             match stats and win/loss XP into paintball_ranks.
function AwardMatchXP(source, result, modeKey, scores)
    local cid = GetPlayerCID and GetPlayerCID(source)
    if not cid then return end

    local rewards = Config.Leveling.XPRewards
    local xpGain  = rewards.MatchComplete or 200
    local winInc  = 0
    local lossInc = 0

    if result == 'win' then
        xpGain  = xpGain + (rewards.Win  or 750)
        winInc  = 1
    elseif result == 'loss' then
        xpGain  = xpGain + (rewards.Loss or 250)
        lossInc = 1
    end

    local modeWinCol  = modeKey and (modeKey .. "_wins")
    local modeLossCol = modeKey and (modeKey .. "_losses")

    EnsureRankRow(cid, GetPlayerFullName(source))

    local before = MySQL.query.await(
        "SELECT xp FROM paintball_ranks WHERE citizenid = ? LIMIT 1",
        { cid }
    )
    local bXP = (before and before[1] and before[1].xp) or 0

    local setSQL = "xp = xp + ?, wins = wins + ?, losses = losses + ?"
    local params = { xpGain, winInc, lossInc }

    if modeWinCol and winInc > 0 then
        setSQL  = setSQL .. ", `" .. modeWinCol  .. "` = `" .. modeWinCol  .. "` + ?"
        params[#params+1] = 1
    end
    if modeLossCol and lossInc > 0 then
        setSQL  = setSQL .. ", `" .. modeLossCol .. "` = `" .. modeLossCol .. "` + ?"
        params[#params+1] = 1
    end
    params[#params+1] = cid

    MySQL.query("UPDATE paintball_ranks SET " .. setSQL .. " WHERE citizenid = ?", params)

    -- Level-up notification
    local newXP   = bXP + xpGain
    local oldRank = CalculateRankFromXP(bXP)
    local newRank = CalculateRankFromXP(newXP)

    if newRank.level > oldRank.level or newRank.prestige > oldRank.prestige then
        TriggerClientEvent("Pug:client:PaintballRankUp", source, {
            oldLevel    = oldRank.level,
            newLevel    = newRank.level,
            oldPrestige = oldRank.prestige,
            newPrestige = newRank.prestige,
            xp          = newXP,
        })
        TriggerClientEvent("Pug:client:PlayPaintballClientSound", source, "rankup", 0.05)
    end

    -- Refresh the in-game leaderboard prop for nearby players
    TriggerClientEvent("Pug:client:RefreshLeaderboardPaintball", source)
end

-----------------------------------------------------------------------
-- Leaderboard callback
-----------------------------------------------------------------------
-- [REPAIRED]: Returns sorted player stats for the DUI leaderboard; filters by
--             game mode or "personal" (all modes for the requesting player).
Config.FrameworkFunctions.CreateCallback("Pug:Leaderboard:GetDataPaintball", function(source, cb, modeFilter)
    modeFilter = tostring(modeFilter or "")

    -- Determine which mode columns to surface
    local modeKey = nil
    for key, gm in pairs(Config.GameModes or {}) do
        if gm.name == modeFilter then
            modeKey = key; break
        end
    end

    local function toModeKey(k)
        if k == "Team_DeathMatch"    then return "tdm"
        elseif k == "Hold_Your_Own"  then return "hyo"
        elseif k == "Capture_The_Flag" then return "ctf"
        elseif k == "Gun_Game"       then return "gg"
        elseif k == "Free_For_All"   then return "ffa"
        elseif k == "One_In_The_Chamber" then return "oitc"
        elseif k == "Kill_Confirmed" then return "kc"
        end
        return nil
    end

    if modeFilter == "personal" then
        -- Return the requesting player's stats across all modes
        local cid = GetPlayerCID and GetPlayerCID(source)
        if not cid then cb(nil) return end
        local rows = MySQL.query.await(
            "SELECT * FROM paintball_ranks WHERE citizenid = ? LIMIT 1",
            { cid }
        )
        if not rows or not rows[1] then cb(nil) return end
        local r   = rows[1]
        local out = {}
        local function pushMode(label, k)
            local mk = toModeKey(k)
            if not mk then return end
            out[#out+1] = {
                mode   = label,
                kills  = r[mk .. "_kills"]  or 0,
                deaths = r[mk .. "_deaths"] or 0,
                wins   = r[mk .. "_wins"]   or 0,
                losses = r[mk .. "_losses"] or 0,
            }
        end
        for k, gm in pairs(Config.GameModes or {}) do
            pushMode(gm.name, k)
        end
        cb(out)
        return
    end

    -- Ranked list for a specific mode
    local mk = modeKey and toModeKey(modeKey)

    local killsCol  = mk and (mk .. "_kills")  or "kills"
    local deathsCol = mk and (mk .. "_deaths") or "deaths"
    local winsCol   = mk and (mk .. "_wins")   or "wins"
    local lossesCol = mk and (mk .. "_losses") or "losses"

    local rows = MySQL.query.await(([[
        SELECT citizenid, name, xp, level, prestige, kills, deaths, wins, losses, headshots,
               `%s` AS mode_kills, `%s` AS mode_deaths, `%s` AS mode_wins, `%s` AS mode_losses
        FROM paintball_ranks
        ORDER BY `%s` DESC, xp DESC
        LIMIT 100
    ]]):format(killsCol, deathsCol, winsCol, lossesCol, killsCol))

    if not rows then cb({}) return end

    local out = {}
    for i, row in ipairs(rows) do
        local ri = CalculateRankFromXP(row.xp or 0)
        out[#out+1] = {
            rank     = i,
            name     = row.name or row.citizenid,
            kills    = row.mode_kills  or 0,
            deaths   = row.mode_deaths or 0,
            wins     = row.mode_wins   or 0,
            losses   = row.mode_losses or 0,
            headshots = row.headshots  or 0,
            xp       = row.xp         or 0,
            level    = ri.level,
            prestige = ri.prestige,
        }
    end
    cb(out)
end)
