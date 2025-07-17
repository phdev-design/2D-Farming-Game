# tilling_state_player2.gd
extends NodeState

@export var player: CharacterBody2D # 建議使用通用的 CharacterBody2D，或你自己的 Player2 類別
@export var animated_sprite_2d: AnimatedSprite2D


# _on_next_transitions 用來檢查是否需要轉換到下一個狀態
func _on_next_transitions() -> void:
	# 當動畫播放完畢...
	if !animated_sprite_2d.is_playing():
		# ...就發出訊號，轉換到 Player 2 的 "Idle_P2" 狀態
		transition.emit("Idle_P2")


# _on_enter 會在進入此狀態時被呼叫一次
func _on_enter() -> void:
	# 根據玩家最後的移動方向，決定鋤地的動畫
	var direction = player.direction

	# 【核心修改】這段邏輯和 idle/walk/chopping 狀態一樣，用來判斷主要方向
	if abs(direction.x) > abs(direction.y):
		# 水平方向
		animated_sprite_2d.play("tilling_side")
		if direction.x > 0:
			# 向右
			animated_sprite_2d.flip_h = false
		else:
			# 向左
			animated_sprite_2d.flip_h = true
	else:
		# 垂直方向
		animated_sprite_2d.flip_h = false # 垂直方向不翻轉
		if direction.y > 0:
			# 向下
			animated_sprite_2d.play("tilling_front")
		else:
			# 向上 (或方向為零的預設情況)
			animated_sprite_2d.play("tilling_back")


# _on_exit 會在離開此狀態時被呼叫一次
func _on_exit() -> void:
	# 停止動畫，為下一個狀態做準備
	animated_sprite_2d.stop()
