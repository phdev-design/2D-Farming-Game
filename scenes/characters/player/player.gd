# player.gd
class_name Player
extends CharacterBody2D

# --- 新增的引用 ---
# 請在 Godot 編輯器中將 FieldCursorComponent 節點拖曳到這裡
@export var fields_cursor_component: FieldsCursorComponent
# --------------------

@onready var hit_component: HitComponent = $HitComponent
@export var current_tool: DataTypes.Tools = DataTypes.Tools.None
var direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	ToolManage.tool_selected.connect(on_tool_selected)
	
func on_tool_selected(tool: DataTypes.Tools) -> void:
	print("Player received tool_selected signal! New tool is: ", tool)
	current_tool = tool
	hit_component.current_tool = tool

# --- 新增的輸入處理函式 --fields_cursor_component.gd-
# 我們使用 _unhandled_input 來確保在 UI 事件處理完後才執行
func _unhandled_input(event: InputEvent) -> void:
	# 當 "hit" 按鍵被按下時
	if event.is_action_pressed("hit"):
		
		# 你的 "B. use_tool is true!" 訊息可能來自這裡，你可以保留或刪除
		print("B. use_tool is true! Current tool is: ", current_tool)

		# 根據當前手上的工具，決定要做什麼
		if current_tool == DataTypes.Tools.TillGround:
			
			# 檢查 fields_cursor_component 是否已經設定
			if fields_cursor_component:
				# 命令 FieldsCursorComponent 去執行耕地動作
				fields_cursor_component.perform_till_action()
			else:
				print("[錯誤] Player 腳本沒有設定 fields_cursor_component 的引用!")
