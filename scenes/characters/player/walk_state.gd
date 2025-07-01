# walk_state.gd
extends NodeState

# 在 Godot 編輯器中，將 Player 節點和 AnimatedSprite2D 節點拖曳到這裡
@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D
@export var speed: float = 100.0


# _on_physics_process 會在物理引擎的每一幀被呼叫
func _on_physics_process(_delta: float) -> void:
	# 從我們的全域輸入事件腳本中獲取移動向量
	var input_vector = GameInputEvents.get_movement_vector()
	
	# 設定玩家的速度
	player.velocity = input_vector * speed
	player.move_and_slide()
	
	# 如果玩家正在移動，就更新其儲存的方向
	# 這樣當他停下來時，Idle 狀態才知道該面向哪裡
	if input_vector != Vector2.ZERO:
		player.direction = input_vector
	
	# 根據目前的移動方向更新動畫
	update_animation(player.velocity)


# _on_next_transitions 用來檢查是否需要轉換到下一個狀態
func _on_next_transitions() -> void:
	# 優先檢查「使用工具」的輸入
	if GameInputEvents.use_tool():
		# 【關鍵修改】使用 match 陳述式來根據當前工具決定下一個狀態
		match player.current_tool:
			DataTypes.Tools.None:
				# 如果手上沒拿工具，就繼續走路，不做任何事
				pass
			DataTypes.Tools.AxeWood:
				transition.emit("Chopping")
				return # 切換後直接結束
			DataTypes.Tools.TillGround:
				transition.emit("Tilling")
				return # 切換後直接結束
			DataTypes.Tools.WaterCrops:
				transition.emit("Watering")
				return # 切換後直接結束

	# 如果沒有任何移動輸入...
	if !GameInputEvents.is_moving():
		# ...就發出訊號，轉換到 "Idle" 狀態
		transition.emit("Idle")


# _on_exit 會在離開此狀態時被呼叫一次
func _on_exit() -> void:
	# 離開走路狀態時，停止走路動畫。
	# Idle 狀態會立即接管並播放它自己的閒置動畫。
	animated_sprite_2d.stop()


# 一個專門用來更新動畫的輔助函式
# 注意：這裡的邏輯和 idle_state 中的邏輯完全一樣，只是動畫名稱不同
func update_animation(velocity: Vector2) -> void:
	# 如果沒有在移動，就不更新動畫，保持最後一幀的樣子
	if velocity == Vector2.ZERO:
		return

	var anim_name = "walk_front" # 預設的動畫名稱

	# 比較 X 軸和 Y 軸的移動量，看哪個方向的移動更顯著
	if abs(velocity.x) > abs(velocity.y):
		# 水平方向的移動量更大
		if velocity.x > 0:
			anim_name = "walk_right"
		else:
			anim_name = "walk_left"
	else:
		# 垂直方向的移動量更大（或兩者相等）
		if velocity.y > 0:
			anim_name = "walk_front" # Vector2.DOWN 對應 "front"
		else:
			anim_name = "walk_back"  # Vector2.UP 對應 "back"
	
	# 為了避免不必要的重複播放，只在需要更換動畫時才呼叫 .play()
	if animated_sprite_2d.animation != anim_name:
		animated_sprite_2d.play(anim_name)
