extends Sprite2D

@onready var hurt_component: HurtComponent = $HurtComponent
@onready var damage_component: DamageComponent = $DamageComponent

var log_scene = preload("res://scenes/objects/trees/log.tscn")

func _ready() -> void:
	hurt_component.hurt.connect(on_hurt)
	damage_component.max_damaged_reached.connect(on_max_damage_reached)
	
func on_hurt(hit_damage: int) -> void:
	damage_component.apply_damage(hit_damage)
	material.set_shader_parameter("shake_intensity", 0.8)
	await get_tree().create_timer(1.0).timeout
	material.set_shader_parameter("shake_intensity", 0.0)
	
func on_max_damage_reached() -> void:
	call_deferred("add_log_scene")
	print("max damaged reached")
	queue_free()

# 【核心修正】
func add_log_scene() -> void:
	# 使用 for 迴圈來重複執行 3 次，生成 3 個木頭
	for i in 3:
		var log_instance = log_scene.instantiate() as Node2D
		
		# 1. 先將木頭實例加入到場景樹中
		get_parent().add_child(log_instance)
		
		# 2. 在它被加入場景樹之後，再設定它的「全域座標」。
		log_instance.global_position = self.global_position
		
		# 3. 【新增功能】為每個木頭加上一個小的隨機位置偏移，讓它們散開
		var random_offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))
		log_instance.global_position += random_offset
