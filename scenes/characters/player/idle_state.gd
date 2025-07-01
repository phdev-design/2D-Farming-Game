# idle_state.gd
extends NodeState

# 在 Godot 編輯器中，將 Player 節點和 AnimatedSprite2D 節點拖曳到這裡
@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

# _on_enter 會在進入此狀態時被呼叫一次
# 這是設定初始動畫和狀態的最佳位置，可以避免畫面閃爍
func _on_enter() -> void:
	# 玩家進入閒置狀態，速度應立即歸零
	player.velocity = Vector2.ZERO
	# 根據玩家最後的移動方向，更新並播放對應的閒置動畫
	# 這可以確保角色在停下來時，會面向最後移動的方向
	update_animation(player.direction)


# _on_physics_process 會在物理引擎的每一幀被呼叫
func _on_physics_process(_delta: float) -> void:
	# 持續確保玩家速度為零
	player.velocity = Vector2.ZERO
	player.move_and_slide()


# _on_next_transitions 更新的地方
func _on_next_transitions() -> void:
	# 檢查是否觸發了「使用工具」的輸入
	if GameInputEvents.use_tool():
		# 【關鍵修改】根據 DataTypes.gd 的 enum 進行判斷
		# 使用 match 陳述式來根據當前工具的 enum 值決定下一個狀態
		match player.current_tool:
			DataTypes.Tools.None:
				# 如果手上沒拿工具，就什麼事都不做
				return
			DataTypes.Tools.AxeWood:
				transition.emit("Chopping")
			DataTypes.Tools.TillGround:
				transition.emit("Tilling")
			DataTypes.Tools.WaterCrops:
				transition.emit("Watering")
			# 你可以在這裡為其他工具（例如 PlantCorn）新增 case
			# DataTypes.Tools.PlantCorn:
			#	 transition.emit("Planting")

		return # 執行完工具操作後就結束，避免再檢查移動

	# 如果沒有使用工具，再檢查移動輸入
	if GameInputEvents.is_moving():
		transition.emit("Walk")

# _on_exit 會在離開此狀態時被呼叫一次
func _on_exit() -> void:
	# 當離開閒置狀態時（例如開始走路），停止目前的動畫
	# Walk 狀態會接著播放它自己的走路動畫
	animated_sprite_2d.stop()


# 一個專門用來更新動畫的輔助函式
func update_animation(direction: Vector2) -> void:
	var anim_name = "idle_front" # 預設的動畫名稱

	# 這段邏輯可以聰明地處理八方向輸入，並決定要播放哪個四方向動畫
	# 它會比較 X 軸和 Y 軸的移動量，看哪個方向的移動更顯著
	if abs(direction.x) > abs(direction.y):
		# 水平方向的移動量更大
		if direction.x > 0:
			anim_name = "idle_right"
		else:
			anim_name = "idle_left"
	else:
		# 垂直方向的移動量更大（或兩者相等）
		if direction.y > 0:
			anim_name = "idle_front" # Vector2.DOWN 對應 "front"
		else:
			anim_name = "idle_back"  # Vector2.UP 對應 "back"
	
	# 為了避免不必要的重複播放，只在需要更換動畫時才呼叫 .play()
	if animated_sprite_2d.animation != anim_name:
		animated_sprite_2d.play(anim_name)
