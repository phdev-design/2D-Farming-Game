# walk_state_player2.gd
extends NodeState

# 在 Godot 編輯器中，將 Player2 節點和其對應的 AnimatedSprite2D 節點拖曳到這裡
@export var player: CharacterBody2D # 建議使用通用的 CharacterBody2D，或你自己的 Player2 類別
@export var animated_sprite_2d: AnimatedSprite2D
@export var speed: float = 100.0


# _on_physics_process 會在物理引擎的每一幀被呼叫
func _on_physics_process(_delta: float) -> void:
	# 【關鍵修改】從你的全域輸入事件腳本中獲取 Player 2 的移動向量
	# 注意：你需要在你的 GameInputEvents.gd 中建立這個 get_movement_vector_player2 函式，
	# 並將其綁定到第二位玩家的控制鍵（例如 I, J, K, L）。
	var input_vector = GameInputEvents.get_movement_vector_player2()
	
	# 設定玩家的速度
	player.velocity = input_vector * speed
	player.move_and_slide()
	
	# 如果玩家正在移動，就更新其儲存的方向
	# 這樣當他停下來時，Idle 狀態才知道該面向哪裡
	if input_vector != Vector2.ZERO:
		player.direction = input_vector
	
	# 根據目前的移動方向更新動畫與翻轉
	update_animation_and_flip(player.velocity)


# _on_next_transitions 用來檢查是否需要轉換到下一個狀態
func _on_next_transitions() -> void:
	# 【關鍵修改】優先檢查 Player 2「使用工具」的輸入
	if GameInputEvents.use_tool_player2():
		# 使用 match 陳述式來根據當前工具決定下一個狀態
		match player.current_tool:
			DataTypes.Tools.None:
				pass # 如果手上沒拿工具，就繼續走路
			DataTypes.Tools.AxeWood:
				transition.emit("Chopping_P2") # 建議狀態名稱也加上後綴以區分
				return
			DataTypes.Tools.TillGround:
				transition.emit("Tilling_P2")
				return
			DataTypes.Tools.WaterCrops:
				transition.emit("Watering_P2")
				return

	# 【關鍵修改】如果 Player 2 沒有任何移動輸入...
	if !GameInputEvents.is_moving_player2():
		# ...就發出訊號，轉換到 "Idle_P2" 狀態
		transition.emit("Idle_P2")


# _on_exit 會在離開此狀態時被呼叫一次
func _on_exit() -> void:
	# 離開走路狀態時，停止走路動畫。
	# Idle 狀態會立即接管並播放它自己的閒置動畫。
	animated_sprite_2d.stop()


# 【核心修改】一個專門用來更新動畫和處理水平翻轉 (flip_h) 的輔助函式
func update_animation_and_flip(velocity: Vector2) -> void:
	# 如果沒有在移動，就不更新動畫，保持最後一幀的樣子
	if velocity == Vector2.ZERO:
		return

	var anim_name = "walk_front" # 預設的動畫名稱

	# 比較 X 軸和 Y 軸的移動量，看哪個方向的移動更顯著
	if abs(velocity.x) > abs(velocity.y):
		# 水平方向的移動量更大
		# 動畫永遠使用 "walk_side"
		anim_name = "walk_side" 
		if velocity.x > 0:
			# 向右移動，不翻轉圖像
			animated_sprite_2d.flip_h = false
		else:
			# 向左移動，水平翻轉圖像
			animated_sprite_2d.flip_h = true
	else:
		# 垂直方向的移動量更大（或兩者相等）
		# 在垂直移動時，我們不希望角色被翻轉，所以重設 flip_h
		animated_sprite_2d.flip_h = false
		if velocity.y > 0:
			anim_name = "walk_front" # Vector2.DOWN 對應 "front"
		else:
			anim_name = "walk_back"  # Vector2.UP 對應 "back"
	
	# 為了避免不必要的重複播放，只在需要更換動畫時才呼叫 .play()
	if animated_sprite_2d.animation != anim_name:
		animated_sprite_2d.play(anim_name)
