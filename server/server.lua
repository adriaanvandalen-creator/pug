-- filename: server/server.lua
-- [REPAIRED]: Entire file reconstructed — no server/ directory existed; resource was non-functional.

-----------------------------------------------------------------------
-- Core helpers
-----------------------------------------------------------------------

-- [REPAIRED]: Centralised citizenid/identifier resolution for ESX and QBCore.
function GetPlayerCID(source)
    if Framework == "QBCore" then
        local player = FWork.Functions.GetPlayer(source)
        return player and player.PlayerData.citizenid
    else
        local player = FWork.GetPlayerFromId(source)
        return player and player.identifier
    end
end

function GetPlayerFullName(source)
    if Framework == "QBCore" then
        local player = FWork.Functions.GetPlayer(source)
        if player then
            local ci = player.PlayerData.charinfo or {}
            local first = ci.firstname or ""
            local last  = ci.lastname  or ""
            return (first .. " " .. last):match("^%s*(.-)%s*$")
        end
    else
        local player = FWork.GetPlayerFromId(source)
        if player then return player.getName() end
    end
    return GetPlayerName(source) or ("Player " .. tostring(source))
end

-- [REPAIRED]: Admin check respects Config.WhitelistedCIDsToStartGame; falls back
--             to ace permission when list is empty.
function IsAdmin(source)
    if Config.WhitelistedCIDsToStartGame and #Config.WhitelistedCIDsToStartGame > 0 then
        local cid = GetPlayerCID(source)
        if not cid then return false end
        for _, v in ipairs(Config.WhitelistedCIDsToStartGame) do
            if tostring(v) == tostring(cid) then return true end
        end
        return false
    end
    return IsPlayerAceAllowed(source, "command.ban")
end

-----------------------------------------------------------------------
-- Database initialisation
-----------------------------------------------------------------------
-- [REPAIRED]: All four tables created on resource start via oxmysql.
MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `paintball_ranks` (
            `id`           INT          AUTO_INCREMENT PRIMARY KEY,
            `citizenid`    VARCHAR(50)  NOT NULL,
            `kills`        INT          DEFAULT 0,
            `deaths`       INT          DEFAULT 0,
            `wins`         INT          DEFAULT 0,
            `losses`       INT          DEFAULT 0,
            `headshots`    INT          DEFAULT 0,
            `xp`           INT          DEFAULT 0,
            `level`        INT          DEFAULT 1,
            `prestige`     INT          DEFAULT 0,
            `tdm_kills`    INT          DEFAULT 0,
            `tdm_deaths`   INT          DEFAULT 0,
            `tdm_wins`     INT          DEFAULT 0,
            `tdm_losses`   INT          DEFAULT 0,
            `hyo_kills`    INT          DEFAULT 0,
            `hyo_deaths`   INT          DEFAULT 0,
            `hyo_wins`     INT          DEFAULT 0,
            `hyo_losses`   INT          DEFAULT 0,
            `ctf_kills`    INT          DEFAULT 0,
            `ctf_deaths`   INT          DEFAULT 0,
            `ctf_wins`     INT          DEFAULT 0,
            `ctf_losses`   INT          DEFAULT 0,
            `ctf_captures` INT          DEFAULT 0,
            `ctf_returns`  INT          DEFAULT 0,
            `gg_kills`     INT          DEFAULT 0,
            `gg_deaths`    INT          DEFAULT 0,
            `gg_wins`      INT          DEFAULT 0,
            `gg_losses`    INT          DEFAULT 0,
            `ffa_kills`    INT          DEFAULT 0,
            `ffa_deaths`   INT          DEFAULT 0,
            `ffa_wins`     INT          DEFAULT 0,
            `ffa_losses`   INT          DEFAULT 0,
            `oitc_kills`   INT          DEFAULT 0,
            `oitc_deaths`  INT          DEFAULT 0,
            `oitc_wins`    INT          DEFAULT 0,
            `oitc_losses`  INT          DEFAULT 0,
            `kc_kills`     INT          DEFAULT 0,
            `kc_deaths`    INT          DEFAULT 0,
            `kc_wins`      INT          DEFAULT 0,
            `kc_losses`    INT          DEFAULT 0,
            `kc_confirms`  INT          DEFAULT 0,
            `name`         VARCHAR(100) DEFAULT NULL,
            UNIQUE KEY `uk_citizenid` (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Add name column to existing installations that predate this column
    MySQL.query("ALTER TABLE `paintball_ranks` ADD COLUMN IF NOT EXISTS `name` VARCHAR(100) DEFAULT NULL")

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `paintball_outfits` (
            `id`      INT          AUTO_INCREMENT PRIMARY KEY,
            `team`    VARCHAR(20)  NOT NULL,
            `gender`  VARCHAR(30)  NOT NULL,
            `outfit`  LONGTEXT     NOT NULL,
            UNIQUE KEY `uk_team_gender` (`team`, `gender`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `paintball_teams` (
            `id`          INT          AUTO_INCREMENT PRIMARY KEY,
            `name`        VARCHAR(100) NOT NULL,
            `tag`         VARCHAR(10)  DEFAULT NULL,
            `color_hex`   VARCHAR(10)  DEFAULT '#0ea5e9',
            `logo_url`    TEXT         DEFAULT NULL,
            `owner_cid`   VARCHAR(50)  NOT NULL,
            `outfit_json` LONGTEXT     DEFAULT NULL,
            `created_at`  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
            KEY `idx_owner` (`owner_cid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `paintball_team_members` (
            `id`        INT          AUTO_INCREMENT PRIMARY KEY,
            `team_id`   INT          NOT NULL,
            `citizenid` VARCHAR(50)  NOT NULL,
            `joined_at` TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY `uk_cid` (`citizenid`),
            KEY `idx_team_id` (`team_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    print("^2[pug-paintball] Database tables initialised.^0")
end)

-----------------------------------------------------------------------
-- Outfit storage — team-wide (admin-set via /redoutfit / /blueoutfit)
-----------------------------------------------------------------------
-- [REPAIRED]: Persists global team outfits captured from admin's ped.
RegisterNetEvent("Pug:server:UpdateRedTeamsClothes", function(Data)
    if not Data or not Data.Gender then return end
    MySQL.query(
        "INSERT INTO paintball_outfits (team, gender, outfit) VALUES (?, ?, ?) " ..
        "ON DUPLICATE KEY UPDATE outfit = VALUES(outfit)",
        { "redteam", Data.Gender, json.encode(Data) }
    )
    if Config.Debug then
        print("[pug-paintball] Red outfit saved for: " .. Data.Gender)
    end
end)

RegisterNetEvent("Pug:server:UpdateBlueTeamsClothes", function(Data)
    if not Data or not Data.Gender then return end
    MySQL.query(
        "INSERT INTO paintball_outfits (team, gender, outfit) VALUES (?, ?, ?) " ..
        "ON DUPLICATE KEY UPDATE outfit = VALUES(outfit)",
        { "blueteam", Data.Gender, json.encode(Data) }
    )
    if Config.Debug then
        print("[pug-paintball] Blue outfit saved for: " .. Data.Gender)
    end
end)

-- [REPAIRED]: Callback returns stored outfit data for a team+gender pair.
Config.FrameworkFunctions.CreateCallback("Pug:SVCB:GetTeamOutfits", function(source, cb, Info)
    if not Info or not Info.Team or not Info.Gender then cb(nil) return end
    local rows = MySQL.query.await(
        "SELECT outfit FROM paintball_outfits WHERE team = ? AND gender = ? LIMIT 1",
        { Info.Team, Info.Gender }
    )
    if rows and rows[1] and rows[1].outfit then
        local ok, data = pcall(json.decode, rows[1].outfit)
        cb(ok and data or nil)
    else
        cb(nil)
    end
end)

-----------------------------------------------------------------------
-- Admin commands: capture outfits
-----------------------------------------------------------------------
-- [REPAIRED]: Registered /redoutfit and /blueoutfit using names from Config.
RegisterCommand(Config.RedOutfitCommand, function(source, args)
    if source == 0 then return end
    if Config.RequireAdminToStartGame and not IsAdmin(source) then
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
            Config.Translations.error.not_admin or "You are not authorised.", "error", 3000)
        return
    end
    TriggerClientEvent("Pug:client:StoreRedTeamClothes", source)
end, false)

RegisterCommand(Config.BlueOutfitCommand, function(source, args)
    if source == 0 then return end
    if Config.RequireAdminToStartGame and not IsAdmin(source) then
        TriggerClientEvent("Pug:client:PaintballNotifyEvent", source,
            Config.Translations.error.not_admin or "You are not authorised.", "error", 3000)
        return
    end
    TriggerClientEvent("Pug:client:StoreBlueTeamClothes", source)
end, false)

-----------------------------------------------------------------------
-- Player disconnect — delegate lobby cleanup to sv_lobby.lua
-----------------------------------------------------------------------
-- [REPAIRED]: Calls CleanupPlayerFromLobbies (defined in sv_lobby.lua) on drop.
AddEventHandler('playerDropped', function()
    local src = source
    PaintballReviveGrace[src] = nil
    Citizen.CreateThread(function()
        Wait(0)
        if CleanupPlayerFromLobbies then
            CleanupPlayerFromLobbies(src)
        end
    end)
end)

-- Wasabi Ambulance V2 only accepts revives coming from the server, so the client asks us
-- to revive it while it is in a match (or just left one, see EndMatch).
PaintballReviveGrace = PaintballReviveGrace or {}

RegisterNetEvent("Pug:server:PaintballWasabiRevive", function()
    local src = source
    local lid = PlayerLobby[src]
    local inMatch = lid and Lobbies[lid] and Lobbies[lid].started
    local inGrace = PaintballReviveGrace[src] and PaintballReviveGrace[src] >= os.time()
    if not inMatch and not inGrace then return end

    local wasabiResource = GetWasabiAmbulanceResource()
    if not wasabiResource then return end

    local ok, err = pcall(function() exports[wasabiResource]:RevivePlayer(src) end)
    if not ok then
        if Config.Debug then print("[pug-paintball] " .. wasabiResource .. ":RevivePlayer failed: " .. tostring(err)) end
        TriggerClientEvent("wasabi_ambulance:revive", src)
    end
end)

-- Warn when Wasabi Ambulance V2 has not been told to ignore paintball deaths; without it
-- Wasabi opens its death screen every time someone dies in a match.
CreateThread(function()
    Wait(5000)
    print("^2[pug-paintball] Wasabi Ambulance V2 respawn fix loaded^7")
    if GetCurrentResourceName() ~= "pug-paintball" then
        print(("^1[PUG WARNING]^7: this resource is named ^3%s^7 but must be named ^3pug-paintball^7 (UI images and the Wasabi death check use that name). Rename the folder and make sure no other copy of pug-paintball is started.^7"):format(GetCurrentResourceName()))
    end
    local wasabiResource = GetWasabiAmbulanceResource()
    if not wasabiResource then return end
    local listeners = LoadResourceFile(wasabiResource, 'bridge/listeners/client.lua')
    if listeners and listeners:find('IsPaintballHandlingDeath', 1, true) then
        print(("^2[pug-paintball] %s is set to ignore paintball deaths^7"):format(wasabiResource))
    elseif listeners then
        print(([[
            ^4========================================================^7
            ^1[PUG WARNING]^7: ^3%s/bridge/listeners/client.lua^7 does not ignore paintball deaths!
            Add this inside ^3function listeners.shouldProcessDeath()^7 (and shouldProcessInjuries),
            above its last ^3return true^7, then restart %s:

            if GetResourceState('pug-paintball') == 'started' then
                local ok, handling = pcall(function() return exports['pug-paintball']:IsPaintballHandlingDeath() end)
                if ok and handling then
                    return false
                end
            end
            ^4========================================================^7
        ]]):format(wasabiResource, wasabiResource))
    end
end)
