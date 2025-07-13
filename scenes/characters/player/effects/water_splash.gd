class_name WaterSplash
extends Node2D

@export var splash_duration: float = 1.0
@export var particle_count: int = 20
@export var splash_intensity: float = 1.0

@onready var particle_effect: GPUParticles2D = $ParticleEffect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

var tween: Tween

func _ready() -> void:
	# 設置粒子效果
	setup_particles()
	
	# 開始水花效果
	start_splash()
	
	# 設置自動清理
	timer.wait_time = splash_duration + 0.5
	timer.start()

func setup_particles() -> void:
	if not particle_effect:
		return
	
	# 動態調整粒子數量
	particle_effect.amount = particle_count
	particle_effect.lifetime = splash_duration
	
	# 根據強度調整粒子效果
	var material = particle_effect.process_material as ParticleProcessMaterial
	if material:
		material.initial_velocity_min = 20.0 * splash_intensity
		material.initial_velocity_max = 40.0 * splash_intensity
		material.scale_min = 0.5 * splash_intensity
		material.scale_max = 1.2 * splash_intensity

func start_splash() -> void:
	# 啟動粒子效果
	if particle_effect:
		particle_effect.emitting = true
		particle_effect.restart()
	
	# 播放音效
	#play_splash_sound()
	
	# 創建縮放動畫
	create_scale_animation()

func create_scale_animation() -> void:
	# 創建水花的縮放動畫
	tween = create_tween()
	tween.set_parallel(true)
	
	# 從小到大再到小的縮放效果
	scale = Vector2(0.5, 0.5)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.1)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.3).set_delay(0.3)
	
	# 透明度動畫
	modulate.a = 1.0
	tween.tween_property(self, "modulate:a", 0.0, 0.4).set_delay(0.4)

#func play_splash_sound() -> void:
	## 播放水花音效
	#if AudioManager and AudioManager.has_method("play_sound"):
		#AudioManager.play_sound("water_splash")

func _on_timer_timeout() -> void:
	# 清理水花效果
	queue_free()

# 可選：設置水花效果的方法
func set_splash_intensity(intensity: float) -> void:
	splash_intensity = intensity
	setup_particles()

func set_splash_color(color: Color) -> void:
	if particle_effect:
		var material = particle_effect.process_material as ParticleProcessMaterial
		if material:
			material.color = color

# 可選：手動觸發水花效果
func trigger_splash() -> void:
	start_splash()
