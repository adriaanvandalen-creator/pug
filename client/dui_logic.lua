-- filename: client/dui_logic.lua
-- [DEOBFUSCATED]: Full Luraph-style local-variable obfuscation removed.
--   All L*_* variable names replaced with descriptive identifiers.
--   Control flow (goto/label) unwrapped to readable if/else.
--   Zero logic changes — every native call, event, and callback preserved exactly.

-- =============================================================================
-- === Initialization: Leaderboard Spawn Location ==============================
-- =============================================================================

-- The active leaderboard mode filter sent to the server callback.
-- Updated whenever the player picks a mode from the leaderboard menu.
local currentModeFilter = "Hold Your Own"  -- was: L0_1

-- Choose the leaderboard prop spawn location based on whether the int_arcade
-- MLO resource is running. Heading is offset +180 so the board faces players.
local leaderboardSpawnLocation  -- was: L1_1

if GetResourceState("int_arcade") == "started" then
  leaderboardSpawnLocation = vector4(
    Config.LeaderboardLocation.x,
    Config.LeaderboardLocation.y,
    Config.LeaderboardLocation.z,
    Config.LeaderboardLocation.w + 180
  )
else
  leaderboardSpawnLocation = vector4(
    Config.BackupLeaderboardLocation.x,
    Config.BackupLeaderboardLocation.y,
    Config.BackupLeaderboardLocation.z,
    Config.BackupLeaderboardLocation.w + 180
  )
end

-- =============================================================================
-- === DUI Browser & Whiteboard Texture ========================================
-- =============================================================================

-- Creates (or recreates) the DUI browser pointed at html_dui/index.html,
-- builds a runtime TXD/texture from its handle, and replaces the whiteboard
-- prop's texture so the leaderboard page is visible in-world.
-- Assigned to the global UpdateInGameLeaderboard so other files can call it.
function UpdateInGameLeaderboard()  -- was: L2_1 (first definition)
  -- Tear down any existing DUI before creating a fresh one
  if duiObj then
    DestroyDui(duiObj)
    duiObj = nil
  end

  local resourceName = GetCurrentResourceName()
  local duiUrl       = "nui://" .. resourceName .. "/html_dui/index.html"

  duiObj = CreateDui(duiUrl, 512, 512)

  local duiHandle = GetDuiHandle(duiObj)
  local txd       = CreateRuntimeTxd("paintballleaderboard_txd")

  -- Return value intentionally unused — side-effect of registering the texture is what matters
  CreateRuntimeTextureFromDuiHandle(txd, "paintballleaderboard_tex", duiHandle)

  -- Replace the whiteboard prop texture with the leaderboard DUI texture
  AddReplaceTexture(
    "ch_prop_whiteboard_02",     -- prop model name
    "script_rt_arcadeplan_02",   -- original texture name to replace
    "paintballleaderboard_txd",  -- runtime TXD name
    "paintballleaderboard_tex"   -- runtime texture name
  )

  -- Warn the operator if they renamed the resource but forgot to update the HTML
  if GetCurrentResourceName() ~= "pug-paintball" then
    print("^2IF YOU HAVE CHANGED THE RESOURCE NAME THEN MAKE SURE TO CHANGE THE RESOURCE NAME IN HTML_DUI/INDEX.HTML AT LINE 129^0")
  end
end

-- =============================================================================
-- === NUI Callback: getLeaderboardData ========================================
-- =============================================================================

-- Called by the DUI page (JavaScript) when it needs fresh leaderboard rows.
-- Forwards the current mode filter to the server and passes the result back to NUI.
RegisterNUICallback("getLeaderboardData", function(data, cb)  -- [LOCAL]
  -- was: L2_1 (RegisterNUICallback alias), L3_1 ("getLeaderboardData"), L4_1 (handler)
  Config.FrameworkFunctions.TriggerCallback(
    "Pug:Leaderboard:GetDataPaintball",
    function(result)  -- was: L4_2 (inner cb forwarder)
      cb(result)
    end,
    currentModeFilter  -- was: L5_2 = L0_1
  )
end)

-- =============================================================================
-- === Leaderboard Prop Spawning ===============================================
-- =============================================================================

-- Requests and loads the whiteboard model, spawns it frozen at the configured
-- location, then attaches a target zone so players can open the leaderboard menu.
local function spawnLeaderboardProp()  -- was: L2_1 (second definition, reassigned)
  local modelHash = GetHashKey("ch_prop_whiteboard_02")  -- was: L0_2

  RequestModel(modelHash)
  while not HasModelLoaded(modelHash) do
    Wait(0)
  end

  -- Create the prop at the XYZ of the spawn location; heading set separately below
  leaderboardProp = CreateObject(
    modelHash,
    leaderboardSpawnLocation.x,  -- was: L3_2 = L1_1.x
    leaderboardSpawnLocation.y,  -- was: L4_2 = L1_1.y
    leaderboardSpawnLocation.z   -- was: L5_2 = L1_1.z
  )

  SetEntityHeading(leaderboardProp, leaderboardSpawnLocation.w)  -- was: L1_1.w
  FreezeEntityPosition(leaderboardProp, true)

  -- Add a target interaction (ox_target / qb-target / qtarget via PugAddTargetToEntity)
  PugAddTargetToEntity(leaderboardProp, {
    {
      label    = Config.Translations.menu.open_leaderboard,
      icon     = "fas fa-list",
      event    = "Pug:client:ShowLeaderboardMenuPaintball",  -- [LOCAL]
      distance = 4.0,
    }
  })
end

-- =============================================================================
-- === Event: ShowLeaderboardMenuPaintball =====================================
-- =============================================================================

-- [LOCAL] Opens a context menu listing every available leaderboard mode filter.
-- Each option fires FilterLeaderboardPaintball with the selected mode name.
RegisterNetEvent("Pug:client:ShowLeaderboardMenuPaintball", function()  -- was: L3_1, L4_1, L5_1
  local menuOptions = {}  -- was: L0_2

  -- Helper: inserts a menu entry for a game mode only if it exists in Config.GameModes.
  -- Captures menuOptions from the enclosing scope.
  local function addModeOption(modeKey, title, description, icon, iconColor)  -- was: L1_2 / (A0_3..A4_3)
    local gameModeConfig = Config.GameModes[modeKey]  -- was: L5_3
    if gameModeConfig then
      menuOptions[#menuOptions + 1] = {    -- was: L6_3[L7_3] = L8_3
        title       = title,              -- was: A1_3
        description = description,        -- was: A2_3
        icon        = icon,               -- was: A3_3
        iconColor   = iconColor,          -- was: A4_3
        event       = "Pug:client:FilterLeaderboardPaintball",
        args        = { mode = gameModeConfig.name },  -- was: L9_3 = { mode = L10_3 }
      }
    end
  end

  -- Add one entry per game mode that is present in Config.GameModes
  -- was: repeated L2_2 = L1_2; L2_2(L3_2, L4_2, L5_2, L6_2, L7_2) blocks
  addModeOption(
    "Free_For_All",
    Config.Translations.menu.lb_ffa_title,
    Config.Translations.menu.lb_ffa_description,
    "fas fa-user",
    "#f8c441"
  )
  addModeOption(
    "Capture_The_Flag",
    Config.Translations.menu.lb_ctf_title,
    Config.Translations.menu.lb_ctf_description,
    "fas fa-flag",
    "#d93636"
  )
  addModeOption(
    "Gun_Game",
    Config.Translations.menu.lb_gungame_title,
    Config.Translations.menu.lb_gungame_description,
    "fas fa-crosshairs",
    "#7cff01ff"
  )
  addModeOption(
    "One_In_The_Chamber",
    Config.Translations.menu.lb_oitc_title,
    Config.Translations.menu.lb_oitc_description,
    "fas fa-bomb",
    "#a264ff"
  )
  addModeOption(
    "Hold_Your_Own",
    Config.Translations.menu.lb_hyo_title,
    Config.Translations.menu.lb_hyo_description,
    "fas fa-shield-alt",
    "#4aa3ff"
  )
  addModeOption(
    "Team_DeathMatch",
    Config.Translations.menu.lb_tdm_title,
    Config.Translations.menu.lb_tdm_description,
    "fas fa-users",
    "#ff9f33"
  )
  addModeOption(
    "Kill_Confirmed",
    Config.Translations.menu.lb_kc_title,
    Config.Translations.menu.lb_kc_description,
    "fas fa-tags",
    "#22c55e"
  )

  -- Personal stats option (cross-mode summary for the requesting player)
  -- was: L2_2 = #L0_2; L2_2 = L2_2 + 1; L3_2 = {...}; L0_2[L2_2] = L3_2
  menuOptions[#menuOptions + 1] = {
    title       = Config.Translations.menu.lb_personal_title,
    description = Config.Translations.menu.lb_personal_description,
    icon        = "fas fa-id-badge",
    iconColor   = "#3bd1c6",
    event       = "Pug:client:FilterLeaderboardPaintball",
    args        = { mode = "personal" },
  }

  PugCreateMenu(
    "br_leaderboard_menu",
    Config.Translations.menu.leaderboard_options,
    menuOptions
  )
end)

-- =============================================================================
-- === Event: FilterLeaderboardPaintball =======================================
-- =============================================================================

-- [LOCAL] Updates currentModeFilter and refreshes both the DUI texture and the
-- menu so the newly selected leaderboard mode is reflected immediately.
RegisterNetEvent("Pug:client:FilterLeaderboardPaintball", function(data)  -- was: L3_1, L4_1, L5_1 / A0_2
  -- Support both data.mode (ox_lib/direct) and data.args.mode (qb-menu) shapes
  local selectedMode = data.mode  -- was: L1_2 = A0_2.mode
  if not selectedMode then
    if data.args then
      selectedMode = data.args.mode  -- was: L1_2 = A0_2.args.mode
    end
  end
  if not selectedMode then return end

  currentModeFilter = selectedMode        -- was: L0_1 = L1_2  (upvalue write)
  UpdateInGameLeaderboard()               -- was: L2_2 = UpdateInGameLeaderboard; L2_2()
  TriggerEvent("Pug:client:ShowLeaderboardMenuPaintball")  -- [LOCAL] -- was: L2_2(L3_2)
end)

-- =============================================================================
-- === Proximity Thread: Spawn / Despawn Leaderboard Prop ======================
-- =============================================================================

-- Tracks whether the leaderboard prop is currently spawned in-world.
-- Shared as an upvalue with the proximity thread and the refresh handler.
local leaderboardSpawned = false  -- was: L3_1 (reassigned from RegisterNetEvent alias)

-- Polls every second. Spawns the whiteboard prop + DUI when the player walks
-- within 20m, and destroys both when they walk away.
CreateThread(function()  -- was: L4_1 = CreateThread; L4_1(L5_1)
  while true do
    Wait(1000)

    local ped          = PlayerPedId()                    -- was: L0_2
    local playerCoords = GetEntityCoords(ped)             -- was: L1_2
    local leaderboardPos = vector3(                       -- was: L2_2 (vector3 constructor result)
      leaderboardSpawnLocation.x,                        -- was: L3_2 = L1_1.x
      leaderboardSpawnLocation.y,                        -- was: L4_2 = L1_1.y
      leaderboardSpawnLocation.z                         -- was: L5_2 = L1_1.z
    )
    local distance = #(playerCoords - leaderboardPos)    -- was: L2_2 = #(L1_2 - L2_2)

    if distance < 20.0 then
      -- Only spawn when on foot and not paused
      local inVehicle      = IsPedInAnyVehicle(ped)     -- was: L3_2
      local pauseMenuOpen  = IsPauseMenuActive()         -- was: L3_2 (reused after vehicle check)
      if not inVehicle and not pauseMenuOpen then
        if not leaderboardSpawned then                   -- was: L3_2 = L3_1; if not L3_2
          leaderboardSpawned = true                      -- was: L3_1 = true
          spawnLeaderboardProp()                         -- was: L3_2 = L2_1; L3_2()
          UpdateInGameLeaderboard()                      -- was: L3_2 = UpdateInGameLeaderboard; L3_2()
        end
      end
    else
      -- Player walked away — clean up the prop if it exists
      if leaderboardSpawned then                         -- was: L3_2 = L3_1; if L3_2
        if DoesEntityExist(leaderboardProp) then         -- was: L3_2 = DoesEntityExist; L4_2 = leaderboardProp
          DeleteEntity(leaderboardProp)
          leaderboardProp = nil
        end
        leaderboardSpawned = false                       -- was: L3_1 = false
      end
    end
  end
end)

-- =============================================================================
-- === Event: RefreshLeaderboardPaintball ======================================
-- =============================================================================

-- [SERVER→CLIENT] Called by the server after a match ends to push fresh stats
-- to the DUI. Only updates if the prop is currently visible (player is nearby).
RegisterNetEvent("Pug:client:RefreshLeaderboardPaintball", function()  -- was: L4_1, L5_1, L6_1
  if leaderboardSpawned then   -- was: L0_2 = L3_1; if L0_2
    UpdateInGameLeaderboard()  -- was: L0_2 = UpdateInGameLeaderboard; L0_2()
  end
end)
