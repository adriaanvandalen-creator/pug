-- FULL MAP MAKING TUTORIAL HERE: https://youtu.be/wALLIIaNoPE (If you make any more new maps please share them in pugs discord in the snippet section. THank you!)
---------- [STRINGS] ----------
Config.Language = "english" -- spanish, chinese, french, polish, japanese, english
Config.KillFeedPosition = "middle-right" -- Kill feed location: top-left, top-right, bottom-left, bottom-right, middle-left, middle-right
Config.Currency = "bank" -- Currency used for buy-ins and payouts (cash, bank, or crypto)
Config.PaintballBusinessName = "paintball" -- Job name that receives paintball business revenue (ignore if not using business mode)
Config.ScoreBoardCommand = 'pballboard' -- Command to open the scoreboard during a match
Config.ScoreBoardKeyBind = 'G' -- Keybind to open the scoreboard during a match
Config.SurrenderCommand = 'surrenderpaintball' -- Command used to surrender and exit a match early
Config.BombSiteModel = 'xm_prop_crates_weapon_mix_01a' -- Model for S&D bomb sites (unused since the mode was removed)
Config.OneInTheChamberWeapon = "weapon_pistol" -- Weapon given in One in the Chamber
Config.SpecailWeaponItem = "weapon_minigun" -- Special weapon rewarded for the configured kill streak
Config.RedOutfitCommand = "redoutfit" -- Admin command to save current outfit as the Red Team uniform (set male/female by ped model)
Config.BlueOutfitCommand = "blueoutfit" -- Admin command to save current outfit as the Blue Team uniform (set male/female by ped model)
Config.KCTagModel = "xm3_prop_xm3_toy_dog_01a" -- Prop model used for dropped kill tags
---------- [INTAGERS] ----------
Config.MaxKCScore = 15                 -- Number of confirmed tags required for a team to win the match
Config.KCTagLifetimeSeconds = 45       -- Time (in seconds) before a dropped tag despawns if not collected
Config.KCTagPickupRadius = 2.0         -- Distance (in meters) required to pick up or deny a kill tag
Config.MaxTeamNameLength = 10       -- Maximum number of characters allowed for a team name
Config.MaxTeamClanTagLength = 4     -- Maximum number of characters allowed for a team clan tag
Config.MinTeamPlayersToRewardXP = 1 -- Minimum total players required for XP rewards; prevents low-player boosting (i would make this 5 or more, this is 1 for dev testing)
Config.MaxTDMScore = 15 -- Score needed for a team to win Team Deathmatch
Config.MaxFFAScore = 15 -- Kills required to win Free-For-All, Gun Game, and One in the Chamber
Config.MaxLives = 7 -- Max lives allowed in Hold Your Own
Config.MinWager = 0 -- Minimum bet players can place on a match
Config.MaxWager = 25000 -- Maximum bet players can place on a match
Config.MaxTeam = 12 -- Do not change; reserved for future expansion beyond 24-player support
Config.UavKillstreak = 3 -- Kills needed without dying to earn a UAV
Config.SpecialWeaponKillsStreak = 5 -- Kills needed without dying to earn the special weapon reward
Config.PassiveModeCoolDownWaitTime = 3 -- Seconds a player stays in passive mode after respawn
Config.ArmorAmountGivenToPlayer = 0 -- Armor value (0–100) given to players each time they spawn
Config.GameTimerLimitOptions = { 5, 15, 20, 25, 30, 40, 60 } -- Match time-limit options (in minutes)
---------- [BOOLS] ----------
Config.Debug = false -- Enables debug polys for zones and debug prints
Config.EnableWager = true -- Enables the wager menu option and ability for people to bet games against one another
Config.PlayCameraAnimationOnPed = false -- Enables the camera animation when viewing the paintball lobby menus
Config.SetPlayersRadios = true -- Automatically assigns players to their team radio channels at game start
Config.GivePlayerRadio = true -- Gives the player a radio or not
Config.RestrictPaintballToDayTimeOnly = false -- Restricts paintball to daytime only when true
Config.SetUnlimitedSprint = true -- Disable this to remove unlimited sprint
Config.GiveFullHealthOnkill = true -- Disable if players should NOT be healed to full on kill
Config.HostOnlyCanControllWeaponSelect = true -- When true, only the host can adjust weapons and settings pre-game
Config.EnableKillStreaks = true -- Disable to turn off all killstreak features
Config.UavAlwaysOnDuringFFA = true -- Disable if FFA should NOT have a constant UAV
Config.RequireAdminToStartGame = false -- When true, only admins can start a battle royale game
Config.RequirePlayersOnBothTeams = false -- Requires at least one player per team to start when true
Config.CanChooseGunMidGame = false -- Disable if players should NOT be able to swap weapons mid-match
Config.SpectateEnabled = true -- Disable to remove the spectate option entirely
Config.LockInventory = true -- Locks players' inventories for the duration of a match
Config.MakeCloneOfPlayer = false -- Creates a clone of the player at their position when enabled (only works if you have pug-battleroyale)
Config.UseVrHeadSet = false -- Enable when using VR headsets instead of peds (requires your BR script)
Config.PaintballIsABusiness = false -- Sends 15% of wagers to the business account when enabled (QB-Core only)
Config.EnableGTA5Crosshair = true -- Disable to hide GTA V’s default crosshair during matches
Config.UsingCrossHairByDefault = false -- Enable if your server always uses crosshairs by default
Config.DoScreenFadeOut = true -- Fades the screen out at the end of the match
Config.WeaponHandWatchdog = false -- Re-gives the match weapon if you end up unarmed / blocks hands-up; can make the weapon flicker with ox_inventory
------------------------------
Config.PedLocation = vector4(-1283.4, -299.2, 35.04, 180.0) -- Location of the ped players interact with to join the game
Config.ArenaPed = 'u_m_y_pogo_01' -- Model used for the join-game ped
------------------------------
Config.LeaderboardLocation = vector4(-1284.1, -300.2, 35.04, 90.0) -- World location of the physical leaderboard display
------------------------------
Config.WhitelistedCIDsToStartGame = { -- Add CIDs (QB-Core) or identifiers (ESX) allowed to start games; leave empty for no whitelist
    -- "EJD97814",
}
------------------------------
-- "/redoutfit" and "/blueoutfit" are the commands to save the current outfit you are wearing as each teams outfit. To set the girls outfit you need to be the female model and vice versa.
------------------------------
------------------------------
-- Backup starting ped & scoreboard location if you do not have the int_arcade mlo installed
Config.BackupPedLocation = vector4(246.3549, -810.2741, 30.2237, 59.9826) -- Backup Location of the ped players interact with to join the game if you do not have the int_arcade mlo installed
Config.BackupLeaderboardLocation = vector4(246.9448, -812.9821, 30.1616, 69.5782) -- Backup World location of the physical leaderboard display if you do not have the int_arcade mlo installed