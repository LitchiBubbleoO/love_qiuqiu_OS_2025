return {
    -- ========== 游戏时间设置 ==========
    -- 游戏结束时间（秒）
    game_end_time = 300,
    -- 显示排行榜时间（秒）
    show_rank_time = 10,
    
    -- ========== 玩家设置 ==========
    -- 默认半径
    default_radius = 20,
    -- 默认速度
    default_speed = 200,
    -- 默认分数
    default_score = 0,
    -- 默认等级
    default_level = 1,
    -- 等级提升所需分数
    score_per_level = 10,
    -- 每级增加的半径
    radius_per_level = 2,
    
    -- ========== 游戏区域设置 ==========
    -- 游戏区域起始X坐标（玩家列表区域宽度）
    game_area_start_x = 200,
    -- 游戏区域宽度
    game_area_width = 600,
    -- 游戏区域起始Y坐标
    game_area_start_y = 0,
    -- 游戏区域高度
    game_area_height = 600,
    
    -- ========== 玩家初始位置 ==========
    -- 玩家初始X坐标
    player_init_x = 400,
    -- 玩家初始Y坐标
    player_init_y = 300,
    
    -- ========== 窗口设置 ==========
    -- 窗口宽度
    window_width = 800,
    -- 窗口高度
    window_height = 600,
    
    -- ========== 网络设置 ==========
    -- 位置发送间隔（秒）
    send_interval = 0.05,
    -- 插值时间（秒，用于平滑其他玩家移动）
    interpolation_time = 0.15,
    -- 重连间隔（秒）
    reconnect_interval = 5.0,
    
    -- ========== UI设置 ==========
    -- 玩家列表区域宽度
    player_list_width = 200,
    -- 默认背景颜色
    default_background_color = {0.1, 0.1, 0.15},
    -- 默认前景颜色
    default_foreground_color = {1, 1, 1},
    
    -- ========== 房间设置 ==========
    -- 最大玩家人数（用于房间创建）
    max_players = 10,
    -- 房间列表每页显示数量
    rooms_per_page = 12,
    -- 服务器地址
    server_host = "47.97.172.52",
    -- server_host = "47.108.78.65",
    -- 服务器端口
    server_port = 5555,
}
