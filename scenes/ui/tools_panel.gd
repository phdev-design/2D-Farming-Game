extends PanelContainer

@onready var tool_axe: Button = $MarginContainer/HBoxContainer/ToolAxe
@onready var tool_tilling: Button = $MarginContainer/HBoxContainer/ToolTilling
@onready var tool_watering_can: Button = $MarginContainer/HBoxContainer/ToolWateringCan
@onready var tool_corn: Button = $MarginContainer/HBoxContainer/ToolCorn
@onready var tool_tomato: Button = $MarginContainer/HBoxContainer/ToolTomato

func _ready() -> void:
	ToolManage.enable_tool.connect(on_enable_tool_button)
	
	tool_tilling.disabled = true
	tool_tilling.focus_mode= Control.FOCUS_NONE

	tool_watering_can.disabled = true
	tool_watering_can.focus_mode= Control.FOCUS_NONE

	tool_corn.disabled = true
	tool_corn.focus_mode= Control.FOCUS_NONE

	tool_tomato.disabled = true
	tool_tomato.focus_mode= Control.FOCUS_NONE
	

# 【核心修改】使用 _process 函式來進行更可靠的檢查
func _process(_delta: float) -> void:
	# 每一幀都檢查滑鼠指標是否在 PanelContainer 的全域矩形範圍內。
	# 【重要】我們移除了 else 區塊，只在滑鼠懸停時將旗標設為 true。
	if get_global_rect().has_point(get_global_mouse_position()):
		GameInputEvents.is_mouse_over_ui = true


func _on_tool_axe_pressed() -> void:
	# 新增這一行來除錯
	print("1. Axe button pressed. Calling ToolManage.select_tool()")
	ToolManage.select_tool(DataTypes.Tools.AxeWood)

func _on_tool_tilling_pressed() -> void:
	ToolManage.select_tool(DataTypes.Tools.TillGround)

func _on_tool_watering_can_pressed() -> void:
	ToolManage.select_tool(DataTypes.Tools.WaterCrops)

func _on_tool_corn_pressed() -> void:
	ToolManage.select_tool(DataTypes.Tools.PlantCorn)

func _on_tool_tomato_pressed() -> void:
	ToolManage.select_tool(DataTypes.Tools.PlantTomato)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_tool"):
		if event.button_index == MOUSE_BUTTON_RIGHT:
			ToolManage.select_tool(DataTypes.Tools.None)
			tool_axe.release_focus()
			tool_tilling.release_focus()
			tool_watering_can.release_focus()
			tool_corn.release_focus()
			tool_tomato.release_focus()

func on_enable_tool_button(tool: DataTypes.Tools) -> void:
	if tool == DataTypes.Tools.TillGround:
		tool_tilling.disabled = false
		tool_tilling.focus_mode = Control.FOCUS_ALL
	elif tool == DataTypes.Tools.WaterCrops:
		tool_watering_can.disabled = false
		tool_watering_can.focus_mode = Control.FOCUS_ALL
	elif tool == DataTypes.Tools.PlantCorn:
		tool_corn.disabled = false
		tool_corn.focus_mode = Control.FOCUS_ALL
	elif tool == DataTypes.Tools.PlantTomato:
		tool_tomato.disabled = false
		tool_tomato.focus_mode = Control.FOCUS_ALL
