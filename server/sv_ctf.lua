-- filename: server/sv_ctf.lua
-- [REPAIRED]: Reconstructed missing CTF logic; handles flag pickup, drop, capture,
--             and return events, flag state per match, and win-condition hooks
--             back into sv_lobby.lua and sv_ranks.lua.

-----------------------------------------------------------------------
-- CTF state  (indexed by lobbyId)
-- Flags: { red = {carrier=nil, atBase=true}, blue = {carrier=nil, atBase=true} }
-----------------------------------------------------------------------
CTFState = {}  -- [lobbyId] = { red={carrier,atBase}, blue={carrier,atBase}, redCaptures, blueCaptures }

-----------------------------------------------------------------------
-- Public: CTFInitMatch
-- Called by sv_lobby.lua → StartMatch when game mode is Capture_The_Flag.
-----------------------------------------------------------------------
-- [REPAIRED]: Initialises fresh CTF state for a newly started match.
-- mapKey is the arena key (e.g. "Jpark"); resolved to actual map ID via Config.Arenas.
function CTFInitMatch(lobbyId, mapKey)
    -- Resolve arena key → actual interior/set map ID used in flag location tables
    local arenaData  = Config.Arenas and Config.Arenas[mapKey]
    local actualMapId = (arenaData and arenaData.map) or mapKey

    CTFState[lobbyId] = {
        red  = { carrier = nil, atBase = true },
        blue = { carrier = nil, atBase = true },
        redCaptures  = 0,
        blueCaptures = 0,
        mapKey = actualMapId,  -- store actual map ID for Config.Red/BlueFlagLocation lookups
    }

    -- Broadcast starting flag positions to all players in the lobby
    local lobby = Lobbies and Lobbies[lobbyId]
    if not lobby then return end

    local redFlagData  = Config.RedFlagLocation  and Config.RedFlagLocation[actualMapId]
    local blueFlagData = Config.BlueFlagLocation and Config.BlueFlagLocation[actualMapId]
    if redFlagData and blueFlagData then
        for _, src in ipairs(lobby.all or {}) do
            TriggerClientEvent("Pug:CTF:FlagPositions", src, redFlagData.Coords, blueFlagData.Coords)
        end
    end

    if Config.Debug then
        print(("[pug-paintball][CTF] Match initialised. Lobby=%d Arena=%s MapId=%s"):format(
            lobbyId, tostring(mapKey), tostring(actualMapId)))
    end
end

-----------------------------------------------------------------------
-- Public: CTFCleanup
-- Called by sv_lobby.lua → EndMatch to clean up CTF state.
-----------------------------------------------------------------------
function CTFCleanup(lobbyId)
    CTFState[lobbyId] = nil
end

-----------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------

-- Returns the flag colour the specified source is currently carrying, or nil.
local function GetCarriedFlagColor(lobbyId, src)
    local state = CTFState[lobbyId]
    if not state then return nil end
    if state.red.carrier  == src then return "red"  end
    if state.blue.carrier == src then return "blue" end
    return nil
end

-- Broadcasts a flag status update to all members of a lobby.
local function BroadcastFlagStatus(lobbyId, color, status, carrierName)
    local lobby = Lobbies and Lobbies[lobbyId]
    if not lobby then return end

    local soundRed  = { taken = "Flag_Has_Been_Taken",     returned = "Flag_Has_Been_Returned",     captured = "Flag_Has_Been_Captured",     dropped = "Flag_Has_Been_Dropped" }
    local soundBlue = { taken = "Enemy_Flag_Taken",        returned = "Enemy_Flag_Returned",        captured = "Enemy_Flag_Captured",        dropped = "Enemy_Flag_Dropped" }

    for _, src in ipairs(lobby.all or {}) do
        TriggerClientEvent("Pug:CTF:FlagStatusUpdate", src, color, status, carrierName)

        -- Play the relevant sound (red team hears "Flag_Has_Been_*", blue hears "Enemy_*")
        local isRedPlayer = lobby.redteam and lobby.redteam[src] ~= nil
        local soundTable  = isRedPlayer and soundRed or soundBlue

        local soundName = soundTable[status]
        if soundName then
            TriggerClientEvent("Pug:client:PlayPaintballClientSound", src, soundName, 0.05)
        end
    end
end

-----------------------------------------------------------------------
-- Flag pickup
-----------------------------------------------------------------------
-- [REPAIRED]: A player picks up an enemy flag from its base or from the ground.
RegisterNetEvent("Pug:CTF:PickupFlag", function(color)
    local source  = source
    local lobbyId = PlayerLobby and PlayerLobby[source]
    if not lobbyId then return end
    local state = CTFState[lobbyId]
    local lobby = Lobbies and Lobbies[lobbyId]
    if not state or not lobby or not lobby.started then return end

    -- Verify the picker is on the opposing team
    local pickerTeam = nil
    if lobby.redteam  and lobby.redteam[source]  then pickerTeam = "red"  end
    if lobby.blueteam and lobby.blueteam[source] then pickerTeam = "blue" end
    if not pickerTeam then return end

    -- Can only pick up the opponent's flag
    if color == pickerTeam then return end

    local flag = state[color]
    if not flag then return end
    if flag.carrier then return end  -- already carried

    flag.carrier = source
    flag.atBase  = false

    local carrierName = GetPlayerFullName(source)
    BroadcastFlagStatus(lobbyId, color, "taken", carrierName)

    if Config.Debug then
        print(("[pug-paintball][CTF] %s flag picked up by %d (%s)"):format(color, source, carrierName))
    end
end)

-----------------------------------------------------------------------
-- Flag drop (on carrier death)
-----------------------------------------------------------------------
-- [REPAIRED]: Drops a carried flag at the carrier's last known position on death.
RegisterNetEvent("Pug:CTF:DropFlag", function()
    local source  = source
    local lobbyId = PlayerLobby and PlayerLobby[source]
    if not lobbyId then return end
    local state = CTFState[lobbyId]
    local lobby = Lobbies and Lobbies[lobbyId]
    if not state or not lobby then return end

    local color = GetCarriedFlagColor(lobbyId, source)
    if not color then return end

    state[color].carrier = nil
    state[color].atBase  = false   -- flag is now on ground (not at base, not carried)

    local dropperName = GetPlayerFullName(source)
    BroadcastFlagStatus(lobbyId, color, "dropped", dropperName)

    -- Notify all clients of the drop position so they can render the ground flag
    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        local coords = GetEntityCoords(ped)
        for _, src in ipairs(lobby.all or {}) do
            TriggerClientEvent("Pug:CTF:FlagDropped", src, color, coords)
        end
    end

    if Config.Debug then
        print(("[pug-paintball][CTF] %s flag dropped by %d (%s)"):format(color, source, dropperName))
    end
end)

-----------------------------------------------------------------------
-- Flag capture (carrier delivers to their own base)
-----------------------------------------------------------------------
-- [REPAIRED]: Awards flag-capture XP, increments team capture count, checks win.
RegisterNetEvent("Pug:CTF:CaptureFlag", function(color)
    local source  = source
    local lobbyId = PlayerLobby and PlayerLobby[source]
    if not lobbyId then return end
    local state = CTFState[lobbyId]
    local lobby = Lobbies and Lobbies[lobbyId]
    if not state or not lobby or not lobby.started then return end

    -- Must be the actual carrier
    if state[color].carrier ~= source then return end

    -- Determine capturing team from the flag colour (they captured the opposing flag)
    local capturingTeam = (color == "red") and "blue" or "red"

    state[color].carrier = nil
    state[color].atBase  = true   -- flag returns to enemy base after capture

    if capturingTeam == "red" then
        state.redCaptures = (state.redCaptures or 0) + 1
    else
        state.blueCaptures = (state.blueCaptures or 0) + 1
    end

    -- Sync CTF scores into MatchScores for EndMatch/CheckWinCondition
    local sc = MatchScores and MatchScores[lobbyId]
    if sc then
        sc.ctfRed  = state.redCaptures
        sc.ctfBlue = state.blueCaptures
    end

    local capturerName = GetPlayerFullName(source)
    BroadcastFlagStatus(lobbyId, color, "captured", capturerName)

    -- Re-broadcast flag position so all clients know the flag is back at base
    local redFlagData  = Config.RedFlagLocation  and Config.RedFlagLocation[state.mapKey]
    local blueFlagData = Config.BlueFlagLocation and Config.BlueFlagLocation[state.mapKey]
    local flagCoords   = (color == "red") and (redFlagData and redFlagData.Coords)
                      or (color == "blue") and (blueFlagData and blueFlagData.Coords)
    if flagCoords then
        for _, src in ipairs(lobby.all or {}) do
            TriggerClientEvent("Pug:CTF:FlagReturned", src, color, flagCoords)
        end
    end

    -- Award capture XP
    local cid = GetPlayerCID and GetPlayerCID(source)
    if cid then
        local captureXP = Config.Leveling.XPRewards.FlagCapture or 300

        -- Read XP before the update so we can detect rank-ups accurately
        local before = MySQL.query.await(
            "SELECT xp FROM paintball_ranks WHERE citizenid = ? LIMIT 1", { cid }
        )
        local oldXP = (before and before[1] and before[1].xp) or 0

        MySQL.query.await(
            "UPDATE paintball_ranks SET xp = xp + ?, ctf_captures = ctf_captures + 1 WHERE citizenid = ?",
            { captureXP, cid }
        )

        local newXP = oldXP + captureXP
        local oldRD = CalculateRankFromXP(oldXP)
        local newRD = CalculateRankFromXP(newXP)
        if newRD.level > oldRD.level or newRD.prestige > oldRD.prestige then
            TriggerClientEvent("Pug:client:PaintballRankUp", source, {
                oldLevel = oldRD.level, newLevel = newRD.level,
                oldPrestige = oldRD.prestige, newPrestige = newRD.prestige,
                xp = newXP,
            })
            TriggerClientEvent("Pug:client:PlayPaintballClientSound", source, "rankup", 0.05)
        end
    end

    -- Score announcement notification to all players
    for _, src in ipairs(lobby.all or {}) do
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", src,
            capturerName .. " captured the " .. color .. " flag! " ..
            tostring(state.redCaptures) .. " – " .. tostring(state.blueCaptures),
            "success", 4000)
    end

    -- Check win: first to 3 captures
    if state.redCaptures >= 3 then
        if EndMatch then EndMatch(lobbyId, 'redteam', 'ctf_capture') end
    elseif state.blueCaptures >= 3 then
        if EndMatch then EndMatch(lobbyId, 'blueteam', 'ctf_capture') end
    end

    if Config.Debug then
        print(("[pug-paintball][CTF] %s flag captured by %d. Red=%d Blue=%d"):format(
            color, source, state.redCaptures, state.blueCaptures))
    end
end)

-----------------------------------------------------------------------
-- Flag return (player returns their own team's dropped flag)
-----------------------------------------------------------------------
-- [REPAIRED]: Awards return XP and resets the flag to base; broadcasts status.
RegisterNetEvent("Pug:CTF:ReturnFlag", function(color)
    local source  = source
    local lobbyId = PlayerLobby and PlayerLobby[source]
    if not lobbyId then return end
    local state = CTFState[lobbyId]
    local lobby = Lobbies and Lobbies[lobbyId]
    if not state or not lobby or not lobby.started then return end

    -- Only the owning team can return their own flag
    local returnerTeam = nil
    if lobby.redteam  and lobby.redteam[source]  then returnerTeam = "red"  end
    if lobby.blueteam and lobby.blueteam[source] then returnerTeam = "blue" end
    if returnerTeam ~= color then return end

    -- Flag must actually be on the ground (not at base, not carried)
    if state[color].atBase or state[color].carrier then return end

    state[color].carrier = nil
    state[color].atBase  = true

    local returnerName = GetPlayerFullName(source)
    BroadcastFlagStatus(lobbyId, color, "returned", returnerName)

    -- Reposition the flag prop back to spawn on all clients
    local redFlagData  = Config.RedFlagLocation  and Config.RedFlagLocation[state.mapKey]
    local blueFlagData = Config.BlueFlagLocation and Config.BlueFlagLocation[state.mapKey]
    local flagCoords   = (color == "red") and (redFlagData and redFlagData.Coords)
                      or (color == "blue") and (blueFlagData and blueFlagData.Coords)
    if flagCoords then
        for _, src in ipairs(lobby.all or {}) do
            TriggerClientEvent("Pug:CTF:FlagReturned", src, color, flagCoords)
        end
    end

    -- Award return XP
    local cid = GetPlayerCID and GetPlayerCID(source)
    if cid then
        local returnXP = Config.Leveling.XPRewards.FlagReturn or 200
        MySQL.query(
            "UPDATE paintball_ranks SET xp = xp + ?, ctf_returns = ctf_returns + 1 WHERE citizenid = ?",
            { returnXP, cid }
        )
    end

    if Config.Debug then
        print(("[pug-paintball][CTF] %s flag returned by %d (%s)"):format(color, source, returnerName))
    end
end)

-----------------------------------------------------------------------
-- Death handler: auto-drop flag if carrier is killed
-- Called indirectly — sv_scoreboard.lua fires this after processing a kill.
-----------------------------------------------------------------------
RegisterNetEvent("Pug:CTF:CarrierKilled", function(victimSrc)
    local source  = source   -- the killer (or server trigger)
    victimSrc = tonumber(victimSrc) or source
    local lobbyId = PlayerLobby and PlayerLobby[victimSrc]
    if not lobbyId then return end

    local state = CTFState[lobbyId]
    if not state then return end

    local color = GetCarriedFlagColor(lobbyId, victimSrc)
    if not color then return end

    -- Drop it
    state[color].carrier = nil
    state[color].atBase  = false

    local lobby = Lobbies and Lobbies[lobbyId]
    if not lobby then return end

    local ped = GetPlayerPed(victimSrc)
    if ped and ped ~= 0 then
        local coords = GetEntityCoords(ped)
        for _, src in ipairs(lobby.all or {}) do
            TriggerClientEvent("Pug:CTF:FlagDropped", src, color, coords)
        end
    end
    BroadcastFlagStatus(lobbyId, color, "dropped", GetPlayerFullName(victimSrc))
end)
