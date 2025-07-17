# idle_state_player2.gd
extends NodeState

# 在 Godot 編輯器中，將 Player2 節點和其對應的 AnimatedSprite2D 節點拖曳到這裡
@export var player: CharacterBody2D # 建議使用通用的 CharacterBody2D，或你自己的 Player2 類別
@export var animated_sprite_2d: AnimatedSprite2D

# _on_enter 會在進入此狀態時被呼叫一次
func _on_enter() -> void:
	# 玩家進入閒置狀態，速度應立即歸零
	player.velocity = Vector2.ZERO
	# 根據玩家最後的移動方向，更新並播放對應的閒置動畫
	# 這可以確保角色在停下來時，會面向最後移動的方向
	update_animation_and_flip(player.direction)


# _on_physics_process 會在物理引擎的每一幀被呼叫
func _on_physics_process(_delta: float) -> void:
	# 持續確保玩家速度為零，避免殘留的動量
	player.velocity = Vector2.ZERO
	player.move_and_slide()


# _on_next_transitions 用來檢查是否需要轉換到下一個狀態
func _on_next_transitions() -> void:
	# 【關鍵修改】檢查 Player 2 是否觸發了「使用工具」的輸入
	if GameInputEvents.use_tool_player2():
		print("B. use_tool is true! Current tool is: ", player.current_tool)
		# 使用 match 陳述式來根據當前工具決定下一個狀態
		match player.current_tool:
			DataTypes.Tools.None:
				return # 如果手上沒拿工具，就什麼事都不做
			DataTypes.Tools.AxeWood:
				print("C. Trying to transition to Chopping_P2")
				transition.emit("Chopping_P2") # 建議狀態名稱也加上後綴以區分
			DataTypes.Tools.TillGround:
				transition.emit("Tilling_P2")
			DataTypes.Tools.WaterCrops:
				transition.emit("Watering_P2")
		return # 執行完工具操作後就結束，避免再檢查移動

	# 【關鍵修改】如果 Player 2 沒有使用工具，再檢查其移動輸入
	if GameInputEvents.is_moving_player2():
		transition.emit("Walk_P2") # 切換到 Player 2 的走路狀態


# _on_exit 會在離開此狀態時被呼叫一次
func _on_exit() -> void:
	# 當離開閒置狀態時（例如開始走路），停止目前的動畫
	animated_sprite_2d.stop()


# 【核心修改】一個專門用來更新動畫和處理水平翻轉 (flip_h) 的輔助函式
func update_animation_and_flip(direction: Vector2) -> void:
	# 如果方向是零向量（例如遊戲剛開始時），就預設面向前方
	if direction == Vector2.ZERO:
		animated_sprite_2d.play("idle_front")
		return

	var anim_name = "idle_front" # 預設的動畫名稱

	# 比較 X 軸和 Y 軸的移動量，看哪個方向的移動更顯著
	if abs(direction.x) > abs(direction.y):
		# 水平方向的移動量更大
		# 動畫永遠使用 "idle_side"
		anim_name = "idle_side" 
		if direction.x > 0:
			# 向右，不翻轉圖像
			animated_sprite_2d.flip_h = false
		else:
			# 向左，水平翻轉圖像
			animated_sprite_2d.flip_h = true
	else:
		# 垂直方向的移動量更大（或兩者相等）
		# 在垂直移動時，我們不希望角色被翻轉，所以重設 flip_h
		animated_sprite_2d.flip_h = false
		if direction.y > 0:
			anim_name = "idle_front" # Vector2.DOWN 對應 "front"
		else:
			anim_name = "idle_back"  # Vector2.UP 對應 "back"
	
	# 為了避免不必要的重複播放，只在需要更換動畫時才呼叫 .play()
	if animated_sprite_2d.animation != anim_name:
		animated_sprite_2d.play(anim_name)
