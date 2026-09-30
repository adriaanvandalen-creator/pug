if Config.Language ~= "spanish" then return end

Config.Translations = {
    error = {
        choose_team_first = "Debes unirte a un equipo primero",
        no_lives_entered = "No se ingresaron vidas del jugador.",
        max_lives_set = "El máximo de vidas que se puede establecer es ",
        no_wager = "No se ingresó el monto de la apuesta.",
        wager_cap = "La apuesta debe estar entre ",
        active_game = "Ya hay un juego activo",
        ammo_given = "Recibirás una nueva bala en 7 segundos",
        cant_do_this = "No puedes hacer esto hasta que reaparezcas completamente",
        no_id_entered = "No se ingresó ningún ID",
        need_to_be_lobby_host = "Debes ser el anfitrión del lobby para cambiar esta configuración",
        daytime_only = "El paintball está cerrado durante la noche...",
        missing_input = "Falta información...",
        
        you_are_not_in_lobby = "No estás en un lobby.",
        lobby_no_longer_exists = "Ese lobby ya no existe.",
        cannot_join_down = "No puedes unirte al juego estando derribado",
        incorrect_passcode = "Código incorrecto",
        need_to_choose_weapon = "Debes elegir un arma antes de unirte a un equipo.",
        team_not_loaded = "No se pudo cargar el equipo.",

        -- SERVER.LUA
        only_host_can_start = "Solo el anfitrión puede iniciar el juego.",
        must_join_team_to_start = "Debes unirte a un equipo antes de iniciar la partida.",
        game_already_started = "Ya hay una partida iniciada",
        need_players_per_team = "Debe haber al menos 1 jugador por equipo",
        not_enough_players_after_prune = "No hay suficientes jugadores en los equipos después de remover a los sin equipo.",
        stats_reset = "¡TODAS LAS ESTADÍSTICAS DEL JUEGO HAN SIDO RESETEADAS! UN JUGADOR NO SE DESCONECTÓ CORRECTAMENTE",

        player_missing_entry_fee = "%s no tiene %d",
        removed_for_no_team = "Fuiste removido por no elegir equipo antes de que comenzara la partida.",
        ongoing_game_required_spectate = "Debe haber una partida activa para espectar",
        no_players_in_game = "No hay jugadores en la partida",

        -- SV_LOBBY.LUA
        no_lobby_specified = "No se especificó un lobby.",
        lobby_no_longer_exists_refresh = "Ese lobby ya no existe. Actualizando la lista...",
        lobby_locked_passcode = "El lobby está bloqueado. Ingresa el código desde el navegador de lobbies.",
        team_full = "El equipo está lleno",
        join_failed = "No se pudo unir",

        only_host_change_wager = "Solo el anfitrión puede cambiar la apuesta.",
        only_host_change_lives = "Solo el anfitrión puede cambiar las vidas.",
        only_host_change_map = "Solo el anfitrión puede cambiar el mapa.",
        only_host_change_mode = "Solo el anfitrión puede cambiar el modo de juego.",
        only_host_change_match_time = "Solo el anfitrión puede cambiar el tiempo de partida.",
        only_host_shutdown_lobby = "Solo el anfitrión puede cerrar este lobby.",
        only_host_kick_players = "Solo el anfitrión puede expulsar jugadores.",
        only_host_change_waapons = "Solo el anfitrión puede cambiar las armas.",

        invalid_map_key = "Clave de mapa inválida.",
        lobby_not_found = "Lobby no encontrado.",
        player_too_far_for_host = "Este jugador está demasiado lejos para darle el anfitrión del lobby",
        player_already_host = "Ya eres el anfitrión del juego",
        host_removed_far = "El anfitrión fue removido por alejarse demasiado",
        player_not_found_id = "No se encontró al jugador con ID: [%s]",
        already_hosting_lobby = "Ya eres anfitrión de otro lobby. Ciérralo o transfiere el anfitrión para crear uno nuevo.",
        use_leave_lobby = "Usa 'Salir del Lobby' si deseas salir.",
        player_not_in_lobby_anymore = "Ese jugador ya no está en el lobby.",
    },

    success = {
        savedfrinfall = "¡No te preocupes, has sido salvado rey! :)",
        weapon_chosen = "Has elegido ",
        start_in = "La arena comenzará en 10 segundos",
        e_open_menu = "[E] ABRIR MENÚ DE ARMAS",

        removed_from_arena = "Has sido removido del área de la arena.",

        team_created = "Equipo creado.",
        team_updated = "Equipo actualizado.",
        invite_sent = "Invitación enviada.",
        joined_team = "Te uniste al equipo.",
        member_removed = "Miembro removido.",
        owner_transferred = "Propiedad transferida.",
        left_team = "Saliste del equipo.",
    },

    menu = {
        arenalobby = "Lobby de la Arena de Paintball",
        start = "Iniciar",
        players = "Jugadores",
        redteam = "Equipo Rojo",
        ffateam = "Lobby FFA",
        blueteam = "Equipo Azul",
        lives = "Cantidad de vidas",
        arena_lives = "Vidas de la Arena",
        wager = "Monto de la Apuesta",
        arena_wager = "Apuesta de la Arena",
        weapon = "Arma",
        map = "Mapa",
        mode = "Modo de Juego",
        spectate = "Espectar Jugadores",
        random = "Aleatorio",
        pistol_option = "Pequeñas y mortales",
        smg_option = "Subfusiles ligeros",
        shotgun_option = "Escopetas de corto alcance",
        assault_option = "Armas grandes y potentes",
        sniper_option = "Francotirador",
        pistol_header = "Pistolas",
        smg_header = "Subfusiles",
        shotgun_header = "Escopetas",
        assault_header = "Rifles de Asalto",
        sniper_header = "Rifles de Francotirador",
        close_back = "Cerrar (ESC)",
        go_back = "< Regresar",
        player_lives = "Vidas del Jugador",
        arena_lives = "Vidas de la Arena",
        view_lobby = "Ver Lobby",
        become_host = "Convertirse en Anfitrión",
        become_hostt_description = "Convertirse en el anfitrión del lobby",
        give_host = "Transferir Anfitrión",
        give_host_description = "Dar el anfitrión del lobby a otro jugador",
        player_id = "(ID DEL JUGADOR)",
        host_of_lobby = "El anfitrión del lobby es el jugador ID: [",

        join = "Unirse ",
        choose = "Elegir ",
        respawn_in = "Reapareces en ",
        you_respawn_in = "Reaparecerás en 10 segundos",
        use_uav = "USAR UAV",
        use = "USAR ",
        removed_lobby_host = "Te alejaste demasiado del juego. Se te removió como anfitrión.",

        scoreboard_keybind_desc = "Ver Marcador de Paintball",
        red_flag_blip = "Bandera Roja",
        blue_flag_blip = "Bandera Azul",

        next_weapon_progress = "(%d/%d) El siguiente arma será %s",

        -- Leaderboard
        lb_ffa_title = "🏆 Todos contra Todos",
        lb_ffa_description = "Mejores jugadores en FFA.",
        lb_ctf_title = "🚩 Captura la Bandera",
        lb_ctf_description = "Líderes en batallas de bandera.",
        lb_gungame_title = "🔫 Gun Game",
        lb_gungame_description = "Estadísticas del modo Gun Game.",
        lb_oitc_title = "💣 Una en la Cámara",
        lb_oitc_description = "Rendimiento en OITC.",
        lb_hyo_title = "🛡️ Mantén tu Territorio",
        lb_hyo_description = "Clasificación de Mantén tu Territorio.",
        lb_tdm_title = "🔥 Duelo por Equipos",
        lb_tdm_description = "Clasificación de Duelo por Equipos.",
        lb_personal_title = "📊 Mis Estadísticas",
        lb_personal_description = "Estadísticas personales en todos los modos.",

        -- Hub
        team_hub_title = "Centro de Equipos",
        team_hub_description = "Crear/administrar/ver tu equipo global de paintball",
        create_lobby_title = "Crear Lobby",
        create_lobby_description = "Crear un nuevo lobby de paintball (código opcional)",
        no_lobbies_title = "No hay lobbies aún",
        no_lobbies_description = "Crea uno para comenzar.",
        paintball_lobbies_title = "Lobbies de Paintball",

        lobby_list_title = "Lobby [%s] %s %s",
        lobby_list_desc = "Modo: %s | Mapa: %s | Jugadores: %s",
        lobby_view_title = "Lobby [%s] %s %s",

        create_lobby_header = "Crear Lobby",
        lobby_name_label = "Nombre del Lobby (opcional)",
        lobby_pass_label = "Código del Lobby (opcional)",
        must_enter_lobby_name = "Debes ingresar un nombre para el lobby",

        lobby_locked_title = "Lobby Bloqueado",
        enter_passcode_label = "Ingresar Código",

        leave_lobby_title = "Salir del Lobby",
        leave_lobby_description = "Salir al navegador de lobbies.",
        manage_lobby_title = "Administrar Lobby",
        manage_lobby_description = "Transferir anfitrión, cerrar o establecer código.",
        leave_prefix = "Salir ",

        rank_header_title = "Prestigio %d • Nv. %d (%s)",
        rank_header_desc = "XP de este nivel: %d / %d (Total: %d)",

        match_time_title = "Tiempo de Partida",
        match_time_option = "%d minutos",
        match_time_option_description = "Finalizar la partida después de %d minutos.",

        transfer_host_title = "Transferir Anfitrión",
        transfer_host_description = "Dar el anfitrión a otro jugador.",
        shutdown_lobby_title = "Cerrar Lobby",
        shutdown_lobby_description = "Expulsar jugadores y borrar el lobby.",
        set_passcode_title = "Establecer Código",
        set_passcode_description = "Bloquear lobby con un código (vacío para quitar).",
        kick_player_title = "Expulsar Jugador",
        kick_player_description = "Remover un jugador del lobby.",

        no_players_to_kick_title = "No hay jugadores para expulsar",
        no_players_to_kick_description = "Eres el único jugador en el lobby.",
        kick_confirm_title = "¿Expulsar a %s?",
        kick_confirm_description = "¿Seguro que deseas expulsar a %s?",
        kick_confirm_body = "Será removido del lobby.",
        kick_yes_title = "Sí, expulsar",
        kick_yes_description = "Remover a %s del lobby.",
        kick_no_title = "No, regresar",
        kick_no_description = "Regresar a la lista.",

        shutdown_confirm_title = "¿Seguro que deseas cerrar el lobby?",
        shutdown_confirm_description = "Todos los jugadores serán expulsados.",
        shutdown_yes_title = "Sí, cerrar",
        shutdown_yes_description = "Cerrar el lobby para todos.",
        shutdown_no_title = "No, regresar",
        shutdown_no_description = "Volver a administración.",

        set_passcode_header = "Establecer Código del Lobby",
        passcode_label = "Código (vacío para limpiar)",

        exit_spectate_title = "Salir del Modo Espectador",
        exit_spectate_description = "Volver a tu personaje",
        spectate_player_title = "Jugador %s",
        spectate_player_description = "ID: %s",

        random_map_description = "Mapas elegidos aleatoriamente",

        -- OPEN.lua
        open_menu_hint = "[E] Para abrir menú",
        open_menu_hint_view_arena = "~b~[E] ~w~Ver Arena",
        ped_text_paintball = "~o~PAINTBALL",
        blip_paintball = "Paintball",
        target_view_arena_label = "Ver Arena",
        submit_text = "Enviar",
        radial_surrender_label = "Rendirse \n Paintball",

        -- Teams menu
        teams_menu_title = "Equipos",
        create_team_title = "Crear Equipo",
        create_team_desc = "Crear un nuevo equipo de paintball.",
        no_team_title = "Sin Equipo",
        no_team_desc = "Crea un equipo para invitar amigos.",
        role_owner = "Líder",
        role_member = "Miembro",
        role_you = "Tú",
        members_label = "Miembros: %d",

        create_team_header = "Crear Equipo",
        create_team_name = "Nombre del Equipo",
        create_team_tag = "Etiqueta (opcional)",
        create_team_color = "Color Hex (opcional)",
        create_team_logo = "URL del Logo (opcional) [solo enlaces de fivemanage.com]",

        failed_create_team = "Error al crear equipo: %s",
        created_team = "Equipo creado.",

        manage_members_title = "Administrar Miembros",
        manage_members_desc = "Expulsar o ascender miembros.",
        edit_team_title = "Editar Equipo",
        edit_team_desc = "Nombre, etiqueta, color, logo.",
        invite_player_title = "Invitar Jugador",
        invite_player_desc = "Invitar a un jugador por ID.",
        invite_player_dialog_header = "Invitar Jugador",
        invite_player_id_label = "ID del Jugador",

        leave_team_title = "Salir del Equipo",
        leave_team_desc = "Salir del equipo actual.",
        failed_load_team = "No se pudo cargar el equipo.",

        edit_team_header = "Editar Equipo",
        edit_team_field_name = "Nombre",
        edit_team_field_tag = "Etiqueta",
        edit_team_field_color = "Color Hex",
        edit_team_field_logo = "URL del Logo",

        failed_update_team = "Error al actualizar equipo: %s",
        updated_team = "Equipo actualizado.",

        failed_send_invite = "Error al enviar invitación: %s",
        invite_sent = "Invitación enviada.",

        team_invite_title = "Invitación de Equipo",
        join_team_title = "Unirse a %s",
        join_team_desc = "Aceptar invitación de %s",
        decline_title = "Rechazar",
        decline_desc = "Ignorar esta invitación.",

        failed_join_team = "Error al unirse al equipo: %s",
        joined_team = "Te uniste al equipo.",

        members_menu_title = "Miembros • %s",
        member_owner_suffix = " (Líder)",
        member_you_suffix = " (Tú)",

        promote_member_title = "Ascender a Líder",
        promote_member_desc = "Transferir liderazgo a %s.",
        kick_member_title = "Expulsar del Equipo",
        kick_member_desc = "Remover a %s del equipo.",
        back_title = "Volver",
        back_desc = "Regresar a la lista de miembros.",

        failed_kick_member = "Error al expulsar miembro: %s",
        member_removed = "Miembro removido.",
        failed_transfer_owner = "Error al transferir liderazgo: %s",
        owner_transferred = "Liderazgo transferido.",

        failed_leave_team = "Error al salir del equipo: %s",
        left_team = "Saliste del equipo.",

        view_members_title = "Ver Miembros",
        view_members_desc = "Ver quién está en este equipo.",

        -- SERVER results
        ffa_timeout_winner = "%s ganó (límite de tiempo)",
        match_draw_timeout = "La partida terminó en empate (límite de tiempo).",
        red_team_win_timeout = "El equipo rojo ganó (límite de tiempo)",
        blue_team_win_timeout = "El equipo azul ganó (límite de tiempo)",
        red_team_win = "¡El equipo rojo ganó!",
        blue_team_win = "¡El equipo azul ganó!",
        generic_team_win = "¡El equipo %s ganó!",
        ffa_winner = "¡%s ganó!",
        eliminated_message = "¡%s ha sido eliminado!",
        ffa_players_left = "¡Quedan %d jugadores en FFA!",
        players_left_red = "¡Quedan %d jugadores en el equipo rojo!",
        players_left_blue = "¡Quedan %d jugadores en el equipo azul!",
        removed_unteamed_summary = "Se removieron %d jugadores sin equipo antes de iniciar.",

        lives_left_message = "%s tiene %d vidas restantes",

        ffa_full_spectate = "El FFA está lleno; ahora estás como espectador.",
        ffa_move_fail_spectate = "No se pudo mover a FFA; ahora estás como espectador.",

        lobby_shutdown_by_host = "El lobby [%d] fue cerrado por el anfitrión.",
        left_lobby_message = "Saliste del lobby [%d].",
        joined_game_message = "%s se unió a la partida!",
        joined_red_team_message = "%s se unió al equipo rojo!",
        joined_blue_team_message = "%s se unió al equipo azul!",
        left_lobby_announce = "%s salió del lobby!",

        wager_set_prize_pool = "¡Se estableció un premio de $%d!",
        lives_set_message = "¡Se establecieron %d vidas por jugador!",
        map_set_to = "El mapa ha sido cambiado a %s",
        mode_set_to = "El modo de juego ha sido cambiado a %s",
        match_time_set = "Tiempo de partida establecido en %d minutos.",

        passcode_set_and_locked = "Código establecido y lobby bloqueado.",
        passcode_cleared = "y lobby desbloqueado.",

        lobby_created_host = "Lobby [%d] creado. Eres el anfitrión.",
        already_hosting_lobby = "Ya eres anfitrión del lobby [%d]. Ciérralo o transfiere el anfitrión para crear otro.",

        kicked_from_lobby = "Fuiste expulsado del lobby por el anfitrión.",
        kicked_broadcast = "%s fue expulsado del lobby por el anfitrión.",

        lobby_not_found_msg = "Lobby no encontrado",
        incorrect_passcode_msg = "Código incorrecto",

        team_red_label = "Rojo",
        team_blue_label = "Azul",
        team_ffa_label = "FFA",
        team_spectator_label = "Espectador",
        team_unknown_label = "Desconocido",
        default_player_name = "Jugador %d",

        -- GAME MODES
        mode_tdm_title = "Duelo por Equipos",
        mode_tdm_description = "12v12 • El primer equipo en alcanzar el límite de bajas gana.",

        mode_hyo_title = "Resiste por Tu Cuenta",
        mode_hyo_description = "12v12 • Sobrevive el mayor tiempo posible con vidas limitadas.",

        mode_ctf_title = "Capturar la Bandera",
        mode_ctf_description = "12v12 • Captura la bandera enemiga tres veces para ganar.",

        mode_gungame_title = "Gun Game",
        mode_gungame_description = "Cada baja mejora tu arma. Llega al arma final para ganar.",

        mode_ffa_title = "Todos Contra Todos",
        mode_ffa_description = "Cada jugador por sí mismo. Alcanza el objetivo de bajas para ganar.",

        mode_oitc_title = "Una en la Recámara",
        mode_oitc_description = "Empiezas con una bala. Cada baja te da otra. Haz que cada disparo cuente.",

        -- SCOREBOARD HEADERS
        sb_player       = "JUGADOR",
        sb_score        = "PUNTUACIÓN",
        sb_kills_short  = "K",
        sb_deaths_short = "D",
        sb_points       = "PUNTOS",
        sb_lives        = "VIDAS",
        sb_ctf          = "BANDERAS",
        sb_kd_ratio     = "K/D",

        mode_kc_title = "Bajas Confirmadas",
        mode_kc_description = "12v12 | Confirma las bajas recogiendo placas enemigas y niega puntos tomando las de tu equipo",


        set_team_outfit_male_title   = "Establecer Atuendo Masculino",
        set_team_outfit_female_title = "Establecer Atuendo Femenino",

        team_info_title = "Cómo Funcionan los Equipos",
        team_info_desc  = "Aprende cómo funcionan los equipos, colores y atuendos",

        team_info_header = "Guía de Equipos de Paintball",

        team_info_how_title = "¿Qué es un Equipo?",
        team_info_how_desc = "Un equipo es un grupo global de paintball. Los jugadores pueden unirse a partidas juntos y compartir colores y atuendos.",

        team_info_color_title = "Colores del Equipo",
        team_info_color_desc = "Si todos los jugadores de un lado pertenecen al mismo equipo, el color de la interfaz coincidirá con el color del equipo.",

        team_info_outfits_title = "Atuendos del Equipo",
        team_info_outfits_desc = "El líder del equipo puede establecer atuendos masculinos y femeninos. Se aplican automáticamente cuando el equipo completo juega en un mismo lado.",

        team_info_rules_title = "Reglas Importantes",
        team_info_rules_desc = "• Los nombres y etiquetas de equipo deben ser únicos\n• Las etiquetas están limitadas a 4 caracteres\n• Los equipos mixtos NO usarán colores ni atuendos del equipo",

        open_leaderboard = "📋 Abrir menú de clasificaciones",
        leaderboard_options = "📋 Opciones de clasificaciones",


        lb_kc_title = "Baja Confirmada",
        lb_kc_description = "Ver a los mejores jugadores de Baja Confirmada",

                -- Jpark
        arena_Jpark_name = "Parque Jurásico",
        arena_Jpark_description = "Bienvenido a Parque Jurásico",

        -- Wball
        arena_Wball_name = "Bola Demoledora",
        arena_Wball_description = "Hora de destruirlo todo",

        -- Syard
        arena_Syard_name = "Desguace 2",
        arena_Syard_description = "Cae el titán",

        -- Swreck
        arena_Swreck_name = "Naufragio",
        arena_Swreck_description = "Un barco ha sido destruido",

        -- IWhouse
        arena_IWhouse_name = "Casa Industrial",
        arena_IWhouse_description = "No te caigas",

        -- Fpalace
        arena_Fpalace_name = "Palacio del Futuro",
        arena_Fpalace_description = "Demasiado futurista, sin cobertura",

        -- Tsoldier
        arena_Tsoldier_name = "Soldado de Juguete",
        arena_Tsoldier_description = "Un pequeño hombre en un gran mundo",

        -- Tcity
        arena_Tcity_name = "Ciudad de Neumáticos",
        arena_Tcity_description = "No es esa Ciudad de Neumáticos",

        -- WITpark
        arena_WITpark_name = "Un Paseo por el Parque",
        arena_WITpark_description = "Parque Ciudad de Neumáticos",

        -- Ttown
        arena_Ttown_name = "Ciudad de Tubos",
        arena_Ttown_description = "Ciudad Pueblo de Tubos",

        -- UConstruction
        arena_UConstruction_name = "Construcción Uptown",
        arena_UConstruction_description = "Caos en la zona de construcción",

        -- Gstreet
        arena_Gstreet_name = "Grove Street",
        arena_Gstreet_description = "¿Quién manda en el barrio?",

        -- Scity
        arena_Scity_name = "Stab City",
        arena_Scity_description = "Caos en el parque de caravanas",

        -- RSyard
        arena_RSyard_name = "Desguace de Reds",
        arena_RSyard_description = "Óxido, chatarra y caos",

        -- Ghouse
        arena_Ghouse_name = "La Casa de la Abuela",
        arena_Ghouse_description = "Hace las mejores galletas",

        -- GCVilliage
        arena_GCVilliage_name = "Gran Aldea del Campamento",
        arena_GCVilliage_description = "Mira dónde pisas",

        -- Highjacked
        arena_Highjacked_name = "Secuestrado",
        arena_Highjacked_description = "Intenta no marearte",

        -- DTDocks
        arena_DTDocks_name = "Muelles del Centro",
        arena_DTDocks_description = "Lo que pasa en los muelles se queda en los muelles",

        -- ORats
        arena_ORats_name = "Ratas del Petróleo",
        arena_ORats_description = "Cubierto de grasa y aceite",

        -- HRise
        arena_HRise_name = "Rascacielos",
        arena_HRise_description = "No apto para los que temen a las alturas",


        -- Gabz / Indoor
        arena_IDarena_name = "Arena Interior",
        arena_IDarena_description = "Rojo contra Azul",

        arena_IDderby_name = "Derbi Interior",
        arena_IDderby_description = "Pensado para coches… ya sabes",

        -- Nuketown
        arena_Narena_name = "Arena Nuketown",
        arena_Narena_description = "Nuketown clásico",

        arena_NMpark_name = "Nuketown Mirror Park",
        arena_NMpark_description = "Nuketown en la ciudad",


    },
}