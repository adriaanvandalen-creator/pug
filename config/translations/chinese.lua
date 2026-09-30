if Config.Language ~= "chinese" then return end

Config.Translations = {
    error = {
        choose_team_first = "你需要先加入一个队伍",
        no_lives_entered = "未输入玩家生命值。",
        max_lives_set = "可设置的最大生命值为 ",
        no_wager = "未输入赌注金额。",
        wager_cap = "赌注必须在以下范围内：",
        active_game = "当前已有一场比赛正在进行",
        ammo_given = "你将在 7 秒内获得一颗新子弹",
        cant_do_this = "你必须完全重生后才能执行此操作",
        no_id_entered = "未输入任何 ID",
        need_to_be_lobby_host = "你必须是大厅主持人才能进行此设置",
        daytime_only = "夜间暂停开放，白天才能进入 Paintball...",
        missing_input = "缺少输入...",

        you_are_not_in_lobby = "你不在任何大厅中。",
        lobby_no_longer_exists = "该大厅已不存在。",
        cannot_join_down = "你处于倒地状态，无法加入游戏",
        incorrect_passcode = "密码错误",
        need_to_choose_weapon = "加入队伍前必须选择武器。",
        team_not_loaded = "加载队伍失败。",

        -- SERVER.LUA
        only_host_can_start = "只有大厅主持人可以开始游戏。",
        must_join_team_to_start = "开始比赛前必须加入一个队伍。",
        game_already_started = "比赛已经开始",
        need_players_per_team = "每个队伍至少需要 1 名玩家",
        not_enough_players_after_prune = "移除无队伍玩家后，队伍人数不足。",
        stats_reset = "所有比赛统计已重置！某位玩家未正确断开连接",

        player_missing_entry_fee = "%s 缺少 %d",
        removed_for_no_team = "你未选择队伍，被移出比赛。",
        ongoing_game_required_spectate = "必须有正在进行的比赛才能观看",
        no_players_in_game = "当前比赛中没有玩家",

        -- SV_LOBBY.LUA
        no_lobby_specified = "未指定大厅。",
        lobby_no_longer_exists_refresh = "该大厅已不存在。正在刷新大厅列表...",
        lobby_locked_passcode = "大厅已上锁。请在大厅浏览器中输入密码。",
        team_full = "队伍已满",
        join_failed = "加入失败",

        only_host_change_wager = "只有大厅主持人能修改赌注。",
        only_host_change_lives = "只有大厅主持人能修改生命值。",
        only_host_change_map = "只有大厅主持人能修改地图。",
        only_host_change_mode = "只有大厅主持人能修改游戏模式。",
        only_host_change_match_time = "只有大厅主持人能修改比赛时长。",
        only_host_shutdown_lobby = "只有大厅主持人能关闭大厅。",
        only_host_kick_players = "只有大厅主持人能踢出玩家。",
        only_host_change_waapons = "只有房主可以更改武器。",

        invalid_map_key = "无效的地图键值。",
        lobby_not_found = "未找到大厅。",
        player_too_far_for_host = "此玩家距离太远，无法让他成为大厅主持人",
        player_already_host = "你已经是大厅主持人",
        host_removed_far = "大厅主持人因距离过远被移除",
        player_not_found_id = "未找到 ID 为 [%s] 的玩家",
        already_hosting_lobby = "你已经主持了一个大厅。请关闭或转移主持权后再创建新大厅。",
        use_leave_lobby = "如需离开，请使用“退出大厅”。",
        player_not_in_lobby_anymore = "该玩家已不在大厅中。",
    },

    success = {
        savedfrinfall = "别担心，你被救了，国王！ :)",
        weapon_chosen = "你已选择 ",
        start_in = "竞技场将在 10 秒后开始",
        e_open_menu = "[E] 打开武器菜单",

        removed_from_arena = "你已被移出竞技场区域。",

        team_created = "队伍已创建。",
        team_updated = "队伍已更新。",
        invite_sent = "邀请已发送。",
        joined_team = "你加入了队伍。",
        member_removed = "队员已移除。",
        owner_transferred = "所有权已转移。",
        left_team = "你已离开队伍。",
    },

    menu = {
        -- CLIENT.LUA
        arenalobby = "Paintball 竞技场大厅",
        start = "开始",
        players = "玩家",
        redteam = "红队",
        ffateam = "FFA 大厅",
        blueteam = "蓝队",
        lives = "生命值数量",
        arena_lives = "竞技场生命值",
        wager = "赌注金额",
        arena_wager = "竞技场赌注",
        weapon = "武器",
        map = "地图",
        mode = "游戏模式",
        spectate = "观看玩家",
        random = "随机",
        pistol_option = "小巧致命",
        smg_option = "轻型冲锋枪",
        shotgun_option = "近距离重型霰弹枪",
        assault_option = "大威力突击武器",
        sniper_option = "狙击精确射击",
        pistol_header = "手枪",
        smg_header = "冲锋枪",
        shotgun_header = "霰弹枪",
        assault_header = "突击步枪",
        sniper_header = "狙击步枪",
        close_back = "关闭 (ESC)",
        go_back = "< 返回",
        player_lives = "玩家生命值",
        arena_lives = "竞技场生命值",
        view_lobby = "查看大厅",
        become_host = "成为主持人",
        become_hostt_description = "成为大厅主持人",
        give_host = "转移主持人",
        give_host_description = "将主持人转移给其他玩家",
        player_id = "(玩家 ID)",
        host_of_lobby = "该大厅的主持人 ID 为： [",

        join = "加入 ",
        choose = "选择 ",
        respawn_in = "将在 ",
        you_respawn_in = "你将在 10 秒后重生",
        use_uav = "使用 UAV",
        use = "使用 ",
        removed_lobby_host = "你离比赛太远，已被取消主持人资格",

        scoreboard_keybind_desc = "查看 Paintball 计分板",
        red_flag_blip = "红旗",
        blue_flag_blip = "蓝旗",

        next_weapon_progress = "(%d/%d) 下一把武器：%s",

        -- DUI_LOGIC.LUA
        lb_ffa_title = "🏆 自由混战 (FFA)",
        lb_ffa_description = "FFA 模式顶尖玩家。",
        lb_ctf_title = "🚩 占领旗帜",
        lb_ctf_description = "旗帜争夺战排行榜。",
        lb_gungame_title = "🔫 枪械升级战",
        lb_gungame_description = "枪械升级战 模式统计。",
        lb_oitc_title = "💣 一发入魂 (OITC)",
        lb_oitc_description = "OITC 回合表现。",
        lb_hyo_title = "🛡️ 守住领地",
        lb_hyo_description = "守住领地排行榜。",
        lb_tdm_title = "🔥 团队死斗",
        lb_tdm_description = "团队死斗排行榜。",
        lb_personal_title = "📊 我的统计",
        lb_personal_description = "所有模式的个人统计。",

        -- MENUS.LUA
        team_hub_title = "队伍中心",
        team_hub_description = "创建/管理/查看你的 Paintball 队伍",
        create_lobby_title = "创建大厅",
        create_lobby_description = "创建新大厅（可选密码）",
        no_lobbies_title = "暂无大厅",
        no_lobbies_description = "创建一个大厅开始游戏。",
        paintball_lobbies_title = "Paintball 大厅",

        lobby_list_title = "大厅 [%s] %s %s",
        lobby_list_desc = "模式: %s | 地图: %s | 玩家: %s",
        lobby_view_title = "大厅 [%s] %s %s",

        create_lobby_header = "创建大厅",
        lobby_name_label = "大厅名称（可选）",
        lobby_pass_label = "大厅密码（可选）",
        must_enter_lobby_name = "你必须输入大厅名称",

        lobby_locked_title = "大厅已上锁",
        enter_passcode_label = "输入密码",

        leave_lobby_title = "退出大厅",
        leave_lobby_description = "返回大厅浏览页面。",
        manage_lobby_title = "管理大厅",
        manage_lobby_description = "转移主持人、关闭或设置密码。",
        leave_prefix = "退出 ",

        rank_header_title = "声望 %d • 等级 %d (%s)",
        rank_header_desc = "本等级经验：%d / %d（总计：%d）",

        match_time_title = "比赛时长",
        match_time_option = "%d 分钟",
        match_time_option_description = "在 %d 分钟后结束比赛。",

        transfer_host_title = "转移主持人",
        transfer_host_description = "将主持人转移给其他玩家。",
        shutdown_lobby_title = "关闭大厅",
        shutdown_lobby_description = "踢出所有玩家并删除大厅。",
        set_passcode_title = "设置密码",
        set_passcode_description = "设置大厅密码（留空为清除）。",
        kick_player_title = "踢出玩家",
        kick_player_description = "将玩家移出大厅。",

        no_players_to_kick_title = "没有可踢出的玩家",
        no_players_to_kick_description = "你是大厅中唯一的玩家。",
        kick_confirm_title = "踢出 %s？",
        kick_confirm_description = "确定要踢出 %s？",
        kick_confirm_body = "他们将被移出大厅。",
        kick_yes_title = "是，踢出玩家",
        kick_yes_description = "从大厅中移除 %s。",
        kick_no_title = "否，返回",
        kick_no_description = "返回玩家列表。",

        shutdown_confirm_title = "确定要关闭大厅？",
        shutdown_confirm_description = "所有玩家将被移除，大厅将被删除。",
        shutdown_yes_title = "是，关闭大厅",
        shutdown_yes_description = "关闭大厅。",
        shutdown_no_title = "否，返回",
        shutdown_no_description = "返回管理界面。",

        set_passcode_header = "设置大厅密码",
        passcode_label = "密码（留空为清除）",

        exit_spectate_title = "退出观战",
        exit_spectate_description = "返回角色控制",
        spectate_player_title = "玩家 %s",
        spectate_player_description = "ID：%s",

        random_map_description = "随机选择地图",

        -- OPEN.LUA
        open_menu_hint = "[E] 打开菜单",
        open_menu_hint_view_arena = "~b~[E] ~w~查看竞技场",
        ped_text_paintball = "~o~PAINTBALL",
        blip_paintball = "Paintball",
        target_view_arena_label = "查看竞技场",
        submit_text = "提交",
        radial_surrender_label = "投降 \n Paintball",

        -- Teams
        teams_menu_title = "队伍",
        create_team_title = "创建队伍",
        create_team_desc = "创建一个新的 Paintball 队伍。",
        no_team_title = "无队伍",
        no_team_desc = "创建队伍以邀请朋友。",
        role_owner = "队长",
        role_member = "成员",
        role_you = "你",
        members_label = "成员：%d",

        create_team_header = "创建队伍",
        create_team_name = "队伍名称",
        create_team_tag = "标签（可选）",
        create_team_color = "颜色 Hex（可选）",
        create_team_logo = "Logo 链接（可选）[仅限 fivemanage.com 链接]",

        failed_create_team = "创建队伍失败：%s",
        created_team = "队伍创建成功。",

        manage_members_title = "管理成员",
        manage_members_desc = "踢出或提升队员。",
        edit_team_title = "编辑队伍",
        edit_team_desc = "名称、标签、颜色、Logo。",
        invite_player_title = "邀请玩家",
        invite_player_desc = "通过 ID 邀请玩家。",
        invite_player_dialog_header = "邀请玩家",
        invite_player_id_label = "玩家 ID",

        leave_team_title = "离开队伍",
        leave_team_desc = "离开当前队伍。",
        failed_load_team = "加载队伍失败。",

        edit_team_header = "编辑队伍",
        edit_team_field_name = "名称",
        edit_team_field_tag = "标签",
        edit_team_field_color = "颜色 Hex",
        edit_team_field_logo = "Logo 链接",

        failed_update_team = "更新队伍失败：%s",
        updated_team = "队伍更新成功。",

        failed_send_invite = "发送邀请失败：%s",
        invite_sent = "邀请已发送。",

        team_invite_title = "队伍邀请",
        join_team_title = "加入 %s",
        join_team_desc = "接受来自 %s 的邀请",
        decline_title = "拒绝",
        decline_desc = "忽略此邀请。",

        failed_join_team = "加入队伍失败：%s",
        joined_team = "你加入了队伍。",

        members_menu_title = "成员 • %s",
        member_owner_suffix = "（队长）",
        member_you_suffix = "（你）",

        promote_member_title = "升为队长",
        promote_member_desc = "将队长权限移交给 %s。",
        kick_member_title = "踢出队伍",
        kick_member_desc = "将 %s 移出队伍。",
        back_title = "返回",
        back_desc = "回到成员列表。",

        failed_kick_member = "踢出成员失败：%s",
        member_removed = "已移除成员。",
        failed_transfer_owner = "转移队长失败：%s",
        owner_transferred = "队长已更换。",

        failed_leave_team = "离开队伍失败：%s",
        left_team = "你已离开队伍。",

        view_members_title = "查看成员",
        view_members_desc = "查看此队伍的成员。",

        -- SERVER.LUA results
        ffa_timeout_winner = "%s 获胜！（时间限制）",
        match_draw_timeout = "比赛以平局结束（时间限制）。",
        red_team_win_timeout = "红队获胜！（时间限制）",
        blue_team_win_timeout = "蓝队获胜！（时间限制）",
        red_team_win = "红队获胜！",
        blue_team_win = "蓝队获胜！",
        generic_team_win = "%s 队获胜！",
        ffa_winner = "%s 获胜！",
        eliminated_message = "%s 被淘汰！",
        ffa_players_left = "FFA 剩余 %d 名玩家！",
        players_left_red = "红队剩余 %d 名玩家！",
        players_left_blue = "蓝队剩余 %d 名玩家！",

        host_now = "你现在是大厅主持人。",
        removed_unteamed_summary = "开赛前移除了 %d 名未选队玩家。",

        lives_left_message = "%s 剩余 %d 条生命",

        ffa_full_spectate = "FFA 已满，你现处于观战模式。",
        ffa_move_fail_spectate = "无法加入 FFA，你现处于观战模式。",

        lobby_shutdown_by_host = "大厅 [%d] 已被主持人关闭。",
        left_lobby_message = "你已离开大厅 [%d]。",
        joined_game_message = "%s 加入了游戏！",
        joined_red_team_message = "%s 加入了红队！",
        joined_blue_team_message = "%s 加入了蓝队！",
        left_lobby_announce = "%s 离开了大厅！",

        wager_set_prize_pool = "奖金池已设置为 $%d！",
        lives_set_message = "每位玩家的生命值设为 %d！",
        map_set_to = "地图已更改为 %s",
        mode_set_to = "游戏模式已更改为 %s",
        match_time_set = "比赛时长设为 %d 分钟。",

        passcode_set_and_locked = "密码已设置，大厅已上锁。",
        passcode_cleared_unlocked = "密码已清除，大厅已解锁。",

        lobby_created_host = "大厅 [%d] 已创建，你是主持人。",
        already_hosting_lobby = "你已经主持大厅 [%d]。关闭或转移主持人后才能创建新大厅。",

        kicked_from_lobby = "你被大厅主持人踢出。",
        kicked_broadcast = "%s 被大厅主持人踢出。",

        lobby_not_found_msg = "未找到大厅",
        incorrect_passcode_msg = "密码错误",

        team_red_label = "红队",
        team_blue_label = "蓝队",
        team_ffa_label = "FFA",
        team_spectator_label = "观战",
        team_unknown_label = "未知",
        default_player_name = "玩家 %d",

        -- GAME MODES
        mode_tdm_title = "团队死斗",
        mode_tdm_description = "12v12 • 率先达到击杀上限的队伍获胜。",

        mode_hyo_title = "坚持到底",
        mode_hyo_description = "12v12 • 在有限生命下尽可能坚持更久。",

        mode_ctf_title = "夺旗模式",
        mode_ctf_description = "12v12 • 首先夺取敌方旗帜三次的队伍获胜。",

        mode_gungame_title = "武器升级战",
        mode_gungame_description = "每次击杀都会升级武器。到达最终武器即可获胜。",

        mode_ffa_title = "自由混战",
        mode_ffa_description = "各自为战。率先达到击杀目标者获胜。",

        mode_oitc_title = "一发入魂",
        mode_oitc_description = "你只有一颗子弹。每次击杀可获得一颗新的子弹。让每一枪都物尽其用。",

        -- SCOREBOARD HEADERS
        sb_player       = "玩家",
        sb_score        = "得分",
        sb_kills_short  = "K",
        sb_deaths_short = "D",
        sb_points       = "积分",
        sb_lives        = "生命",
        sb_ctf          = "夺旗",
        sb_kd_ratio     = "K/D",

        mode_kc_title = "确认击杀",
        mode_kc_description = "12v12 | 拾取敌方标牌以确认击杀，拾取己方标牌可阻止得分",

        set_team_outfit_male_title   = "设置男性服装",
        set_team_outfit_female_title = "设置女性服装",

        team_info_title = "队伍系统说明",
        team_info_desc  = "了解队伍、颜色和服装的运作方式",

        team_info_header = "彩弹队伍指南",

        team_info_how_title = "什么是队伍？",
        team_info_how_desc = "队伍是全局彩弹团队。成员可以一起参加比赛，并共享队伍颜色和服装。",

        team_info_color_title = "队伍颜色",
        team_info_color_desc = "如果同一方的所有玩家都属于同一个队伍，界面颜色将显示为该队伍的颜色。",

        team_info_outfits_title = "队伍服装",
        team_info_outfits_desc = "队伍拥有者可以设置男性和女性服装。当整个队伍在同一方时将自动应用。",

        team_info_rules_title = "重要规则",
        team_info_rules_desc = "• 队伍名称和标签必须唯一\n• 标签最多 4 个字符\n• 混合队伍不会使用队伍颜色或服装",

        open_leaderboard = "📋 打开排行榜菜单",
        leaderboard_options = "📋 排行榜选项",

        lb_kc_title = "击杀确认",
        lb_kc_description = "查看击杀确认模式中的顶尖玩家",

                -- Jpark
        arena_Jpark_name = "侏罗纪公园",
        arena_Jpark_description = "欢迎来到侏罗纪公园",

        -- Wball
        arena_Wball_name = "破坏球",
        arena_Wball_description = "是时候狠狠干一场了",

        -- Syard
        arena_Syard_name = "废料场 2",
        arena_Syard_description = "巨人倒下了",

        -- Swreck
        arena_Swreck_name = "沉船",
        arena_Swreck_description = "一艘船已经失事",

        -- IWhouse
        arena_IWhouse_name = "工业厂房",
        arena_IWhouse_description = "小心别掉下去",

        -- Fpalace
        arena_Fpalace_name = "未来宫殿",
        arena_Fpalace_description = "过于未来化，几乎没有掩体",

        -- Tsoldier
        arena_Tsoldier_name = "玩具士兵",
        arena_Tsoldier_description = "小人物的大世界",

        -- Tcity
        arena_Tcity_name = "轮胎城",
        arena_Tcity_description = "不是那个轮胎城",

        -- WITpark
        arena_WITpark_name = "公园漫步",
        arena_WITpark_description = "轮胎公园城",

        -- Ttown
        arena_Ttown_name = "管道小镇",
        arena_Ttown_description = "管道之城",

        -- UConstruction
        arena_UConstruction_name = "上城区施工区",
        arena_UConstruction_description = "施工现场的混乱",

        -- Gstreet
        arena_Gstreet_name = "格罗夫街",
        arena_Gstreet_description = "谁在掌控这条街区？",

        -- Scity
        arena_Scity_name = "刺杀城",
        arena_Scity_description = "拖车公园的混战",

        -- RSyard
        arena_RSyard_name = "雷德的废品场",
        arena_RSyard_description = "锈迹、废料与混乱",

        -- Ghouse
        arena_Ghouse_name = "奶奶的房子",
        arena_Ghouse_description = "她做的饼干最好吃",

        -- GCVilliage
        arena_GCVilliage_name = "大营地村庄",
        arena_GCVilliage_description = "注意脚下",

        -- Highjacked
        arena_Highjacked_name = "劫持",
        arena_Highjacked_description = "尽量别晕船",

        -- DTDocks
        arena_DTDocks_name = "市中心码头",
        arena_DTDocks_description = "码头发生的事就留在码头",

        -- ORats
        arena_ORats_name = "石油鼠",
        arena_ORats_description = "浑身都是油和污垢",

        -- HRise
        arena_HRise_name = "高楼大厦",
        arena_HRise_description = "不适合恐高者",


        -- Gabz / Indoor
        arena_IDarena_name = "室内竞技场",
        arena_IDarena_description = "红队对蓝队",

        arena_IDderby_name = "室内德比",
        arena_IDderby_description = "本来是给车用的……你懂的",

        -- Nuketown
        arena_Narena_name = "核弹小镇竞技场",
        arena_Narena_description = "经典核弹小镇",

        arena_NMpark_name = "核弹小镇·镜像公园",
        arena_NMpark_description = "城市中的核弹小镇",

    },
}
