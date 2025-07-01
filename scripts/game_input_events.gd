# game_input_events.gd
class_name GameInputEvents

# 不再需要 static var direction

# 這個函式現在可以正確處理斜向移動
static func get_movement_vector() -> Vector2:
	# 這行程式碼會自動處理 WASD 同時按下的情況
	# 它會回傳一個長度為 1 的方向向量，例如 (0.707, -0.707)
	# 如果沒有按鍵，則回傳 (0, 0)
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

# is_movement_input() 也可以簡化
static func is_moving() -> bool:
	# 只要上面四個動作中有任何一個被按下，就回傳 true
	return Input.is_action_pressed("move_left") or \
		   Input.is_action_pressed("move_right") or \
		   Input.is_action_pressed("move_up") or \
		   Input.is_action_pressed("move_down")

static func use_tool() -> bool:
	var use_tool_value: bool = Input.is_action_just_pressed("hit")
	
	return use_tool_value
