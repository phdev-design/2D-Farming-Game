extends Node

const MINUTES_PER_DAY: int = 24 * 60
const MINUTES_PER_HOUR: int = 60
const GAME_MINUTES_DURATION: float = TAU / MINUTES_PER_DAY

var game_speed: float = 5.0

var intitial_day: int = 1
var intitial_hour: int = 12
var intitial_minute: int = 30

var time: float = 0.0
var current_minute: int = -1
var current_day: int = 0

signal game_time(time: float)
signal time_tick(day: int, hour: int, minute: int)
signal time_tick_day(day: int)

func _ready() -> void:
	set_initial_time()
	
func _process(delta: float) -> void:
	time += delta * game_speed * GAME_MINUTES_DURATION
	game_time.emit(time)
	
	recalculate_time()
	
func set_initial_time() -> void:
	var intitial_total_minutes = intitial_day * MINUTES_PER_DAY + (intitial_hour * MINUTES_PER_HOUR) + intitial_minute
	
	time = intitial_total_minutes * GAME_MINUTES_DURATION
	
func recalculate_time() -> void:
	var total_minutes: int = int(time / GAME_MINUTES_DURATION)
	var day: int = int(total_minutes / MINUTES_PER_DAY)
	var current_daya_minutes: int = total_minutes % MINUTES_PER_DAY
	var hour: int = int(current_daya_minutes / MINUTES_PER_HOUR)
	var minute: int = int(current_daya_minutes % MINUTES_PER_HOUR)
	
	if current_minute != minute:
		current_minute = minute
		time_tick.emit(day, hour, minute)
		
	if current_day != day:
		current_day = day
		time_tick_day.emit(day)
