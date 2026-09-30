if Config.Language ~= "english" then return end
Config.Translations = {
    error = {
        choose_team_first = "You need to join a team first",
        no_lives_entered = "Player lives not entered.",
        max_lives_set = "Maximum lives that can be set is ",
        no_wager = "Wager Amount not entered.",
        wager_cap = "Wager must be between ",
        active_game = "A game is already active",
        ammo_given = "You will recieve a new bullet in 7 seconds",
        cant_do_this = "You cannot do this until you respawn fully",
        no_id_entered = "No id was entered",
        need_to_be_lobby_host = "You need to be lobby host to change this setting",
        daytime_only = "Paintball is closed during the night time...", 
        missing_input = "Missing Input...", 

        you_are_not_in_lobby = "You are not in a lobby.",
        lobby_no_longer_exists = "That lobby no longer exists.",
        cannot_join_down = "You cannot join a game while downed",
        incorrect_passcode = "Incorrect passcode",
        need_to_choose_weapon = "You must choose a weapon before joining a team.",
        team_not_loaded = "Failed to load team.",

        -- SERVER.LUA
        -- Paintball server-side errors / warnings
        only_host_can_start           = "Only the host can start the game.",
        must_join_team_to_start       = "You must join a team before starting the match.",
        game_already_started          = "A game is already started",
        need_players_per_team         = "Needs to be at least 1 player per team",
        not_enough_players_after_prune = "Not enough players on teams after removing unteamed players.",
        stats_reset                   = "ALL GAME STATS HAVE BEEN RESET! A PLAYER DID NOT DISCONNECT PROPERLY",

        player_missing_entry_fee      = "%s is missing %d",
        removed_for_no_team           = "You were removed for not picking a team before the match started.",
        ongoing_game_required_spectate = "A game needs to be ongoing to spectate",
        no_players_in_game            = "There are no players in game",


        -- SV_LOBBY.LUA
        -- Lobby / host / join errors
        no_lobby_specified            = "No lobby specified.",
        lobby_no_longer_exists_refresh = "That lobby no longer exists. Refreshing lobby list...",
        lobby_locked_passcode         = "Lobby is locked. Enter passcode from the Lobby Browser.",
        team_full                     = "Team is full",
        join_failed                   = "Join failed",

        only_host_change_wager        = "Only the host can change the wager.",
        only_host_change_lives        = "Only the host can change lives.",
        only_host_change_map          = "Only the host can change the map.",
        only_host_change_mode         = "Only the host can change the game mode.",
        only_host_change_match_time   = "Only the host can change the match time.",
        only_host_shutdown_lobby      = "Only the host can shut down this lobby.",
        only_host_kick_players        = "Only the host can kick players.",
        only_host_change_waapons        = "Only the host can change the weapons.",

        invalid_map_key               = "Invalid map key.",
        lobby_not_found               = "Lobby not found.",
        player_too_far_for_host       = "This player is too far to be given host of the lobby",
        player_already_host           = "You are already the game host",
        host_removed_far              = "The host was removed for going too far away",
        player_not_found_id           = "Player with ID: [%s] was not found",
        already_hosting_lobby         = "You already host this lobby. Shut it down or transfer host to create another.",
        use_leave_lobby               = "Use Leave Lobby if you want to leave.",
        player_not_in_lobby_anymore   = "That player is no longer in the lobby.",

    },
    success = {
        savedfrinfall = "Don't worry you've been saved king! :)",
        weapon_chosen = "Youve chosen ",
        start_in = "The arena will start in 10 seconds",
        e_open_menu = "[E] OPEN WEAPON MENU",

        removed_from_arena = "You have been removed from the arena area.",

        team_created = "Team created.",
        team_updated = "Team updated.",
        invite_sent = "Invite sent.",
        joined_team = "You joined the team.",
        member_removed = "Member removed.",
        owner_transferred = "Ownership transferred.",
        left_team = "You left the team.",

    },
    menu = {
        -- CLIENT.LUA
        arenalobby = "Paintball Arena Lobby",
        start = "Start",
        players = "Players",
        redteam = "Red Team",
        ffateam = "FFA Lobby",
        blueteam = "Blue Team",
        lives = 'Amount of lives',
        arena_lives = 'Arena Lives',
        wager = 'Wager Amount',
        arena_wager = 'Arena Wager',
        weapon = 'Weapon',
        map = 'Map',
        mode = 'Game Mode',
        spectate = 'Spectate Players',
        random = 'Random',
        pistol_option = 'Small and deadly',
        smg_option = "Lightweight machine guns",
        shotgun_option = 'Heavy close range shotguns',
        assault_option = 'Big boy big gun',
        sniper_option = 'Faze up',
        pistol_header = "Pistol's",
        smg_header = "Smg's",
        shotgun_header = "Shotgun's",
        assault_header = "Assault Rifle's",
        sniper_header = "Sniper Rifle's",
        close_back = "Close (ESC)",
        go_back = "< Go Back",
        player_lives = "Player lives",
        arena_lives = "Arena Lives",
        view_lobby = "View Lobby",
        become_host = "Host Lobby",
        become_hostt_description = "Become host of the lobby",
        give_host = "Transfer Lobby Host",
        give_host_description = "Give lobby host to another player",
        player_id = "(PLAYER ID)",
        host_of_lobby = "Host of the lobby is player ID: [",

        join = "Join ",
        choose = "Choose ",
        respawn_in = "Respawn in ",
        you_respawn_in = "You will respawn in 10 seconds",
        use_uav = "USE UAV",
        use = "USE ",
        removed_lobby_host = "You went to far from the paintball game. Removed as lobby host",

        scoreboard_keybind_desc = "View Paintball Scoreboard",
        red_flag_blip           = "Red Flag",
        blue_flag_blip          = "Blue Flag",

        next_weapon_progress = "(%d/%d) Next weapon will be %s",

        -- DUI_LOGIC.LUA
        -- Paintball leaderboard menu
        lb_ffa_title = "🏆 Free For All",
        lb_ffa_description = "Top players in FFA paintball.",
        lb_ctf_title = "🚩 Capture The Flag",
        lb_ctf_description = "Leaders in flag battles.",
        lb_gungame_title = "🔫 Gun Game",
        lb_gungame_description = "Stats for the gun game mode.",
        lb_oitc_title = "💣 One In The Chamber",
        lb_oitc_description = "Performance in OITC rounds.",
        lb_hyo_title = "🛡️ Hold Your Own",
        lb_hyo_description = "Hold your position leaderboard.",
        lb_tdm_title = "🔥 Team Deathmatch",
        lb_tdm_description = "Team Deathmatch leaderboard.",
        lb_personal_title = "📊 View My Stats",
        lb_personal_description = "Your personal stats in all game modes.",

        -- MENUS.LUA
        -- Hub / lobby list
        team_hub_title = "Team Hub",
        team_hub_description = "Make/Manage/View your global paintball team",
        create_lobby_title = "Create Lobby",
        create_lobby_description = "Make a new paintball lobby (optional passcode)",
        no_lobbies_title = "No lobbies yet",
        no_lobbies_description = "Create one to get started.",
        paintball_lobbies_title = "Paintball Lobbies",

        lobby_list_title = "Lobby [%s] %s %s",
        lobby_list_desc = "Mode: %s | Map: %s | Players: %s",
        lobby_view_title = "Lobby [%s] %s %s",
        -- Create lobby dialog
        create_lobby_header = "Create Lobby",
        lobby_name_label = "Lobby Name",
        lobby_pass_label = "Passcode (optional)",
        must_enter_lobby_name = "You need to create a lobby name",
        -- Passcode dialog
        lobby_locked_title = "Lobby Locked",
        enter_passcode_label = "Enter Passcode",
        -- View lobby base actions
        leave_lobby_title = "Leave Lobby",
        leave_lobby_description = "Exit this lobby and return to the lobby browser.",
        manage_lobby_title = "Manage Lobby",
        manage_lobby_description = "Transfer host, shut down, or set a passcode.",
        leave_prefix = "Leave ",
        -- Rank header in lobby
        rank_header_title = "Prestige %d • Lv. %d (%s)",
        rank_header_desc = "XP this level: %d / %d (Total: %d)",
        -- Match time
        match_time_title = "Match Time",
        match_time_option = "%d minutes",
        match_time_option_description = "End the game after %d minutes.",
        -- Manage lobby submenu
        transfer_host_title = "Transfer Host",
        transfer_host_description = "Give lobby ownership to another player by ID.",
        shutdown_lobby_title = "Shutdown Lobby",
        shutdown_lobby_description = "Kick all players, reset, and delete this lobby.",
        set_passcode_title = "Set Passcode",
        set_passcode_description = "Lock this lobby behind a passcode (blank to clear).",
        kick_player_title = "Kick Player",
        kick_player_description = "Remove a player from this lobby.",
        -- Kick menu
        no_players_to_kick_title = "No players to kick",
        no_players_to_kick_description = "You are currently the only player in this lobby.",
        kick_confirm_title = "Kick %s?",
        kick_confirm_description = "Are you sure you want to kick %s?",
        kick_confirm_body = "They will be removed from this lobby.",
        kick_yes_title = "Yes, kick player",
        kick_yes_description = "Remove %s from the lobby.",
        kick_no_title = "No, go back",
        kick_no_description = "Return to the player list.",
        -- Shutdown confirm dialog
        shutdown_confirm_title = "Are you sure you want to shut down the lobby?",
        shutdown_confirm_description = "All players will be removed and the lobby will be deleted.",
        shutdown_yes_title = "Yes, shut it down",
        shutdown_yes_description = "End the lobby for everyone.",
        shutdown_no_title = "No, go back",
        shutdown_no_description = "Return to lobby management.",
        -- Set passcode dialog
        set_passcode_header = "Set Lobby Passcode",
        passcode_label = "Passcode (leave blank to clear)",
        -- Spectate menu
        exit_spectate_title = "Exit Spectate",
        exit_spectate_description = "Return to your character",
        spectate_player_title = "Player %s",
        spectate_player_description = "ID: %s",
        -- Choose map
        random_map_description = "Randomly chosen maps",

        -- OPEN.LUA
        open_menu_hint             = "[E] To open menu",
        open_menu_hint_view_arena  = "~b~[E] ~w~View Arena",
        ped_text_paintball         = "~o~PAINTBALL",
        blip_paintball             = "Paint Ball",
        target_view_arena_label    = "View Arena",
        submit_text                = "Submit",
        radial_surrender_label     = "Surrender \n Paintball",


        -- TEMAS.LUA
        -- Teams main menu
        teams_menu_title = "Teams",
        create_team_title = "Create Team",
        create_team_desc = "Make a new paintball team.",
        no_team_title = "No Team",
        no_team_desc = "Create a team to invite friends.",
        role_owner = "Owner",
        role_member = "Member",
        role_you = "You",
        members_label = "Members: %d",
        -- Create team dialog
        create_team_header = "Create Team",
        create_team_name = "Team Name",
        create_team_tag = "Tag (optional)",
        create_team_color = "Color Hex (optional)",
        create_team_logo = "Logo URL (optional) [fivemanage.com links only]",
        -- Team creation results
        failed_create_team = "Failed to create team: %s",
        created_team = "Team created.",
        -- Manage team
        manage_members_title = "Manage Members",
        manage_members_desc = "Kick or promote team members.",
        edit_team_title = "Edit Team",
        edit_team_desc = "Name, tag, color, logo.",
        invite_player_title = "Invite Player",
        invite_player_desc = "Invite a player by ID.",
        invite_player_dialog_header = "Invite Player",
        invite_player_id_label = "Player ID",
        leave_team_title = "Leave Team",
        leave_team_desc = "Leave this team.",
        failed_load_team = "Failed to load team.",
        -- Edit team dialog
        edit_team_header = "Edit Team",
        edit_team_field_name = "Name",
        edit_team_field_tag = "Tag",
        edit_team_field_color = "Color Hex",
        edit_team_field_logo = "Logo URL",
        failed_update_team = "Failed to update team: %s",
        updated_team = "Team updated.",
        -- Invite result
        failed_send_invite = "Failed to send invite: %s",
        invite_sent = "Invite sent.",
        -- Invite received popup
        team_invite_title = "Team Invite",
        join_team_title = "Join %s",
        join_team_desc = "Accept invite from %s",
        decline_title = "Decline",
        decline_desc = "Ignore this invite.",
        -- Accept invite
        failed_join_team = "Failed to join team: %s",
        joined_team = "You joined the team.",
        -- Members list
        members_menu_title = "Members • %s",
        member_owner_suffix = " (Owner)",
        member_you_suffix = " (You)",
        -- Manage team member
        promote_member_title = "Promote to Leader",
        promote_member_desc = "Transfer team ownership to %s.",
        kick_member_title = "Kick from Team",
        kick_member_desc = "Remove %s from the team.",
        back_title = "Back",
        back_desc = "Return to members list.",
        -- Kick / promote results
        failed_kick_member = "Failed to kick member: %s",
        member_removed = "Member removed.",
        failed_transfer_owner = "Failed to transfer ownership: %s",
        owner_transferred = "Ownership transferred.",
        -- Leave team results
        failed_leave_team = "Failed to leave team: %s",
        left_team = "You left the team.",
        view_members_title = "View Members",
        view_members_desc  = "See who is in this team.",


        -- SERVER.LUA
        -- Match result / notifications (server-side)
        ffa_timeout_winner   = "%s Won! (time limit)",
        match_draw_timeout   = "Match ended in a draw (time limit).",
        red_team_win_timeout = "Red team won! (time limit)",
        blue_team_win_timeout = "Blue team won! (time limit)",
        red_team_win         = "Red team won!",
        blue_team_win        = "Blue team won!",
        generic_team_win     = "%s team won!",
        ffa_winner           = "%s won!",
        eliminated_message   = "%s has been eliminated!",
        ffa_players_left     = "%d players left in the FFA!",
        players_left_red     = "%d players left on the red team!",
        players_left_blue    = "%d players left on the blue team!",
        host_now             = "You are now the lobby host.",
        removed_unteamed_summary = "Removed %d unteamed player%s before match start.",
        lives_left_message   = "%s has %d lives left",


        -- SV_LOBBY.LUA
        -- FFA mode switching
        ffa_full_spectate        = "FFA is full; you are spectating.",
        ffa_move_fail_spectate   = "Could not move you into FFA; you are spectating.",

        -- Lobby lifecycle
        lobby_shutdown_by_host   = "Lobby [%d] was shut down by host.",
        left_lobby_message       = "You left Lobby [%d].",
        host_now                 = "You are now the lobby host.",

        -- Join / leave notifications
        joined_game_message      = "%s joined the game!",
        joined_red_team_message  = "%s joined the red team!",
        joined_blue_team_message = "%s joined the blue team!",
        left_lobby_announce      = "%s left the lobby!",

        -- Wager / lives / map / mode / match time
        wager_set_prize_pool     = "$%d has been set for the prize pool!",
        lives_set_message        = "%d lives per player has been set!",
        map_set_to               = "Map has been set to %s",
        mode_set_to              = "The Game Mode has been set to %s",
        match_time_set           = "Match time set to %d minutes.",

        -- Passcode
        passcode_set_and_locked   = "Passcode set and lobby locked.",
        passcode_cleared_unlocked = "Passcode cleared and lobby unlocked.",

        -- Lobby create / host
        lobby_created_host       = "Lobby [%d] created. You are the host.",
        already_hosting_lobby    = "You already host Lobby [%d]. Shut it down or transfer host to create another.",

        -- Kick messages
        kicked_from_lobby        = "You were kicked from the lobby by the host.",
        kicked_broadcast         = "%s was kicked from the lobby by the host.",

        -- Lobby gate / misc
        lobby_not_found_msg      = "Lobby not found",
        incorrect_passcode_msg   = "Incorrect passcode",

        -- Members list team labels
        team_red_label           = "Red",
        team_blue_label          = "Blue",
        team_ffa_label           = "FFA",
        team_spectator_label     = "Spectator",
        team_unknown_label       = "Unknown",
        default_player_name      = "Player %d",


        -- GAME MODES
        mode_tdm_title = "Team Deathmatch",
        mode_tdm_description = "12v12 • First team to reach the kill limit wins.",
        mode_hyo_title = "Hold Your Own",
        mode_hyo_description = "12v12 • Survive as long as possible with limited lives.",
        mode_ctf_title = "Capture The Flag",
        mode_ctf_description = "12v12 • Capture the enemy flag three times to win.",
        mode_gungame_title = "Gun Game",
        mode_gungame_description = "Each kill upgrades your weapon. Reach the final weapon to win.",
        mode_ffa_title = "Free For All",
        mode_ffa_description = "Every player for themselves. Hit the kill goal to take the win.",
        mode_oitc_title = "One In The Chamber",
        mode_oitc_description = "Start with one bullet. Each kill earns another. Make every shot count.",


        -- SCOREBOARD HEADERS
        sb_player       = "PLAYER",
        sb_score        = "SCORE",
        sb_kills_short  = "K",
        sb_deaths_short = "D",
        sb_points       = "POINTS",
        sb_lives        = "LIVES",
        sb_ctf          = "CTF",
        sb_kd_ratio     = "KD",

        mode_kc_title = "Kill Confirmed",
        mode_kc_description = "12v12 | Confirm kills by collecting enemy tags, deny by grabbing friendly tags",

        set_team_outfit_male_title   = "Set Male Outfit",
        set_team_outfit_female_title = "Set Female Outfit",

        team_info_title = "How Teams Work",
        team_info_desc  = "Learn how teams, colors, and outfits function",

        team_info_header = "Paintball Teams Guide",

        team_info_how_title = "What Is a Team?",
        team_info_how_desc = "A team is a global paintball group. Members can join matches together and share colors and outfits.",

        team_info_color_title = "Team Colors",
        team_info_color_desc = "If everyone on one side is from the same team, the UI color will match that team's color.",

        team_info_outfits_title = "Team Outfits",
        team_info_outfits_desc = "Team owners can set male and female outfits. These apply automatically when a full team plays on one side.",

        team_info_rules_title = "Important Rules",
        team_info_rules_desc = "• Team names and tags must be unique\n• Tags are limited to 4 characters\n• Mixed teams will NOT use team colors or outfits",


        open_leaderboard = "📋 Open Leaderboard Menu",
        leaderboard_options = "📋 Leaderboard Options",

        lb_kc_title = "Kill Confirmed",
        lb_kc_description = "View the top players for Kill Confirmed",

        -- Jpark
        arena_Jpark_name = "Jurassic Park",
        arena_Jpark_description = "Welcome to Jurassic Park",

        -- Wball
        arena_Wball_name = "Wrecking Ball",
        arena_Wball_description = "Time to wreck some balls",

        -- Syard
        arena_Syard_name = "Scrap Yard 2",
        arena_Syard_description = "Down goes the titan",

        -- Swreck
        arena_Swreck_name = "Ship Wreck",
        arena_Swreck_description = "A ship has been wrecked",

        -- IWhouse
        arena_IWhouse_name = "Industrial Whore House",
        arena_IWhouse_description = "Don’t fall off",

        -- Fpalace
        arena_Fpalace_name = "Future Palace",
        arena_Fpalace_description = "Too futuristic, no cover",

        -- Tsoldier
        arena_Tsoldier_name = "Toy Soldier",
        arena_Tsoldier_description = "Little man in a big world",

        -- Tcity
        arena_Tcity_name = "Tire City",
        arena_Tcity_description = "Not that Tire City",

        -- WITpark
        arena_WITpark_name = "Walk in the Park",
        arena_WITpark_description = "Tire Park City",

        -- Ttown
        arena_Ttown_name = "Tube Town",
        arena_Ttown_description = "Tube City Town",

        -- UConstruction
        arena_UConstruction_name = "Uptown Construction",
        arena_UConstruction_description = "Construction site chaos",

        -- Gstreet
        arena_Gstreet_name = "Grove Street",
        arena_Gstreet_description = "Who’s running the block?",

        -- Scity
        arena_Scity_name = "Stab City",
        arena_Scity_description = "Trailer park mayhem",

        -- RSyard
        arena_RSyard_name = "Reds Salvage Yard",
        arena_RSyard_description = "Rust, scrap, and chaos",

        -- Ghouse
        arena_Ghouse_name = "Grandma’s House",
        arena_Ghouse_description = "She makes the best cookies",

        -- GCVilliage
        arena_GCVilliage_name = "Great Camp Village",
        arena_GCVilliage_description = "Watch your step",

        -- Highjacked
        arena_Highjacked_name = "Highjacked",
        arena_Highjacked_description = "Try not to get seasick",

        -- DTDocks
        arena_DTDocks_name = "Downtown Docks",
        arena_DTDocks_description = "What happens on the docks stays on the docks",

        -- ORats
        arena_ORats_name = "Oil Rats",
        arena_ORats_description = "Covered in grease and oil",

        -- HRise
        arena_HRise_name = "High Rise",
        arena_HRise_description = "Not for the afraid of heights",


        -- Gabz / Indoor
        arena_IDarena_name = "Indoor Arena",
        arena_IDarena_description = "Red vs Blue",

        arena_IDderby_name = "Indoor Derby",
        arena_IDderby_description = "Meant for cars… but you know",

        -- Nuketown
        arena_Narena_name = "Nuketown Arena",
        arena_Narena_description = "Classic Nuketown",

        arena_NMpark_name = "Nuketown Mirror Park",
        arena_NMpark_description = "Nuketown in the city",

    },
}
