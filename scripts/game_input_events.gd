# game_input_events.gd
class_name GameInputEvents

# 【新增】一個全域變數，用來追蹤滑鼠是否在 UI 上方
static var is_mouse_over_ui: bool = false

# --- Player 1 Functions ---

static func get_movement_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

static func is_moving() -> bool:
	return Input.is_action_pressed("move_left") or \
		   Input.is_action_pressed("move_right") or \
		   Input.is_action_pressed("move_up") or \
		   Input.is_action_pressed("move_down")

static func use_tool() -> bool:
	# 【修改】只有當滑鼠不在 UI 上方時，才將點擊視為「使用工具」
	if is_mouse_over_ui:
		# 新增這一行
		# print("Attempted to use tool, but mouse is over UI.")
		return false
	
	# 新增這一行
	#print("A. Checking for 'hit' action. Pressed: ", Input.is_action_just_pressed("hit"))
	return Input.is_action_just_pressed("hit")

# --- Player 2 Functions ---

static func get_movement_vector_player2() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

static func is_moving_player2() -> bool:
	return Input.is_action_pressed("move_left") or \
		   Input.is_action_pressed("move_right") or \
		   Input.is_action_pressed("move_up") or \
		   Input.is_action_pressed("move_down")

static func use_tool_player2() -> bool:
	if is_mouse_over_ui:
		# 新增這一行
		# print("Attempted to use tool, but mouse is over UI.")
		return false
	
	# 新增這一行
	#print("A. Checking for 'hit' action. Pressed: ", Input.is_action_just_pressed("hit"))
	return Input.is_action_just_pressed("hit")
