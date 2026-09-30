if Config.Language ~= "french" then return end
Config.Translations = {
    error = {
        choose_team_first = "Vous devez d'abord rejoindre une équipe",
        no_lives_entered = "Nombre de vies du joueur non renseigné.",
        max_lives_set = "Le nombre maximum de vies est ",
        no_wager = "Montant du pari non renseigné.",
        wager_cap = "Le pari doit être compris entre ",
        active_game = "Une partie est déjà active",
        ammo_given = "Vous recevrez une nouvelle balle dans 7 secondes",
        cant_do_this = "Vous ne pouvez pas faire ça tant que vous n'êtes pas complètement réapparu",
        no_id_entered = "Aucun ID n'a été saisi",
        need_to_be_lobby_host = "Vous devez être l'hôte du lobby pour changer ce paramètre",
        daytime_only = "Le paintball est fermé la nuit...",
        missing_input = "Entrée manquante...",

        you_are_not_in_lobby = "Vous n'êtes pas dans un lobby.",
        lobby_no_longer_exists = "Ce lobby n'existe plus.",
        cannot_join_down = "Vous ne pouvez pas rejoindre une partie en étant à terre",
        incorrect_passcode = "Code d'accès incorrect",
        need_to_choose_weapon = "Vous devez choisir une arme avant de rejoindre une équipe.",
        team_not_loaded = "Échec du chargement de l'équipe.",

        -- SERVER.LUA
        -- Paintball server-side errors / warnings
        only_host_can_start            = "Seul l'hôte peut démarrer la partie.",
        must_join_team_to_start        = "Vous devez rejoindre une équipe avant de lancer le match.",
        game_already_started           = "Une partie est déjà démarrée",
        need_players_per_team          = "Il faut au moins 1 joueur par équipe",
        not_enough_players_after_prune = "Pas assez de joueurs dans les équipes après suppression des joueurs sans équipe.",
        stats_reset                    = "TOUTES LES STATS ONT ÉTÉ RÉINITIALISÉES ! UN JOUEUR NE S'EST PAS DÉCONNECTÉ CORRECTEMENT",

        player_missing_entry_fee       = "%s n'a pas %d",
        removed_for_no_team            = "Vous avez été retiré car vous n'avez pas choisi d'équipe avant le début du match.",
        ongoing_game_required_spectate = "Une partie doit être en cours pour spectater",
        no_players_in_game             = "Il n'y a aucun joueur en jeu",

        -- SV_LOBBY.LUA
        -- Lobby / host / join errors
        no_lobby_specified             = "Aucun lobby spécifié.",
        lobby_no_longer_exists_refresh = "Ce lobby n'existe plus. Actualisation de la liste...",
        lobby_locked_passcode          = "Lobby verrouillé. Entrez le code depuis le navigateur de lobbies.",
        team_full                      = "L'équipe est pleine",
        join_failed                    = "Échec de la connexion",

        only_host_change_wager         = "Seul l'hôte peut modifier le pari.",
        only_host_change_lives         = "Seul l'hôte peut modifier les vies.",
        only_host_change_map           = "Seul l'hôte peut modifier la carte.",
        only_host_change_mode          = "Seul l'hôte peut modifier le mode de jeu.",
        only_host_change_match_time    = "Seul l'hôte peut modifier la durée du match.",
        only_host_shutdown_lobby       = "Seul l'hôte peut fermer ce lobby.",
        only_host_kick_players         = "Seul l'hôte peut expulser des joueurs.",
        only_host_change_waapons = "Seul l’hôte peut changer les armes.",

        invalid_map_key                = "Clé de carte invalide.",
        lobby_not_found                = "Lobby introuvable.",
        player_too_far_for_host        = "Ce joueur est trop loin pour recevoir l'hôte du lobby",
        player_already_host            = "Vous êtes déjà l'hôte de la partie",
        host_removed_far               = "L'hôte a été retiré car il est allé trop loin",
        player_not_found_id            = "Joueur avec l'ID : [%s] introuvable",
        already_hosting_lobby          = "Vous hébergez déjà ce lobby. Fermez-le ou transférez l'hôte pour en créer un autre.",
        use_leave_lobby                = "Utilisez Quitter le lobby si vous voulez partir.",
        player_not_in_lobby_anymore    = "Ce joueur n'est plus dans le lobby.",
    },

    success = {
        savedfrinfall = "T'inquiète, on t'a sauvé roi ! :)",
        weapon_chosen = "Vous avez choisi ",
        start_in = "L'arène commencera dans 10 secondes",
        e_open_menu = "[E] OUVRIR LE MENU DES ARMES",

        removed_from_arena = "Vous avez été retiré de la zone de l'arène.",

        team_created = "Équipe créée.",
        team_updated = "Équipe mise à jour.",
        invite_sent = "Invitation envoyée.",
        joined_team = "Vous avez rejoint l'équipe.",
        member_removed = "Membre retiré.",
        owner_transferred = "Propriété transférée.",
        left_team = "Vous avez quitté l'équipe.",
    },

    menu = {
        -- CLIENT.LUA
        arenalobby = "Lobby de l'arène Paintball",
        start = "Démarrer",
        players = "Joueurs",
        redteam = "Équipe Rouge",
        ffateam = "Lobby FFA",
        blueteam = "Équipe Bleue",
        lives = "Nombre de vies",
        arena_lives = "Vies de l'arène",
        wager = "Montant du pari",
        arena_wager = "Pari de l'arène",
        weapon = "Arme",
        map = "Carte",
        mode = "Mode de jeu",
        spectate = "Spectater les joueurs",
        random = "Aléatoire",
        pistol_option = "Petit et mortel",
        smg_option = "Mitraillettes légères",
        shotgun_option = "Fusils à pompe lourds à courte portée",
        assault_option = "Gros calibre",
        sniper_option = "Mode sniper",
        pistol_header = "Pistolets",
        smg_header = "SMG",
        shotgun_header = "Fusils à pompe",
        assault_header = "Fusils d'assaut",
        sniper_header = "Fusils de précision",
        close_back = "Fermer (ESC)",
        go_back = "< Retour",
        player_lives = "Vies du joueur",
        arena_lives = "Vies de l'arène",
        view_lobby = "Voir le lobby",
        become_host = "Héberger le lobby",
        become_hostt_description = "Devenir l'hôte du lobby",
        give_host = "Transférer l'hôte du lobby",
        give_host_description = "Donner l'hôte du lobby à un autre joueur",
        player_id = "(ID JOUEUR)",
        host_of_lobby = "L'hôte du lobby est le joueur ID : [",

        join = "Rejoindre ",
        choose = "Choisir ",
        respawn_in = "Réapparition dans ",
        you_respawn_in = "Vous réapparaîtrez dans 10 secondes",
        use_uav = "UTILISER UAV",
        use = "UTILISER ",
        removed_lobby_host = "Vous êtes allé trop loin du paintball. Retiré en tant qu'hôte du lobby",

        scoreboard_keybind_desc = "Voir le tableau des scores Paintball",
        red_flag_blip = "Drapeau Rouge",
        blue_flag_blip = "Drapeau Bleu",

        next_weapon_progress = "(%d/%d) Prochaine arme : %s",

        -- DUI_LOGIC.LUA
        -- Paintball leaderboard menu
        lb_ffa_title = "🏆 Free For All",
        lb_ffa_description = "Meilleurs joueurs en FFA paintball.",
        lb_ctf_title = "🚩 Capture The Flag",
        lb_ctf_description = "Leaders des combats de drapeau.",
        lb_gungame_title = "🔫 Gun Game",
        lb_gungame_description = "Stats du mode Gun Game.",
        lb_oitc_title = "💣 One In The Chamber",
        lb_oitc_description = "Performance en manches OITC.",
        lb_hyo_title = "🛡️ Hold Your Own",
        lb_hyo_description = "Classement Hold Your Own.",
        lb_tdm_title = "🔥 Team Deathmatch",
        lb_tdm_description = "Classement Team Deathmatch.",
        lb_personal_title = "📊 Voir mes stats",
        lb_personal_description = "Vos stats personnelles dans tous les modes.",

        -- MENUS.LUA
        -- Hub / lobby list
        team_hub_title = "Hub d'équipe",
        team_hub_description = "Créer/Gérer/Voir votre équipe paintball globale",
        create_lobby_title = "Créer un lobby",
        create_lobby_description = "Créer un nouveau lobby paintball (code optionnel)",
        no_lobbies_title = "Aucun lobby pour l'instant",
        no_lobbies_description = "Créez-en un pour commencer.",
        paintball_lobbies_title = "Lobbies Paintball",

        lobby_list_title = "Lobby [%s] %s %s",
        lobby_list_desc = "Mode : %s | Carte : %s | Joueurs : %s",
        lobby_view_title = "Lobby [%s] %s %s",
        -- Create lobby dialog
        create_lobby_header = "Créer un lobby",
        lobby_name_label = "Nom du lobby (optionnel)",
        lobby_pass_label = "Code d'accès (optionnel)",
        must_enter_lobby_name = "Vous devez entrer un nom de lobby",
        -- Passcode dialog
        lobby_locked_title = "Lobby verrouillé",
        enter_passcode_label = "Entrer le code",
        -- View lobby base actions
        leave_lobby_title = "Quitter le lobby",
        leave_lobby_description = "Quitter ce lobby et revenir au navigateur de lobbies.",
        manage_lobby_title = "Gérer le lobby",
        manage_lobby_description = "Transférer l'hôte, fermer, ou définir un code.",
        leave_prefix = "Quitter ",
        -- Rank header in lobby
        rank_header_title = "Prestige %d • Niv. %d (%s)",
        rank_header_desc = "XP à ce niveau : %d / %d (Total : %d)",
        -- Match time
        match_time_title = "Durée du match",
        match_time_option = "%d minutes",
        match_time_option_description = "Terminer la partie après %d minutes.",
        -- Manage lobby submenu
        transfer_host_title = "Transférer l'hôte",
        transfer_host_description = "Donner la propriété du lobby à un autre joueur via ID.",
        shutdown_lobby_title = "Fermer le lobby",
        shutdown_lobby_description = "Expulser tout le monde, réinitialiser et supprimer ce lobby.",
        set_passcode_title = "Définir un code",
        set_passcode_description = "Verrouiller ce lobby avec un code (vide pour effacer).",
        kick_player_title = "Expulser un joueur",
        kick_player_description = "Retirer un joueur de ce lobby.",
        -- Kick menu
        no_players_to_kick_title = "Aucun joueur à expulser",
        no_players_to_kick_description = "Vous êtes actuellement le seul joueur dans ce lobby.",
        kick_confirm_title = "Expulser %s ?",
        kick_confirm_description = "Êtes-vous sûr de vouloir expulser %s ?",
        kick_confirm_body = "Il sera retiré de ce lobby.",
        kick_yes_title = "Oui, expulser le joueur",
        kick_yes_description = "Retirer %s du lobby.",
        kick_no_title = "Non, retour",
        kick_no_description = "Retourner à la liste des joueurs.",
        -- Shutdown confirm dialog
        shutdown_confirm_title = "Êtes-vous sûr de vouloir fermer le lobby ?",
        shutdown_confirm_description = "Tous les joueurs seront retirés et le lobby sera supprimé.",
        shutdown_yes_title = "Oui, fermer",
        shutdown_yes_description = "Mettre fin au lobby pour tout le monde.",
        shutdown_no_title = "Non, retour",
        shutdown_no_description = "Retourner à la gestion du lobby.",
        -- Set passcode dialog
        set_passcode_header = "Définir le code du lobby",
        passcode_label = "Code (laisser vide pour effacer)",
        -- Spectate menu
        exit_spectate_title = "Quitter le mode spectateur",
        exit_spectate_description = "Retourner à votre personnage",
        spectate_player_title = "Joueur %s",
        spectate_player_description = "ID : %s",
        -- Choose map
        random_map_description = "Cartes choisies aléatoirement",

        -- OPEN.LUA
        open_menu_hint = "[E] Ouvrir le menu",
        open_menu_hint_view_arena = "~b~[E] ~w~Voir l'arène",
        ped_text_paintball = "~o~PAINTBALL",
        blip_paintball = "Paint Ball",
        target_view_arena_label = "Voir l'arène",
        submit_text = "Valider",
        radial_surrender_label = "Abandonner \n Paintball",

        -- TEMAS.LUA
        -- Teams main menu
        teams_menu_title = "Équipes",
        create_team_title = "Créer une équipe",
        create_team_desc = "Créer une nouvelle équipe paintball.",
        no_team_title = "Aucune équipe",
        no_team_desc = "Créez une équipe pour inviter des amis.",
        role_owner = "Propriétaire",
        role_member = "Membre",
        role_you = "Vous",
        members_label = "Membres : %d",
        -- Create team dialog
        create_team_header = "Créer une équipe",
        create_team_name = "Nom de l'équipe",
        create_team_tag = "Tag (optionnel)",
        create_team_color = "Couleur Hex (optionnel)",
        create_team_logo = "URL du logo (optionnel) [liens fivemanage.com uniquement]",
        -- Team creation results
        failed_create_team = "Échec de création de l'équipe : %s",
        created_team = "Équipe créée.",
        -- Manage team
        manage_members_title = "Gérer les membres",
        manage_members_desc = "Expulser ou promouvoir des membres.",
        edit_team_title = "Modifier l'équipe",
        edit_team_desc = "Nom, tag, couleur, logo.",
        invite_player_title = "Inviter un joueur",
        invite_player_desc = "Inviter un joueur via ID.",
        invite_player_dialog_header = "Inviter un joueur",
        invite_player_id_label = "ID du joueur",
        leave_team_title = "Quitter l'équipe",
        leave_team_desc = "Quitter cette équipe.",
        failed_load_team = "Échec du chargement de l'équipe.",
        -- Edit team dialog
        edit_team_header = "Modifier l'équipe",
        edit_team_field_name = "Nom",
        edit_team_field_tag = "Tag",
        edit_team_field_color = "Couleur Hex",
        edit_team_field_logo = "URL du logo",
        failed_update_team = "Échec de mise à jour : %s",
        updated_team = "Équipe mise à jour.",
        -- Invite result
        failed_send_invite = "Échec d'envoi de l'invitation : %s",
        invite_sent = "Invitation envoyée.",
        -- Invite received popup
        team_invite_title = "Invitation d'équipe",
        join_team_title = "Rejoindre %s",
        join_team_desc = "Accepter l'invitation de %s",
        decline_title = "Refuser",
        decline_desc = "Ignorer cette invitation.",
        -- Accept invite
        failed_join_team = "Échec pour rejoindre l'équipe : %s",
        joined_team = "Vous avez rejoint l'équipe.",
        -- Members list
        members_menu_title = "Membres • %s",
        member_owner_suffix = " (Propriétaire)",
        member_you_suffix = " (Vous)",
        -- Manage team member
        promote_member_title = "Promouvoir en leader",
        promote_member_desc = "Transférer la propriété de l'équipe à %s.",
        kick_member_title = "Expulser de l'équipe",
        kick_member_desc = "Retirer %s de l'équipe.",
        back_title = "Retour",
        back_desc = "Retourner à la liste des membres.",
        -- Kick / promote results
        failed_kick_member = "Échec d'expulsion : %s",
        member_removed = "Membre retiré.",
        failed_transfer_owner = "Échec du transfert de propriété : %s",
        owner_transferred = "Propriété transférée.",
        -- Leave team results
        failed_leave_team = "Échec pour quitter l'équipe : %s",
        left_team = "Vous avez quitté l'équipe.",
        view_members_title = "Voir les membres",
        view_members_desc = "Voir qui est dans cette équipe.",

        -- SERVER.LUA
        -- Match result / notifications (server-side)
        ffa_timeout_winner = "%s a gagné ! (limite de temps)",
        match_draw_timeout = "Match terminé sur un match nul (limite de temps).",
        red_team_win_timeout = "L'équipe rouge a gagné ! (limite de temps)",
        blue_team_win_timeout = "L'équipe bleue a gagné ! (limite de temps)",
        red_team_win = "L'équipe rouge a gagné !",
        blue_team_win = "L'équipe bleue a gagné !",
        generic_team_win = "L'équipe %s a gagné !",
        ffa_winner = "%s a gagné !",
        eliminated_message = "%s a été éliminé !",
        ffa_players_left = "%d joueurs restants en FFA !",
        players_left_red = "%d joueurs restants dans l'équipe rouge !",
        players_left_blue = "%d joueurs restants dans l'équipe bleue !",
        host_now = "Vous êtes maintenant l'hôte du lobby.",
        removed_unteamed_summary = "Suppression de %d joueur%s sans équipe avant le début.",
        lives_left_message = "%s a %d vies restantes",

        -- SV_LOBBY.LUA
        -- FFA mode switching
        ffa_full_spectate = "FFA est plein ; vous êtes en mode spectateur.",
        ffa_move_fail_spectate = "Impossible de vous déplacer en FFA ; vous êtes en mode spectateur.",

        -- Lobby lifecycle
        lobby_shutdown_by_host = "Le lobby [%d] a été fermé par l'hôte.",
        left_lobby_message = "Vous avez quitté le lobby [%d].",
        host_now = "Vous êtes maintenant l'hôte du lobby.",

        -- Join / leave notifications
        joined_game_message = "%s a rejoint la partie !",
        joined_red_team_message = "%s a rejoint l'équipe rouge !",
        joined_blue_team_message = "%s a rejoint l'équipe bleue !",
        left_lobby_announce = "%s a quitté le lobby !",

        -- Wager / lives / map / mode / match time
        wager_set_prize_pool = "$%d a été défini pour la cagnotte !",
        lives_set_message = "%d vies par joueur ont été définies !",
        map_set_to = "La carte a été définie sur %s",
        mode_set_to = "Le mode de jeu a été défini sur %s",
        match_time_set = "Durée du match définie à %d minutes.",

        -- Passcode
        passcode_set_and_locked = "Code défini et lobby verrouillé.",
        passcode_cleared_unlocked = "Code effacé et lobby déverrouillé.",

        -- Lobby create / host
        lobby_created_host = "Lobby [%d] créé. Vous êtes l'hôte.",
        already_hosting_lobby = "Vous hébergez déjà le lobby [%d]. Fermez-le ou transférez l'hôte pour en créer un autre.",

        -- Kick messages
        kicked_from_lobby = "Vous avez été expulsé du lobby par l'hôte.",
        kicked_broadcast = "%s a été expulsé du lobby par l'hôte.",

        -- Lobby gate / misc
        lobby_not_found_msg = "Lobby introuvable",
        incorrect_passcode_msg = "Code incorrect",

        -- Members list team labels
        team_red_label = "Rouge",
        team_blue_label = "Bleu",
        team_ffa_label = "FFA",
        team_spectator_label = "Spectateur",
        team_unknown_label = "Inconnu",
        default_player_name = "Joueur %d",

        -- GAME MODES
        mode_tdm_title = "Team Deathmatch",
        mode_tdm_description = "12v12 • La première équipe à atteindre la limite de kills gagne.",
        mode_hyo_title = "Hold Your Own",
        mode_hyo_description = "12v12 • Survivez le plus longtemps possible avec des vies limitées.",
        mode_ctf_title = "Capture The Flag",
        mode_ctf_description = "12v12 • Capturez le drapeau ennemi trois fois pour gagner.",
        mode_gungame_title = "Gun Game",
        mode_gungame_description = "Chaque kill améliore votre arme. Atteignez la dernière pour gagner.",
        mode_ffa_title = "Free For All",
        mode_ffa_description = "Chacun pour soi. Atteignez l'objectif de kills pour gagner.",
        mode_oitc_title = "One In The Chamber",
        mode_oitc_description = "Commencez avec une balle. Chaque kill en donne une. Faites compter chaque tir.",

        -- SCOREBOARD HEADERS
        sb_player = "JOUEUR",
        sb_score = "SCORE",
        sb_kills_short = "K",
        sb_deaths_short = "M",
        sb_points = "POINTS",
        sb_lives = "VIES",
        sb_ctf = "CTF",
        sb_kd_ratio = "KD",

        mode_kc_title = "Kill Confirmed",
        mode_kc_description = "12v12 | Confirmez les kills en récupérant les tags ennemis, et refusez en prenant ceux des alliés",

        set_team_outfit_male_title = "Définir la tenue homme",
        set_team_outfit_female_title = "Définir la tenue femme",

        team_info_title = "Comment fonctionnent les équipes",
        team_info_desc = "Apprenez le fonctionnement des équipes, des couleurs et des tenues",

        team_info_header = "Guide des équipes Paintball",

        team_info_how_title = "Qu'est-ce qu'une équipe ?",
        team_info_how_desc = "Une équipe est un groupe global de paintball. Les membres peuvent rejoindre des matchs ensemble et partager des couleurs et des tenues.",

        team_info_color_title = "Couleurs d'équipe",
        team_info_color_desc = "Si tout un camp est composé du même team, la couleur de l'UI correspondra à celle de l'équipe.",

        team_info_outfits_title = "Tenues d'équipe",
        team_info_outfits_desc = "Les propriétaires d'équipe peuvent définir des tenues homme et femme. Elles s'appliquent automatiquement quand une équipe complète joue d'un côté.",

        team_info_rules_title = "Règles importantes",
        team_info_rules_desc = "• Les noms et tags d'équipe doivent être uniques\n• Les tags sont limités à 4 caractères\n• Les équipes mixtes n'utiliseront PAS les couleurs ou tenues",

        open_leaderboard = "📋 Ouvrir le menu des classements",
        leaderboard_options = "📋 Options du classement",

        lb_kc_title = "Élimination confirmée",
        lb_kc_description = "Voir les meilleurs joueurs en Élimination confirmée",

                -- Jpark
        arena_Jpark_name = "Parc Jurassique",
        arena_Jpark_description = "Bienvenue à Jurassic Park",

        -- Wball
        arena_Wball_name = "Boule de Démolition",
        arena_Wball_description = "Il est temps de tout détruire",

        -- Syard
        arena_Syard_name = "Dépotoir 2",
        arena_Syard_description = "Le titan s’effondre",

        -- Swreck
        arena_Swreck_name = "Épave",
        arena_Swreck_description = "Un navire s’est échoué",

        -- IWhouse
        arena_IWhouse_name = "Bâtiment Industriel",
        arena_IWhouse_description = "Ne tombez pas",

        -- Fpalace
        arena_Fpalace_name = "Palais du Futur",
        arena_Fpalace_description = "Trop futuriste, aucune couverture",

        -- Tsoldier
        arena_Tsoldier_name = "Soldat de Jouet",
        arena_Tsoldier_description = "Un petit homme dans un grand monde",

        -- Tcity
        arena_Tcity_name = "Ville des Pneus",
        arena_Tcity_description = "Ce n’est pas cette Ville des Pneus",

        -- WITpark
        arena_WITpark_name = "Promenade au Parc",
        arena_WITpark_description = "Parc de la Ville des Pneus",

        -- Ttown
        arena_Ttown_name = "Ville des Tubes",
        arena_Ttown_description = "La cité des tubes",

        -- UConstruction
        arena_UConstruction_name = "Construction Uptown",
        arena_UConstruction_description = "Chaos sur le chantier",

        -- Gstreet
        arena_Gstreet_name = "Grove Street",
        arena_Gstreet_description = "Qui contrôle le quartier ?",

        -- Scity
        arena_Scity_name = "Stab City",
        arena_Scity_description = "Chaos du parc de caravanes",

        -- RSyard
        arena_RSyard_name = "Dépotoir de Reds",
        arena_RSyard_description = "Rouille, ferraille et chaos",

        -- Ghouse
        arena_Ghouse_name = "Maison de Grand-Mère",
        arena_Ghouse_description = "Elle fait les meilleurs cookies",

        -- GCVilliage
        arena_GCVilliage_name = "Grand Village du Camp",
        arena_GCVilliage_description = "Attention où vous mettez les pieds",

        -- Highjacked
        arena_Highjacked_name = "Détourné",
        arena_Highjacked_description = "Essayez de ne pas avoir le mal de mer",

        -- DTDocks
        arena_DTDocks_name = "Quais du Centre-Ville",
        arena_DTDocks_description = "Ce qui se passe sur les quais reste sur les quais",

        -- ORats
        arena_ORats_name = "Rats du Pétrole",
        arena_ORats_description = "Couvert de graisse et d’huile",

        -- HRise
        arena_HRise_name = "Gratte-Ciel",
        arena_HRise_description = "Déconseillé aux personnes ayant le vertige",


        -- Gabz / Indoor
        arena_IDarena_name = "Arène Intérieure",
        arena_IDarena_description = "Rouge contre Bleu",

        arena_IDderby_name = "Derby Intérieur",
        arena_IDderby_description = "Prévu pour les voitures… enfin presque",

        -- Nuketown
        arena_Narena_name = "Arène Nuketown",
        arena_Narena_description = "Nuketown classique",

        arena_NMpark_name = "Nuketown Mirror Park",
        arena_NMpark_description = "Nuketown en ville",


    },
}
