if Config.Language ~= "polish" then return end
Config.Translations = {
    error = {
        choose_team_first = "Najpierw musisz dołączyć do drużyny",
        no_lives_entered = "Nie podano liczby żyć.",
        max_lives_set = "Maksymalna liczba żyć to ",
        no_wager = "Nie podano kwoty zakładu.",
        wager_cap = "Zakład musi mieścić się w przedziale ",
        active_game = "Gra jest już aktywna",
        ammo_given = "Nowy nabój otrzymasz za 7 sekund",
        cant_do_this = "Nie możesz tego zrobić, dopóki w pełni się nie odrodzisz",
        no_id_entered = "Nie podano ID",
        need_to_be_lobby_host = "Musisz być gospodarzem lobby, aby zmienić to ustawienie",
        daytime_only = "Paintball jest zamknięty w nocy...", 
        missing_input = "Brak danych...", 

        you_are_not_in_lobby = "Nie jesteś w lobby.",
        lobby_no_longer_exists = "To lobby już nie istnieje.",
        cannot_join_down = "Nie możesz dołączyć do gry będąc powalonym",
        incorrect_passcode = "Nieprawidłowy kod dostępu",
        need_to_choose_weapon = "Musisz wybrać broń przed dołączeniem do drużyny.",
        team_not_loaded = "Nie udało się załadować drużyny.",

        -- SERVER.LUA
        -- Paintball server-side errors / warnings
        only_host_can_start           = "Tylko gospodarz może rozpocząć grę.",
        must_join_team_to_start       = "Musisz dołączyć do drużyny przed rozpoczęciem meczu.",
        game_already_started          = "Gra już się rozpoczęła",
        need_players_per_team         = "W każdej drużynie musi być co najmniej 1 gracz",
        not_enough_players_after_prune = "Za mało graczy w drużynach po usunięciu nieprzypisanych.",
        stats_reset                   = "WSZYSTKIE STATYSTYKI GRY ZOSTAŁY ZRESETOWANE! GRACZ NIE ROZŁĄCZYŁ SIĘ PRAWIDŁOWO",

        player_missing_entry_fee      = "%s brakuje %d",
        removed_for_no_team           = "Zostałeś usunięty za brak wyboru drużyny przed startem.",
        ongoing_game_required_spectate = "Aby obserwować, gra musi trwać",
        no_players_in_game            = "Brak graczy w grze",


        -- SV_LOBBY.LUA
        -- Lobby / host / join errors
        no_lobby_specified            = "Nie wybrano lobby.",
        lobby_no_longer_exists_refresh = "Lobby już nie istnieje. Odświeżanie listy...",
        lobby_locked_passcode         = "Lobby jest zamknięte. Wpisz kod z przeglądarki lobby.",
        team_full                     = "Drużyna jest pełna",
        join_failed                   = "Dołączenie nie powiodło się",

        only_host_change_wager        = "Tylko gospodarz może zmienić zakład.",
        only_host_change_lives        = "Tylko gospodarz może zmienić liczbę żyć.",
        only_host_change_map          = "Tylko gospodarz może zmienić mapę.",
        only_host_change_mode         = "Tylko gospodarz może zmienić tryb gry.",
        only_host_change_match_time   = "Tylko gospodarz może zmienić czas meczu.",
        only_host_shutdown_lobby      = "Tylko gospodarz może zamknąć to lobby.",
        only_host_kick_players        = "Tylko gospodarz może wyrzucać graczy.",
        only_host_change_waapons = "Tylko gospodarz może zmieniać broń.",

        invalid_map_key               = "Nieprawidłowy klucz mapy.",
        lobby_not_found               = "Nie znaleziono lobby.",
        player_too_far_for_host       = "Ten gracz jest zbyt daleko, aby przejąć hosta lobby",
        player_already_host           = "Już jesteś gospodarzem gry",
        host_removed_far              = "Gospodarz został usunięty za zbyt duże oddalenie się",
        player_not_found_id           = "Nie znaleziono gracza o ID: [%s]",
        already_hosting_lobby         = "Już jesteś gospodarzem tego lobby. Zamknij je lub przekaż hosta, aby utworzyć kolejne.",
        use_leave_lobby               = "Jeśli chcesz wyjść, użyj opcji Opuść lobby.",
        player_not_in_lobby_anymore   = "Ten gracz nie jest już w lobby.",

    },
    success = {
        savedfrinfall = "Spokojnie, zostałeś uratowany królu! :)",
        weapon_chosen = "Wybrałeś ",
        start_in = "Arena rozpocznie się za 10 sekund",
        e_open_menu = "[E] OTWÓRZ MENU BRONI",

        removed_from_arena = "Zostałeś usunięty z obszaru areny.",

        team_created = "Drużyna utworzona.",
        team_updated = "Drużyna zaktualizowana.",
        invite_sent = "Zaproszenie wysłane.",
        joined_team = "Dołączyłeś do drużyny.",
        member_removed = "Członek usunięty.",
        owner_transferred = "Własność przekazana.",
        left_team = "Opuściłeś drużynę.",

    },
    menu = {
        -- CLIENT.LUA
        arenalobby = "Lobby Areny Paintball",
        start = "Start",
        players = "Gracze",
        redteam = "Czerwona drużyna",
        ffateam = "Lobby FFA",
        blueteam = "Niebieska drużyna",
        lives = 'Liczba żyć',
        arena_lives = 'Życia areny',
        wager = 'Kwota zakładu',
        arena_wager = 'Zakład areny',
        weapon = 'Broń',
        map = 'Mapa',
        mode = 'Tryb gry',
        spectate = 'Obserwuj graczy',
        random = 'Losowo',
        pistol_option = 'Małe i zabójcze',
        smg_option = "Lekkie pistolety maszynowe",
        shotgun_option = 'Ciężkie strzelby do walki w zwarciu',
        assault_option = 'Ciężki kaliber',
        sniper_option = 'Snajperska precyzja',
        pistol_header = "Pistolety",
        smg_header = "SMG",
        shotgun_header = "Strzelby",
        assault_header = "Karabiny szturmowe",
        sniper_header = "Karabiny snajperskie",
        close_back = "Zamknij (ESC)",
        go_back = "< Wróć",
        player_lives = "Życia gracza",
        arena_lives = "Życia areny",
        view_lobby = "Pokaż lobby",
        become_host = "Zostań gospodarzem",
        become_hostt_description = "Zostań gospodarzem lobby",
        give_host = "Przekaż hosta lobby",
        give_host_description = "Przekaż hosta lobby innemu graczowi",
        player_id = "(ID GRACZA)",
        host_of_lobby = "Gospodarzem lobby jest gracz o ID: [",

        join = "Dołącz ",
        choose = "Wybierz ",
        respawn_in = "Odrodzenie za ",
        you_respawn_in = "Odrodzisz się za 10 sekund",
        use_uav = "UŻYJ UAV",
        use = "UŻYJ ",
        removed_lobby_host = "Za bardzo oddaliłeś się od gry. Usunięto cię z roli gospodarza lobby",

        scoreboard_keybind_desc = "Pokaż tablicę wyników Paintball",
        red_flag_blip           = "Czerwona flaga",
        blue_flag_blip          = "Niebieska flaga",

        next_weapon_progress = "(%d/%d) Następna broń to %s",

        -- DUI_LOGIC.LUA
        -- Paintball leaderboard menu
        lb_ffa_title = "🏆 Free For All",
        lb_ffa_description = "Najlepsi gracze w FFA paintball.",
        lb_ctf_title = "🚩 Capture The Flag",
        lb_ctf_description = "Liderzy w walkach o flagę.",
        lb_gungame_title = "🔫 Gun Game",
        lb_gungame_description = "Statystyki trybu Gun Game.",
        lb_oitc_title = "💣 One In The Chamber",
        lb_oitc_description = "Wyniki w rundach OITC.",
        lb_hyo_title = "🛡️ Hold Your Own",
        lb_hyo_description = "Ranking trybu Hold Your Own.",
        lb_tdm_title = "🔥 Team Deathmatch",
        lb_tdm_description = "Ranking Team Deathmatch.",
        lb_personal_title = "📊 Pokaż moje statystyki",
        lb_personal_description = "Twoje statystyki we wszystkich trybach.",

        -- MENUS.LUA
        -- Hub / lobby list
        team_hub_title = "Centrum drużyny",
        team_hub_description = "Twórz/Zarządzaj/Zobacz globalną drużynę paintballową",
        create_lobby_title = "Utwórz lobby",
        create_lobby_description = "Utwórz nowe lobby paintball (opcjonalny kod)",
        no_lobbies_title = "Brak lobby",
        no_lobbies_description = "Utwórz je, aby zacząć.",
        paintball_lobbies_title = "Lobby Paintball",

        lobby_list_title = "Lobby [%s] %s %s",
        lobby_list_desc = "Tryb: %s | Mapa: %s | Gracze: %s",
        lobby_view_title = "Lobby [%s] %s %s",
        -- Create lobby dialog
        create_lobby_header = "Utwórz lobby",
        lobby_name_label = "Nazwa lobby (opcjonalnie)",
        lobby_pass_label = "Kod dostępu (opcjonalnie)",
        must_enter_lobby_name = "Musisz podać nazwę lobby",
        -- Passcode dialog
        lobby_locked_title = "Lobby zablokowane",
        enter_passcode_label = "Wpisz kod dostępu",
        -- View lobby base actions
        leave_lobby_title = "Opuść lobby",
        leave_lobby_description = "Opuść to lobby i wróć do przeglądarki lobby.",
        manage_lobby_title = "Zarządzaj lobby",
        manage_lobby_description = "Przekaż hosta, zamknij lub ustaw kod dostępu.",
        leave_prefix = "Opuść ",
        -- Rank header in lobby
        rank_header_title = "Prestiż %d • Poziom %d (%s)",
        rank_header_desc = "XP na tym poziomie: %d / %d (Razem: %d)",
        -- Match time
        match_time_title = "Czas meczu",
        match_time_option = "%d minut",
        match_time_option_description = "Zakończ grę po %d minutach.",
        -- Manage lobby submenu
        transfer_host_title = "Przekaż hosta",
        transfer_host_description = "Przekaż własność lobby innemu graczowi po ID.",
        shutdown_lobby_title = "Zamknij lobby",
        shutdown_lobby_description = "Wyrzuć wszystkich graczy, zresetuj i usuń lobby.",
        set_passcode_title = "Ustaw kod dostępu",
        set_passcode_description = "Zablokuj lobby kodem (puste = usuń).",
        kick_player_title = "Wyrzuć gracza",
        kick_player_description = "Usuń gracza z tego lobby.",
        -- Kick menu
        no_players_to_kick_title = "Brak graczy do wyrzucenia",
        no_players_to_kick_description = "Jesteś jedynym graczem w tym lobby.",
        kick_confirm_title = "Wyrzucić %s?",
        kick_confirm_description = "Na pewno chcesz wyrzucić %s?",
        kick_confirm_body = "Zostanie usunięty z tego lobby.",
        kick_yes_title = "Tak, wyrzuć gracza",
        kick_yes_description = "Usuń %s z lobby.",
        kick_no_title = "Nie, wróć",
        kick_no_description = "Wróć do listy graczy.",
        -- Shutdown confirm dialog
        shutdown_confirm_title = "Na pewno chcesz zamknąć lobby?",
        shutdown_confirm_description = "Wszyscy gracze zostaną usunięci, a lobby skasowane.",
        shutdown_yes_title = "Tak, zamknij",
        shutdown_yes_description = "Zakończ lobby dla wszystkich.",
        shutdown_no_title = "Nie, wróć",
        shutdown_no_description = "Wróć do zarządzania lobby.",
        -- Set passcode dialog
        set_passcode_header = "Ustaw kod dostępu lobby",
        passcode_label = "Kod dostępu (puste = usuń)",
        -- Spectate menu
        exit_spectate_title = "Zakończ obserwację",
        exit_spectate_description = "Wróć do postaci",
        spectate_player_title = "Gracz %s",
        spectate_player_description = "ID: %s",
        -- Choose map
        random_map_description = "Losowo wybrane mapy",

        -- OPEN.LUA
        open_menu_hint             = "[E] Otwórz menu",
        open_menu_hint_view_arena  = "~b~[E] ~w~Pokaż arenę",
        ped_text_paintball         = "~o~PAINTBALL",
        blip_paintball             = "Paintball",
        target_view_arena_label    = "Pokaż arenę",
        submit_text                = "Zatwierdź",
        radial_surrender_label     = "Poddaj się \n Paintball",


        -- TEMAS.LUA
        -- Teams main menu
        teams_menu_title = "Drużyny",
        create_team_title = "Utwórz drużynę",
        create_team_desc = "Utwórz nową drużynę paintballową.",
        no_team_title = "Brak drużyny",
        no_team_desc = "Utwórz drużynę, aby zapraszać znajomych.",
        role_owner = "Właściciel",
        role_member = "Członek",
        role_you = "Ty",
        members_label = "Członkowie: %d",
        -- Create team dialog
        create_team_header = "Utwórz drużynę",
        create_team_name = "Nazwa drużyny",
        create_team_tag = "Tag (opcjonalnie)",
        create_team_color = "Kolor HEX (opcjonalnie)",
        create_team_logo = "URL logo (opcjonalnie) [tylko linki fivemanage.com]",
        -- Team creation results
        failed_create_team = "Nie udało się utworzyć drużyny: %s",
        created_team = "Drużyna utworzona.",
        -- Manage team
        manage_members_title = "Zarządzaj członkami",
        manage_members_desc = "Wyrzucaj lub awansuj członków drużyny.",
        edit_team_title = "Edytuj drużynę",
        edit_team_desc = "Nazwa, tag, kolor, logo.",
        invite_player_title = "Zaproś gracza",
        invite_player_desc = "Zaproś gracza po ID.",
        invite_player_dialog_header = "Zaproś gracza",
        invite_player_id_label = "ID gracza",
        leave_team_title = "Opuść drużynę",
        leave_team_desc = "Opuść tę drużynę.",
        failed_load_team = "Nie udało się załadować drużyny.",
        -- Edit team dialog
        edit_team_header = "Edytuj drużynę",
        edit_team_field_name = "Nazwa",
        edit_team_field_tag = "Tag",
        edit_team_field_color = "Kolor HEX",
        edit_team_field_logo = "URL logo",
        failed_update_team = "Nie udało się zaktualizować drużyny: %s",
        updated_team = "Drużyna zaktualizowana.",
        -- Invite result
        failed_send_invite = "Nie udało się wysłać zaproszenia: %s",
        invite_sent = "Zaproszenie wysłane.",
        -- Invite received popup
        team_invite_title = "Zaproszenie do drużyny",
        join_team_title = "Dołącz do %s",
        join_team_desc = "Akceptuj zaproszenie od %s",
        decline_title = "Odrzuć",
        decline_desc = "Zignoruj to zaproszenie.",
        -- Accept invite
        failed_join_team = "Nie udało się dołączyć do drużyny: %s",
        joined_team = "Dołączyłeś do drużyny.",
        -- Members list
        members_menu_title = "Członkowie • %s",
        member_owner_suffix = " (Właściciel)",
        member_you_suffix = " (Ty)",
        -- Manage team member
        promote_member_title = "Przekaż własność",
        promote_member_desc = "Przekaż własność drużyny do %s.",
        kick_member_title = "Wyrzuć z drużyny",
        kick_member_desc = "Usuń %s z drużyny.",
        back_title = "Wróć",
        back_desc = "Wróć do listy członków.",
        -- Kick / promote results
        failed_kick_member = "Nie udało się wyrzucić członka: %s",
        member_removed = "Członek usunięty.",
        failed_transfer_owner = "Nie udało się przekazać własności: %s",
        owner_transferred = "Własność przekazana.",
        -- Leave team results
        failed_leave_team = "Nie udało się opuścić drużyny: %s",
        left_team = "Opuściłeś drużynę.",
        view_members_title = "Pokaż członków",
        view_members_desc  = "Zobacz kto jest w tej drużynie.",


        -- SERVER.LUA
        -- Match result / notifications (server-side)
        ffa_timeout_winner   = "%s wygrał! (limit czasu)",
        match_draw_timeout   = "Mecz zakończył się remisem (limit czasu).",
        red_team_win_timeout = "Czerwona drużyna wygrała! (limit czasu)",
        blue_team_win_timeout = "Niebieska drużyna wygrała! (limit czasu)",
        red_team_win         = "Czerwona drużyna wygrała!",
        blue_team_win        = "Niebieska drużyna wygrała!",
        generic_team_win     = "Drużyna %s wygrała!",
        ffa_winner           = "%s wygrał!",
        eliminated_message   = "%s został wyeliminowany!",
        ffa_players_left     = "Pozostało %d graczy w FFA!",
        players_left_red     = "Pozostało %d graczy w czerwonej drużynie!",
        players_left_blue    = "Pozostało %d graczy w niebieskiej drużynie!",
        host_now             = "Jesteś teraz gospodarzem lobby.",
        removed_unteamed_summary = "Usunięto %d nieprzypisanego gracza%s przed startem meczu.",
        lives_left_message   = "%s ma %d żyć",


        -- SV_LOBBY.LUA
        -- FFA mode switching
        ffa_full_spectate        = "FFA jest pełne; obserwujesz.",
        ffa_move_fail_spectate   = "Nie udało się przenieść do FFA; obserwujesz.",

        -- Lobby lifecycle
        lobby_shutdown_by_host   = "Lobby [%d] zostało zamknięte przez gospodarza.",
        left_lobby_message       = "Opuściłeś lobby [%d].",
        host_now                 = "Jesteś teraz gospodarzem lobby.",

        -- Join / leave notifications
        joined_game_message      = "%s dołączył do gry!",
        joined_red_team_message  = "%s dołączył do czerwonej drużyny!",
        joined_blue_team_message = "%s dołączył do niebieskiej drużyny!",
        left_lobby_announce      = "%s opuścił lobby!",

        -- Wager / lives / map / mode / match time
        wager_set_prize_pool     = "Ustawiono $%d jako pulę nagród!",
        lives_set_message        = "Ustawiono %d żyć na gracza!",
        map_set_to               = "Ustawiono mapę: %s",
        mode_set_to              = "Ustawiono tryb gry: %s",
        match_time_set           = "Czas meczu ustawiony na %d minut.",

        -- Passcode
        passcode_set_and_locked   = "Ustawiono kod i zablokowano lobby.",
        passcode_cleared_unlocked = "Usunięto kod i odblokowano lobby.",

        -- Lobby create / host
        lobby_created_host       = "Lobby [%d] utworzone. Jesteś gospodarzem.",
        already_hosting_lobby    = "Już jesteś gospodarzem lobby [%d]. Zamknij je lub przekaż hosta, aby utworzyć kolejne.",

        -- Kick messages
        kicked_from_lobby        = "Zostałeś wyrzucony z lobby przez gospodarza.",
        kicked_broadcast         = "%s został wyrzucony z lobby przez gospodarza.",

        -- Lobby gate / misc
        lobby_not_found_msg      = "Nie znaleziono lobby",
        incorrect_passcode_msg   = "Nieprawidłowy kod dostępu",

        -- Members list team labels
        team_red_label           = "Czerwoni",
        team_blue_label          = "Niebiescy",
        team_ffa_label           = "FFA",
        team_spectator_label     = "Widz",
        team_unknown_label       = "Nieznane",
        default_player_name      = "Gracz %d",


        -- GAME MODES
        mode_tdm_title = "Team Deathmatch",
        mode_tdm_description = "12v12 • Pierwsza drużyna, która osiągnie limit zabójstw, wygrywa.",
        mode_hyo_title = "Hold Your Own",
        mode_hyo_description = "12v12 • Przetrwaj jak najdłużej z ograniczoną liczbą żyć.",
        mode_ctf_title = "Capture The Flag",
        mode_ctf_description = "12v12 • Przechwyć flagę przeciwnika trzy razy, aby wygrać.",
        mode_gungame_title = "Gun Game",
        mode_gungame_description = "Każde zabójstwo ulepsza broń. Dotrzyj do ostatniej, aby wygrać.",
        mode_ffa_title = "Free For All",
        mode_ffa_description = "Każdy na każdego. Osiągnij limit zabójstw, by wygrać.",
        mode_oitc_title = "One In The Chamber",
        mode_oitc_description = "Zaczynasz z jednym nabojem. Każde zabójstwo daje kolejny. Liczy się każdy strzał.",


        -- SCOREBOARD HEADERS
        sb_player       = "GRACZ",
        sb_score        = "WYNIK",
        sb_kills_short  = "Z",
        sb_deaths_short = "Ś",
        sb_points       = "PUNKTY",
        sb_lives        = "ŻYCIA",
        sb_ctf          = "CTF",
        sb_kd_ratio     = "KD",

        mode_kc_title = "Kill Confirmed",
        mode_kc_description = "12v12 | Potwierdzaj zabójstwa zbierając znaczniki wroga, a anuluj je podnosząc własne.",

        set_team_outfit_male_title   = "Ustaw strój męski",
        set_team_outfit_female_title = "Ustaw strój damski",

        team_info_title = "Jak działają drużyny",
        team_info_desc  = "Dowiedz się, jak działają drużyny, kolory i stroje",

        team_info_header = "Przewodnik po drużynach Paintball",

        team_info_how_title = "Czym jest drużyna?",
        team_info_how_desc = "Drużyna to globalna grupa paintballowa. Członkowie mogą grać razem oraz dzielić kolory i stroje.",

        team_info_color_title = "Kolory drużyny",
        team_info_color_desc = "Jeśli wszyscy po jednej stronie są z tej samej drużyny, kolor UI dopasuje się do koloru drużyny.",

        team_info_outfits_title = "Stroje drużyny",
        team_info_outfits_desc = "Właściciel drużyny może ustawić strój męski i damski. Zastosują się automatycznie, gdy pełna drużyna gra po jednej stronie.",

        team_info_rules_title = "Ważne zasady",
        team_info_rules_desc = "• Nazwy drużyn i tagi muszą być unikalne\n• Tagi są ograniczone do 4 znaków\n• Mieszane składy NIE użyją kolorów ani strojów drużyny",

        open_leaderboard = "📋 Otwórz menu rankingu",
        leaderboard_options = "📋 Opcje rankingu",

                -- Jpark
        arena_Jpark_name = "Park Jurajski",
        arena_Jpark_description = "Witamy w Parku Jurajskim",

        -- Wball
        arena_Wball_name = "Kula Wyburzeniowa",
        arena_Wball_description = "Czas wszystko zniszczyć",

        -- Syard
        arena_Syard_name = "Złomowisko 2",
        arena_Syard_description = "Tytan upada",

        -- Swreck
        arena_Swreck_name = "Wrak Statku",
        arena_Swreck_description = "Statek został zniszczony",

        -- IWhouse
        arena_IWhouse_name = "Hala Przemysłowa",
        arena_IWhouse_description = "Uważaj, żeby nie spaść",

        -- Fpalace
        arena_Fpalace_name = "Pałac Przyszłości",
        arena_Fpalace_description = "Zbyt futurystyczne, brak osłon",

        -- Tsoldier
        arena_Tsoldier_name = "Żołnierz Zabawka",
        arena_Tsoldier_description = "Mały człowiek w wielkim świecie",

        -- Tcity
        arena_Tcity_name = "Miasto Opon",
        arena_Tcity_description = "To nie to Miasto Opon",

        -- WITpark
        arena_WITpark_name = "Spacer po Parku",
        arena_WITpark_description = "Park Miasta Opon",

        -- Ttown
        arena_Ttown_name = "Miasto Rur",
        arena_Ttown_description = "Miasto pełne rur",

        -- UConstruction
        arena_UConstruction_name = "Budowa Uptown",
        arena_UConstruction_description = "Chaos na placu budowy",

        -- Gstreet
        arena_Gstreet_name = "Grove Street",
        arena_Gstreet_description = "Kto rządzi dzielnicą?",

        -- Scity
        arena_Scity_name = "Stab City",
        arena_Scity_description = "Chaos w parku przyczep",

        -- RSyard
        arena_RSyard_name = "Złomowisko Redsa",
        arena_RSyard_description = "Rdza, złom i chaos",

        -- Ghouse
        arena_Ghouse_name = "Dom Babci",
        arena_Ghouse_description = "Piecze najlepsze ciasteczka",

        -- GCVilliage
        arena_GCVilliage_name = "Wielka Wioska Obozowa",
        arena_GCVilliage_description = "Patrz pod nogi",

        -- Highjacked
        arena_Highjacked_name = "Porwanie",
        arena_Highjacked_description = "Spróbuj nie dostać choroby morskiej",

        -- DTDocks
        arena_DTDocks_name = "Doky Centrum",
        arena_DTDocks_description = "Co wydarzy się w dokach, zostaje w dokach",

        -- ORats
        arena_ORats_name = "Naftowe Szczury",
        arena_ORats_description = "Pokryci smarem i olejem",

        -- HRise
        arena_HRise_name = "Wysoki Budynek",
        arena_HRise_description = "Nie dla osób z lękiem wysokości",


        -- Gabz / Indoor
        arena_IDarena_name = "Arena Wewnętrzna",
        arena_IDarena_description = "Czerwoni kontra Niebiescy",

        arena_IDderby_name = "Derby Wewnętrzne",
        arena_IDderby_description = "Przeznaczone dla samochodów… no wiesz",

        -- Nuketown
        arena_Narena_name = "Arena Nuketown",
        arena_Narena_description = "Klasyczne Nuketown",

        arena_NMpark_name = "Nuketown Mirror Park",
        arena_NMpark_description = "Nuketown w mieście",


    },
}
