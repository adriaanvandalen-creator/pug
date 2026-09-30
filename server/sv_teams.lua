-- filename: server/sv_teams.lua
-- [REPAIRED]: Reconstructed missing teams file; handles team CRUD, invite system,
--             member management, and all related callbacks and server events.

-----------------------------------------------------------------------
-- In-memory pending invites
-- [pendingInvites[targetCid] = { teamId, inviterId, inviterName, teamName, teamTag }]
-----------------------------------------------------------------------
local PendingInvites = {}

-----------------------------------------------------------------------
-- Helper: resolve citizenid from a server ID (safe wrapper)
-----------------------------------------------------------------------
local function GetCidByServerId(src)
    return GetPlayerCID and GetPlayerCID(src) or nil
end

-- Find a connected player's source by citizenid
local function FindSourceByCid(cid)
    for _, src in ipairs(GetPlayers()) do
        local c = GetCidByServerId(tonumber(src))
        if c and tostring(c) == tostring(cid) then
            return tonumber(src)
        end
    end
    return nil
end

-- Build a member list for a given team_id, annotating who the viewer is and who owns.
local function BuildMemberList(teamId, viewerCid, ownerCid)
    local rows = MySQL.query.await(
        "SELECT citizenid FROM paintball_team_members WHERE team_id = ?",
        { teamId }
    )
    if not rows then return {} end

    local members = {}
    for _, row in ipairs(rows) do
        local cid  = row.citizenid
        local name = cid  -- fallback; attempt live lookup
        local src  = FindSourceByCid(cid)
        if src then name = GetPlayerFullName(src) end

        members[#members+1] = {
            citizenid = cid,
            name      = name,
            isOwner   = (tostring(cid) == tostring(ownerCid)),
            isYou     = (tostring(cid) == tostring(viewerCid)),
        }
    end
    return members
end

-----------------------------------------------------------------------
-- Callbacks
-----------------------------------------------------------------------

-- [REPAIRED]: Returns the teams the requesting player belongs to.
Config.FrameworkFunctions.CreateCallback("Pug:Teams:GetMine", function(source, cb)
    local cid = GetCidByServerId(source)
    if not cid then cb({}) return end

    local rows = MySQL.query.await([[
        SELECT t.id, t.name, t.tag, t.color_hex, t.owner_cid,
               (SELECT COUNT(*) FROM paintball_team_members WHERE team_id = t.id) AS member_count
        FROM paintball_teams t
        INNER JOIN paintball_team_members m ON m.team_id = t.id
        WHERE m.citizenid = ?
        LIMIT 1
    ]], { cid })

    cb(rows or {})
end)

-- [REPAIRED]: Returns full team profile (team row + member list) for ManageTeam menu.
Config.FrameworkFunctions.CreateCallback("Pug:Teams:GetProfile", function(source, cb, teamId)
    if not teamId then cb(false, nil) return end
    local cid = GetCidByServerId(source)

    local rows = MySQL.query.await(
        "SELECT * FROM paintball_teams WHERE id = ? LIMIT 1",
        { teamId }
    )
    if not rows or not rows[1] then
        cb(false, nil)
        return
    end

    local team    = rows[1]
    local members = BuildMemberList(teamId, cid, team.owner_cid)

    cb(true, { team = team, members = members })
end)

-----------------------------------------------------------------------
-- Team creation
-----------------------------------------------------------------------
-- [REPAIRED]: Creates a new team and adds the creator as first member + owner.
RegisterNetEvent("Pug:Teams:Create", function(data)
    local source = source
    local cid    = GetCidByServerId(source)
    if not cid then return end

    if not data or not data.name or data.name == "" then
        TriggerClientEvent("Pug:Teams:CreateResult", source, false, "Name is required.")
        return
    end

    -- Validate field lengths
    local name = tostring(data.name):sub(1, 100)
    local tag  = data.tag       and tostring(data.tag):gsub("%s+", ""):sub(1, Config.MaxTeamClanTagLength or 4) or nil
    local col  = data.color_hex and tostring(data.color_hex):sub(1, 10) or "#0ea5e9"
    local logo = data.logo_url  and tostring(data.logo_url)             or nil

    -- Check player isn't already on a team
    local existing = MySQL.query.await(
        "SELECT 1 FROM paintball_team_members WHERE citizenid = ? LIMIT 1",
        { cid }
    )
    if existing and existing[1] then
        TriggerClientEvent("Pug:Teams:CreateResult", source, false, "You are already in a team.")
        return
    end

    -- Name uniqueness check
    local dupe = MySQL.query.await(
        "SELECT 1 FROM paintball_teams WHERE name = ? LIMIT 1",
        { name }
    )
    if dupe and dupe[1] then
        TriggerClientEvent("Pug:Teams:CreateResult", source, false, "Team name is already taken.")
        return
    end

    local insertId = MySQL.insert.await(
        "INSERT INTO paintball_teams (name, tag, color_hex, logo_url, owner_cid) VALUES (?, ?, ?, ?, ?)",
        { name, tag, col, logo, cid }
    )

    if not insertId then
        TriggerClientEvent("Pug:Teams:CreateResult", source, false, "Database error.")
        return
    end

    MySQL.query(
        "INSERT INTO paintball_team_members (team_id, citizenid) VALUES (?, ?)",
        { insertId, cid }
    )

    TriggerClientEvent("Pug:Teams:CreateResult", source, true, insertId)
end)

-----------------------------------------------------------------------
-- Team metadata update (name, tag, color, logo, outfit_json)
-----------------------------------------------------------------------
-- [REPAIRED]: Validates ownership before updating any team metadata fields.
RegisterNetEvent("Pug:Teams:UpdateMeta", function(teamId, updates)
    local source = source
    local cid    = GetCidByServerId(source)
    if not cid or not teamId or not updates then return end

    local rows = MySQL.query.await(
        "SELECT owner_cid FROM paintball_teams WHERE id = ? LIMIT 1",
        { teamId }
    )
    if not rows or not rows[1] then
        TriggerClientEvent("Pug:Teams:UpdateMetaResult", source, false, "Team not found.")
        return
    end
    if tostring(rows[1].owner_cid) ~= tostring(cid) then
        TriggerClientEvent("Pug:Teams:UpdateMetaResult", source, false, "Not the team owner.")
        return
    end

    -- Build a safe SET clause from allowed keys
    local allowed  = { name = true, tag = true, color_hex = true, logo_url = true, outfit_json = true }
    local setparts = {}
    local params   = {}
    for k, v in pairs(updates) do
        if allowed[k] then
            setparts[#setparts+1] = "`" .. k .. "` = ?"
            params[#params+1]     = v
        end
    end
    if #setparts == 0 then
        TriggerClientEvent("Pug:Teams:UpdateMetaResult", source, false, "Nothing to update.")
        return
    end
    params[#params+1] = teamId

    MySQL.query(
        "UPDATE paintball_teams SET " .. table.concat(setparts, ", ") .. " WHERE id = ?",
        params
    )
    TriggerClientEvent("Pug:Teams:UpdateMetaResult", source, true, "Updated.")
end)

-----------------------------------------------------------------------
-- Invite system
-----------------------------------------------------------------------
-- [REPAIRED]: Sends a team invite to a connected player by their server ID.
RegisterNetEvent("Pug:Teams:InvitePlayer", function(teamId, targetServerId)
    local source    = source
    local ownerCid  = GetCidByServerId(source)
    if not ownerCid or not teamId or not targetServerId then return end

    -- Verify ownership
    local rows = MySQL.query.await(
        "SELECT name, tag, owner_cid FROM paintball_teams WHERE id = ? LIMIT 1",
        { teamId }
    )
    if not rows or not rows[1] or tostring(rows[1].owner_cid) ~= tostring(ownerCid) then
        TriggerClientEvent("Pug:Teams:InviteResult", source, false, "Not the team owner.")
        return
    end

    local targetSrc = tonumber(targetServerId)
    if not targetSrc or targetSrc == source then
        TriggerClientEvent("Pug:Teams:InviteResult", source, false, "Invalid player ID.")
        return
    end

    if not GetPlayerName(targetSrc) then
        TriggerClientEvent("Pug:Teams:InviteResult", source, false, "Player not online.")
        return
    end

    local targetCid = GetCidByServerId(targetSrc)
    if not targetCid then
        TriggerClientEvent("Pug:Teams:InviteResult", source, false, "Could not resolve player.")
        return
    end

    -- Check target not already in a team
    local already = MySQL.query.await(
        "SELECT 1 FROM paintball_team_members WHERE citizenid = ? LIMIT 1",
        { targetCid }
    )
    if already and already[1] then
        TriggerClientEvent("Pug:Teams:InviteResult", source, false, "That player is already in a team.")
        return
    end

    local team = rows[1]
    PendingInvites[tostring(targetCid)] = {
        teamId      = teamId,
        inviterId   = source,
        inviterName = GetPlayerFullName(source),
        teamName    = team.name,
        teamTag     = team.tag,
    }

    TriggerClientEvent("Pug:Teams:InviteReceived", targetSrc, {
        teamId      = teamId,
        teamName    = team.name,
        teamTag     = team.tag,
        inviterId   = source,
        inviterName = GetPlayerFullName(source),
    })
    TriggerClientEvent("Pug:Teams:InviteResult", source, true, "Invite sent.")
end)

-- [REPAIRED]: Processes an accepted team invite; adds player as member.
RegisterNetEvent("Pug:Teams:AcceptInvite", function(teamId)
    local source = source
    local cid    = GetCidByServerId(source)
    if not cid then return end

    local inv = PendingInvites[tostring(cid)]
    if not inv or tonumber(inv.teamId) ~= tonumber(teamId) then
        TriggerClientEvent("Pug:Teams:AcceptInviteResult", source, false, "No pending invite for that team.")
        return
    end

    PendingInvites[tostring(cid)] = nil

    -- Check player not already in a team (race condition guard)
    local already = MySQL.query.await(
        "SELECT 1 FROM paintball_team_members WHERE citizenid = ? LIMIT 1",
        { cid }
    )
    if already and already[1] then
        TriggerClientEvent("Pug:Teams:AcceptInviteResult", source, false, "You are already in a team.")
        return
    end

    MySQL.query(
        "INSERT IGNORE INTO paintball_team_members (team_id, citizenid) VALUES (?, ?)",
        { teamId, cid }
    )
    TriggerClientEvent("Pug:Teams:AcceptInviteResult", source, true, "Joined team.")
end)

-- [REPAIRED]: Discards a pending invite.
RegisterNetEvent("Pug:Teams:DeclineInvite", function(teamId)
    local source = source
    local cid    = GetCidByServerId(source)
    if not cid then return end
    PendingInvites[tostring(cid)] = nil
end)

-----------------------------------------------------------------------
-- Member management
-----------------------------------------------------------------------
-- [REPAIRED]: Kicks a member from the team (owner-only).
RegisterNetEvent("Pug:Teams:KickMember", function(teamId, targetCid)
    local source  = source
    local ownerCid = GetCidByServerId(source)
    if not ownerCid or not teamId or not targetCid then return end

    local rows = MySQL.query.await(
        "SELECT owner_cid FROM paintball_teams WHERE id = ? LIMIT 1",
        { teamId }
    )
    if not rows or not rows[1] or tostring(rows[1].owner_cid) ~= tostring(ownerCid) then
        TriggerClientEvent("Pug:Teams:KickMemberResult", source, false, "Not the team owner.")
        return
    end
    if tostring(targetCid) == tostring(ownerCid) then
        TriggerClientEvent("Pug:Teams:KickMemberResult", source, false, "Cannot kick yourself.")
        return
    end

    MySQL.query(
        "DELETE FROM paintball_team_members WHERE team_id = ? AND citizenid = ?",
        { teamId, targetCid }
    )
    TriggerClientEvent("Pug:Teams:KickMemberResult", source, true, "Member removed.")

    -- Notify kicked player if online
    local kickedSrc = FindSourceByCid(tostring(targetCid))
    if kickedSrc then
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", kickedSrc,
            Config.Translations.menu.member_removed or "You were removed from your team.", "error", 4000)
    end
end)

-- [REPAIRED]: Transfers team ownership to another member.
RegisterNetEvent("Pug:Teams:SetOwner", function(teamId, newOwnerCid)
    local source   = source
    local ownerCid = GetCidByServerId(source)
    if not ownerCid or not teamId or not newOwnerCid then return end

    local rows = MySQL.query.await(
        "SELECT owner_cid FROM paintball_teams WHERE id = ? LIMIT 1",
        { teamId }
    )
    if not rows or not rows[1] or tostring(rows[1].owner_cid) ~= tostring(ownerCid) then
        TriggerClientEvent("Pug:Teams:SetOwnerResult", source, false, "Not the team owner.")
        return
    end

    -- Verify target is a member
    local isMember = MySQL.query.await(
        "SELECT 1 FROM paintball_team_members WHERE team_id = ? AND citizenid = ? LIMIT 1",
        { teamId, newOwnerCid }
    )
    if not isMember or not isMember[1] then
        TriggerClientEvent("Pug:Teams:SetOwnerResult", source, false, "That player is not a team member.")
        return
    end

    MySQL.query(
        "UPDATE paintball_teams SET owner_cid = ? WHERE id = ?",
        { newOwnerCid, teamId }
    )
    TriggerClientEvent("Pug:Teams:SetOwnerResult", source, true, "Ownership transferred.")
end)

-- [REPAIRED]: Removes the requesting player from their team; deletes team if owner
--             and only member.
RegisterNetEvent("Pug:Teams:Leave", function(teamId)
    local source = source
    local cid    = GetCidByServerId(source)
    if not cid or not teamId then return end

    local team = MySQL.query.await(
        "SELECT owner_cid FROM paintball_teams WHERE id = ? LIMIT 1",
        { teamId }
    )
    if not team or not team[1] then
        TriggerClientEvent("Pug:Teams:LeaveResult", source, false, "Team not found.")
        return
    end
    local ownerCid = team[1].owner_cid

    if tostring(ownerCid) == tostring(cid) then
        -- Owner leaving: check member count
        local mc = MySQL.query.await(
            "SELECT COUNT(*) AS cnt FROM paintball_team_members WHERE team_id = ?",
            { teamId }
        )
        local count = (mc and mc[1] and mc[1].cnt) or 0
        if count <= 1 then
            -- Dissolve the team
            MySQL.query("DELETE FROM paintball_team_members WHERE team_id = ?", { teamId })
            MySQL.query("DELETE FROM paintball_teams WHERE id = ?",              { teamId })
            TriggerClientEvent("Pug:Teams:LeaveResult", source, true, "Team dissolved.")
            return
        else
            -- Transfer ownership to next member before leaving
            local next = MySQL.query.await(
                "SELECT citizenid FROM paintball_team_members WHERE team_id = ? AND citizenid != ? LIMIT 1",
                { teamId, cid }
            )
            if next and next[1] then
                MySQL.query("UPDATE paintball_teams SET owner_cid = ? WHERE id = ?", { next[1].citizenid, teamId })
            end
        end
    end

    MySQL.query(
        "DELETE FROM paintball_team_members WHERE team_id = ? AND citizenid = ?",
        { teamId, cid }
    )
    TriggerClientEvent("Pug:Teams:LeaveResult", source, true, "Left team.")
end)
