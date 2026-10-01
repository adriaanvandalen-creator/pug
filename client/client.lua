
-- ============================================================================
-- WEAPON LABEL REGISTRATION
-- ============================================================================
AddTextEntry("WEAPON_PAINTGUN", "Paintball")

-- ============================================================================
-- MODULE STATE
-- ============================================================================
local keysDisabled            = false
local activeArenaEntitySet    = nil
local currentMapName          = nil
local intent_unknown_3        = nil
local respawnCountdown        = 10
local oitcLivesLeft           = 0
local redTeamScore            = 0
local blueTeamScore           = 0
local originalCoords          = nil
local clonePed                = nil
local enemyFlagEntity         = nil
local ownFlagEntity           = nil
local currentGameModeName     = Config.GameModes.Hold_Your_Own.name
local redFlagSpawnCoords      = nil
local blueFlagSpawnCoords     = nil
local savedRadioChannel       = 0
local killStreak              = 0
local activeCamHandle         = 0
local isCapturingFlag         = false
local countdownCam            = nil
local savedPlayerHealth       = nil

-- ============================================================================
-- GLOBALS exported / shared with the rest of the resource
-- ============================================================================
IsPlayerDead    = false
isInMatch       = false
DeathCooldown   = false
PaintballDeathGraceUntil = 0 -- keeps ambulance scripts off our deaths while we leave the arena
ChosenWeapon    = "weapon_pistol"
playerTeam      = nil
LobbyHost       = false

local matchTimerActive  = false
local teamLivesConfig   = nil

-- ============================================================================
-- HELPERS: GAME-MODE PROBE
-- ============================================================================

-- Returns true when the supplied game-mode key matches the currently active
function CheckMatchingGameMode(gameModeKey)
  local gameMode = Config.GameModes[gameModeKey]
  if gameMode and currentGameModeName == Config.GameModes[gameModeKey].name then
    return true
  end
  return false
end

local function requestModelLoad(modelHash)
  RequestModel(modelHash)
  while not HasModelLoaded(modelHash) do
    Wait(0)
  end
end

-- ============================================================================
-- BOOT-TIME: PICK A DEFAULT WEAPON FROM Config.WeaponItems
-- ============================================================================
CreateThread(function()
  for _, weaponItem in pairs(Config.WeaponItems) do
    ChosenWeapon = weaponItem.name
    break
  end
end)

-- ============================================================================
-- ITEM/INVENTORY HELPERS
-- ============================================================================

function GivePaintballItems()
  return TriggerServerEvent("Pug:server:ItemsGivePaintBallPlayer")
end

-- ============================================================================
-- CLOTHING SAVE/RESTORE
-- The match changes the player's outfit (clan pack or team default); we snapshot
-- the original at match start and restore it at match end.
-- ============================================================================

local savedClothes = nil

-- Snapshot the player's current ped components/props into `savedClothes`.
function SaveClothes()
  local ped = PlayerPedId()
  local snap = {}

  local function captureComponent(componentId)
    local drawable               = GetPedDrawableVariation(ped, componentId)
    local texture, palette, t4   = GetPedTextureVariation(ped, componentId)
    return { drawable, texture, palette, t4 }
  end

  snap.torso      = captureComponent(3)
  snap.mask       = captureComponent(1)
  snap.pants      = captureComponent(4)
  snap.jacket     = captureComponent(11)
  snap.shoes      = captureComponent(6)
  snap.undershirt = captureComponent(8)
  snap.bag        = captureComponent(5)

  -- The "hat" slot is a prop, not a component, so it uses the prop variants.
  do
    local propIdx              = GetPedPropIndex(ped, 0)
    local propTex, p3, p4      = GetPedPropTextureIndex(ped, 0)
    snap.hat = { propIdx, propTex, p3, p4 }
  end

  savedClothes = snap
end

function RestoreClothes()
  if not savedClothes then return end
  local ped = PlayerPedId()

  SetPedComponentVariation(ped, 3,  savedClothes.torso[1],      savedClothes.torso[2])
  SetPedComponentVariation(ped, 1,  savedClothes.mask[1],       savedClothes.mask[2])
  SetPedComponentVariation(ped, 4,  savedClothes.pants[1],      savedClothes.pants[2])
  SetPedComponentVariation(ped, 11, savedClothes.jacket[1],     savedClothes.jacket[2])
  SetPedComponentVariation(ped, 6,  savedClothes.shoes[1],      savedClothes.shoes[2])
  SetPedComponentVariation(ped, 8,  savedClothes.undershirt[1], savedClothes.undershirt[2])
  SetPedComponentVariation(ped, 5,  savedClothes.bag[1],        savedClothes.bag[2])

  if savedClothes.hat[1] and savedClothes.hat[1] >= 0 then
    SetPedPropIndex(ped, 0, savedClothes.hat[1], savedClothes.hat[2], true)
  else
    ClearPedProp(ped, 0)
  end
end

-- ============================================================================
-- DRAW HELPERS
-- ============================================================================

-- Draw a centered single-line string near the top of the screen.
local function drawCenteredText(text)
  SetTextFont(4)
  SetTextScale(0.5, 0.5)
  SetTextColour(255, 255, 255, 255)
  SetTextCentre(true)
  SetTextEntry("STRING")
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextEdge(4, 0, 0, 0, 255)
  SetTextOutline()
  AddTextComponentString(text)
  DrawText(0.5, 0.03)
end

-- ============================================================================
-- ox_inventory WEAPON-WHEEL SYNC
-- pug-paintball needs ox_inventory to know about the auto-given weapon so the
-- HUD reflects it; this is wrapped in pcall in case the export is missing.
-- ============================================================================
local function notifyOxInventoryCurrentWeapon(weaponName)
  if GetResourceState("ox_inventory") == "started"
     and GetResourceState("jaksam_inventory") ~= "started" then

    local ok = pcall(function()
      exports.ox_inventory:SetCurrentWeapon(weaponName)
    end)
    if ok then return end

    -- Export is not registered in the user's ox_inventory build — tell them
    -- exactly what to paste so weapon syncing works.
    print([[
            ^4========================================================^7
            ^1[PUG WARNING]^7: Missing required export in ^3ox_inventory/client.lua^7!
            Paste the following line from the ^2pug-paintball/readme.md^7 
            at the very bottom of the ^3ox_inventory/client.lua^7 file to enable weapon syncing:

            exports("SetCurrentWeapon", function(ThisWeapon)
                local inPaintball = GetResourceState("pug-paintball") == "started" and exports["pug-paintball"]:IsInPaintball()
                local inBattleRoyale = GetResourceState("pug-battleroyale") == "started" and exports["pug-battleroyale"]:IsInBattleRoyale()
                if not inPaintball and not inBattleRoyale then return end
                currentWeapon = ThisWeapon
            end)
            ^4========================================================^7
        ]])
  end
end

-- ============================================================================
-- WEAPON DELIVERY
-- Picks the right weapon for the active mode and gives it to the local ped.
--   useOneAmmoForOITC : when true (OITC reload path) start with 1 round in clip
--   giveSpecialWeapon : when true, give Config.SpecailWeaponItem (kill-streak)
--   stripToUnarmed    : when true, force the player to weapon_unarmed
-- ============================================================================
-- Give + select a weapon without replaying the draw animation when it's already in hand
-- (re-selecting it every call is what made the weapon flicker).
local function equipMatchWeapon(weaponName, ammo, clip)
  local ped  = PlayerPedId()
  local hash = GetHashKey(weaponName)
  if not HasPedGotWeapon(ped, hash, false) then
    GiveWeaponToPed(ped, hash, 0, false, false)
  end
  if ammo then SetPedAmmo(ped, hash, ammo) end
  if GetSelectedPedWeapon(ped) ~= hash then
    SetCurrentPedWeapon(ped, hash, true)
  end
  if clip then SetAmmoInClip(ped, hash, clip) end
end

function GiveThePlayerTheWeapon(useOneAmmoForOITC, giveSpecialWeapon, stripToUnarmed)
  if Config.Debug then
    print(("[pug-paintball] GiveThePlayerTheWeapon(%s, %s, %s)\n%s"):format(
      tostring(useOneAmmoForOITC), tostring(giveSpecialWeapon), tostring(stripToUnarmed),
      debug.traceback("", 2)))
  end
  CreateThread(function()
    if stripToUnarmed then
      -- ---------- strip back to fists --------------------------------------
      notifyOxInventoryCurrentWeapon("WEAPON_UNARMED")
      SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)

    elseif giveSpecialWeapon then
      -- ---------- kill-streak special weapon (e.g. RPG) --------------------
      notifyOxInventoryCurrentWeapon(Config.SpecailWeaponItem)
      equipMatchWeapon(Config.SpecailWeaponItem, 1000)

    elseif CheckMatchingGameMode("Gun_Game") then
      -- ---------- Gun Game: give the weapon at index ChosenWeapon ---------
      local weaponName = RndomWeapons[ChosenWeapon]
      notifyOxInventoryCurrentWeapon(weaponName)
      equipMatchWeapon(weaponName, 1000)

    elseif CheckMatchingGameMode("One_In_The_Chamber") then
      -- ---------- OITC: the OneInTheChamberWeapon, one shot at a time -----
      equipMatchWeapon(Config.OneInTheChamberWeapon)

      if useOneAmmoForOITC then
        -- Start with 1 ammo (used on respawn after firing).
        notifyOxInventoryCurrentWeapon(Config.OneInTheChamberWeapon)
        SetPedAmmo(PlayerPedId(), GetHashKey(Config.OneInTheChamberWeapon), 1)
      else
        -- Initial give: keep whatever is in the player's clip + 1.
        notifyOxInventoryCurrentWeapon(Config.OneInTheChamberWeapon)
        local currentWeaponHash = GetSelectedPedWeapon(GetPlayerPed(PlayerId()))
        local ammoInClip        = select(2, GetAmmoInClip(GetPlayerPed(PlayerId()), currentWeaponHash))
        SetAmmoInClip(PlayerPedId(), currentWeaponHash, ammoInClip + 1)
      end

    else
      -- ---------- default: regular team-deathmatch weapon -----------------
      notifyOxInventoryCurrentWeapon(ChosenWeapon)
      equipMatchWeapon(ChosenWeapon, 1000, 1000)
    end
  end)
end

-- ============================================================================
-- MODE PROBES & LIVES LOOKUP
-- ============================================================================

local function isFFAGameMode()
  if CheckMatchingGameMode("Gun_Game")
  or CheckMatchingGameMode("Free_For_All")
  or CheckMatchingGameMode("One_In_The_Chamber") then
    return true
  end
  return false
end

-- Returns the lives count for the local player based on team / mode.
local function getLivesForLocalPlayer()
  if not teamLivesConfig then return nil end
  if isFFAGameMode() then         return teamLivesConfig.ffa  end
  if playerTeam == "redteam"  then return teamLivesConfig.red  end
  if playerTeam == "blueteam" then return teamLivesConfig.blue end
  return nil
end

-- ============================================================================
-- COUNTDOWN CAMERA
-- A scripted cam that shows the player a top-down view of the chosen spawn
-- while the match-start countdown ticks.
-- ============================================================================

local function destroyCountdownCam()
  if activeCamHandle ~= 0 then
    DestroyCam(activeCamHandle, false)
    DestroyCam(countdownCam,   false)
    RenderScriptCams(0, 0, 1, 1, 1)
    activeCamHandle = 0
  end
end

-- Build a top-down cam at `coords`, optionally pointing at the ped after a
local function createCountdownCam(coords, rotation, transitionMs)
  destroyCountdownCam()
  countdownCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
  SetCamCoord(countdownCam, coords)

  if rotation ~= nil then
    SetCamRot(countdownCam, vector3(rotation.x, rotation.y, rotation.z))
  end

  if transitionMs then
    RenderScriptCams(true, 1, transitionMs, 300, 0)
    PointCamAtCoord (countdownCam, GetEntityCoords(PlayerPedId()))
  else
    RenderScriptCams(1, 0, 0, 1, 1)
  end

  Wait(250)
  activeCamHandle = countdownCam
end

-- Picks the spawn furthest from the player (so the countdown cam shows a wide
-- arena view, not the spot they're standing on) and creates the cam there.
local function setupCountdownCamForFurthestSpawn()
  local localPed     = PlayerPedId()
  local localCoords  = GetEntityCoords(localPed)

  -- Choose the right spawn list based on the active mode/team.
  local spawnList
  if isFFAGameMode() then
    spawnList = Config.FFASpawns[currentMapName]
  elseif playerTeam == "redteam" then
    -- NB: original puts red players at the BLUE spawn for the cam intro
    -- (mirror view). We preserve that behaviour exactly.
    spawnList = Config.BlueTeamSpawns[currentMapName]
  else
    spawnList = Config.RedTeamSpawns[currentMapName]
  end

  -- Furthest-from-player linear scan.
  local function distance(a, b)
    local dx = b.x - a.x
    local dy = b.y - a.y
    local dz = b.z - a.z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
  end

  local bestDist, bestSpawn = 0, nil
  for i = 1, #spawnList do
    local s = spawnList[i]
    local d = distance(localCoords, s)
    if bestDist < d then
      bestDist = d
      bestSpawn = s
    end
  end

  if bestSpawn then
    createCountdownCam(
      vector3(bestSpawn.x, bestSpawn.y, bestSpawn.z + 40),  -- 40m above the spawn
      vector3(0.0, 0.0, 0.0),
      4000
    )
  end
end

-- ============================================================================
-- RESOURCE LIFECYCLE: clean up if we're stopped mid-match
-- ============================================================================
AddEventHandler("onResourceStop", function(resourceName)
  if GetCurrentResourceName() ~= resourceName then return end

  -- If we still have the paintball gun out, swap to unarmed first so the
  -- player isn't left aiming a now-invalid weapon hash.
  if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("weapon_paintballgun") then
    SetCurrentPedWeapon(PlayerPedId(), GetHashKey("weapon_unarmed"), true)
  end

  if leaderboardProp then
    DeleteEntity(leaderboardProp)
  end

  if isInMatch then
    SetEntityCoords(PlayerPedId(), originalCoords)
    RestoreClothes()
    UnlockInventory()
    TriggerEvent("Pug:client:RemovePlayerFromGameOpen")

    if Config.RemoveAllItemsForPlayer then
      GivePaintballItems()
    end

    if Config.UseVrHeadSet and GetResourceState("pug-battleroyale") == "started" then
      TriggerEvent("Pug-VrHeadSet:toggle")
    end

    GiveThePlayerTheWeapon(false, false, true)  -- strip to unarmed
    TriggerEvent("Pug:client:PaintballReviveEvent")
  end
end)

-- ============================================================================
-- BODY-DOUBLE CLONE (used during the countdown intro so the spectator-cam
-- view shows a static-looking ped while the real one is teleported around).
-- ============================================================================
function CreateClone()
  clonePed = ClonePed(PlayerPedId(), 1, 1, 1)
  Wait(500)
  SetEntityInvincible              (clonePed, true)
  FreezeEntityPosition             (clonePed, true)
  TaskSetBlockingOfNonTemporaryEvents(clonePed, true)
  SetBlockingOfNonTemporaryEvents  (clonePed, true)
  ClearPedTasksImmediately         (clonePed)

  if IsPedInAnyVehicle(PlayerPedId()) then
    -- If we were in a vehicle, slot the clone into our seat instead of leaving
    -- the seat empty.
    local veh   = GetVehiclePedIsIn(PlayerPedId())
    local maxSeat = GetVehicleMaxNumberOfPassengers(veh)
    for seat = math.ceil(0, 2), -1, 1 do  -- (preserved verbatim from decompile)
      if GetPedInVehicleSeat(veh, seat) == PlayerPedId() then
        SetPedIntoVehicle(clonePed, veh, seat)
      end
    end
  else
    SetEntityCoords(clonePed, originalCoords.x, originalCoords.y, originalCoords.z - 1)
    TaskStartScenarioInPlace(clonePed, "PROP_HUMAN_PARKING_METER", 0, true)
  end
end

-- Helper to load an animation dictionary and yield until it's available.
local function requestAndAwaitAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    RequestAnimDict(dict)
    Wait(50)
  end
end

-- ============================================================================
-- COUNTDOWN ANIMATION ROULETTE
-- One of ten random idles played on the local ped while the cam is wide.
-- ============================================================================
local function playRandomCountdownAnimation()
  local roll = math.random(1, 10)

  -- Each branch loads its own dict before TaskPlayAnim. We collapse the 10
  -- copies into a single helper that walks a small lookup table.
  local choices = {
    [1]  = { "missmic4",                                                 "michael_tux_fidget"     },
    [2]  = { "clothingtie",                                              "try_tie_positive_a"     },
    [3]  = { "anim@heists@humane_labs@finale@strip_club",                "ped_b_celebrate_loop"   },
    [4]  = { "anim@mp_corona_idles@male_d@idle_a",                       "idle_a"                 },
    [5]  = { "friends@fra@ig_1",                                         "base_idle"              },
    [6]  = { "random@countrysiderobbery",                                "idle_a"                 },
    [7]  = { "anim@deathmatch_intros@unarmed",                           "intro_male_unarmed_c"   },
    [8]  = { "anim@deathmatch_intros@unarmed",                           "intro_male_unarmed_e"   },
    [9]  = { "anim@mp_player_intcelebrationfemale@knuckle_crunch",       "knuckle_crunch"         },
    [10] = { "random@train_tracks",                                      "idle_e"                 },
  }
  local pick = choices[roll]
  if pick then
    local dict, anim = pick[1], pick[2]
    requestAndAwaitAnimDict(dict)
    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
  end
end

-- ============================================================================
-- DRAW HELPERS (extended)
-- ============================================================================
local function drawTextEx(text, font, rgbColour, scale, x, y)
  SetTextFont(font)
  SetTextScale(scale, scale)
  SetTextColour(rgbColour[1], rgbColour[2], rgbColour[3], 255)
  SetTextEntry("STRING")
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextEdge(4, 0, 0, 0, 255)
  SetTextOutline()
  AddTextComponentString(text)
  DrawText(x, y)
end

-- ============================================================================
-- INFO STRUCT exposed to other resources via the global ClosedInfo()
-- ============================================================================
function ClosedInfo()
  return {
    ingame = isInMatch,
    team   = playerTeam,
    weapon = ChosenWeapon,
    map    = currentMapName,
    mode   = currentGameModeName,
  }
end

-- ============================================================================
-- NET EVENTS — basic delete / weapon-broadcast / sound notifications
-- ============================================================================

RegisterNetEvent("Pug:DeleteClonePaintball", function(entity)
  TriggerEvent("FullyDeletePaintballEntity", entity)
end)

RegisterNetEvent("Pug:client:SetAllPlayersWeapons", function(weaponName)
  ChosenWeapon = weaponName
  if isInMatch then
    GiveThePlayerTheWeapon()
  end
  -- Use the friendly label if Config.WeaponItems knows about it; otherwise the
  -- raw name is shown in the toast.
  local label = (Config.WeaponItems[weaponName] and Config.WeaponItems[weaponName].label) or weaponName
  PaintBallNotify(label, "success")
end)

RegisterNetEvent("Pug:client:PlayerKilledNotification", function()
  PugSoundPlay("terminate", 0.2)
end)
RegisterNetEvent("Pug:client:AllPlayersKilledNotification", function()
  PugSoundPlay("terminate", 0.2)
end)

-- ============================================================================
-- MBA (Maze Bank Arena) INTERIOR ENTITY-SET TOGGLES
-- The arena interior at (-324.22, -1968.49, 20.60) supports many "looks";
-- pug-paintball deactivates everything then activates the matching set per
-- and L36_1/L37_1 (ipairs helpers).
-- ============================================================================
local mbaEntitySets = {
  basketball  = { "mba_tribune", "mba_tarps",     "mba_basketball", "mba_jumbotron" },
  derby       = { "mba_cover",   "mba_terrain",   "mba_derby",      "mba_ring_of_fire" },
  paintball   = { "mba_tribune", "mba_chairs",    "mba_paintball",  "mba_jumbotron" },
  concert     = { "mba_tribune", "mba_tarps",     "mba_backstage",  "mba_concert",    "mba_jumbotron" },
  fashion     = { "mba_tribune", "mba_tarps",     "mba_backstage",  "mba_fashion",    "mba_jumbotron" },
  fameorshame = { "mba_tribune", "mba_tarps",     "mba_backstage",  "mba_fameorshame","mba_jumbotron" },
  wrestling   = { "mba_tribune", "mba_tarps",     "mba_fighting",   "mba_wrestling",  "mba_jumbotron" },
  mma         = { "mba_tribune", "mba_tarps",     "mba_fighting",   "mba_mma",        "mba_jumbotron" },
  boxing      = { "mba_tribune", "mba_tarps",     "mba_fighting",   "mba_boxing",     "mba_jumbotron" },
  all         = {
    "mba_tribune", "mba_cover",   "mba_tarps",       "mba_chairs",  "mba_basketball",
    "mba_derby",   "mba_paintball","mba_fighting",   "mba_wrestling","mba_mma",
    "mba_boxing",  "mba_backstage","mba_concert",    "mba_fashion", "mba_fameorshame",
    "mba_ring_of_fire","mba_jumbotron","mba_terrain",
  },
}

local function deactivateAllMbaEntitySets(interior)
  for _, name in ipairs(mbaEntitySets.all) do
    DeactivateInteriorEntitySet(interior, name)
  end
  RefreshInterior(interior)
end

-- Activate the entity sets for one of the named MBA configurations and refresh.
local function activateMbaEntitySets(interior, setName)
  for _, name in ipairs(mbaEntitySets[setName]) do
    ActivateInteriorEntitySet(interior, name)
  end
  RefreshInterior(interior)
end

RegisterNetEvent("Paintball:client:UpdateMBALocation", function(setName)
  local interior = GetInteriorAtCoords(-324.2203, -1968.493, 20.60336)
  if interior ~= 0 then
    deactivateAllMbaEntitySets(interior)
    Wait(500)
    activateMbaEntitySets(interior, setName)
  end
end)

-- ============================================================================
-- MATCH TIMER (NUI overlay countdown of remaining match minutes)
-- ============================================================================
local function startMatchTimer(matchMinutesArg)
  CreateThread(function()
    Wait(12000)  -- give the start sequence time before the timer kicks in

    local minutes = tonumber(matchMinutesArg) or 1
    local durationMs = minutes * 60 * 1000
    local endTime    = GetNetworkTime() + durationMs

    matchTimerActive = true
    while matchTimerActive and isInMatch do
      local remaining = endTime - GetNetworkTime()

      if remaining <= 0 then
        matchTimerActive = false
        SendNUIMessage({ action = "MatchTimerHide" })
      else
        local secondsLeft = math.floor(remaining / 1000)
        if secondsLeft < 0 then secondsLeft = 0 end
        SendNUIMessage({ action = "MatchTimerUpdate", seconds = secondsLeft })
      end

      Wait(1000)
    end

    SendNUIMessage({ action = "MatchTimerHide" })
  end)
end

-- ============================================================================
-- CLAN OUTFIT PACK
-- The server can hand the client a JSON-encoded outfit (per gender) that is
-- applied to the local ped at match start; if it can't be parsed we fall
-- through to the team's default outfit.
-- ============================================================================
local clanOutfitJson = nil

RegisterNetEvent("Pug:client:SetClanOutfitPack", function(jsonBlob)
  clanOutfitJson = jsonBlob
end)

-- Apply a parsed outfit table (with .hat/.torso/.mask/etc + matching .tXxx
local function applyClanOutfit(outfit)
  if not outfit or type(outfit) ~= "table" then return end
  local ped = PlayerPedId()

  -- HAT prop (use index >= 0; otherwise clear).
  if outfit.hat ~= nil then
    if outfit.hat >= 0 then
      SetPedPropIndex(ped, 0, outfit.hat, outfit.that or 0, true)
    else
      ClearPedProp(ped, 0)
    end
  end

  -- Each of the body components: drawable + matching texture (.tXxx).
  if outfit.torso      ~= nil then SetPedComponentVariation(ped, 3,  outfit.torso,      outfit.ttorso      or 0) end
  if outfit.mask       ~= nil then SetPedComponentVariation(ped, 1,  outfit.mask,       outfit.tmask       or 0) end
  if outfit.pants      ~= nil then SetPedComponentVariation(ped, 4,  outfit.pants,      outfit.tpants      or 0) end
  if outfit.jacket     ~= nil then SetPedComponentVariation(ped, 11, outfit.jacket,     outfit.tjacket     or 0) end
  if outfit.shoes      ~= nil then SetPedComponentVariation(ped, 6,  outfit.shoes,      outfit.tshoes      or 0) end
  if outfit.undershirt ~= nil then SetPedComponentVariation(ped, 8,  outfit.undershirt, outfit.tundershirt or 0) end
  if outfit.bag        ~= nil then SetPedComponentVariation(ped, 5,  outfit.bag,        outfit.tbag        or 0) end
end

-- Try to parse and apply the JSON outfit pack. Returns:
--   false           — no pack stored, parse failed, ped is wrong gender, etc.
--   true            — outfit applied successfully
local function tryApplyClanOutfit()
  if not clanOutfitJson or clanOutfitJson == "" then return false end

  local ok, parsed = pcall(json.decode, clanOutfitJson)
  if not ok or type(parsed) ~= "table" then return false end

  local ped       = PlayerPedId()
  local pedModel  = GetEntityModel(ped)
  local isMpMale   = (pedModel ==  1885233650)  -- mp_m_freemode_01
  local isMpFemale = (pedModel == -1667301416)  -- mp_f_freemode_01
  if not isMpMale and not isMpFemale then return false end

  local outfit = isMpMale and parsed.male or parsed.female
  if not outfit or type(outfit) ~= "table" then return false end

  applyClanOutfit(outfit)
  return true
end

-- ============================================================================
-- BEGIN PAINTBALL MATCH — the big one
-- Sent by the server once enough players are ready and a map/mode is locked.
-- Sets up clothing, spawns, weapons, screen fades, and the countdown loop.
--   mapName        : arena identifier (used as a key in Config.*Spawns)
--   oitcLives      : starting lives for One-In-The-Chamber
--   gameMode       : Config.GameModes.<key>.name string
--   teamPlayers    : array of server-IDs for the local team (size-checked
--                    against spawn count to avoid overlaps)
--   randomWeapons  : table assembled by server for Gun-Game weapon ladder
--   matchMinutes   : timer length in minutes (string)
--   redLives,
--   blueLives,
--   ffaLives       : per-bucket starting lives
-- ============================================================================
RegisterNetEvent("Pug:paintball:BeginPaintballMatch",
function(mapName, oitcLives, gameMode, teamPlayers, randomWeapons,
         matchMinutes, redLives, blueLives, ffaLives)

  -- jaksam_inventory has its own weapon-wheel toggle.
  if GetResourceState("jaksam_inventory") == "started" then
    exports.jaksam_inventory:setWeaponWheel(true)
  end
  -- ox_inventory: let us hand out weapons during the match instead of disarming
  -- anything it didn't equip itself (that caused the weapon to flicker).
  if GetResourceState("ox_inventory") == "started" then
    local ok, err = pcall(function() exports.ox_inventory:weaponWheel(true) end)
    if not ok then
      print("^1[pug-paintball] ox_inventory weaponWheel export failed, ox_inventory will keep disarming match weapons: " .. tostring(err) .. "^7")
    end
  end

  -- Debug: log every change of the weapon in hand so anything still swapping it shows up.
  if Config.Debug then
    CreateThread(function()
      Wait(1000)
      local last = GetSelectedPedWeapon(PlayerPedId())
      while isInMatch do
        local now = GetSelectedPedWeapon(PlayerPedId())
        if now ~= last then
          print(("[pug-paintball] weapon in hand changed %s -> %s (dead: %s)"):format(
            last, now, tostring(IsEntityDead(PlayerPedId()))))
          last = now
        end
        Wait(0)
      end
    end)
  end

  -- Snapshot baseline state we'll need to restore on match end.
  savedPlayerHealth  = GetEntityHealth(PlayerPedId())
  teamLivesConfig    = {
    red  = tonumber(redLives),
    blue = tonumber(blueLives),
    ffa  = tonumber(ffaLives),
  }

  PugCloseMenu()
  startMatchTimer(matchMinutes)

  currentGameModeName = gameMode
  originalCoords      = GetEntityCoords(PlayerPedId())
  RndomWeapons        = randomWeapons
  SaveClothes()
  currentMapName      = mapName

  LockInventory()
  isInMatch = true
  oitcLivesLeft = oitcLives

  TriggerEvent("Pug:Anticheat:FixRemovedGun")

  if CheckMatchingGameMode("Capture_The_Flag") then
    TriggerEvent("Pug:client:CaptureTheFlagLoop")
  end
  TriggerEvent("Pug:client:DisableKeys", true)

  -- ---- Pick a spawn point ------------------------------------------------
  local localPed   = PlayerPedId()
  local spawnCoord = nil
  local spawnHead  = nil

  if isFFAGameMode() then
    -- FFA: random spawn from FFASpawns[map]. Player count guard prevents the
    -- "more players than spawn slots" overlap problem.
    local spawnIdx
    if #teamPlayers > #Config.FFASpawns[currentMapName] then
      spawnIdx = placement                              -- assigned externally
    else
      spawnIdx = math.random(1, #Config.FFASpawns[currentMapName])
    end
    local spawn = Config.FFASpawns[currentMapName][spawnIdx]
    spawnCoord  = vector3(spawn.x, spawn.y, spawn.z - 1.0)
    spawnHead   = spawn.w or 0.0

  else
    -- TDM: random spawn from the team's spawn list.
    local teamSpawns
    if playerTeam == "redteam" then
      teamSpawns = Config.RedTeamSpawns
    else
      teamSpawns = Config.BlueTeamSpawns
    end

    local spawnIdx
    if #teamPlayers > #teamSpawns[currentMapName] then
      spawnIdx = nil  -- preserved verbatim — falls through to nil-index error
    else
      spawnIdx = math.random(1, #teamSpawns[currentMapName])
    end

    local spawn = teamSpawns[currentMapName][spawnIdx]
    spawnCoord  = vector3(spawn.x, spawn.y, spawn.z)
    spawnHead   = spawn.w or 0.0
  end

  HandleStartingSetup(spawnHead)
  SetEntityCoords (localPed, spawnCoord.x, spawnCoord.y, spawnCoord.z)
  SetEntityHeading(localPed, spawnHead)

  -- ---- Outfit (clan pack, otherwise team default) -----------------------
  if not isFFAGameMode() and not tryApplyClanOutfit() then
    if playerTeam == "redteam" then
      OutFitRed()
    else
      OutFitBlue()
    end
  end

  -- ---- MBA interior tweak (gabz/derby maps) -----------------------------
  if currentMapName == "gabz" or currentMapName == "derby" then
    if currentMapName == "gabz" then
      TriggerEvent("Paintball:client:UpdateMBALocation", "paintball")
    else
      TriggerEvent("Paintball:client:UpdateMBALocation", "derby")
    end
  end

  Wait(900)

  -- ---- Zone marker (some arenas have a damaging out-of-zone marker) -----
  for _, arena in pairs(Config.Arenas) do
    if arena.map == currentMapName and arena.ZoneCenter then
      TriggerEvent("Pug:client:RunZoneLoop", arena.ZoneCenter, arena.Radius)
      break
    end
  end

  FreezeEntityPosition(PlayerPedId(), false)
  DoScreenFadeIn(4000)
  Wait(900)

  -- ---- Mode-specific weapon priming -------------------------------------
  if CheckMatchingGameMode("Gun_Game") then
    ChosenWeapon = 1
    GiveThePlayerTheWeapon()
  elseif CheckMatchingGameMode("One_In_The_Chamber") then
    ChosenWeapon = Config.OneInTheChamberWeapon
  end

  setupCountdownCamForFurthestSpawn()
  FreezeEntityPosition(PlayerPedId(), true)

  -- ---- Countdown loop ---------------------------------------------------
  while respawnCountdown ~= 0 do
    if respawnCountdown == 10 then
      PaintBallNotify(Config.Translations.success.start_in, "error", 2500)
      PlaySound(-1, "slow", "SHORT_PLAYER_SWITCH_SOUND_SET", 0, 0, 1)
    elseif respawnCountdown <= 5 then
      PaintBallNotify(tostring(respawnCountdown), "error", 500)
      PlaySound(-1, "slow", "SHORT_PLAYER_SWITCH_SOUND_SET", 0, 0, 1)
    end

    respawnCountdown = respawnCountdown - 1

    if respawnCountdown == 4 then
      destroyCountdownCam()
    end

    GiveThePlayerTheWeapon(CheckMatchingGameMode("One_In_The_Chamber"))
    Wait(1000)
  end

  -- ---- Post-countdown: finalise HUD, parachute, voice, audio ------------
  if Config.Menu == "ox_lib" then
    SetupOxLibRadial()
  end

  -- Hide reticule HUD components depending on the cross-hair config.
  if Config.SmallResource then
    local hudIds = { 19, 20, 21, 22 }
    if Config.EnableGTA5Crosshair then
      hudIds = { 14, 19, 20, 21, 22 }
    end
    exports[Config.SmallResource]:removeDisableHudComponents(hudIds)
  end

  ClearPedTasks(PlayerPedId())
  TaskReloadWeapon(PlayerPedId(), false)
  Wait(500)
  FreezeEntityPosition(PlayerPedId(), false)

  -- Parachute model + tint (used as a fall-back air drop tool in some modes).
  SetPlayerParachuteModelOverride(PlayerId(), 1336576410)  -- ba_prop_battle_parachute
  SetPedParachuteTintIndex(PlayerPedId(), 6)
  GiveWeaponToPed(PlayerPedId(), -72657034, 1, 0, 0)        -- gadget_parachute, don't force in hand
  GiveThePlayerTheWeapon()                                   -- equip combat weapon immediately

  if CheckMatchingGameMode("One_In_The_Chamber") then
    TriggerEvent("Pug:client:HandleOneInTheChamberLogic")
  end

  -- pma-voice: temporarily move the player onto a team radio channel.
  if GetResourceState("pma-voice") == "started" and Config.SetPlayersRadios then
    savedRadioChannel = LocalPlayer.state.radioChannel
    exports["pma-voice"]:setVoiceProperty("radioEnabled", true)

    if not getLivesForLocalPlayer() then
      local channel = (playerTeam == "redteam") and 945 or 900
      exports["pma-voice"]:setRadioChannel(channel)
    end
  end

  SetPedArmour(PlayerPedId(), Config.ArmorAmountGivenToPlayer)
  PugSoundPlay("letsdothis", 0.05)

  TriggerEvent("Pug:paintball:RunClientBlips")
  TriggerEvent("Pug:paintball:PutWeaponHandCheck")

  if CheckMatchingGameMode("Kill_Confirmed") then
    TriggerEvent("Pug:client:BeginKillConfirmedLoop")
  end
end)

-- ============================================================================
-- TEAM JOIN / GAME-START PUSH
-- ============================================================================

-- placement-slot index for spawn distribution.
RegisterNetEvent("Pug:paintball:joinedTeam", function(team, placementIdx)
  if Config.UseVrHeadSet and GetResourceState("pug-battleroyale") == "started" then
    TriggerEvent("Pug-VrHeadSet:toggle")
  end
  playerTeam = team
  placement  = placementIdx
end)

RegisterNetEvent("Pug:paintball:startGame", function()
  if playerTeam == nil then
    PaintBallNotify(Config.Translations.error.choose_team_first, "error")
  else
    TriggerServerEvent("Pug:paintball:startGame")
  end
end)

-- ============================================================================
-- PLAYER BLIPS (server hands us the team server-IDs; we maintain blips for
-- their peds while in-match)
-- ============================================================================
local playerBlipServerIds = {}
local playerBlips         = {}

RegisterNetEvent("Pug:paintball:GetBlipDtata", function(serverIds)
  playerBlipServerIds = {}
  for _, sid in pairs(serverIds or {}) do
    playerBlipServerIds[#playerBlipServerIds + 1] = sid
  end
end)

-- ============================================================================
-- WEAPON-IN-HAND WATCHDOG
-- If the player ends up unarmed mid-match (e.g. anim glitch), give the weapon
-- back. Skips the check while parachuting / dead / falling.
-- ============================================================================
RegisterNetEvent("Pug:paintball:PutWeaponHandCheck", function()
  -- Off by default: it never ran in the original release (it crashed on IsPedHandsUp)
  -- and it fights inventory scripts, making the weapon flicker.
  if not Config.WeaponHandWatchdog then return end
  local unarmedSince = nil
  while isInMatch do
    Wait(0)
    if not isInMatch then break end

    local ped = PlayerPedId()

    -- Block hands-up entirely during a match: cancel the task the moment it
    -- is detected so the animation never completes and the weapon stays in hand.
    if IsEntityPlayingAnim(ped, "missminuteman_1ig_2", "handsup_base", 3) then
      ClearPedTasksImmediately(ped)
      GiveThePlayerTheWeapon()
      Wait(100)

    -- Unarmed fallback: catches any other path that strips the weapon
    -- (parachute glitch, death animation, etc.).
    -- Only after being unarmed for over a second, and at most every 2 seconds, so it
    -- never fights a weapon swap or the inventory script.
    elseif GetSelectedPedWeapon(ped) == GetHashKey("weapon_unarmed") then
      unarmedSince = unarmedSince or GetGameTimer()
      if GetGameTimer() - unarmedSince > 1000
         and DoesEntityExist(ped) and not IsEntityDead(ped)
         and not IsPedInParachuteFreeFall(ped)
         and not IsPedFalling(ped)
         and (GetPedParachuteState(ped) == -1 or GetPedParachuteState(ped) == 0)
         and not IsPlayerDead then

        GiveThePlayerTheWeapon()
        if CheckMatchingGameMode("One_In_The_Chamber") then
          SetEntityHealth(PlayerPedId(), 107)
        end
        unarmedSince = nil
        Wait(2000)
      else
        Wait(200)
      end

    else
      unarmedSince = nil
      Wait(100)
    end
  end
end)

-- ============================================================================
-- TEAMMATE BLIP MAINTENANCE
-- ============================================================================
RegisterNetEvent("Pug:paintball:RunClientBlips", function()
  Wait(1000)
  while isInMatch do
    if isInMatch then
      for blipIndex, serverId in pairs(playerBlipServerIds) do
        if GetPlayerServerId(PlayerId()) ~= serverId then
          local exists = DoesEntityExist(GetPlayerPed(GetPlayerFromServerId(serverId)))

          if exists then
            if not DoesBlipExist(playerBlips[blipIndex]) then
              playerBlips[blipIndex] = AddBlipForEntity(GetPlayerPed(GetPlayerFromServerId(serverId)))
              if playerTeam == "blueteam" then
                SetBlipAsFriendly(playerBlips[blipIndex], true)
              end
            end
          else
            -- Player's ped no longer exists — remove the stale blip.
            if DoesBlipExist(playerBlips[blipIndex]) then
              RemoveBlip(playerBlips[blipIndex])
            end
          end
        end
      end
    else
      playerBlipServerIds = {}
      break
    end
    Wait(2000)
  end
end)

-- Wipe every player blip we own.
RegisterNetEvent("Pug:client:PaintballRemoveAllBlips", function()
  for blipIndex in pairs(playerBlips) do
    if DoesBlipExist(playerBlips[blipIndex]) then
      RemoveBlip(playerBlips[blipIndex])
      playerBlips[blipIndex] = nil
    end
  end
end)

-- ============================================================================
-- LEAVE-ARENA CLEANUP
-- Called when the player loses their last life, surrenders, or the match ends.
-- ============================================================================
local removeFromArenaCooldown = false

RegisterNetEvent("Pug:paintball:removeFromArena", function()
  if Config.Debug then print("Removed From Arena") end

  if GetResourceState("jaksam_inventory") == "started" then
    exports.jaksam_inventory:setWeaponWheel(false)
  end
  if GetResourceState("ox_inventory") == "started" then
    pcall(function() exports.ox_inventory:weaponWheel(false) end)
  end

  if isInMatch then
    PaintballDeathGraceUntil = GetGameTimer() + 15000
    isInMatch = false
    GiveThePlayerTheWeapon(false, false, true)  -- strip weapon
    Wait(4000)

    if Config.DoScreenFadeOut then DoScreenFadeOut(500) end
    Wait(500)
    SetEntityCoords(PlayerPedId(), originalCoords)

    -- Re-snap to the original coords after another second in case any other
    -- script teleported the player away.
    CreateThread(function()
      Wait(1000)
      local pos = GetEntityCoords(PlayerPedId())
      if #(pos - originalCoords) > 20.0 then
        SetEntityCoords(PlayerPedId(), originalCoords)
      end
    end)

    -- Compatibility fix for ars_ambulancejob — give it time to finish reviving
    -- before we trigger our own revive event.
    CreateThread(function()
      if GetResourceState("ars_ambulancejob") == "started" then
        Wait(2000)
      end
      TriggerEvent("Pug:client:PaintballReviveEvent")
    end)

    UnlockInventory()

    -- Reset ChosenWeapon to the first item in Config.WeaponItems.
    for _, weaponItem in pairs(Config.WeaponItems) do
      ChosenWeapon = weaponItem.name
      break
    end

    RestoreClothes()
    Wait(50)

    -- One-shot: only run the radio/inventory cleanup once even if the event
    -- fires multiple times in quick succession.
    if not removeFromArenaCooldown then
      removeFromArenaCooldown = true

      if GetResourceState("pma-voice") == "started" and Config.SetPlayersRadios then
        exports["pma-voice"]:setRadioChannel(savedRadioChannel)
        savedRadioChannel = 0
      end

      TriggerEvent("Pug:client:RemovePlayerFromGameOpen")
      if Config.RemoveAllItemsForPlayer then GivePaintballItems() end
      TriggerEvent("Pug:client:WaitCoolDownFix")
      Wait(2000)
    end

    redFlagSpawnCoords  = nil
    blueFlagSpawnCoords = nil

    TriggerEvent("Pug:client:GetRidOfPaintballMap")
    TriggerServerEvent("Pug:server:PaintballSetBucket")

    if Config.Menu == "ox_lib" then
      lib.removeRadialItem("paintballsurrender")
    end

    -- Re-add disabled HUD components (cross-hair etc.)
    if Config.SmallResource then
      local primary
      if Config.UsingCrossHairByDefault then
        primary = 19
      elseif Config.EnableGTA5Crosshair then
        primary = 14
      else
        primary = 19
      end
      local hudIds = { primary, 19, 20, 21, 22 }
      exports[Config.SmallResource]:addDisableHudComponents(hudIds)
    end

    SetEntityAlpha(PlayerPedId(), 255)

    if savedPlayerHealth then
      SetEntityHealth(PlayerPedId(), savedPlayerHealth)
      savedPlayerHealth = nil
    end
  end

  Wait(500)

  -- VR head-set cleanup (if BattleRoyale is also installed).
  if Config.UseVrHeadSet and GetResourceState("pug-battleroyale") == "started" then
    for _, ped in pairs(GetGamePool("CPed")) do
      if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped)) <= 5.0 then
        TriggerEvent("FullyDeletePaintballEntity", ped)
      end
    end
    clonePed = nil
  end

  if DoesBlipExist(BlueFlagBlip) then RemoveBlip(BlueFlagBlip); BlueFlagBlip = nil end
  if DoesBlipExist(RedFlagBlip)  then RemoveBlip(RedFlagBlip);  RedFlagBlip  = nil end

  teamLivesConfig    = nil
  if clonePed and DoesEntityExist(clonePed) then DeleteEntity(clonePed) end
  clonePed           = nil
  isInMatch          = false
  matchTimerActive   = false
  SendNUIMessage({ action = "MatchTimerHide" })

  playerTeam        = nil
  respawnCountdown  = 10
  oitcLivesLeft     = 0
  redTeamScore      = 0
  blueTeamScore     = 0
  IsPlayerDead      = false
  killStreak        = 0

  TriggerEvent("Pug:client:KC:ClearAll")
  Wait(1000)
  DoScreenFadeIn(500)
  Wait(200)

  if Config.UseVrHeadSet and GetResourceState("pug-battleroyale") == "started" then
    TriggerEvent("Pug-VrHeadSet:toggle")
  end

  TriggerEvent("Pug:client:PaintballRemoveAllBlips")
end)

-- ============================================================================
-- INTERIOR PROP CLEANUP — disable the various MBA "scenes" we may have left
-- enabled, then refresh.
-- ============================================================================
RegisterNetEvent("Pug:client:GetRidOfPaintballMap", function()
  Wait(7000)
  local interior = GetInteriorAtCoords(2800.0, -3800.0, 100.0)
  for _, propName in ipairs({
    "Set_Dystopian_Scene", "Set_Dystopian_02", "Set_Dystopian_03",
    "Set_Dystopian_04",   "Set_Dystopian_07", "Set_Dystopian_09",
    "Set_Dystopian_10",   "Set_Scifi_Scene",  "Set_Scifi_09",
    "Set_Wasteland_Scene","Set_Wasteland_01", "Set_Wasteland_03",
    "Set_Wasteland_07",   "Set_Wasteland_09",
  }) do
    DisableInteriorProp(interior, propName)
  end
  -- Also disable + refresh the *currently active* set.
  DisableInteriorProp(interior, activeArenaEntitySet)
  RefreshInterior(interior, activeArenaEntitySet)
end)

-- Toggle a debounce flag used by `removeFromArena` so that our cleanup
-- routine doesn't double-run.
RegisterNetEvent("Pug:client:WaitCoolDownFix", function()
  Wait(3500)
  removeFromArenaCooldown = false
end)

-- ============================================================================
-- SPECTATE FLOW
-- A player who's been removed (or the lobby host) can spectate live matches.
-- The flow uses a server callback to fetch lobby coords/map, fades the screen,
-- teleports the local ped above the target, then runs a tracking loop.
-- ============================================================================
isSpectating = false  -- exported global

RegisterNetEvent("Pug:client:StartSpectate", function(arg)
  -- The arg can be (a) a server-id number, (b) a table with `id` / `person`
  -- and an optional `lobbyId`, or (c) an array whose first slot is the id.
  local targetServerId = nil
  local lobbyId        = nil

  if type(arg) == "table" then
    targetServerId = arg.id or arg.person or arg[1]
    lobbyId        = arg.lobbyId
  else
    targetServerId = arg
  end

  if not targetServerId then return end

  -- Server callback payload differs depending on whether we're targeting a
  -- specific lobby or just a player.
  local cbPayload
  if lobbyId then
    cbPayload = { spectate = targetServerId, lobbyId = lobbyId }
  else
    cbPayload = targetServerId
  end

  Config.FrameworkFunctions.TriggerCallback("Pug:SVCB:GetLobbyDetails",
  function(lobby)
    if not lobby then
      PaintBallNotify(Config.Translations.error.lobby_no_longer_exists, "error")
      TriggerEvent("Pug:client:OpenPaintballHUB",
        { args = { entity = PB_LAST_ENTITY } })
      return
    end

    -- Snapshot original coords if we don't have them yet (so we can restore
    -- when ExitSpectate fires).
    if not originalCoords then
      originalCoords = GetEntityCoords(PlayerPedId())
    end
    if Config.Debug then print(originalCoords, "orginial coords") end

    -- The lobby map name might be a label; look up the canonical map id.
    currentMapName = tostring(lobby.map)
    for _, arena in pairs(Config.Arenas) do
      if arena.name == currentMapName then
        currentMapName = arena.map
      end
    end
    if Config.Debug then print(currentMapName, "spectate arena") end

    -- Move ourselves into the spectate bucket.
    if lobbyId then
      TriggerServerEvent("Pug:server:PaintballSetBucket", true, lobbyId)
    else
      TriggerServerEvent("Pug:server:PaintballSetBucket", true)
    end

    inMatch()  -- the interior-disable / arena-prep helper, see below
    DoScreenFadeOut(1000)
    Wait(1000)
    SetEntityCoords(PlayerPedId(),
      lobby.location.x, lobby.location.y, lobby.location.z - 7.0)
    Wait(1000)
    DoScreenFadeIn(1000)

    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetServerId))
    local startCoords = GetEntityCoords(PlayerPedId())

    -- ---- Spectate tracking loop ----------------------------------------
    local function spectateLoop()
      DrawTextOptiopnForSpectate()
      isSpectating = true
      local localPed = PlayerPedId()
      SetEntityVisible    (localPed, false)
      SetEntityInvincible (localPed, true)
      NetworkSetInSpectatorMode(true, targetPed)

      while isSpectating do
        -- Press SPACE (control 38) to switch to a different player.
        if IsControlJustPressed(0, 38) then
          if lobbyId then
            TriggerEvent("Pug:client:SpectatePlayers", { lobbyId = lobbyId })
          else
            TriggerEvent("Pug:client:SpectatePlayers")
          end
        end

        -- Keep ourselves under the target so the GTA cam tracks them.
        local targetCoords = GetEntityCoords(targetPed)
        SetEntityCoordsNoOffset(localPed,
          targetCoords.x, targetCoords.y, targetCoords.z - 70.0,
          false, false, false)

        -- If we drift more than 450u from where we started, exit spectate.
        if #(startCoords - targetCoords) > 450.0 then
          TriggerEvent("Pug:client:ExitSpectate")
          break
        end
        Wait(0)
      end
    end

    spectateLoop()
  end, cbPayload)
end)

RegisterNetEvent("Pug:client:ExitSpectate", function()
  TriggerServerEvent("Pug:server:PaintballSetBucket")
  HideTextOptiopnForSpectate()

  if originalCoords then
    SetEntityCoords(PlayerPedId(), originalCoords)
    originalCoords = nil
  end
  isSpectating = false
  NetworkSetInSpectatorMode(false, target)
  SetEntityVisible   (PlayerPedId(), true)
  SetEntityInvincible(PlayerPedId(), false)
end)

-- ============================================================================
-- /surrender COMMAND
-- ============================================================================
RegisterCommand(Config.SurrenderCommand, function()
  if isInMatch then
    if not DeathCooldown and not IsPlayerDead then
      TriggerServerEvent("Pug:paintball:RemovePlayer", playerTeam)
      TriggerEvent("Pug:client:InPaintBallMatchWLFalse")
    else
      PaintBallNotify(Config.Translations.error.cant_do_this, "error")
    end
  end
end)

-- Ends the cooldown that prevents combat keys from being registered for the
-- few seconds after a respawn.
RegisterNetEvent("Pug:client:DisableControlCooldown", function(longerCooldown)
  if longerCooldown then Wait(13000) else Wait(10000) end
  keysDisabled = false
end)

-- ============================================================================
-- DEATH-CAM SETTINGS
-- Vertical / horizontal sensitivity used while orbiting the death-cam.
-- (`L45_1+L46_1)*0.5` etc. is preserved verbatim from the original.)
-- ============================================================================
local DEATH_CAM_PITCH_MAX_SUM_HALF = (150.0 + 5.0) * 0.5
local DEATH_CAM_PITCH_BASE         = 5.0
local DEATH_CAM_PITCH_RANGE        = 150.0
local DEATH_CAM_SENS_VERT          = 3.0
local DEATH_CAM_SENS_HORZ          = 3.0

local function applyDeathCamLook(camHandle, dt)
  local horz = GetDisabledControlNormal(0, 220)
  local vert = GetDisabledControlNormal(0, 221)
  local rot  = GetCamRot(camHandle, 2)

  if horz ~= 0.0 or vert ~= 0.0 then
    new_z = rot.z + (horz * -1.0) * DEATH_CAM_SENS_HORZ * (dt + 0.1)
    new_x = math.max(
              math.min(20.0, rot.x + (vert * -1.0) * DEATH_CAM_SENS_VERT * (dt + 0.1)),
              -89.5)
    SetCamRot(camHandle, new_x, 0.0, new_z, 2)
  end
end

-- ============================================================================
-- ARENA INTERIOR CHECK
-- True when the active map is an MBA scene (used to apply scene-specific
-- ============================================================================
local function isMBASceneArena()
  local matches = {
    Set_Dystopian_02 = true, Set_Dystopian_03 = true, Set_Dystopian_04 = true,
    Set_Dystopian_07 = true, Set_Dystopian_09 = true, Set_Dystopian_10 = true,
    Set_Scifi_09     = true, Set_Wasteland_01 = true, Set_Wasteland_03 = true,
    Set_Wasteland_07 = true, Set_Wasteland_09 = true,
  }
  return matches[currentMapName] == true
end

-- ============================================================================
-- ONE-IN-THE-CHAMBER RELOAD GUARD
-- If the player fires their last bullet, give them a 7s "ammo given" notify
-- and then top them up.
-- ============================================================================
RegisterNetEvent("Pug:client:HandleOneInTheChamberLogic", function()
  while isInMatch do
    Wait(0)
    if not isInMatch then break end

    if IsPedShooting(PlayerPedId()) then
      local weaponHash = GetSelectedPedWeapon(GetPlayerPed(PlayerId()))
      local _, ammoInClip = GetAmmoInClip(GetPlayerPed(PlayerId()), weaponHash)

      if ammoInClip <= 0 then
        PaintBallNotify(Config.Translations.error.ammo_given, "error")
        Wait(7000)
        if not IsPlayerDead then
          GiveThePlayerTheWeapon(true)  -- top up with 1 round
        end
      end
    end
  end
end)

-- ============================================================================
-- inMatch() — interior preparation called on entering an arena
-- Disables the existing scene props (so the new scene doesn't render through)
-- and enables the matching MBA "Set_*" props for our map. Optional unlimited
-- ============================================================================
function inMatch()
  CreateThread(function()
    -- (currently unused but original keeps it as gating logic)
    local hasOxInventory = (GetResourceState("ox_inventory") == "started") or nil

    local needsSceneProps = false
    for _, arena in pairs(Config.Arenas) do
      if arena.map == currentMapName and isMBASceneArena() then
        needsSceneProps = true
      end
    end

    if needsSceneProps then
      RequestIpl("xs_arena_interior")
      local interior = GetInteriorAtCoords(2800.0, -3800.0, 100.0)

      -- Off: every Set_* we might have had previously.
      for _, name in ipairs({
        "Set_Dystopian_Scene","Set_Dystopian_02","Set_Dystopian_03","Set_Dystopian_04",
        "Set_Dystopian_07","Set_Dystopian_09","Set_Dystopian_10","Set_Scifi_Scene",
        "Set_Scifi_09","Set_Wasteland_Scene","Set_Wasteland_01","Set_Wasteland_03",
        "Set_Wasteland_07","Set_Wasteland_09",
      }) do
        DisableInteriorProp(interior, name)
      end
      DisableInteriorProp(interior, activeArenaEntitySet)

      -- On: crowd + the matching scene + the new map.
      for _, name in ipairs({
        "Set_Crowd_A","Set_Crowd_B","Set_Crowd_C","Set_Crowd_D","Set_Dystopian_Scene",
      }) do
        EnableInteriorProp(interior, name)
      end
      EnableInteriorProp(interior, currentMapName)
      activeArenaEntitySet = currentMapName
    end

    -- Optional unlimited-sprint loop.
    if Config.SetUnlimitedSprint then
      while isInMatch do
        Wait(1000)
        if Config.SetUnlimitedSprint then
          RestorePlayerStamina(PlayerId(), 1.0)
        end
      end
    end
  end)
end

-- ============================================================================
-- DEATH HANDLER (gameEventTriggered → CEventNetworkEntityDamage)
-- The big death pipeline: blip the killer, post the kill update, run the
-- death cam, respawn the player at a team spawn, and trigger revive.
-- ============================================================================
local deathHandlerLock = false

AddEventHandler("gameEventTriggered", function(event, payload)
  if event ~= "CEventNetworkEntityDamage" then return end

  local victimPed     = payload[2]
  local fatalFlag     = (payload[4] == 1)
  local damagerPed    = payload[1]
  local rawIsDeath    = payload[4]
  if not IsPedAPlayer(damagerPed) then return end

  local localPlayerId = PlayerId()

  -- True if the local player was the victim and they're either fatally hit
  -- or already dead/dying.
  local localIsVictim
  if rawIsDeath then
    local victimPlayerIdx = NetworkGetPlayerIndexFromPed(damagerPed)
    if not IsPedDeadOrDying(damagerPed, true) then
      localIsVictim = (IsPedFatallyInjured(damagerPed) == localPlayerId)
                       and IsPedFatallyInjured(damagerPed)
    end
  end

  if (fatalFlag and isInMatch) or (localIsVictim and isInMatch) then

    -- Re-entrancy lock: don't run the pipeline twice for the same death.
    if not deathHandlerLock then
      deathHandlerLock = true
      CreateThread(function()
        Wait(5000)
        deathHandlerLock = false
      end)
    else
      return
    end

    local deathCoords = GetEntityCoords(damagerPed)
    local deathPedNet = PedToNet(damagerPed)

    -- Some configs let dead players still shoot in their final frames; if so,
    -- enable the relevant controls.
    if ForceAllowShoot then
      EnableControlAction(0, 23, true)
      EnableControlAction(0, 36, true)
    end

    print("fatally injured or dead")
    killStreak  = 0
    IsPlayerDead = true

    local killerPed         = GetPedSourceOfDeath(PlayerPedId())
    local causeOfDeathHash  = GetPedCauseOfDeath  (PlayerPedId())
    local killerClientId    = NetworkGetPlayerIndexFromPed(killerPed)

    if Config.Debug then
      print(killerPed,      "killerEntity")
      print(killerClientId, "killerClientId")
    end

    -- Was the kill a head-shot? Bone IDs 31086/39317/31085 = head/skull/neck.
    local wasHeadshot = false
    local _, lastBone = GetPedLastDamageBone(PlayerPedId())
    if lastBone == 31086 or lastBone == 39317 or lastBone == 31085 then
      wasHeadshot = true
    end
    ClearPedLastDamageBone(PlayerPedId())

    -- Resolve weapon hash → friendly weapon name (config key) where possible.
    local weaponName = causeOfDeathHash
    if weaponName ~= 0 then
      for key, item in pairs(Config.WeaponItems) do
        if GetHashKey(key) == weaponName then
          weaponName = item.name
        end
      end
    end

    TriggerServerEvent("Pug:server:PaintBallKillUpdate",
      GetPlayerServerId(killerClientId), weaponName, wasHeadshot)
    if Config.Debug then print(weaponName, "deathcause") end

    -- Capture-The-Flag: if we died holding the enemy flag, drop it where we
    -- fell so it can be picked back up by the other team.
    if CheckMatchingGameMode("Capture_The_Flag") then
      if playerTeam == "redteam"
         and IsEntityAttachedToEntity(PlayerPedId(), enemyFlagEntity) then
        TriggerServerEvent("Pug:server:RespawnFlag", "blue",
          GetEntityCoords(PlayerPedId()), true)
      elseif playerTeam == "blueteam"
         and IsEntityAttachedToEntity(PlayerPedId(), enemyFlagEntity) then
        TriggerServerEvent("Pug:server:RespawnFlag", "red",
          GetEntityCoords(PlayerPedId()), true)
      end
    end

    -- Wait for the player to come to rest (stop sliding, stop ragdolling) up
    -- to a 7-second timeout, then forcibly clear ragdoll state.
    local timeoutMs = 7000
    while true do
      local stoppedMoving = not (GetEntitySpeed(PlayerPedId()) > 0.5)
                            and not IsPedRagdoll(PlayerPedId())
      if stoppedMoving then break end
      Wait(100)
      timeoutMs = timeoutMs - 100
      if timeoutMs <= 0 then
        SetPedCanRagdoll(PlayerPedId(), false)
        ClearPedTasksImmediately(PlayerPedId())
        Wait(2000)
        SetPedCanRagdoll(PlayerPedId(), true)
        break
      end
    end
    Wait(200)

    -- ---- Mode-specific death follow-up ----------------------------------
    if currentGameModeName then
      -- CTF gets a longer cooldown camera + countdown.
      if CheckMatchingGameMode("Capture_The_Flag") then
        DeathCooldown = true
        respawnCountdown = Config.CaptureTheFlagDeathTime
        TriggerEvent("Pug:client:FlagDeathCoolDown")
        PugSoundPlay("countdown", 0.01)

        -- Death-cam loop: orbit + countdown text until DeathCooldown ends.
        while DeathCooldown do
          local sensDt = (1.0 / (DEATH_CAM_PITCH_RANGE - DEATH_CAM_PITCH_BASE))
                         * (DEATH_CAM_PITCH_MAX_SUM_HALF - DEATH_CAM_PITCH_BASE)
          applyDeathCamLook(countdownCam, sensDt)
          drawTextEx(
            Config.Translations.menu.respawn_in .. respawnCountdown,
            4,
            { 255, 255, 255 },
            0.4,
            0.5,
            0.9380000000000001
          )
          Wait(5)
        end

        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(countdownCam, false)
        countdownCam = nil

        -- Move them to a team spawn point (CTF only).
        if keysDisabled then
          local spawnList = (playerTeam == "redteam")
                              and Config.RedTeamSpawns or Config.BlueTeamSpawns
          local idx = math.random(1, #spawnList[currentMapName])
          local s   = spawnList[currentMapName][idx]
          SetEntityCoords (PlayerPedId(), s)
          SetEntityHeading(PlayerPedId(), s.w)

          FreezeEntityPosition(PlayerPedId(), false)
          SetEntityVisible    (PlayerPedId(), true)
        end
      end

      -- ---- Standard respawn for every other mode ----------------------
      if Config.DoScreenFadeOut then DoScreenFadeOut(500) end
      Wait(500)

      if CheckMatchingGameMode("Capture_The_Flag") then
        FreezeEntityPosition(PlayerPedId(), false)
        SetEntityVisible    (PlayerPedId(), true)
      end

      -- Optional weapon-select prompt mid-game (host-only, when configured).
      if Config.CanChooseGunMidGame
         and not CheckMatchingGameMode("Gun_Game")
         and not CheckMatchingGameMode("One_In_The_Chamber") then
        if Config.HostOnlyCanControllWeaponSelect then
          if LobbyHost
             and LobbyHost == GetPlayerServerId(PlayerId()) then
            PaintBallNotify(Config.Translations.success.e_open_menu, "success", 2500)
          end
        else
          PaintBallNotify(Config.Translations.success.e_open_menu, "success", 2500)
        end
      end

      SetPlayerParachuteModelOverride(PlayerId(), 1336576410)
      SetPedParachuteTintIndex(PlayerPedId(), 6)
      GiveWeaponToPed(PlayerPedId(), -72657034, 1, 0, 1)  -- gadget_parachute

      if CheckMatchingGameMode("One_In_The_Chamber") then
        TriggerServerEvent("Pug:SV:NotifyLivesLeft", oitcLivesLeft)
      end

      -- ---- Pick a respawn spawn -----------------------------------------
      local spawn
      if isFFAGameMode() then
        local list = Config.FFASpawns[currentMapName]
        local s = list[math.random(1, #list)]
        spawn = vector4(s.x, s.y, s.z - 1, s.w)
      else
        local list = (playerTeam == "redteam") and Config.RedTeamSpawns[currentMapName]
                                                 or Config.BlueTeamSpawns[currentMapName]
        spawn = list[math.random(1, #list)]
      end
      local respawnHeading = spawn.w

      -- A dead or dying ped can't be teleported (it stays where it fell). Resurrect it
      -- where it lies (collision is loaded there), then move the living ped to the spawn,
      -- frozen until the spawn's floor has loaded. Retry until we really are there.
      local spawnPos = vector3(spawn.x, spawn.y, spawn.z)
      local ped
      for attempt = 1, 10 do
        ped = PlayerPedId()
        if IsEntityDead(ped) or IsPedFatallyInjured(ped) or IsPedDeadOrDying(ped, true) then
          local deathPos = GetEntityCoords(ped)
          NetworkResurrectLocalPlayer(deathPos.x, deathPos.y, deathPos.z, respawnHeading, true, false)
          ped = PlayerPedId()
          ClearPedTasksImmediately(ped)
          SetEntityHealth(ped, GetEntityMaxHealth(ped))
        end
        FreezeEntityPosition(ped, true)
        SetEntityCoords (ped, spawn.x, spawn.y, spawn.z)
        SetEntityHeading(ped, respawnHeading)
        local collisionDeadline = GetGameTimer() + 5000
        while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < collisionDeadline do
          RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)
          Wait(0)
        end
        Wait(100)
        if #(GetEntityCoords(ped) - spawnPos) < 5.0 then break end
        if Config.Debug then print(("[pug-paintball] respawn teleport attempt %d didn't stick, retrying"):format(attempt)) end
      end
      FreezeEntityPosition(ped, false)
      if Config.Debug then
        local p = GetEntityCoords(ped)
        print(("[pug-paintball] respawn: spawn %.1f %.1f %.1f, now at %.1f %.1f %.1f (dead: %s)"):format(
          spawn.x, spawn.y, spawn.z, p.x, p.y, p.z, tostring(IsEntityDead(ped))))
      end

      -- ak47_ambulancejob takes longer to revive than wasabi.
      if GetResourceState("ak47_ambulancejob") == "started" then Wait(1000)
      else Wait(100) end

      -- Force-clear ragdoll one more time if needed.
      if IsPedRagdoll(PlayerPedId()) then
        SetPedCanRagdoll(PlayerPedId(), false)
        ClearPedTasksImmediately(PlayerPedId())
        Wait(2000)
        SetPedCanRagdoll(PlayerPedId(), true)
      end

      TriggerEvent("Pug:client:PaintballReviveEvent", respawnHeading)

      -- Brief invulnerability ("passive mode") right after respawn.
      if Config.PassiveModeCoolDownWaitTime ~= 0 then
        SetEntityInvincible(PlayerPedId(), true)
        SetEntityAlpha     (PlayerPedId(), 150)
      end

      DoScreenFadeIn(1000)
      Wait(1500)
      SetPedArmour(PlayerPedId(), Config.ArmorAmountGivenToPlayer)
      GiveThePlayerTheWeapon()

      if CheckMatchingGameMode("One_In_The_Chamber") then
        SetEntityHealth(PlayerPedId(), 107)
      end

      -- Restore pma-voice radio to the team channel.
      if GetResourceState("pma-voice") == "started" and Config.SetPlayersRadios then
        exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
        local channel = nil
        if not getLivesForLocalPlayer() then
          channel = (playerTeam == "redteam") and 945 or 900
        end
        exports["pma-voice"]:setRadioChannel(channel)
      end

      Wait(500)
      if Config.PassiveModeCoolDownWaitTime ~= 0 then
        TriggerEvent("Pug:client:RemovePassiveModePB")
      end
    end

    TriggerEvent("Pug:client:PlayerIsDeadFinish")
  end
end)

-- ============================================================================
-- COMPATIBILITY: weapon-in-hand fix for popular ambulance scripts that strip
-- the weapon on revive.
-- ============================================================================
RegisterNetEvent("Pug:client:FixWeaponInHandIssue", function()
  Wait(2500)
  if GetResourceState("wasabi_ambulance")  == "started"
  or GetResourceState("ak47_ambulancejob") == "started" then
    GiveThePlayerTheWeapon()
    if CheckMatchingGameMode("One_In_The_Chamber") then
      SetEntityHealth(PlayerPedId(), 110)
    end
  end
end)

-- ============================================================================
-- PASSIVE-MODE COOLDOWN
-- After respawn we're invincible+translucent for `PassiveModeCoolDownWaitTime`
-- seconds (or until the player shoots). This loop also lets the host re-open
-- the gun-select menu mid-passive when configured.
-- ============================================================================
RegisterNetEvent("Pug:client:RemovePassiveModePB", function()
  local ticks = Config.PassiveModeCoolDownWaitTime * 100
  while ticks > 0 do
    Wait(1)
    ticks = ticks - 1

    -- Allow E (control 38) to open the gun-select menu (host-only when set).
    if Config.CanChooseGunMidGame
       and not CheckMatchingGameMode("Gun_Game")
       and not CheckMatchingGameMode("One_In_The_Chamber")
       and IsControlJustPressed(0, 38) then
      if Config.HostOnlyCanControllWeaponSelect then
        if LobbyHost and LobbyHost == GetPlayerServerId(PlayerId()) then
          TriggerEvent("Pug:client:MenuChooseGun")
        end
      else
        TriggerEvent("Pug:client:MenuChooseGun")
      end
    end

    if IsPedShooting(PlayerPedId()) then break end  -- end passive on first shot
  end

  SetEntityInvincible(PlayerPedId(), false)
  SetEntityAlpha     (PlayerPedId(), 255)

  -- Top up health if low after passive ends (skip OITC where low HP is expected).
  if GetEntityHealth(PlayerPedId()) < 200
     and not CheckMatchingGameMode("One_In_The_Chamber") then
    TriggerEvent("Pug:client:PaintballReviveEvent")
  end
end)

-- ============================================================================
-- KILL-STREAK HANDLER
-- Increments killStreak; advances Gun-Game weapon ladder; fires UAV / special
-- weapon offers when the configured kill counts are reached.
-- ============================================================================
RegisterNetEvent("Pug:client:UpdatePlayersKillStreak", function()
  killStreak = killStreak + 1

  -- ---- Gun-Game ladder ---------------------------------------------------
  if CheckMatchingGameMode("Gun_Game") then
    if ChosenWeapon
       and type(ChosenWeapon) == "number"
       and ChosenWeapon >= Config.MaxFFAScore then
      return  -- already on the final tier
    end
    if ChosenWeapon ~= #RndomWeapons then
      ChosenWeapon = ChosenWeapon + 1
    end
    GiveThePlayerTheWeapon()

    if ChosenWeapon ~= #RndomWeapons then
      PaintBallNotify(string.format(
        Config.Translations.menu.next_weapon_progress,
        ChosenWeapon,
        Config.MaxFFAScore,
        Config.WeaponItems[RndomWeapons[ChosenWeapon + 1]].label
      ))
    end
  end

  if CheckMatchingGameMode("One_In_The_Chamber") then
    GiveThePlayerTheWeapon()
  end

  PugSoundPlay("killsoundeffect", 0.08)

  if not isFFAGameMode() then

    -- ---- UAV kill-streak ----------------------------------------------
    if killStreak == Config.UavKillstreak then
      local uavTriggered = nil
      CreateThread(function()
        while isInMatch do
          Wait(2)
          if not isInMatch then break end
          if not uavTriggered then
            -- Show prompt: "[E] use UAV"
            drawTextEx("~w~[E]~y~ " .. Config.Translations.menu.use_uav,
              4, { 255, 255, 255 }, 0.7, 0.55, 0.9380000000000001)

            if IsControlJustPressed(0, 46) then  -- E
              uavTriggered = true
              requestAndAwaitAnimDict("amb@code_human_in_bus_passenger_idles@female@tablet@idle_a")
              TaskPlayAnim(PlayerPedId(),
                "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a",
                "idle_a", 8.0, -8.0, 10000, 16, 0, false, false, false)

              -- Spawn a tablet prop and attach to the right hand.
              local tablet = CreateObject(GetHashKey("prop_cs_tablet"),
                GetEntityCoords(PlayerPedId()))
              local hand   = GetPedBoneIndex(PlayerPedId(), 28422)
              AttachEntityToEntity(tablet, PlayerPedId(), hand,
                -0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
              Wait(2000)

              local enemyTeam = (playerTeam == "redteam") and "red" or "blue"
              TriggerServerEvent("Pug:server:EnemyUAVEffectPaintall", enemyTeam)
              Wait(1000)

              ClearPedTasks(PlayerPedId())

              -- Clean up: delete the tablet but keep CTF flag entities alive.
              for _, obj in pairs(GetGamePool("CObject")) do
                if IsEntityAttachedToEntity(PlayerPedId(), obj)
                   and GetEntityModel(obj) ~= GetHashKey(Config.RedFlagModel)
                   and GetEntityModel(obj) ~= GetHashKey(Config.BlueFlagModel) then
                  SetEntityAsMissionEntity(obj, true, true)
                  DeleteObject(obj)
                  DeleteEntity(obj)
                end
              end
              TriggerEvent("Pug:ReloadGuns:sling")
            end
          else
            break
          end
        end
      end)
    end
  end

  -- ---- Special-weapon (e.g. RPG) kill-streak --------------------------
  if killStreak == Config.SpecialWeaponKillsStreak then
    local specialTriggered = nil
    CreateThread(function()
      while isInMatch do
        Wait(2)
        if not isInMatch then break end
        if not specialTriggered then
          local label = Config.WeaponItems[Config.SpecailWeaponItem].label
          drawTextEx("~w~[H]~g~ " .. Config.Translations.menu.use .. label,
            4, { 255, 255, 255 }, 0.7, 0.63, 0.9380000000000001)

          if IsControlJustPressed(0, 74) then  -- H
            specialTriggered = true
            GiveThePlayerTheWeapon(false, true)  -- give special weapon
            Wait(100)

            -- Auto-revert when the special weapon is empty.
            CreateThread(function()
              while isInMatch do
                Wait(100)
                if IsPlayerDead then break end
                local hash = GetSelectedPedWeapon(GetPlayerPed(PlayerId()))
                local _, ammo = GetAmmoInClip(GetPlayerPed(PlayerId()), hash)
                if ammo < 1 then
                  GiveThePlayerTheWeapon()
                  break
                end
              end
            end)
          end
        else
          break
        end
      end
    end)
  end
end)

-- A short cooldown on death-finished signal (mainly to clear IsPlayerDead).
RegisterNetEvent("Pug:client:PlayerIsDeadFinish", function()
  Wait(2000)
  IsPlayerDead = false
end)

-- ============================================================================
-- SCORE & LEADERBOARD UPDATES
-- ============================================================================
RegisterNetEvent("Pug:client:UpdateTeamsScore", function(red, blue)
  redTeamScore  = red
  blueTeamScore = blue
end)

RegisterNetEvent("Pug:client:UpdateKillsPaintball", function()
  TriggerServerEvent("Pug:Server:UpdatePaintballLeaderBoard")
end)

-- ============================================================================
-- FLAG-DEATH COOLDOWN (CTF special death sequence)
-- ============================================================================
RegisterNetEvent("Pug:client:FlagDeathCoolDown", function()
  DoScreenFadeOut(500)
  while not IsScreenFadedOut() do Wait(10) end
  DoScreenFadeIn(500)
  TriggerEvent("Pug:client:PaintballReviveEvent")

  FreezeEntityPosition(PlayerPedId(), true)
  SetEntityVisible    (PlayerPedId(), false)

  -- Snapshot current coords (used to anchor the death-cam), then put the cam
  -- 40m above us pointing inward.
  local pos = vector3(
    GetEntityCoords(PlayerPedId()).x,
    GetEntityCoords(PlayerPedId()).y,
    GetEntityCoords(PlayerPedId()).z)
  SetEntityCoords(PlayerPedId(),
    vector3(pos.x, pos.y, pos.z + 40.0))

  RenderScriptCams(false, false, 0, 1, 0)
  DestroyCam(countdownCam, false)

  if not DoesCamExist(countdownCam) then
    countdownCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(countdownCam, true)
    SetCamCoord (countdownCam, vector3(pos.x, pos.y, pos.z + 40.0))
    SetCamRot   (countdownCam, -2.5, 0.0, 75.0, 0.0)
    RenderScriptCams(true, false, 0, true, true)
  end

  -- Tick down respawnCountdown until the player presses Quit (`keysDisabled`)
  -- or it reaches zero.
  if not keysDisabled then
    while respawnCountdown >= 1 do
      if keysDisabled then break end
      if respawnCountdown == 10 then
        PaintBallNotify(Config.Translations.menu.you_respawn_in, "error", 2500)
      end
      respawnCountdown = respawnCountdown - 1
      Wait(1000)
    end
  end

  DeathCooldown = false
end)

-- ============================================================================
-- LEADERBOARD UI (per-team score boards & player rows)
-- ============================================================================
local lbRedRows  = {}
local lbBlueRows = {}
local lbTeamMeta = nil

RegisterNetEvent("Pug:Client:UpdatePaintballLeaderBoardPositions",
function(redRows, blueRows, teamMeta)
  lbRedRows  = redRows  or {}
  lbBlueRows = blueRows or {}
  lbTeamMeta = teamMeta or nil
end)

-- Format the +Bind / -Bind console-command tags used by RegisterKeyMapping.
local function formatBindOnText()
  return string.format("+%s_%s",
    Config.ScoreBoardCommand,
    tostring(Config.ScoreBoardKeyBind))
end
local function formatBindOffText()
  local s = formatBindOnText()
  return s:gsub("^%+", "-")
end

-- Touch-binds (non-keymapped) just toggle the scoreboard with `true`.
RegisterCommand(Config.ScoreBoardCommand, function()
  if isInMatch then PaintBallUI(true) end
end, false)

-- KeyMapping pair: pressing the bound key opens the scoreboard, releasing
-- closes it. The two RegisterCommand strings are constructed dynamically so
-- the user can rebind via in-game settings.
local bindOnTag  = formatBindOnText()
local bindOffTag = formatBindOffText()
local scoreboardOpen = false

RegisterKeyMapping(bindOnTag,
  Config.Translations.menu.scoreboard_keybind_desc,
  "keyboard",
  Config.ScoreBoardKeyBind)

RegisterCommand(bindOnTag, function()
  if isInMatch then
    scoreboardOpen = true
    PaintBallUI(true)
  end
end, false)

RegisterCommand(bindOffTag, function()
  scoreboardOpen = false
  SendNUIMessage({ action = "Update", type = "scoreboard", data = {}, active = false })
end, false)

-- The actual UI tick — sends scoreboard state to NUI every 4ms while open.
function PaintBallUI(_unused)
  if respawnCountdown ~= 10 then
    CreateThread(function()
      while scoreboardOpen do
        SendNUIMessage({
          action = "Update",
          type   = "scoreboard",
          data   = {
            mode     = currentGameModeName,
            rScore   = redTeamScore,
            bScore   = blueTeamScore,
            red      = lbRedRows,
            blue     = lbBlueRows,
            teamMeta = lbTeamMeta,
          },
          active = true,
        })
        Wait(4)
      end
    end)
  end
end

-- ============================================================================
-- GLOBAL KEY-DISABLE LOOP
-- During the match certain controls are blocked (vehicle entry, weapon wheel,
-- etc.). Triggered by the BeginPaintballMatch event with arg=true (extended
-- block list including movement) and re-toggled when the match ends.
-- ============================================================================
RegisterNetEvent("Pug:client:DisableKeys", function(includeMovement)
  keysDisabled    = true
  TriggerEvent("Pug:client:DisableControlCooldown", includeMovement)
  scoreboardOpen  = true
  PaintBallUI(true)

  -- Sweep up any straggler flag entities when the match ends.
  if not includeMovement then
    if DoesEntityExist(enemyFlagEntity) then DeleteEntity(enemyFlagEntity) end
    if DoesEntityExist(ownFlagEntity)   then DeleteEntity(ownFlagEntity)   end
  end

  while keysDisabled do
    Wait(0)
    -- Common block list (combat / weapon switch / radio / map / reload).
    DisableControlAction(0, 24,  true)
    DisableControlAction(0, 257, true)
    DisableControlAction(0, 188, true)
    DisableControlAction(0, 187, true)
    DisableControlAction(0, 25,  true)
    DisableControlAction(0, 263, true)

    if includeMovement then
      DisableControlAction(0, 21, true)  -- Sprint
      DisableControlAction(0, 30, true)  -- MoveX
      DisableControlAction(0, 31, true)  -- MoveY
    end

    DisableControlAction(0, 19,  true)  DisableControlAction(0, 45,  true)
    DisableControlAction(0, 22,  true)  DisableControlAction(0, 44,  true)
    DisableControlAction(0, 37,  true)  DisableControlAction(0, 23,  true)
    DisableControlAction(0, 288, true)  DisableControlAction(0, 289, true)
    DisableControlAction(0, 170, true)  DisableControlAction(0, 167, true)
    DisableControlAction(0, 26,  true)  DisableControlAction(0, 73,  true)
    DisableControlAction(0, 71,  true)  DisableControlAction(2, 36,  true)
    DisableControlAction(0, 264, true)  DisableControlAction(0, 257, true)
    DisableControlAction(0, 140, true)  DisableControlAction(0, 141, true)
    DisableControlAction(0, 142, true)  DisableControlAction(0, 143, true)
  end

  scoreboardOpen = false
  SendNUIMessage({ action = "Update", type = "scoreboard", data = {}, active = false })
end)

-- ============================================================================
-- CTF — FLAG SPAWN / BLIP MAINTENANCE
-- ============================================================================
local function setFlagSpawnCoords(redCoord, blueCoord)
  redFlagSpawnCoords  = redCoord
  blueFlagSpawnCoords = blueCoord
end
RegisterNetEvent("Pug:paintball:SpawnFlagLocation", setFlagSpawnCoords)
RegisterNetEvent("Pug:CTF:FlagPositions", setFlagSpawnCoords) -- what sv_ctf.lua actually sends

RegisterNetEvent("Pug:paintball:UpdateFlagBlip", function(coord, colour)
  if colour == "red" then
    redFlagSpawnCoords = coord
    if DoesBlipExist(RedFlagBlip) then RemoveBlip(RedFlagBlip); RedFlagBlip = nil end
    RedFlagBlip = AddBlipForCoord(coord.x, coord.y, coord.z)
    SetBlipSprite     (RedFlagBlip, 38)
    SetBlipDisplay    (RedFlagBlip, 4)
    SetBlipScale      (RedFlagBlip, 0.75)
    SetBlipColour     (RedFlagBlip, 1)
    SetBlipAsShortRange(RedFlagBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Translations.menu.red_flag_blip)
    EndTextCommandSetBlipName(RedFlagBlip)

    -- If we (red team) hold the flag entity but it's stranded, snap it to the
    -- new spawn; if we're blue and the enemy flag is stranded, do the same.
    if playerTeam == "redteam" then
      if DoesEntityExist(ownFlagEntity)
         and not IsEntityAttachedToAnyPed(ownFlagEntity) then
        SetEntityCoords(ownFlagEntity, redFlagSpawnCoords)
      end
    else
      if DoesEntityExist(enemyFlagEntity)
         and not IsEntityAttachedToAnyPed(enemyFlagEntity) then
        SetEntityCoords(enemyFlagEntity, redFlagSpawnCoords)
      end
    end

  elseif colour == "blue" then
    blueFlagSpawnCoords = coord
    if DoesBlipExist(BlueFlagBlip) then RemoveBlip(BlueFlagBlip); BlueFlagBlip = nil end
    BlueFlagBlip = AddBlipForCoord(coord.x, coord.y, coord.z)
    SetBlipSprite     (BlueFlagBlip, 38)
    SetBlipDisplay    (BlueFlagBlip, 4)
    SetBlipScale      (BlueFlagBlip, 0.75)
    SetBlipColour     (BlueFlagBlip, 3)
    SetBlipAsShortRange(BlueFlagBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Translations.menu.blue_flag_blip)
    EndTextCommandSetBlipName(BlueFlagBlip)

    if playerTeam == "redteam" then
      if DoesEntityExist(enemyFlagEntity)
         and not IsEntityAttachedToAnyPed(enemyFlagEntity) then
        SetEntityCoords(enemyFlagEntity, redFlagSpawnCoords)
      end
    else
      if DoesEntityExist(ownFlagEntity)
         and not IsEntityAttachedToAnyPed(ownFlagEntity) then
        SetEntityCoords(ownFlagEntity, blueFlagSpawnCoords)
      end
    end
  end
end)

-- While the local player is holding the enemy flag, send our position to the
-- server so other clients can draw a moving blip.
RegisterNetEvent("Pug:client:UpdateFlagLocationLoop", function()
  while true do
    Wait(800)
    if not enemyFlagEntity then break end

    if IsEntityAttachedToEntity(PlayerPedId(), enemyFlagEntity) then
      local pos = GetEntityCoords(PlayerPedId())
      if not isCapturingFlag then
        if playerTeam == "redteam" then
          TriggerServerEvent("Pug:server:UpdateFlagBlip", pos, "blue")
        elseif playerTeam == "blueteam" then
          TriggerServerEvent("Pug:server:UpdateFlagBlip", pos, "red")
        end
      else
        break  -- already capturing → drop the loop
      end
    else
      break    -- flag detached
    end
  end
end)

-- ============================================================================
-- ZONE LOOP — punishes players who drift outside the configured arena radius
-- by ticking 1 HP off per frame.
-- ============================================================================
RegisterNetEvent("Pug:client:RunZoneLoop", function(centerCoord, radius)
  local r = radius or 100.0
  while isInMatch do
    Wait(1)
    if not isInMatch then break end

    DrawMarker(28,
      centerCoord.x, centerCoord.y, centerCoord.z,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      r, r, r,
      31, 193, 255, 70,
      false, false, 2, nil, nil, false)

    local distToCenter = #(GetEntityCoords(PlayerPedId())
                           - vector3(centerCoord.x, centerCoord.y, centerCoord.z))
    if r <= distToCenter and not IsPlayerDead then
      SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 1)
    end
  end
end)

-- ============================================================================
-- CAPTURE-THE-FLAG MAIN LOOP
-- Spawns the two flag objects, lets the local player pick up the enemy flag
-- on touch, lets them return their own flag if it's been dropped in the open,
-- and awards the team a capture when the local player carries the enemy
-- flag back to their own flag's pedestal.
-- ============================================================================
RegisterNetEvent("Pug:client:CaptureTheFlagLoop", function()
  Wait(5000)

  -- Local team's "home" flag pedestal (where we score the capture).
  local homeFlagCoords
  if playerTeam == "redteam" then
    homeFlagCoords = Config.RedFlagLocation[currentMapName].Coords
  else
    homeFlagCoords = Config.BlueFlagLocation[currentMapName].Coords
  end

  -- Fall back to the configured pedestals if the server's flag positions never arrived.
  redFlagSpawnCoords  = redFlagSpawnCoords  or Config.RedFlagLocation[currentMapName].Coords
  blueFlagSpawnCoords = blueFlagSpawnCoords or Config.BlueFlagLocation[currentMapName].Coords

  while true do
    Wait(100)
    if not isInMatch then
      if DoesEntityExist(enemyFlagEntity) then DeleteEntity(enemyFlagEntity) end
      break
    end

    if not keysDisabled then
      -- ---- Lazily resolve / spawn the two flag entities ----------------
      if playerTeam == "redteam" then
        if not DoesEntityExist(enemyFlagEntity) then
          enemyFlagEntity = GetClosestObjectOfType(blueFlagSpawnCoords, 5.5,
            GetHashKey(Config.BlueFlagModel))
        end
        if not DoesEntityExist(ownFlagEntity) then
          ownFlagEntity = GetClosestObjectOfType(redFlagSpawnCoords, 5.5,
            GetHashKey(Config.RedFlagModel))
        end
        if not DoesEntityExist(enemyFlagEntity) then
          requestModelLoad(Config.BlueFlagModel)
          enemyFlagEntity = CreateObject(Config.BlueFlagModel,
            blueFlagSpawnCoords.x, blueFlagSpawnCoords.y, blueFlagSpawnCoords.z - 1)
          while not DoesEntityExist(enemyFlagEntity) do Wait(100) end
        end
        if not DoesEntityExist(ownFlagEntity) then
          requestModelLoad(Config.RedFlagModel)
          ownFlagEntity = CreateObject(Config.RedFlagModel,
            redFlagSpawnCoords.x, redFlagSpawnCoords.y, redFlagSpawnCoords.z - 1)
          while not DoesEntityExist(ownFlagEntity) do Wait(100) end
        end

      elseif playerTeam == "blueteam" then
        if not DoesEntityExist(enemyFlagEntity) then
          enemyFlagEntity = GetClosestObjectOfType(redFlagSpawnCoords, 5.5,
            GetHashKey(Config.RedFlagModel))
        end
        if not DoesEntityExist(ownFlagEntity) then
          ownFlagEntity = GetClosestObjectOfType(blueFlagSpawnCoords, 5.5,
            GetHashKey(Config.BlueFlagModel))
        end
        if not DoesEntityExist(enemyFlagEntity) then
          requestModelLoad(Config.RedFlagModel)
          enemyFlagEntity = CreateObject(Config.RedFlagModel,
            redFlagSpawnCoords.x, redFlagSpawnCoords.y, redFlagSpawnCoords.z - 1)
          while not DoesEntityExist(enemyFlagEntity) do Wait(100) end
        end
        if not DoesEntityExist(ownFlagEntity) then
          requestModelLoad(Config.BlueFlagModel)
          ownFlagEntity = CreateObject(Config.BlueFlagModel,
            blueFlagSpawnCoords.x, blueFlagSpawnCoords.y, blueFlagSpawnCoords.z - 1)
          while not DoesEntityExist(ownFlagEntity) do Wait(100) end
        end
      end
    end

    -- ---- Pick up the ENEMY flag on touch -----------------------------
    local enemyFlagPos = GetEntityCoords(enemyFlagEntity)
    if enemyFlagEntity and not IsEntityAttachedToAnyPed(enemyFlagEntity)
       and #(GetEntityCoords(PlayerPedId()) - enemyFlagPos) < 1.5
       and not IsEntityAttachedToAnyPed(enemyFlagEntity) then
      Wait(100)
      if not IsPlayerDead and not IsPedRagdoll(PlayerPedId())
         and not IsEntityDead(PlayerPedId()) then

        Config.FrameworkFunctions.TriggerCallback(
          "Pug:serverCB:IsFlagAvailableToTake",
          function(allowed)
            if allowed then
              TriggerEvent("animations:client:EmoteCommandStart", { "damn2" })
              TriggerServerEvent("Pug:server:PickedUpFlagSound", playerTeam, "pickedup")
              Wait(400)
              TriggerEvent("Pug:client:UpdateFlagLocationLoop")
            end
          end,
          "enemy",
          playerTeam)
      end
    end

    -- ---- Return our OWN flag if it's lying loose ---------------------
    local ownFlagPos = GetEntityCoords(ownFlagEntity)
    if ownFlagEntity and not IsEntityAttachedToAnyPed(ownFlagEntity)
       and #(GetEntityCoords(PlayerPedId()) - ownFlagPos) < 1.5 then
      Wait(100)
      if not IsPlayerDead and not IsPedRagdoll(PlayerPedId())
         and not IsEntityDead(PlayerPedId()) then

        if #(ownFlagPos - homeFlagCoords) > 2.5 then
          -- Standing on a stranded own-flag → emote, then return it.
          TriggerEvent("animations:client:EmoteCommandStart", { "damn2" })
          Wait(300)
          if not IsEntityAttachedToAnyPed(ownFlagEntity) then
            TriggerServerEvent("Pug:server:PickedUpFlagSound",
              playerTeam, "returned")
            local respawnColour = (playerTeam == "redteam") and "red" or "blue"
            TriggerServerEvent("Pug:server:RespawnFlag", respawnColour)
          end
        end
        Wait(100)
      end
    end

    -- ---- Score a capture: enemy flag + we're at our pedestal --------
    if playerTeam == "redteam" then
      if IsEntityAttachedToEntity(PlayerPedId(), enemyFlagEntity)
         and #(GetEntityCoords(PlayerPedId())
                - Config.RedFlagLocation[currentMapName].Coords) < 1.5 then
        isCapturingFlag = true
        TriggerServerEvent("Pug:Server:UpdateTeamScore", "red")
        TriggerServerEvent("Pug:server:PickedUpFlagSound", playerTeam, "captured")
        TriggerEvent("animations:client:EmoteCommandStart", { "damn2" })
        TriggerServerEvent("Pug:server:RespawnFlag", "blue")
        Wait(2000)
        isCapturingFlag = false
      end
    elseif playerTeam == "blueteam" then
      if IsEntityAttachedToEntity(PlayerPedId(), enemyFlagEntity)
         and #(GetEntityCoords(PlayerPedId())
                - Config.BlueFlagLocation[currentMapName].Coords) < 1.5 then
        isCapturingFlag = true
        TriggerServerEvent("Pug:Server:UpdateTeamScore", "blue")
        TriggerServerEvent("Pug:server:PickedUpFlagSound", playerTeam, "captured")
        TriggerEvent("animations:client:EmoteCommandStart", { "damn2" })
        TriggerServerEvent("Pug:server:RespawnFlag", "red")
        Wait(2000)
        isCapturingFlag = false
      end
    end
  end
end)

-- ============================================================================
-- CTF — ATTACH PICKED-UP FLAG TO A PED
-- Fires when ANY player on the server picks up a flag; we attach the right
-- entity to the right ped (and delete the corresponding object from spectator
-- views when fully captured).
-- ============================================================================
RegisterNetEvent("Pug:client:AttatchFlagToClientPlayer",
function(flagOwnerSrvId, flagColour, fullyCaptured)
  local carrierPed = GetPlayerPed(GetPlayerFromServerId(flagOwnerSrvId))
  local handBone   = GetPedBoneIndex(PlayerPedId(), 24816)  -- left-hand bone

  -- The original logic distinguishes which entity to attach (own vs enemy)
  -- based on the local player's team relative to the carrying team. We
  -- preserve those four branches one-to-one.
  if flagColour == "redteam" then
    if playerTeam == "redteam" then
      -- I'm red, my own flag is being picked up → either delete or attach.
      if fullyCaptured then
        TriggerEvent("FullyDeletePaintballEntity", enemyFlagEntity)
      else
        AttachEntityToEntity(enemyFlagEntity, carrierPed, handBone,
          0.105, -0.165, 0.02, 0.0, 90.0, 0.0,
          1, 1, 0, 0, 2, 1)
      end
    else
      -- I'm blue, the red flag (which is enemy from blue's POV) is moving.
      if fullyCaptured then
        TriggerEvent("FullyDeletePaintballEntity", ownFlagEntity)
      else
        AttachEntityToEntity(ownFlagEntity, carrierPed, handBone,
          0.105, -0.165, 0.02, 0.0, 90.0, 0.0,
          1, 1, 0, 0, 2, 1)
      end
    end
  else
    -- flagColour == "blueteam"
    if playerTeam == "redteam" then
      if fullyCaptured then
        TriggerEvent("FullyDeletePaintballEntity", ownFlagEntity)
      else
        AttachEntityToEntity(ownFlagEntity, carrierPed, handBone,
          0.105, -0.165, 0.02, 0.0, 90.0, 0.0,
          1, 1, 0, 0, 2, 1)
      end
    else
      if fullyCaptured then
        TriggerEvent("FullyDeletePaintballEntity", enemyFlagEntity)
      else
        AttachEntityToEntity(enemyFlagEntity, carrierPed, handBone,
          0.105, -0.165, 0.02, 0.0, 90.0, 0.0,
          1, 1, 0, 0, 2, 1)
      end
    end
  end
end)

-- ============================================================================
-- SEARCH-AND-DESTROY (Bomb plant/defuse mode)
-- ============================================================================
local isPlantingOrDefusing = false

-- Synchronised "place laptop in bag" animation used both for planting and
-- defusing the bomb.
RegisterNetEvent("Pug:client:BombPlantAnimation", function()
  if isPlantingOrDefusing then return end
  isPlantingOrDefusing = true

  -- Wipe any previous animation props.
  if DoesEntityExist(bag)    then DeleteEntity(bag);    bag = nil    end
  if DoesEntityExist(laptop) then DeleteEntity(laptop); laptop = nil end

  -- Capture player coords for the synchronised scene anchor.
  local anchor = { 1, 2, 3, 4 }  -- preserved verbatim from decompile (table re-init)
  anchor.x = GetEntityCoords(PlayerPedId()).x
  anchor.y = GetEntityCoords(PlayerPedId()).y
  anchor.z = GetEntityCoords(PlayerPedId()).z + 0.7

  local animDict = "anim@heists@ornate_bank@hack"
  RequestAnimDict(animDict)
  RequestModel("hei_prop_hst_laptop")
  RequestModel("hei_p_m_bag_var22_arm_s")
  while not (HasAnimDictLoaded(animDict)
             and HasModelLoaded("hei_prop_hst_laptop")
             and HasModelLoaded("hei_p_m_bag_var22_arm_s")) do
    Wait(100)
  end

  local ped = PlayerPedId()
  local pos = vec3(GetEntityCoords(ped))
  local rot = vec3(GetEntityRotation(ped))

  -- Three sub-scenes: enter → loop → exit.
  local enterPos = GetAnimInitialOffsetPosition(animDict, "hack_enter",
    anchor.x, anchor.y, anchor.z, anchor.x, anchor.y, anchor.z, 0, 0)
  local loopPos  = GetAnimInitialOffsetPosition(animDict, "hack_loop",
    anchor.x, anchor.y, anchor.z, anchor.x, anchor.y, anchor.z, 0, 0)
  local exitPos  = GetAnimInitialOffsetPosition(animDict, "hack_exit",
    anchor.x, anchor.y, anchor.z, anchor.x, anchor.y, anchor.z, 0, 0)

  FreezeEntityPosition(ped, true)

  -- ---- ENTER ---------------------------------------------------------
  local enterScene = NetworkCreateSynchronisedScene(
    enterPos, rot, 2, false, false, 1065353216, 0, 1.3)
  bag    = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), pos, 1, 1, 0)
  laptop = CreateObject(GetHashKey("hei_prop_hst_laptop"),    pos, 1, 1, 0)
  NetworkAddPedToSynchronisedScene   (ped,    enterScene, animDict, "hack_enter",        1.5, -4.0, 1, 16, 1148846080, 0)
  NetworkAddEntityToSynchronisedScene(bag,    enterScene, animDict, "hack_enter_bag",    4.0, -8.0, 1)
  NetworkAddEntityToSynchronisedScene(laptop, enterScene, animDict, "hack_enter_laptop", 4.0, -8.0, 1)

  -- ---- LOOP ----------------------------------------------------------
  local loopScene = NetworkCreateSynchronisedScene(
    loopPos, rot, 2, false, true, 1065353216, 0, 1.3)
  NetworkAddPedToSynchronisedScene   (ped,    loopScene, animDict, "hack_loop",        1.5, -4.0, 1, 16, 1148846080, 0)
  NetworkAddEntityToSynchronisedScene(bag,    loopScene, animDict, "hack_loop_bag",    4.0, -8.0, 1)
  NetworkAddEntityToSynchronisedScene(laptop, loopScene, animDict, "hack_loop_laptop", 4.0, -8.0, 1)

  -- ---- EXIT ----------------------------------------------------------
  local exitScene = NetworkCreateSynchronisedScene(
    exitPos, rot, 2, false, false, 1065353216, 0, 1.3)
  NetworkAddPedToSynchronisedScene   (ped,    exitScene, animDict, "hack_exit",        1.5, -4.0, 1, 16, 1148846080, 0)
  NetworkAddEntityToSynchronisedScene(bag,    exitScene, animDict, "hack_exit_bag",    4.0, -8.0, 1)
  NetworkAddEntityToSynchronisedScene(laptop, exitScene, animDict, "hack_exit_laptop", 4.0, -8.0, 1)

  Wait(200)
  NetworkStartSynchronisedScene(enterScene)
end)

-- ============================================================================
-- SEARCH-AND-DESTROY — PLANT THE BOMB
-- The player must stand near a bomb-site prop and HOLD E (control 38) to
-- plant; if a bomb is already planted, the *defending* team can defuse it.
-- ============================================================================
RegisterNetEvent("Pug:client:PlantTheBomb", function()
  local bombAlreadyPlanted = false

  Config.FrameworkFunctions.TriggerCallback("Pug:serverCB:CheckBombStatus",
    function(planted)
      if planted then bombAlreadyPlanted = true end
    end)
  Wait(100)

  -- Find the closest bomb-site (or planted laptop, when defusing).
  local interactObj = GetClosestObjectOfType(
    GetEntityCoords(PlayerPedId()),
    2.0,
    GetHashKey(Config.BombSiteModel),
    false, false, false)

  if bombAlreadyPlanted then
    interactObj = GetClosestObjectOfType(
      GetEntityCoords(PlayerPedId()),
      1.0,
      GetHashKey("hei_prop_hst_laptop"),
      false, false, false)
  end

  -- Bail if too far away.
  if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(interactObj)) >= 2.5 then
    return
  end

  local progressLabel = bombAlreadyPlanted and "Defusing The Bomb" or "Planting The Bomb"
  TriggerEvent("Pug:client:PlantingBombProgressBar", progressLabel, bombAlreadyPlanted)

  while true do
    if not isPlantingOrDefusing then
      -- Within range and no anim active → kick off the synchronised anim.
      if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(interactObj)) < 2.5 then
        TaskTurnPedToFaceEntity(PlayerPedId(), PlayerPedId(), 5500)
        Wait(100)

        if bombAlreadyPlanted then
          isPlantingOrDefusing = true
          RequestAnimDict("anim@heists@ornate_bank@hack")
          while not HasAnimDictLoaded("anim@heists@ornate_bank@hack") do Wait(0) end
          TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@hack",
            "hack_loop", 8.0, -8.0, -1, 1, 0, false, false, false)
        else
          TriggerEvent("Pug:client:BombPlantAnimation")
        end
      end
    end

    -- Cancel if the player releases E or has finished.
    if IsControlJustReleased(0, 38) or isPlantingOrDefusing then
      goto continueLoop  -- placeholder; see early-out path below
    end

    do
      TriggerEvent("progressbar:client:cancel")
      ClearPedTasks(PlayerPedId())
      isPlantingOrDefusing = false
      if DoesEntityExist(bag)    then DeleteEntity(bag);    bag = nil    end
      if DoesEntityExist(laptop) then DeleteEntity(laptop); laptop = nil end
      FreezeEntityPosition(PlayerPedId(), false)
      break
    end

    ::continueLoop::
    Wait(2)
  end
end)

-- ============================================================================
-- PROGRESS-BAR (handles both QBCore native progress and FWork.Progressbar)
-- A0_2 = label, A1_2 = isDefusing
-- ============================================================================
RegisterNetEvent("Pug:client:PlantingBombProgressBar", function(label, isDefusing)
  -- onFinish handler for both branches (QBCore + standalone) is identical.
  local function onProgressFinish()
    if DoesEntityExist(bag)    then DeleteEntity(bag);    bag = nil    end
    if DoesEntityExist(laptop) then DeleteEntity(laptop); laptop = nil end

    if isDefusing then
      -- Defuse: delete the planted laptop and tell the server.
      local plantedLaptop = GetClosestObjectOfType(
        GetEntityCoords(PlayerPedId()), 3.0,
        GetHashKey("hei_prop_hst_laptop"),
        false, false, false)
      NetworkRequestControlOfEntity(plantedLaptop)
      DeleteEntity(plantedLaptop)
      TriggerServerEvent("Pug:server:SerachAndDestroyUpdate", playerTeam)
      TriggerServerEvent("Pug:server:SetBombPlanted", false)

    else
      -- Plant: spawn the laptop prop where we stand.
      local pos = GetEntityCoords(PlayerPedId())
      object = CreateObject(GetHashKey("hei_prop_hst_laptop"),
        pos.x, pos.y, pos.z, true, true, false)
      PlaceObjectOnGroundProperly(object)
      TriggerServerEvent("Pug:server:SetBombPlanted", true)
      TriggerServerEvent("Pug:server:BombPlantTimer",
        GetEntityCoords(PlayerPedId()))
    end

    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    isPlantingOrDefusing = false
  end

  -- onCancel handler for both branches (also identical).
  local function onProgressCancel()
    isPlantingOrDefusing = false
    ClearPedTasks(PlayerPedId())
    DeleteObject(bag)
    DeleteObject(laptop)
    FreezeEntityPosition(PlayerPedId(), false)
  end

  if Framework == "QBCore" then
    -- QBCore's progress-bar API has positional args.
    FWork.Functions.Progressbar(
      "testing",         -- name
      label,             -- label
      7000,              -- duration ms
      false,             -- useWhileDead
      true,              -- canCancel
      {
        disableMovement   = false,
        disableCarMovement = false,
        disableMouse      = false,
        disableCombat     = false,
      },
      {}, {}, {},        -- animDict / anim / animFlags (already running)
      onProgressFinish,
      onProgressCancel)
  else
    -- Standalone FWork.Progressbar (single options table).
    FWork.Progressbar(
      "Crafting " .. GetItemsInformation(item),
      7500,
      {
        FreezePlayer = true,
        onFinish     = onProgressFinish,
        onCancel     = onProgressCancel,
      })
  end
end)

-- ============================================================================
-- BOMB EXPLOSION + HEALTH RESET (post-explosion)
-- ============================================================================
RegisterNetEvent("Pug:Client:ApplyBombExplosion", function(coord)
  AddExplosion(coord.x, coord.y, coord.z, "EXPLOSION_TANKER", 2.0, true, false, 2.0)
end)

RegisterNetEvent("Pug:client:ResetPlayerHealth", function()
  SetEntityHealth(PlayerPedId(), 200)
end)

-- ============================================================================
-- ROBUST ENTITY DELETION
-- Some FiveM builds ignore DeleteEntity for foreign-owned entities; we request
-- ownership, mark the entity as a mission entity, and finally use the raw
-- native (-1569388442007722673) before the standard delete.
-- ============================================================================
RegisterNetEvent("FullyDeletePaintballEntity", function(entity)
  local target = entity
  NetworkRequestControlOfEntity(target)

  -- Wait up to 2s for ownership.
  local timeout = 2000
  while timeout > 0 do
    if NetworkHasControlOfEntity(target) then break end
    Wait(100); timeout = timeout - 100
  end

  SetEntityAsMissionEntity(target, true, true)
  timeout = 2000
  while timeout > 0 do
    if IsEntityAMissionEntity(target) then break end
    Wait(100); timeout = timeout - 100
  end

  -- Native: SET_ENTITY_AS_NO_LONGER_NEEDED (raw hash form).
  Citizen.InvokeNative(-1569388442007722673,
    Citizen.PointerValueIntInitialized(target))

  if DoesEntityExist(target) then
    DeleteEntity(target)
    return not DoesEntityExist(target)
  end
  return true
end)

-- ============================================================================
-- KILL-CONFIRMED MODE
-- Each kill drops a "tag" that teammates pick up to confirm. The server tells
-- us when to spawn / delete a tag and we render markers + audio cues.
-- ============================================================================
local kcTags          = {}
local lastKcPickupAt  = 0

-- Helper: load a model with a timeout, returning the hash on success.
local function loadModelWithTimeout(modelOrHash, timeoutMs)
  local hash = (type(modelOrHash) == "number" and modelOrHash) or GetHashKey(modelOrHash)
  if not modelOrHash then return false end
  timeoutMs = timeoutMs or 3000

  if not IsModelInCdimage(hash) then return false end

  RequestModel(hash)
  local startTime = GetGameTimer()
  while not HasModelLoaded(hash) do
    if (GetGameTimer() - startTime) >= timeoutMs then return false end
    Wait(0)
  end
  return hash
end

local function removeKcTag(tagId)
  local tag = kcTags[tagId]
  if tag and tag.entity and DoesEntityExist(tag.entity) then
    DeleteEntity(tag.entity)
  end
  kcTags[tagId] = nil
end

local function clearAllKcTags()
  for id in pairs(kcTags) do
    removeKcTag(id)
  end
  kcTags = {}
end

RegisterNetEvent("Pug:client:KC:DeleteTag", function(tagId)
  tagId = tonumber(tagId)
  if not tagId then return end
  removeKcTag(tagId)
end)

RegisterNetEvent("Pug:client:KC:SpawnTag", function(tagId, coords, ownerTeam, ownerCid)
  tagId = tonumber(tagId)
  if not tagId or not coords then return end
  removeKcTag(tagId)  -- ensure we don't double-spawn

  local model = Config.KCTagModel or "prop_ld_health_pack"
  local hash  = loadModelWithTimeout(model)

  local entity = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z)
  if not entity or entity == 0 then return end

  SetEntityCollision        (entity, false, false)
  FreezeEntityPosition      (entity, true)
  SetEntityInvincible       (entity, true)
  PlaceObjectOnGroundProperly(entity)

  kcTags[tagId] = {
    entity    = entity,
    coords    = coords,
    ownerTeam = ownerTeam,
    ownerCid  = ownerCid,
  }
end)

-- The pickup loop: draws a colored marker over each tag, and tries pickup if
-- the player walks within Config.KCTagPickupRadius. Friendly tags are red; the
-- enemy (your own kills) tags are green.
RegisterNetEvent("Pug:client:BeginKillConfirmedLoop", function()
  while isInMatch do
    if not isInMatch then break end
    if CheckMatchingGameMode("Kill_Confirmed") then
      if not IsPlayerDead then
        local localPed   = PlayerPedId()
        local localPos   = GetEntityCoords(localPed)
        local myColor    =
          (playerTeam == "redteam"  and "red") or
          (playerTeam == "blueteam" and "blue") or nil

        for tagId, tag in pairs(kcTags) do
          if tag and tag.coords then
            local distToTag = #(localPos - tag.coords)

            -- Friend = my team, paint red; otherwise green.
            -- (The boolean ladder in the original was equivalent to this.)
            local isFriendlyTag = (myColor ~= nil)
            local r = isFriendlyTag and 255 or 50
            local g = isFriendlyTag and 60  or 120
            local b = isFriendlyTag and 60  or 255

            DrawMarker(31,
              tag.coords.x, tag.coords.y, tag.coords.z + 0.25,
              0.0, 0.0, 0.0,
              0.0, 0.0, 0.0,
              1.0, 1.0, 1.0,
              r, g, b, 160,
              false, true, 2,
              false, nil, nil, false)

            local pickupRadius = tonumber(Config.KCTagPickupRadius) or 2.0
            if distToTag <= pickupRadius then
              local now = GetGameTimer()
              if (now - lastKcPickupAt) > 250 then
                PugSoundPlay("pickuptag", 0.1)
                lastKcPickupAt = now
                TriggerServerEvent("Pug:server:KC:TryPickup", tagId)
              end
            end
          end
        end
        Wait(0)
      end
    else
      Wait(1000)
    end
  end
end)

RegisterNetEvent("Pug:client:KC:ClearAll", function()
  clearAllKcTags()
end)

-- Hand weapon control back to ox_inventory if the resource stops mid-match.
AddEventHandler("onResourceStop", function(resourceName)
  if resourceName ~= GetCurrentResourceName() or not isInMatch then return end
  if GetResourceState("ox_inventory") == "started" then
    pcall(function() exports.ox_inventory:weaponWheel(false) end)
  end
end)
