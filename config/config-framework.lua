Config = {}
---------- [Framework] ----------
-- (DONT TOUCH THIS UNLESS YOU HAVE A CUSTOM FRAMEWORK)
if GetResourceState('es_extended') == 'started' then
    Framework = "ESX" -- (ESX) or (QBCore)
elseif GetResourceState('qb-core') == 'started' then
    Framework = "QBCore" -- (ESX) or (QBCore)
end
if Framework == "QBCore" then
    Config.CoreName = "qb-core" -- your core name
    FWork = exports[Config.CoreName]:GetCoreObject()
elseif Framework == "ESX" then
    Config.CoreName = "es_extended" -- your core name
    FWork = exports[Config.CoreName]:getSharedObject()
end
------------------------------
-- Wasabi Ambulance (V1 and V2). Add your folder name here if you renamed the resource.
Config.WasabiAmbulanceResources = {
    "wasabi_ambulance_v2",
    "wasabi_ambulance",
}
function GetWasabiAmbulanceResource()
    for _, name in ipairs(Config.WasabiAmbulanceResources) do
        if GetResourceState(name) == 'started' then return name end
    end
    return nil
end
------------------------------
-- [THESE ARE NOT NOT MEANT TO BE TOUCHED UNLESS YOU KNOW WHAT YOU ARE DOING]
Config.CompatibleTargetScripts = { -- Put whatever target script you use in this table if it is not here.
    "ox_target",
    "qb-target",
    "qtarget",
}
Config.CompatibleInputScripts = { -- If you have multiple input scripts in your server, Put only the one you want to use in this table or else dont touch this.
    -- "lation_ui",
    "ox_lib",
    "qb-input",
    "ps-ui",
}
Config.CompatibleMenuScripts = { -- If you have multiple Menu scripts in your server, Put only the one you want to use in this table or else dont touch this.
--    "lation_ui",
    "ox_lib",
    "qb-menu",
    "ps-ui",
}
Config.CompatibleInventoryScripts = { -- Having a compatible inventory script is not required
    "tgiann-inventory",
    "ox_inventory",
    "qb-inventory",
    "qs-inventory",
    "ps-inventory",
    "lj-inventory",
    "ak47_inventory",
}
Config.CompatibleSmallResourceScripts = { -- Having a compatible inventory script is not required
    "qb-smallresources",
    -- "qbx_smallresources", -- DONT ENABLE THIS (ITS BACKWARDS COMPATIBLE FOR NOW)
}
Config.InventoryType = "tgiann-inventory"

if GetResourceState(Config.InventoryType) ~= 'started' then
    for _, v in pairs(Config.CompatibleInventoryScripts) do
        if GetResourceState(v) == 'started' then
            Config.InventoryType = tostring(v)
            break
        end
    end
end
-- (DONT TOUCH ANY OF THIS SECTION)
for _, v in pairs(Config.CompatibleInputScripts) do
    if GetResourceState(v) == 'started' then
        Config.Input = tostring(v)
        break
    end
end
-- (DONT TOUCH ANY OF THIS SECTION)
for _, v in pairs(Config.CompatibleMenuScripts) do
    if GetResourceState(v) == 'started' then
        Config.Menu = tostring(v)
        break
    end
end
-- (DONT TOUCH ANY OF THIS SECTION)
for _, v in pairs(Config.CompatibleInventoryScripts) do
    if GetResourceState(v) == 'started' then
        Config.InventoryType = tostring(v)
        break
    end
end
-- (DONT TOUCH ANY OF THIS SECTION)
for _, v in pairs(Config.CompatibleSmallResourceScripts) do
    if GetResourceState(v) == 'started' then
        Config.SmallResource = tostring(v)
        break
    end
end
if GetResourceState("pug-battleroyale") == 'started' then
    Config.HasBattleRoyaleScript = true
end
-- if GetResourceState("nh-context") == 'started' then
--     Config.MapMenuPreview = true
-- end
------------------------------
---------- [Core Framework Functions] ----------
-- (DONT TOUCH ANY OF THIS SECTION)
----------------------------------------------------------
-- Core Framework Functions
----------------------------------------------------------
Config.FrameworkFunctions = {

    TriggerCallback = function(...)
        if Framework == 'QBCore' then
            FWork.Functions.TriggerCallback(...)
        else
            FWork.TriggerServerCallback(...)
        end
    end,

    CreateCallback = function(...)
        if Framework == 'QBCore' then
            FWork.Functions.CreateCallback(...)
        else
            FWork.RegisterServerCallback(...)
        end
    end,

    GetPlayers = function()
        if Framework == 'QBCore' then
            return FWork.Functions.GetPlayers()
        else
            return FWork.GetPlayers()
        end
    end,

    GetItemByName = function(source, item, amount)
        if Framework == 'QBCore' then
            local player = FWork.Functions.GetPlayer(source)
            return player and player.Functions.GetItemByName(item, amount)
        else
            local player = FWork.GetPlayerFromId(source)
            return player.getInventoryItem(item, amount)
        end
    end,

    GetPlayer = function(source, cid, client)
        if Framework == 'QBCore' then
            local self = {}
            local player = nil

            if cid then
                player = FWork.Functions.GetPlayerByCitizenId(source)
            elseif client then
                player = FWork.Functions.GetPlayerData()
            else
                player = FWork.Functions.GetPlayer(source)
            end

            if not player then return nil end

            self.source = source

            -- SAFE CHARINFO HANDLER
            local function safeCharinfo(ci)
                ci = ci or {}
                return {
                    firstname = ci.firstname or "",
                    lastname  = ci.lastname or ""
                }
            end

            ------------------------------------------------------
            -- SAFE PLAYERDATA BUILDING (No more nil crashes)
            ------------------------------------------------------
            if client then
                self.PlayerData = {
                    charinfo = safeCharinfo(player.charinfo),
                    citizenid = player.citizenid,
                    money     = player.money,
                    metadata  = player.metadata,
                }
            else
                self.PlayerData = {
                    charinfo = safeCharinfo(player.PlayerData.charinfo),
                    citizenid = player.PlayerData.citizenid,
                    money     = player.PlayerData.money,
                    metadata  = player.PlayerData.metadata,
                    items     = player.PlayerData.items,
                }
            end

            ------------------------------------------------------
            -- Default QB inventory
            ------------------------------------------------------
            self.AddMoney = function(currency, amount)
                player.Functions.AddMoney(currency, amount)
            end

            self.RemoveMoney = function(currency, amount)
                player.Functions.RemoveMoney(currency, amount)
            end

            self.SetMetaData = function(meta, data)
                player.Functions.SetMetaData(meta, data)
            end

            self.AddItem = function(item, amount, info)
                player.Functions.AddItem(item, amount, false, info)
            end

            self.RemoveItem = function(item, amount)
                player.Functions.RemoveItem(item, amount, false)
            end

            self.ClearInventory = function()
                player.Functions.ClearInventory()
            end

            self.getItemCount = function(item)
                local found = player.Functions.GetItemByName(item)
                return found and found.amount or 0
            end

            ------------------------------------------------------
            -- TGIANN OVERRIDE SECTION (with pcall)
            ------------------------------------------------------
            if Config.InventoryType == "tgiann-inventory" then

                self.AddItem = function(item, amount, info)
                    pcall(function()
                        exports["tgiann-inventory"]:AddItem(self.source, item, amount, false, info or {})
                    end)
                end

                self.RemoveItem = function(item, amount)
                    pcall(function()
                        exports["tgiann-inventory"]:RemoveItem(self.source, item, amount)
                    end)
                end

                self.ClearInventory = function()
                    pcall(function()
                        exports["tgiann-inventory"]:ClearInventory(self.source)
                    end)
                end

                self.getItemCount = function(item)
                    local ok, val = pcall(function()
                        return exports["tgiann-inventory"]:GetItemCount(self.source, item)
                    end)
                    return ok and val or 0
                end

                ------------------------------------------------------------------
                -- FIX: TGIANN DOES NOT HAVE GetInventory → use GetPlayerItems
                ------------------------------------------------------------------
                local ok, inv = pcall(function()
                    return exports["tgiann-inventory"]:GetPlayerItems(self.source)
                end)

                self.PlayerData.items = (ok and inv) and inv or {}
            end

            return self
        end

        ------------------------------------------------------
        -- ESX Section (unchanged)
        ------------------------------------------------------
        -- (your ESX code remains untouched)
    end

}
