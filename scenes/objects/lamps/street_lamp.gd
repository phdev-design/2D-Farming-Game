# street_lamp.gd
# 將此腳本附加到你的街燈場景的根節點上。
extends Sprite2D

## --- 導出變數 ---
# 在編輯器中，將你的 PointLight2D 節點拖曳到這個欄位。
@onready var point_light_2d: PointLight2D = $PointLight2D
@export var light_node: PointLight2D

# (可選) 如果你的燈亮時有額外的光暈圖，可以把那個 Sprite2D 拖到這裡。
# @export var glow_sprite: Sprite2D

# 設定晚上開始的時間（24小時制），例如 18 代表晚上 6 點。
@export var night_start_hour: int = 18

# 設定晚上結束、白天開始的時間，例如 6 代表早上 6 點。
@export var night_end_hour: int = 6


func _ready() -> void:
	# 檢查 DayAndNightCycleManager 是否存在。
	# 這需要你將 DayAndNightCycleManager 設定為自動載入 (Autoload/Singleton)。
	if not DayAndNightCycleManager:
		# 已修正：將 print_error 改為 printerr
		printerr("DayAndNightCycleManager not found. Please set it up as an Autoload.")
		return
		
	# 連接到時間管理器的 time_tick 信號。
	DayAndNightCycleManager.time_tick.connect(on_time_tick)
	
	# 為了避免遊戲開始時燈的狀態不對，立即根據初始時間更新一次。
	# 我們需要從管理器獲取初始小時。
	var initial_hour: int = DayAndNightCycleManager.initial_hour
	update_light_state(initial_hour)


# 當 DayAndNightCycleManager 發出 time_tick 信號時，這個函式會被呼叫。
func on_time_tick(_day: int, hour: int, _minute: int) -> void:
	update_light_state(hour)


# 根據傳入的小時數來更新燈光的狀態。
func update_light_state(hour: int) -> void:
	var is_night: bool = false
	
	# 判斷目前是否為夜晚。
	# 這個邏輯可以處理跨午夜的情況 (例如：晚上18點到隔天早上6點)。
	if night_start_hour > night_end_hour:
		is_night = (hour >= night_start_hour or hour < night_end_hour)
	else:
		# 這個邏輯處理夜晚在同一天內的情況 (例如：晚上22點到24點)。
		is_night = (hour >= night_start_hour and hour < night_end_hour)
	
	# 根據是否為夜晚來開啟或關閉燈光。
	if light_node:
		light_node.enabled = is_night
		
	# (可選) 如果有光暈圖，也一併顯示或隱藏。
	#if glow_sprite:
		#glow_sprite.visible = is_night
