extends Node

# --- 常數 (沒有變動) ---
const MINUTES_PER_DAY: int = 24 * 60
const MINUTES_PER_HOUR: int = 60
const GAME_MINUTE_DURATION: float = TAU / MINUTES_PER_DAY

# --- 變數 (沒有變動) ---
var game_speed: float = 1.0
var initial_day: int = 1
var initial_hour: int = 12
var initial_minute: int = 30
var time: float = 0.0
var current_minute: int = -1
var current_day: int = 0

# --- 信號 (新增一個信號) ---
signal game_time(time: float)
signal time_tick(day: int, hour: int, minute: int)
signal time_tick_day(day: int)
## 新增：當白天/黑夜狀態改變時發出信號
signal night_state_changed(is_night: bool)

# --- 新增一個變數來追蹤夜晚狀態 ---
var _current_is_night: bool = false

func _ready() -> void:
	set_initial_time()
	
func _process(delta: float) -> void:
	time += delta * game_speed * GAME_MINUTE_DURATION
	game_time.emit(time)
	
	recalculate_time()

func set_initial_time() -> void:
	var inital_total_minutes = initial_day * MINUTES_PER_DAY + (initial_hour * MINUTES_PER_HOUR) + initial_minute
	time = inital_total_minutes * GAME_MINUTE_DURATION
	# 初始化時間後，立即計算一次時間以設定初始的白天/黑夜狀態
	recalculate_time()

func recalculate_time() -> void:
	var total_minutes: int = int(time / GAME_MINUTE_DURATION)
	var day: int = int(total_minutes / MINUTES_PER_DAY)
	var current_day_minutes: int = total_minutes % MINUTES_PER_DAY
	var hour: int = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute: int = int(current_day_minutes % MINUTES_PER_HOUR)
	
	if current_minute != minute:
		current_minute = minute
		time_tick.emit(day, hour, minute)
		
	if current_day != day:
		current_day = day
		time_tick_day.emit(day)
		
	# --- 新增的邏輯 ---
	# 判斷是否為夜晚 (例如：晚上 6 點到早上 6 點)
	# 你可以根據你的遊戲需求調整時間
	var should_be_night: bool = hour >= 18 or hour < 6
	
	# 如果狀態發生了改變，就發出信號
	if should_be_night != _current_is_night:
		_current_is_night = should_be_night
		night_state_changed.emit(_current_is_night)

# --- 新增一個函式，讓其他物件可以查詢現在是否為夜晚 ---
func is_night() -> bool:
	return _current_is_night
