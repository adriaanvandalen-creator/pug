local resource = GetCurrentResourceName()
local version = GetResourceMetadata(resource, 'version', 0)
print("Pug Paintball "..tostring(version))


AddTextEntry("WEAPON_PAINTBALLGUN", "Paintball")

function PaintBallNotify(msg, style, length)
    if Framework == "ESX" then
		FWork.ShowNotification(tostring(msg))
	elseif Framework == "QBCore" then
    	FWork.Functions.Notify(tostring(msg), style, length)
	end
end

function DrawTextOptiopnForSpectate()
    if GetResourceState('cd_drawtextui') == 'started' then
        TriggerEvent('cd_drawtextui:ShowUI', 'show', Config.Translations.menu.open_menu_hint)
	elseif Framework == "QBCore" then
		exports[Config.CoreName]:DrawText(Config.Translations.menu.open_menu_hint, 'left')
	else
		FWork.TextUI(Config.Translations.menu.open_menu_hint, "error")
	end
end

function HideTextOptiopnForSpectate()
    if GetResourceState('cd_drawtextui') == 'started' then
        TriggerEvent('cd_drawtextui:HideUI')
	elseif Framework == "QBCore" then
		exports[Config.CoreName]:HideText()
	else
		FWork.HideUI()
	end
end

function PugAddTargetToEntity(entity, data)
    if Config.Target == "ox_target" then
        exports.ox_target:addLocalEntity(entity, data)
    else
        exports[Config.Target]:AddTargetEntity(entity, {
            options = data,
            distance = data.distance or 2.0
        })
    end
end

function PugCreateMenu(menuId, menuTitle, options, parentId)
    if Config.Menu == "lation_ui" then
        local lationOptions = {}
        for _, item in ipairs(options) do
            lationOptions[#lationOptions+1] = {
                title = item.title,
                description = item.description or "",
                icon = item.icon,
                iconColor = item.iconColor,
                disabled = item.disabled,
                readOnly = item.readOnly,
                progress = item.progress,
                image = item.image,
                metadata = item.metadata,
                event = item.event,
                args = item.args,
                keybind = item.keybind,
                menu = item.menu
            }
        end

        local data = {
            id = menuId,
            title = menuTitle,
            subtitle = parentId and "" or nil,
            options = lationOptions
        }

        if parentId then
            data.menu = parentId
        end

        exports.lation_ui:registerMenu(data)
        exports.lation_ui:showMenu(menuId)
    elseif Config.Menu == "ox_lib" then
        local oxOptions = {}
        for _, item in ipairs(options) do
            oxOptions[#oxOptions+1] = {
                title = item.title,
                description = item.description or "",
                icon = item.icon,
                event = item.event,
                image = item.image,
                iconColor = item.iconColor,
                disabled = item.disabled,
                progress = item.progress,
                colorScheme = item.colorScheme,
                arrow = item.arrow,
                args = item.args,
            }
        end

        local data = {
            id = menuId,
            title = menuTitle,
            options = oxOptions
        }

        if parentId then
            data.menu = parentId
        end

        lib.registerContext(data)
        lib.showContext(menuId)
    else
        local qbOptions = {}
        for _, item in ipairs(options) do
            qbOptions[#qbOptions+1] = {
                header = item.title,
                txt = item.description or "",
                icon = item.icon,
                image = item.image,
                iconColor = item.iconColor,
                disabled = item.disabled,
                progress = item.progress,
                params = {
                    event = item.event,
                    args = item.args
                }
            }
        end

        exports[Config.Menu]:openMenu(qbOptions)
    end
end

function PugSoundPlay(Name, Volume, Looped)
    local actionName = "PlaySound"
    if Looped then actionName = "playlooped" end
    SendNUIMessage({
        action = actionName,
        audio = tostring(Name)..".ogg",
        volume = tonumber(Volume),
        loop = Looped,
    })
end

function PugCloseMenu()
    if Config.Menu == "lation_ui" then
        -- exports.lation_ui:closeMenu()
    elseif Config.Menu == "ox_lib" then
        lib.hideContext(false)
    else
        exports[Config.Menu]:closeMenu()
    end
end

function PugInputDialog(header, fields)
    if Config.Input == "ox_lib" or Config.Input == "kl_lib" or Config.Input == "lation_ui" then
        local Input = lib.inputDialog(header, fields)
        if Input then return Input end
    else
        local inputFields = {}
        for _, field in ipairs(fields) do
            table.insert(inputFields, {
                text = field.label,
                name = field.name,
                type = field.type,
                isRequired = field.isRequired or false
            })
        end
        local Input = exports[Config.Input]:ShowInput({
            header = header,
            submitText = Config.Translations.menu.submit_text,
            inputs = inputFields,
        })
        if Input then
            local result = {}
            for _, f in ipairs(fields) do
                table.insert(result, Input[f.name])
            end
            return result
        end
    end
    ClearPedTasksImmediately(PlayerPedId())
    PaintBallNotify(Config.Translations.error.missing_input, "error")
    return false
end

function LockInventory()
    if not Config.LockInventory then return end

    local BusyType = "inv_busy"
    if GetResourceState("ox_inventory") == 'started' then
        BusyType = "invBusy"
    end

    if GetResourceState("tgiann-inventory") == 'started' then
        exports["tgiann-inventory"]:SetInventoryActive(false) -- disable inventory
    else
        LocalPlayer.state:set(BusyType, true, true)
    end
end

local function ClearTrackedWeaponState()
    local ped = PlayerPedId()
    local unarmedHash = GetHashKey("WEAPON_UNARMED")
    local selectedWeapon = GetSelectedPedWeapon(ped)

    if selectedWeapon and selectedWeapon ~= 0 and selectedWeapon ~= unarmedHash then
        SetAmmoInClip(ped, selectedWeapon, 0)
        SetPedAmmo(ped, selectedWeapon, 0)
    end

    SetCurrentPedWeapon(ped, unarmedHash, true)

    if GetResourceState("ox_inventory") == 'started' then
        pcall(function()
            exports.ox_inventory:SetCurrentWeapon("WEAPON_UNARMED")
        end)
    end
end

function UnlockInventory()
    if not Config.LockInventory then return end

    ClearTrackedWeaponState()

    local BusyType = "inv_busy"
    if GetResourceState("ox_inventory") == 'started' then
        BusyType = "invBusy"
    end

    if GetResourceState("tgiann-inventory") == 'started' then
        exports["tgiann-inventory"]:SetInventoryActive(true) -- enable inventory
    else
        LocalPlayer.state:set(BusyType, false, true)
    end
end

local OriginalPlayersArmor
function HandleStartingSetup(spawnHeading) -- When you spawn into the match this function is called
    OriginalPlayersArmor = GetPedArmour(PlayerPedId())

    DoScreenFadeOut(500)
    Wait(500)
    inMatch()
    if Config.UseVrHeadSet and Config.MakeCloneOfPlayer and GetResourceState("pug-battleroyale") == 'started' then
        CreateClone()
    end
    PugSoundPlay("startround", 0.03)
    TriggerEvent('Pug:client:InPaintBallMatchWL')
    SetEntityHealth(PlayerPedId(), 200)
    TriggerEvent("Pug:client:PaintballReviveEvent", spawnHeading)
    if Config.Debug then
        print(ClosedInfo().weapon, 'weapon chosen')
    end
    if CheckMatchingGameMode("Gun_Game") then
    elseif CheckMatchingGameMode("One_In_The_Chamber") then
        GiveThePlayerTheWeapon()
        SetEntityHealth(PlayerPedId(), 110)
    else
        GiveThePlayerTheWeapon()
    end
    FreezeEntityPosition(PlayerPedId(),true)
end

-- HandleEndingSetup
RegisterNetEvent('Pug:client:RemovePlayerFromGameOpen', function() -- removes items when the match ends
    TriggerEvent("Pug:Anticheat:FixRemovedGun")
    ClearTrackedWeaponState()
    RemoveAllPedWeapons(PlayerPedId(), false)
    Wait(0)
    ClearTrackedWeaponState()
    SetEntityHealth(PlayerPedId(), 200)
    if OriginalPlayersArmor then
        SetPedArmour(PlayerPedId(), OriginalPlayersArmor)
        OriginalPlayersArmor = nil
    end
end)

RegisterNetEvent('Pug:paintball:removeFromArena', function()
    CreateThread(function()
        ClearTrackedWeaponState()
        Wait(0)
        ClearTrackedWeaponState()
    end)
end)

local function LoadModel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
	end
end

local function DrawText3Ds(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 41, 11, 41, 90)
    ClearDrawOrigin()
end


-- make a DrawText3D function that draws 3D text on the screen at the given coords
local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local p = GetGameplayCamRelativePitch()
    SetTextScale(0.60, 0.60)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end


CreateThread(function()
    if not Config.UseVrHeadSet or GetResourceState("pug-battleroyale") ~= 'started' then
        -- PedCreation
		ArenaPed = Config.ArenaPed
		LoadModel(ArenaPed)
        local PedLocationSpawn = GetResourceState("int_arcade") == 'started' and vector4(Config.PedLocation.x, Config.PedLocation.y, Config.PedLocation.z-1, Config.PedLocation.w) or vector4(Config.BackupPedLocation.x, Config.BackupPedLocation.y, Config.BackupPedLocation.z-1, Config.BackupPedLocation.w)
		ArenaPedMan = CreatePed(2, ArenaPed, PedLocationSpawn, false, false)
		SetPedFleeAttributes(ArenaPedMan, 0, 0)
		SetPedDiesWhenInjured(ArenaPedMan, false)
		SetPedKeepTask(ArenaPedMan, true)
		SetBlockingOfNonTemporaryEvents(ArenaPedMan, true)
		SetEntityInvincible(ArenaPedMan, true)
		FreezeEntityPosition(ArenaPedMan, true)



        local weaponHash = GetHashKey("WEAPON_CARBINERIFLE")
        GiveWeaponToPed(ArenaPedMan, weaponHash, 0, false, true) -- 250 ammo, equipped in hand
        SetCurrentPedWeapon(ArenaPedMan, weaponHash, true)

        RequestAnimDict("rcmjosh4")
        while not HasAnimDictLoaded("rcmjosh4") do Wait(0) end
        TaskPlayAnim(ArenaPedMan, "rcmjosh4", "josh_leadout_cop2", 8.0, -8.0, -1, 2, 1.0, false, false, false)

        -- End
        blip = AddBlipForCoord(PedLocationSpawn)
        SetBlipSprite(blip, 110)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.75)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Translations.menu.blip_paintball)
        EndTextCommandSetBlipName(blip)

        if Config.Target then
            PugAddTargetToEntity(ArenaPedMan, {
                {
                    name    = "1ViewLobby",
                    type    = "client",
                    event   = "Pug:client:OpenPaintballHUB",
                    icon    = "fas fa-clipboard",
                    label   = Config.Translations.menu.target_view_arena_label,
                    args = { entity = ArenaPedMan},
                    distance = 2.0,
                },
            })
        else
            CreateThread(function()
                while true do
                    Wait(1)
                    if #(GetEntityCoords(PlayerPedId()) - vector3(PedLocationSpawn.x, PedLocationSpawn.y,PedLocationSpawn.z)) <= 3 then
                        DrawText3Ds(
                            PedLocationSpawn.x,
                            PedLocationSpawn.y,
                            PedLocationSpawn.z+1,
                            Config.Translations.menu.open_menu_hint_view_arena
                        )
                        if IsControlJustPressed(0, 38) then
                            local args = {}
                            args.entity = ArenaPedMan
                            TriggerEvent("Pug:client:OpenPaintballHUB", args)
                            Wait(500)
                        end
                    else
                        Wait(2000)
                    end
                end
            end)
        end
        while true do
            Wait(0)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - vector3(PedLocationSpawn.x, PedLocationSpawn.y, PedLocationSpawn.z))
            if distance < 12.0 then
                DrawText3D(
                    PedLocationSpawn.x,
                    PedLocationSpawn.y,
                    PedLocationSpawn.z+2.1,
                    Config.Translations.menu.ped_text_paintball
                )
            else
                Wait(1000)
            end
        end
    end
end)

-- This is the selecting a map event (i dont remember why i placed it in open.lua?)
RegisterNetEvent("Pug:client:SelectChosenMap", function(arenaMap)
    if not LobbyHost or LobbyHost ~= GetPlayerServerId(PlayerId()) then
        PaintBallNotify(Config.Translations.error.need_to_be_lobby_host, 'error')
        TriggerEvent("Pug:client:OpenPaintballHUB", { args = {} })
        return
    end
    TriggerServerEvent("Pug:SV:SetArenaMap", arenaMap or 'random')
    if not ClosedInfo().ingame then
        TriggerEvent("Pug:client:OpenPaintballHUB", { args = {} })
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    local center = vector3(2802.15, -3782.96, 96.95)
    local length, width, heading = 300.0, 400.0, 0.0
    local minZ, maxZ = 90.95, 101.15
    local DEBUG = Config.Debug

    local h = math.rad(heading)
    local cH, sH = math.cos(h), math.sin(h)
    local halfL, halfW = length * 0.5, width * 0.5

    local function rot2(xo, yo)
        return vector3(
            center.x + xo * cH - yo * sH,
            center.y + xo * sH + yo * cH,
            0.0
        )
    end

    local function corners()
        local p1 = rot2( halfL,  halfW)
        local p2 = rot2(-halfL,  halfW)
        local p3 = rot2(-halfL, -halfW)
        local p4 = rot2( halfL, -halfW)
        local b1 = vector3(p1.x, p1.y, minZ)
        local b2 = vector3(p2.x, p2.y, minZ)
        local b3 = vector3(p3.x, p3.y, minZ)
        local b4 = vector3(p4.x, p4.y, minZ)
        local t1 = vector3(p1.x, p1.y, maxZ)
        local t2 = vector3(p2.x, p2.y, maxZ)
        local t3 = vector3(p3.x, p3.y, maxZ)
        local t4 = vector3(p4.x, p4.y, maxZ)
        return b1,b2,b3,b4,t1,t2,t3,t4
    end

    local function isInsideBox(pos)
        if pos.z < minZ or pos.z > maxZ then return false end
        local dx, dy = pos.x - center.x, pos.y - center.y
        local rx =  dx * cH + dy * sH
        local ry = -dx * sH + dy * cH
        return math.abs(rx) <= halfL and math.abs(ry) <= halfW
    end

    local function tri(a,b,c,r,g,bl,a_) DrawPoly(a, b, c, r, g, bl, a_) end
    local function quad(a,b,c,d,r,g,bl,a_)
        tri(a,b,c,r,g,bl,a_); tri(a,c,d,r,g,bl,a_)
    end

    local function drawDebug()
        local b1,b2,b3,b4,t1,t2,t3,t4 = corners()
        DrawLine(b1,b2,255,0,0,220); DrawLine(b2,b3,255,0,0,220)
        DrawLine(b3,b4,255,0,0,220); DrawLine(b4,b1,255,0,0,220)
        DrawLine(t1,t2,0,255,0,220); DrawLine(t2,t3,0,255,0,220)
        DrawLine(t3,t4,0,255,0,220); DrawLine(t4,t1,0,255,0,220)
        DrawLine(b1,t1,0,150,255,220); DrawLine(b2,t2,0,150,255,220)
        DrawLine(b3,t3,0,150,255,220); DrawLine(b4,t4,0,150,255,220)
        quad(b1,b2,t2,t1,0,255,0,60)
        quad(b2,b3,t3,t2,0,255,0,60)
        quad(b3,b4,t4,t3,0,255,0,60)
        quad(b4,b1,t1,t4,0,255,0,60)
        quad(t1,t2,t3,t4,0,255,0,40)
        quad(b1,b2,b3,b4,255,0,0,30)
    end

    local function handleInBounds()
        if ClosedInfo().ingame then
            if ClosedInfo().team == 'redteam' then
                SetEntityCoords(PlayerPedId(), Config.RedTeamSpawns[ClosedInfo().map][placement])
                Wait(500); TriggerEvent("Pug:client:PaintballReviveEvent")
                PaintBallNotify(Config.Translations.success.savedfrinfall, 'success')
            elseif ClosedInfo().team == 'blueteam' then
                SetEntityCoords(PlayerPedId(), Config.BlueTeamSpawns[ClosedInfo().map][placement])
                Wait(500); TriggerEvent("Pug:client:PaintballReviveEvent")
                PaintBallNotify(Config.Translations.success.savedfrinfall, 'success')
            else
                SetEntityCoords(PlayerPedId(), Config.BlueTeamSpawns[ClosedInfo().map][2])
                Wait(500); TriggerEvent("Pug:client:PaintballReviveEvent")
                PaintBallNotify(Config.Translations.success.savedfrinfall, 'success')
            end
        else
            if not IsPedInAnyVehicle(PlayerPedId()) then
                SetEntityCoords(PlayerPedId(), Config.PedLocation)
                Wait(500); TriggerEvent("Pug:client:PaintballReviveEvent")
                PaintBallNotify(Config.Translations.success.savedfrinfall, 'success')
            end
        end
    end

    local lastInside = false
    CreateThread(function()
        while true do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local inside = isInsideBox(pos)
            if inside and not lastInside then handleInBounds() end
            lastInside = inside
            if DEBUG then drawDebug(); Wait(0) else Wait(500) end
        end
    end)
end)





RegisterNetEvent("Pug:client:PaintballNotifyEvent", function(msg, style, length)
	PaintBallNotify(msg, style, length)
end)

if Framework == "QBCore" then
    -- On player load to give items back to the player if the crashed or logged out during a match.
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        Wait(1000)
        if #(GetEntityCoords(PlayerPedId()) - vector3(2945.65, -3796.44, 143.26)) <= 1000 or #(GetEntityCoords(PlayerPedId()) -  vector3(-3234.46, 7045.22, 637.62)) <= 100 or 
        #(GetEntityCoords(PlayerPedId()) -  vector3(1376.41, -784.41, 67.64)) <= 100 and GetResourceState('nuketown-mirrorpark') == 'started' then
            SetEntityCoords(PlayerPedId(), Config.PedLocation)
            PaintBallNotify(Config.Translations.success.removed_from_arena, 'success')
        end
        if not Config.HasBattleRoyaleScript then
            if Config.RemoveAllItemsForPlayer then
                GivePaintballItems()
            end
        end
    end)
elseif Framework == "ESX" then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function()
        Wait(1000)
        if #(GetEntityCoords(PlayerPedId()) - vector3(2945.65, -3796.44, 143.26)) <= 1000 or #(GetEntityCoords(PlayerPedId()) -  vector3(-3234.46, 7045.22, 637.62)) <= 100 or 
        #(GetEntityCoords(PlayerPedId()) -  vector3(1376.41, -784.41, 67.64)) <= 100 and GetResourceState('nuketown-mirrorpark') == 'started' then
            SetEntityCoords(PlayerPedId(), Config.PedLocation)
            PaintBallNotify(Config.Translations.success.removed_from_arena, 'success')
        end
        if not Config.HasBattleRoyaleScript then
            if Config.RemoveAllItemsForPlayer then
                GivePaintballItems()
            end
        end
    end)
end

-- Outffi for red and blue team (THIS CAN ALL BE ADJUSTED IN THE CONFIG. DONT TOUCH THIS HERE.)
function OutFitRed()
    local GenderType = 'mp_m_freemode_01'
    if IsPedModel(PlayerPedId(), 'mp_m_freemode_01') then
        GenderType =  'mp_m_freemode_01'
    else
        GenderType = 'mp_f_freemode_01'
    end 
    local Info = {
        Gender = GenderType,
        Team = "redteam",
    }
    Config.FrameworkFunctions.TriggerCallback('Pug:SVCB:GetTeamOutfits', function(Data)
        if Data then
            for clothingPiece, _ in pairs(Data) do
                if clothingPiece == 'hat' then -- 'hat' is a prop, not a component
                    SetPedPropIndex(PlayerPedId(), 0, Data.hat, Data.that)
                else
                    local componentId
                    if clothingPiece == 'torso' then
                        componentId = 3
                    elseif clothingPiece == 'mask' then
                        componentId = 1
                    elseif clothingPiece == 'pants' then
                        componentId = 4
                    elseif clothingPiece == 'jacket' then
                        componentId = 11
                    elseif clothingPiece == 'shoes' then
                        componentId = 6
                    elseif clothingPiece == 'undershirt' then
                        componentId = 8
                    elseif clothingPiece == 'bag' then
                        componentId = 5
                    end
                    if componentId then
                        SetPedComponentVariation(PlayerPedId(), componentId, Data[clothingPiece], Data['t'..clothingPiece])
                    end
                end
            end
        end
    end, Info)
end

function OutFitBlue()
    local GenderType = 'mp_m_freemode_01'
    if IsPedModel(PlayerPedId(), 'mp_m_freemode_01') then
        GenderType =  'mp_m_freemode_01'
    else
        GenderType = 'mp_f_freemode_01'
    end 
    local Info = {
        Gender = GenderType,
        Team = "blueteam",
    }
    Config.FrameworkFunctions.TriggerCallback('Pug:SVCB:GetTeamOutfits', function(Data)
        if Data then
            for clothingPiece, _ in pairs(Data) do
                if clothingPiece == 'hat' then -- 'hat' is a prop, not a component
                    SetPedPropIndex(PlayerPedId(), 0, Data.hat, Data.that)
                else
                    local componentId
                    if clothingPiece == 'torso' then
                        componentId = 3
                    elseif clothingPiece == 'mask' then
                        componentId = 1
                    elseif clothingPiece == 'pants' then
                        componentId = 4
                    elseif clothingPiece == 'jacket' then
                        componentId = 11
                    elseif clothingPiece == 'shoes' then
                        componentId = 6
                    elseif clothingPiece == 'undershirt' then
                        componentId = 8
                    elseif clothingPiece == 'bag' then
                        componentId = 5
                    end
                    if componentId then
                        SetPedComponentVariation(PlayerPedId(), componentId, Data[clothingPiece], Data['t'..clothingPiece])
                    end
                end
            end
        end
    end, Info)
end

RegisterNetEvent('Pug:client:AcivateUavPaintball',function(coords,id)
    if ClosedInfo().ingame then
        if tonumber(GetPlayerServerId(PlayerId())) == tonumber(id) then return end
        local uavblip = {}
        local alpha = 250
        uavblip[id] = AddBlipForRadius(coords.x,coords.y,coords.z, 7.0)
        SetBlipSprite(uavblip[id],9)
        SetBlipColour(uavblip[id],49)
        SetBlipAlpha(uavblip[id],alpha)
        SetBlipAsShortRange(uavblip[id], false)

        while alpha ~= 0 do
            Wait(100)
            alpha = alpha - 5
            SetBlipAlpha(uavblip[id], alpha)
            if alpha == 0 then
                RemoveBlip(uavblip[id])
                uavblip[id] = nil
                return
            end
        end
    end
end)

RegisterNetEvent("Pug:client:StoreRedTeamClothes", function()
    if IsPedModel(PlayerPedId(), 'mp_m_freemode_01') then
        PlayersGender = "mp_m_freemode_01"
    else
        PlayersGender = "mp_f_freemode_01"
    end
    local Data = {
        torso = GetPedDrawableVariation(PlayerPedId(),3),
        ttorso = GetPedTextureVariation(PlayerPedId(),3),
        mask = GetPedDrawableVariation(PlayerPedId(),1),
        tmask = GetPedTextureVariation(PlayerPedId(),1),
        pants = GetPedDrawableVariation(PlayerPedId(),4),
        tpants = GetPedTextureVariation(PlayerPedId(),4),
        jacket = GetPedDrawableVariation(PlayerPedId(),11),
        tjacket = GetPedTextureVariation(PlayerPedId(),11),
        shoes = GetPedDrawableVariation(PlayerPedId(),6),
        tshoes = GetPedTextureVariation(PlayerPedId(),6),
        undershirt = GetPedDrawableVariation(PlayerPedId(),8),
        tundershirt = GetPedTextureVariation(PlayerPedId(),8),
        bag = GetPedDrawableVariation(PlayerPedId(),5),
        tbag = GetPedTextureVariation(PlayerPedId(),5),
        hat = GetPedPropIndex(PlayerPedId(),0),
        that = GetPedPropTextureIndex(PlayerPedId(), 0),
        Gender = PlayersGender,
    }
    TriggerServerEvent("Pug:server:UpdateRedTeamsClothes", Data)
end)

RegisterNetEvent("Pug:client:StoreBlueTeamClothes", function()
    if IsPedModel(PlayerPedId(), 'mp_m_freemode_01') then
        PlayersGender = "mp_m_freemode_01"
    else
        PlayersGender = "mp_f_freemode_01"
    end
    local Data = {
        torso = GetPedDrawableVariation(PlayerPedId(),3),
        ttorso = GetPedTextureVariation(PlayerPedId(),3),
        mask = GetPedDrawableVariation(PlayerPedId(),1),
        tmask = GetPedTextureVariation(PlayerPedId(),1),
        pants = GetPedDrawableVariation(PlayerPedId(),4),
        tpants = GetPedTextureVariation(PlayerPedId(),4),
        jacket = GetPedDrawableVariation(PlayerPedId(),11),
        tjacket = GetPedTextureVariation(PlayerPedId(),11),
        shoes = GetPedDrawableVariation(PlayerPedId(),6),
        tshoes = GetPedTextureVariation(PlayerPedId(),6),
        undershirt = GetPedDrawableVariation(PlayerPedId(),8),
        tundershirt = GetPedTextureVariation(PlayerPedId(),8),
        bag = GetPedDrawableVariation(PlayerPedId(),5),
        tbag = GetPedTextureVariation(PlayerPedId(),5),
        hat = GetPedPropIndex(PlayerPedId(),0),
        that = GetPedPropTextureIndex(PlayerPedId(), 0),
        Gender = PlayersGender,
    }
    TriggerServerEvent("Pug:server:UpdateBlueTeamsClothes", Data)
end)

function SetupOxLibRadial()
    lib.addRadialItem({
        id = 'paintballsurrender',
        label = Config.Translations.menu.radial_surrender_label,
        icon = 'skull-crossbones',
        onSelect = function ()
            if isInMatch then
                if not DeathCooldown then
                    if not IsPlayerDead then
                        TriggerServerEvent('Pug:paintball:RemovePlayer',playerTeam)
                        TriggerEvent('Pug:client:InPaintBallMatchWLFalse')
                    else
                        PaintBallNotify(Config.Translations.error.cant_do_this, 'error')
                    end
                else
                    PaintBallNotify(Config.Translations.error.cant_do_this, 'error')
                end
            end
            lib.hideRadial()
        end
    })
end

RegisterNetEvent("Pug:client:PaintballKillFeed", function(data)
    if not data then return end
    SendNUIMessage({
        action      = "KillFeed",
        killer      = data.killer or "",
        victim      = data.victim or "",
        weapon      = data.weapon or "",
        killerColor = data.killerColor or "",
        victimColor = data.victimColor or "",
        headshot    = data.headshot or false,
    })
end)


RegisterNetEvent('Pug:client:PaintballRankUp', function(data)
    local oldIcon = Config.Leveling.Prestiges[data.oldPrestige].icon
    local newIcon = Config.Leveling.Prestiges[data.newPrestige].icon

    data.oldIcon = oldIcon
    data.newIcon = newIcon

    SendNUIMessage({
        action = 'RankUp',
        data   = data
    })
end)

RegisterNetEvent("Pug:client:PlayPaintballClientSound", function(Sound, Volume)
    PugSoundPlay(Sound, Volume)
end)

-- Wasabi Ambulance V2 marks a downed player with the `isDead` state bag (> 0 = dead or last stand)
-- and only revives when the server asks it to (RevivePlayer export).
local function IsWasabiDeadValue(value)
    return value == true or (type(value) == 'number' and value > 0)
end

function IsWasabiDead()
    local wasabiResource = GetWasabiAmbulanceResource()
    if not wasabiResource then return false end
    if IsWasabiDeadValue(LocalPlayer.state.isDead) then return true end
    local ok, dead = pcall(function() return exports[wasabiResource]:isPlayerDead(GetPlayerServerId(PlayerId())) end)
    return ok and IsWasabiDeadValue(dead)
end

local wasabiReviveRunning = false
local wasabiReviveUntil = 0
local function RequestWasabiRevive(PlayerHeadingSet)
    wasabiReviveUntil = GetGameTimer() + 6000
    TriggerServerEvent('Pug:server:PaintballWasabiRevive')
    if wasabiReviveRunning then return end
    wasabiReviveRunning = true
    CreateThread(function()
        -- Keep asking until Wasabi lets go of us.
        local dead
        repeat
            Wait(1000)
            dead = IsWasabiDead()
            if dead then TriggerServerEvent('Pug:server:PaintballWasabiRevive') end
        until not dead or GetGameTimer() >= wasabiReviveUntil
        wasabiReviveRunning = false
        if dead then return end
        local ped = PlayerPedId()
        if PlayerHeadingSet then SetEntityHeading(ped, PlayerHeadingSet) end
        if DeathCooldown then -- CTF death cam: stay hidden until the countdown respawns us
            FreezeEntityPosition(ped, true)
            SetEntityVisible(ped, false)
        end
    end)
end

local function ResurrectAndHeal(PlayerHeadingSet)
    local ped = PlayerPedId()
    if IsEntityDead(ped) then
        local coords = GetEntityCoords(ped)
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, PlayerHeadingSet or GetEntityHeading(ped), true, false)
        ped = PlayerPedId()
        ClearPedTasksImmediately(ped)
    end
    ClearPedBloodDamage(ped)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
end

-- Paintball handles its own deaths, so the moment Wasabi puts us on its death screen
-- during a match, get revived and let the paintball respawn take over.
AddStateBagChangeHandler('isDead', nil, function(bagName, _, value)
    if bagName ~= ('player:%s'):format(GetPlayerServerId(PlayerId())) then return end
    if not isInMatch or not IsWasabiDeadValue(value) then return end
    if not GetWasabiAmbulanceResource() then return end
    RequestWasabiRevive()
end)

RegisterNetEvent("Pug:client:PaintballReviveEvent", function(PlayerHeadingSet)
    if GetResourceState('ambulancejob') == 'started' then
        TriggerEvent('ambulancejob:healPlayer', {revive = true}) -- to heal player
    elseif GetResourceState('tk_ambulancejob') == 'started' then
        TriggerEvent('tk_ambulancejob:revive', true)
    elseif GetResourceState('ak47_qb_ambulancejob') == 'started' then
        TriggerEvent('ak47_qb_ambulancejob:revive')
        TriggerEvent('ak47_qb_ambulancejob:skellyfix')
    elseif GetResourceState('ak47_ambulancejob') == 'started' then
        TriggerEvent('ak47_ambulancejob:revive') 
        TriggerEvent('ak47_ambulancejob:skellyfix') 
    elseif GetWasabiAmbulanceResource() then
        if IsWasabiDead() then
            RequestWasabiRevive(PlayerHeadingSet)
        else
            ResurrectAndHeal(PlayerHeadingSet)
        end
        if GetWasabiAmbulanceResource() == 'wasabi_ambulance' then -- V1
            TriggerEvent('esx_ambulancejob:revive')
            TriggerEvent('wasabi_ambulance:revive')
        end
    elseif GetResourceState('ars_ambulancejob') == 'started' then
        Wait(1000)
        TriggerEvent('ars_ambulancejob:healPlayer', {revive = true}) -- to revive player
        TriggerEvent('ars_ambulancejob:healPlayer', {heal = true}) -- to heal player
        Wait(1000)
        if PlayerHeadingSet then ClearPedTasksImmediately(PlayerPedId()) SetEntityHeading(PlayerPedId(), PlayerHeadingSet) end
    elseif GetResourceState('visn_are') == 'started' then
        TriggerEvent('hospital:client:Revive')
        TriggerEvent('esx_ambulancejob:revive')
        TriggerEvent('visn_are:resetHealthBuffer')
    elseif Framework == "QBCore" then
        TriggerEvent('hospital:client:Revive')
        TriggerEvent("qbx_medical:client:playerRevived")
    else
        TriggerEvent('esx_ambulancejob:revive')
    end
end)

RegisterNUICallback('RequestConfig', function(data, cb)
    cb(Config)
end)

local function IsInPaintball()
    return ClosedInfo().ingame
end
exports("IsInPaintball", IsInPaintball)
