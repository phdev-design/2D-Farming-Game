extends Sprite2D

@onready var hurt_component: HurtComponent = $HurtComponent
@onready var damage_component: DamageComponent = $DamageComponent

var log_scene = preload("res://scenes/objects/trees/log.tscn")

func _ready() -> void:
	hurt_component.hurt.connect(on_hurt)
	damage_component.max_damaged_reached.connect(on_max_damage_reached)
	
func on_hurt(hit_damage: int) -> void:
	damage_component.apply_damage(hit_damage)
	material.set_shader_parameter("shake_intensity", 0.5)
	await get_tree().create_timer(1.0).timeout
	material.set_shader_parameter("shake_intensity", 0.0)
	
func on_max_damage_reached() -> void:
	call_deferred("add_log_scene")
	print("max damaged reached")
	queue_free()

# 【核心修正】交換了 add_child 和 global_position 的順序
func add_log_scene() -> void:
	var log_instance = log_scene.instantiate() as Node2D
	
	# 1. 先將木頭實例加入到場景樹中
	get_parent().add_child(log_instance)
	
	# 2. 在它被加入場景樹之後，再設定它的「全域座標」。
	#    這樣 Godot 才能根據它的新父節點，正確計算出它應該在的本地位置。
	log_instance.global_position = self.global_position
