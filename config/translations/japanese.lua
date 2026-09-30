if Config.Language ~= "japanese" then return end
Config.Translations = {
    error = {
        choose_team_first = "最初にチームに参加する必要があります",
        no_lives_entered = "プレイヤーのライフ数が入力されていません。",
        max_lives_set = "設定できる最大ライフ数は ",
        no_wager = "賭け金が入力されていません。",
        wager_cap = "賭け金は次の範囲内である必要があります ",
        active_game = "ゲームはすでに進行中です",
        ammo_given = "7秒後に新しい弾を受け取ります",
        cant_do_this = "完全にリスポーンするまで実行できません",
        no_id_entered = "IDが入力されていません",
        need_to_be_lobby_host = "この設定を変更するにはロビーのホストである必要があります",
        daytime_only = "ペイントボールは夜間は営業していません...",
        missing_input = "入力が不足しています...",

        you_are_not_in_lobby = "ロビーに参加していません。",
        lobby_no_longer_exists = "そのロビーはもう存在しません。",
        cannot_join_down = "ダウン中はゲームに参加できません",
        incorrect_passcode = "パスコードが間違っています",
        need_to_choose_weapon = "チームに参加する前に武器を選択する必要があります。",
        team_not_loaded = "チームの読み込みに失敗しました。",

        -- SERVER.LUA
        -- Paintball server-side errors / warnings
        only_host_can_start            = "ホストのみがゲームを開始できます。",
        must_join_team_to_start        = "試合を開始する前にチームに参加する必要があります。",
        game_already_started           = "ゲームはすでに開始されています",
        need_players_per_team          = "各チームに最低1人のプレイヤーが必要です",
        not_enough_players_after_prune = "未所属プレイヤーを削除した後、チームの人数が足りません。",
        stats_reset                    = "全ゲーム統計がリセットされました！プレイヤーが正しく切断されませんでした",

        player_missing_entry_fee       = "%s は %d 不足しています",
        removed_for_no_team            = "試合開始前にチームを選ばなかったため削除されました。",
        ongoing_game_required_spectate = "観戦するにはゲームが進行中である必要があります",
        no_players_in_game             = "ゲーム中のプレイヤーがいません",


        -- SV_LOBBY.LUA
        -- Lobby / host / join errors
        no_lobby_specified             = "ロビーが指定されていません。",
        lobby_no_longer_exists_refresh = "そのロビーはもう存在しません。ロビー一覧を更新します...",
        lobby_locked_passcode          = "ロビーはロックされています。ロビーブラウザのパスコードを入力してください。",
        team_full                      = "チームが満員です",
        join_failed                    = "参加に失敗しました",

        only_host_change_wager         = "賭け金を変更できるのはホストのみです。",
        only_host_change_lives         = "ライフを変更できるのはホストのみです。",
        only_host_change_map           = "マップを変更できるのはホストのみです。",
        only_host_change_mode          = "ゲームモードを変更できるのはホストのみです。",
        only_host_change_match_time    = "試合時間を変更できるのはホストのみです。",
        only_host_shutdown_lobby       = "ロビーを終了できるのはホストのみです。",
        only_host_kick_players         = "プレイヤーをキックできるのはホストのみです。",
        only_host_change_waapons = "武器を変更できるのはホストのみです。",

        invalid_map_key                = "無効なマップキーです。",
        lobby_not_found                = "ロビーが見つかりません。",
        player_too_far_for_host        = "このプレイヤーは遠すぎてホストを渡せません",
        player_already_host            = "あなたはすでにホストです",
        host_removed_far               = "ホストは遠すぎるため削除されました",
        player_not_found_id            = "ID: [%s] のプレイヤーが見つかりません",
        already_hosting_lobby          = "あなたはすでにこのロビーのホストです。終了するか、ホストを譲渡してから別のロビーを作成してください。",
        use_leave_lobby                = "退出したい場合は「ロビーを退出」を使用してください。",
        player_not_in_lobby_anymore    = "そのプレイヤーはもうロビーにいません。",
    },

    success = {
        savedfrinfall = "心配するな！助かったぜ！ :)",
        weapon_chosen = "選択しました: ",
        start_in = "アリーナは10秒後に開始されます",
        e_open_menu = "[E] 武器メニューを開く",

        removed_from_arena = "アリーナ範囲外のため削除されました。",

        team_created = "チームを作成しました。",
        team_updated = "チームを更新しました。",
        invite_sent = "招待を送信しました。",
        joined_team = "チームに参加しました。",
        member_removed = "メンバーを削除しました。",
        owner_transferred = "所有権を譲渡しました。",
        left_team = "チームを退出しました。",
    },

    menu = {
        -- CLIENT.LUA
        arenalobby = "ペイントボール アリーナ ロビー",
        start = "開始",
        players = "プレイヤー",
        redteam = "レッドチーム",
        ffateam = "FFA ロビー",
        blueteam = "ブルーチーム",
        lives = "ライフ数",
        arena_lives = "アリーナライフ",
        wager = "賭け金",
        arena_wager = "アリーナ賭け金",
        weapon = "武器",
        map = "マップ",
        mode = "ゲームモード",
        spectate = "プレイヤーを観戦",
        random = "ランダム",
        pistol_option = "小さくて致命的",
        smg_option = "軽量サブマシンガン",
        shotgun_option = "近距離向けの重いショットガン",
        assault_option = "ヘビー級の銃",
        sniper_option = "スナイパー",
        pistol_header = "ピストル",
        smg_header = "SMG",
        shotgun_header = "ショットガン",
        assault_header = "アサルトライフル",
        sniper_header = "スナイパーライフル",
        close_back = "閉じる (ESC)",
        go_back = "< 戻る",
        player_lives = "プレイヤーライフ",
        arena_lives = "アリーナライフ",
        view_lobby = "ロビーを見る",
        become_host = "ロビーをホストする",
        become_hostt_description = "ロビーのホストになります",
        give_host = "ロビーホストを譲渡",
        give_host_description = "別のプレイヤーにホストを渡します",
        player_id = "(プレイヤーID)",
        host_of_lobby = "ロビーのホストはプレイヤーID: [",

        join = "参加 ",
        choose = "選択 ",
        respawn_in = "リスポーンまで ",
        you_respawn_in = "10秒後にリスポーンします",
        use_uav = "UAV を使用",
        use = "使用 ",
        removed_lobby_host = "ペイントボールから離れすぎたため、ホスト権限が解除されました",

        scoreboard_keybind_desc = "ペイントボールのスコアボードを見る",
        red_flag_blip = "赤い旗",
        blue_flag_blip = "青い旗",

        next_weapon_progress = "(%d/%d) 次の武器は %s",

        -- DUI_LOGIC.LUA
        -- Paintball leaderboard menu
        lb_ffa_title = "🏆 フリー・フォー・オール",
        lb_ffa_description = "FFA ペイントボールの上位プレイヤー。",
        lb_ctf_title = "🚩 キャプチャー・ザ・フラッグ",
        lb_ctf_description = "フラッグ戦のリーダー。",
        lb_gungame_title = "🔫 ガンゲーム",
        lb_gungame_description = "ガンゲームの統計。",
        lb_oitc_title = "💣 ワン・イン・ザ・チャンバー",
        lb_oitc_description = "OITC ラウンドでの成績。",
        lb_hyo_title = "🛡️ ホールド・ユア・オウン",
        lb_hyo_description = "ポジション維持のランキング。",
        lb_tdm_title = "🔥 チームデスマッチ",
        lb_tdm_description = "チームデスマッチのランキング。",
        lb_personal_title = "📊 自分の統計を見る",
        lb_personal_description = "全ゲームモードの個人統計。",

        -- MENUS.LUA
        -- Hub / lobby list
        team_hub_title = "チームハブ",
        team_hub_description = "グローバルペイントボールチームの作成/管理/閲覧",
        create_lobby_title = "ロビー作成",
        create_lobby_description = "新しいペイントボールロビーを作成（任意でパスコード）",
        no_lobbies_title = "ロビーがありません",
        no_lobbies_description = "作成して始めましょう。",
        paintball_lobbies_title = "ペイントボール ロビー",

        lobby_list_title = "ロビー [%s] %s %s",
        lobby_list_desc = "モード: %s | マップ: %s | プレイヤー: %s",
        lobby_view_title = "ロビー [%s] %s %s",
        -- Create lobby dialog
        create_lobby_header = "ロビー作成",
        lobby_name_label = "ロビー名（任意）",
        lobby_pass_label = "パスコード（任意）",
        must_enter_lobby_name = "ロビー名を入力する必要があります",
        -- Passcode dialog
        lobby_locked_title = "ロビーロック",
        enter_passcode_label = "パスコードを入力",
        -- View lobby base actions
        leave_lobby_title = "ロビーを退出",
        leave_lobby_description = "このロビーを退出してロビーブラウザに戻ります。",
        manage_lobby_title = "ロビー管理",
        manage_lobby_description = "ホスト譲渡、終了、またはパスコード設定。",
        leave_prefix = "退出 ",
        -- Rank header in lobby
        rank_header_title = "プレステージ %d • Lv. %d (%s)",
        rank_header_desc = "このレベルのXP: %d / %d（合計: %d）",
        -- Match time
        match_time_title = "試合時間",
        match_time_option = "%d 分",
        match_time_option_description = "%d 分でゲームを終了します。",
        -- Manage lobby submenu
        transfer_host_title = "ホスト譲渡",
        transfer_host_description = "IDで別のプレイヤーにホスト権限を渡します。",
        shutdown_lobby_title = "ロビー終了",
        shutdown_lobby_description = "全員をキックし、リセットしてロビーを削除します。",
        set_passcode_title = "パスコード設定",
        set_passcode_description = "パスコードでロビーをロック（空欄で解除）。",
        kick_player_title = "プレイヤーをキック",
        kick_player_description = "このロビーからプレイヤーを削除します。",
        -- Kick menu
        no_players_to_kick_title = "キックできるプレイヤーがいません",
        no_players_to_kick_description = "現在あなたしかロビーにいません。",
        kick_confirm_title = "%s をキックしますか？",
        kick_confirm_description = "%s をキックしてもよろしいですか？",
        kick_confirm_body = "このロビーから削除されます。",
        kick_yes_title = "はい、キックする",
        kick_yes_description = "%s をロビーから削除します。",
        kick_no_title = "いいえ、戻る",
        kick_no_description = "プレイヤー一覧に戻ります。",
        -- Shutdown confirm dialog
        shutdown_confirm_title = "ロビーを終了してもよろしいですか？",
        shutdown_confirm_description = "全プレイヤーが削除され、ロビーは削除されます。",
        shutdown_yes_title = "はい、終了する",
        shutdown_yes_description = "全員のロビーを終了します。",
        shutdown_no_title = "いいえ、戻る",
        shutdown_no_description = "ロビー管理に戻ります。",
        -- Set passcode dialog
        set_passcode_header = "ロビーパスコード設定",
        passcode_label = "パスコード（空欄で解除）",
        -- Spectate menu
        exit_spectate_title = "観戦を終了",
        exit_spectate_description = "キャラクターに戻ります",
        spectate_player_title = "プレイヤー %s",
        spectate_player_description = "ID: %s",
        -- Choose map
        random_map_description = "ランダムに選ばれたマップ",

        -- OPEN.LUA
        open_menu_hint = "[E] でメニューを開く",
        open_menu_hint_view_arena = "~b~[E] ~w~アリーナを見る",
        ped_text_paintball = "~o~ペイントボール",
        blip_paintball = "ペイントボール",
        target_view_arena_label = "アリーナを見る",
        submit_text = "送信",
        radial_surrender_label = "降参\nペイントボール",

        -- TEMAS.LUA
        -- Teams main menu
        teams_menu_title = "チーム",
        create_team_title = "チーム作成",
        create_team_desc = "新しいペイントボールチームを作成します。",
        no_team_title = "チームなし",
        no_team_desc = "チームを作成して友達を招待しましょう。",
        role_owner = "オーナー",
        role_member = "メンバー",
        role_you = "あなた",
        members_label = "メンバー: %d",
        -- Create team dialog
        create_team_header = "チーム作成",
        create_team_name = "チーム名",
        create_team_tag = "タグ（任意）",
        create_team_color = "カラーHEX（任意）",
        create_team_logo = "ロゴURL（任意）[fivemanage.com のリンクのみ]",
        -- Team creation results
        failed_create_team = "チーム作成に失敗しました: %s",
        created_team = "チームを作成しました。",
        -- Manage team
        manage_members_title = "メンバー管理",
        manage_members_desc = "メンバーのキックや昇格を行います。",
        edit_team_title = "チーム編集",
        edit_team_desc = "名前、タグ、色、ロゴ。",
        invite_player_title = "プレイヤーを招待",
        invite_player_desc = "IDでプレイヤーを招待します。",
        invite_player_dialog_header = "プレイヤーを招待",
        invite_player_id_label = "プレイヤーID",
        leave_team_title = "チームを退出",
        leave_team_desc = "このチームを退出します。",
        failed_load_team = "チームの読み込みに失敗しました。",
        -- Edit team dialog
        edit_team_header = "チーム編集",
        edit_team_field_name = "名前",
        edit_team_field_tag = "タグ",
        edit_team_field_color = "カラーHEX",
        edit_team_field_logo = "ロゴURL",
        failed_update_team = "チーム更新に失敗しました: %s",
        updated_team = "チームを更新しました。",
        -- Invite result
        failed_send_invite = "招待の送信に失敗しました: %s",
        invite_sent = "招待を送信しました。",
        -- Invite received popup
        team_invite_title = "チーム招待",
        join_team_title = "%s に参加",
        join_team_desc = "%s からの招待を承認",
        decline_title = "拒否",
        decline_desc = "この招待を無視します。",
        -- Accept invite
        failed_join_team = "チーム参加に失敗しました: %s",
        joined_team = "チームに参加しました。",
        -- Members list
        members_menu_title = "メンバー • %s",
        member_owner_suffix = "（オーナー）",
        member_you_suffix = "（あなた）",
        -- Manage team member
        promote_member_title = "リーダーに昇格",
        promote_member_desc = "%s にチーム所有権を譲渡します。",
        kick_member_title = "チームからキック",
        kick_member_desc = "%s をチームから削除します。",
        back_title = "戻る",
        back_desc = "メンバー一覧に戻ります。",
        -- Kick / promote results
        failed_kick_member = "メンバーのキックに失敗しました: %s",
        member_removed = "メンバーを削除しました。",
        failed_transfer_owner = "所有権の譲渡に失敗しました: %s",
        owner_transferred = "所有権を譲渡しました。",
        -- Leave team results
        failed_leave_team = "チーム退出に失敗しました: %s",
        left_team = "チームを退出しました。",
        view_members_title = "メンバーを見る",
        view_members_desc = "このチームのメンバーを確認します。",

        -- SERVER.LUA
        -- Match result / notifications (server-side)
        ffa_timeout_winner = "%s の勝利！（制限時間）",
        match_draw_timeout = "引き分けで終了しました（制限時間）。",
        red_team_win_timeout = "レッドチームの勝利！（制限時間）",
        blue_team_win_timeout = "ブルーチームの勝利！（制限時間）",
        red_team_win = "レッドチームの勝利！",
        blue_team_win = "ブルーチームの勝利！",
        generic_team_win = "%s チームの勝利！",
        ffa_winner = "%s の勝利！",
        eliminated_message = "%s は脱落しました！",
        ffa_players_left = "FFA 残り %d 人！",
        players_left_red = "レッドチーム残り %d 人！",
        players_left_blue = "ブルーチーム残り %d 人！",
        host_now = "あなたがロビーホストになりました。",
        removed_unteamed_summary = "開始前に未所属プレイヤー %d 人%s を削除しました。",
        lives_left_message = "%s の残りライフ: %d",

        -- SV_LOBBY.LUA
        -- FFA mode switching
        ffa_full_spectate = "FFA が満員のため、観戦になります。",
        ffa_move_fail_spectate = "FFA への移動に失敗しました。観戦になります。",

        -- Lobby lifecycle
        lobby_shutdown_by_host = "ロビー [%d] はホストにより終了されました。",
        left_lobby_message = "ロビー [%d] を退出しました。",
        host_now = "あなたがロビーホストになりました。",

        -- Join / leave notifications
        joined_game_message = "%s がゲームに参加しました！",
        joined_red_team_message = "%s がレッドチームに参加しました！",
        joined_blue_team_message = "%s がブルーチームに参加しました！",
        left_lobby_announce = "%s がロビーを退出しました！",

        -- Wager / lives / map / mode / match time
        wager_set_prize_pool = "賞金プールに $%d が設定されました！",
        lives_set_message = "各プレイヤーのライフを %d に設定しました！",
        map_set_to = "マップを %s に設定しました",
        mode_set_to = "ゲームモードを %s に設定しました",
        match_time_set = "試合時間を %d 分に設定しました。",

        -- Passcode
        passcode_set_and_locked = "パスコードを設定し、ロビーをロックしました。",
        passcode_cleared_unlocked = "パスコードを解除し、ロビーを開放しました。",

        -- Lobby create / host
        lobby_created_host = "ロビー [%d] を作成しました。あなたがホストです。",
        already_hosting_lobby = "あなたはすでにロビー [%d] のホストです。終了するか、ホストを譲渡してから別のロビーを作成してください。",

        -- Kick messages
        kicked_from_lobby = "ホストによりロビーからキックされました。",
        kicked_broadcast = "%s はホストによりロビーからキックされました。",

        -- Lobby gate / misc
        lobby_not_found_msg = "ロビーが見つかりません",
        incorrect_passcode_msg = "パスコードが間違っています",

        -- Members list team labels
        team_red_label = "赤",
        team_blue_label = "青",
        team_ffa_label = "FFA",
        team_spectator_label = "観戦",
        team_unknown_label = "不明",
        default_player_name = "プレイヤー %d",

        -- GAME MODES
        mode_tdm_title = "チームデスマッチ",
        mode_tdm_description = "12v12 • 先にキル上限に到達したチームが勝利。",
        mode_hyo_title = "ホールド・ユア・オウン",
        mode_hyo_description = "12v12 • 限られたライフでできるだけ長く生き残れ。",
        mode_ctf_title = "キャプチャー・ザ・フラッグ",
        mode_ctf_description = "12v12 • 敵の旗を3回奪取すれば勝利。",
        mode_gungame_title = "ガンゲーム",
        mode_gungame_description = "キルするたびに武器がアップグレード。最終武器に到達して勝利。",
        mode_ffa_title = "フリー・フォー・オール",
        mode_ffa_description = "全員敵。キル目標に到達して勝利。",
        mode_oitc_title = "ワン・イン・ザ・チャンバー",
        mode_oitc_description = "最初は1発。キルごとに1発追加。1発を無駄にするな。",

        -- SCOREBOARD HEADERS
        sb_player = "プレイヤー",
        sb_score = "スコア",
        sb_kills_short = "K",
        sb_deaths_short = "D",
        sb_points = "ポイント",
        sb_lives = "ライフ",
        sb_ctf = "CTF",
        sb_kd_ratio = "KD",

        mode_kc_title = "キルコンファーム",
        mode_kc_description = "12v12 | 敵タグを回収してキルを確認。味方タグで拒否。",

        set_team_outfit_male_title = "男性の服装を設定",
        set_team_outfit_female_title = "女性の服装を設定",

        team_info_title = "チームの仕組み",
        team_info_desc = "チーム、色、服装の仕組みを学ぶ",

        team_info_header = "ペイントボール チームガイド",

        team_info_how_title = "チームとは？",
        team_info_how_desc = "チームはグローバルなペイントボールグループです。メンバーは一緒に試合へ参加でき、色や服装を共有できます。",

        team_info_color_title = "チームカラー",
        team_info_color_desc = "片側が全員同じチームの場合、UIカラーはそのチームの色になります。",

        team_info_outfits_title = "チームの服装",
        team_info_outfits_desc = "チームオーナーは男女の服装を設定できます。片側が完全に同じチームで揃った場合、自動的に適用されます。",

        team_info_rules_title = "重要ルール",
        team_info_rules_desc = "• チーム名とタグはユニークである必要があります\n• タグは4文字まで\n• 混成チームではチームカラーや服装は適用されません",

        open_leaderboard = "📋 ランキングメニューを開く",
        leaderboard_options = "📋 ランキングオプション",

        lb_kc_title = "キルコンファーム",
        lb_kc_description = "キルコンファームのトッププレイヤーを表示",

                -- Jpark
        arena_Jpark_name = "ジュラシック・パーク",
        arena_Jpark_description = "ジュラシック・パークへようこそ",

        -- Wball
        arena_Wball_name = "レッキングボール",
        arena_Wball_description = "破壊の時間だ",

        -- Syard
        arena_Syard_name = "スクラップヤード 2",
        arena_Syard_description = "巨人が倒れる",

        -- Swreck
        arena_Swreck_name = "難破船",
        arena_Swreck_description = "船が座礁した",

        -- IWhouse
        arena_IWhouse_name = "工業施設",
        arena_IWhouse_description = "落ちないように注意",

        -- Fpalace
        arena_Fpalace_name = "未来の宮殿",
        arena_Fpalace_description = "未来的すぎて遮蔽物がない",

        -- Tsoldier
        arena_Tsoldier_name = "トイ・ソルジャー",
        arena_Tsoldier_description = "大きな世界の小さな兵士",

        -- Tcity
        arena_Tcity_name = "タイヤ・シティ",
        arena_Tcity_description = "あのタイヤ・シティではない",

        -- WITpark
        arena_WITpark_name = "公園の散歩",
        arena_WITpark_description = "タイヤ・パーク・シティ",

        -- Ttown
        arena_Ttown_name = "チューブ・タウン",
        arena_Ttown_description = "チューブの街",

        -- UConstruction
        arena_UConstruction_name = "アップタウン建設現場",
        arena_UConstruction_description = "建設現場の混乱",

        -- Gstreet
        arena_Gstreet_name = "グローブ・ストリート",
        arena_Gstreet_description = "この通りを仕切っているのは誰だ？",

        -- Scity
        arena_Scity_name = "スタブ・シティ",
        arena_Scity_description = "トレーラーパークの大混戦",

        -- RSyard
        arena_RSyard_name = "レッズの廃品置き場",
        arena_RSyard_description = "錆、スクラップ、そして混沌",

        -- Ghouse
        arena_Ghouse_name = "おばあちゃんの家",
        arena_Ghouse_description = "一番おいしいクッキーを作る",

        -- GCVilliage
        arena_GCVilliage_name = "グレート・キャンプ・ビレッジ",
        arena_GCVilliage_description = "足元に注意",

        -- Highjacked
        arena_Highjacked_name = "ハイジャック",
        arena_Highjacked_description = "船酔いに注意",

        -- DTDocks
        arena_DTDocks_name = "ダウンタウン・ドック",
        arena_DTDocks_description = "ドックで起きたことはドックに残る",

        -- ORats
        arena_ORats_name = "オイル・ラッツ",
        arena_ORats_description = "油と汚れまみれ",

        -- HRise
        arena_HRise_name = "高層ビル",
        arena_HRise_description = "高所恐怖症の方は注意",


        -- Gabz / Indoor
        arena_IDarena_name = "屋内アリーナ",
        arena_IDarena_description = "レッド vs ブルー",

        arena_IDderby_name = "屋内ダービー",
        arena_IDderby_description = "本来は車用だけど…まあね",

        -- Nuketown
        arena_Narena_name = "ニュークタウン・アリーナ",
        arena_Narena_description = "クラシック・ニュークタウン",

        arena_NMpark_name = "ニュークタウン・ミラーパーク",
        arena_NMpark_description = "街中のニュークタウン",

    },
}
