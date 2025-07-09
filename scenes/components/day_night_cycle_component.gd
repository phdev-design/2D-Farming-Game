class_name DayNightCycleComponent
extends CanvasModulate

@export var initial_day: int = 1:
	set(id):
		initial_day = id
		DayAndNightCycleManager.intitial_day = id
		DayAndNightCycleManager.set_initial_time()
		
@export var initial_hour: int = 12:
	set(ih):
		initial_hour = ih
		DayAndNightCycleManager.intitial_hour = ih
		
@export var initial_minute: int = 30:
	set(im):
		initial_minute = im
		DayAndNightCycleManager.intitial_minute = im
		DayAndNightCycleManager.set_initial_time()
		
@export var day_night_gradient_texture: GradientTexture1D

func _ready() -> void:
	DayAndNightCycleManager.intitial_day = initial_day
	DayAndNightCycleManager.intitial_hour = initial_hour
	DayAndNightCycleManager.intitial_minute = initial_minute
	DayAndNightCycleManager.set_initial_time()
	
	DayAndNightCycleManager.game_time.connect(on_game_time)
	
func on_game_time(time: float) -> void:
	var sample_value = 0.5 * (sin(time - PI * 0.5) + 1.0)
	color = day_night_gradient_texture.gradient.sample(sample_value)
