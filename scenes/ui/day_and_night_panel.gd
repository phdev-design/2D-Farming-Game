extends Control

@onready var day_label: Label = $DayPanel/MarginContainer/DayLabel
@onready var time_label: Label = $TimePanel/MarginContainer/TimeLabel

@export var normal_speed: int = 1
@export var fast_speed: int = 100
@export var cheetah_speed: int = 200

func _ready() -> void:
	DayAndNightCycleManager.time_tick.connect(on_time_tick)

# 【新增】每一幀都檢查滑鼠是否在此面板上
func _process(_delta: float) -> void:
	# 如果滑鼠在面板的矩形範圍內，就設定全域旗標。
	# 這會和其他 UI 面板一起運作，只要滑鼠在任何一個
	# 實作了此邏輯的 UI 面板上，旗標就會是 true。
	if get_global_rect().has_point(get_global_mouse_position()):
		GameInputEvents.is_mouse_over_ui = true
	
func on_time_tick(day: int, hour: int, minute: int) -> void:
	day_label.text = "Day " + str(day)
	time_label.text = "%02d:%02d" % [hour, minute]
	
func _on_normal_speed_button_pressed() -> void:
	DayAndNightCycleManager.game_speed = normal_speed

func _on_fast_speed_button_pressed() -> void:
	DayAndNightCycleManager.game_speed = fast_speed


func _on_cheetah_speed_button_pressed() -> void:
	DayAndNightCycleManager.game_speed = cheetah_speed
