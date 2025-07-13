class_name WateringState
extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D
@export var hit_component_collision_shape: CollisionShape2D
@export var watering_duration: float = 1.0  # 澆水持續時間
@export var water_particles: GPUParticles2D  # 水粒子效果
@export var water_range: float = 32.0  # 澆水範圍

# 方向配置
var direction_configs = {
	Vector2.UP: {
		"animation": "watering_back",
		"collision_offset": Vector2(0, -36),
		"particle_offset": Vector2(0, -20),
		"particle_rotation": 0.0
	},
	Vector2.DOWN: {
		"animation": "watering_front", 
		"collision_offset": Vector2(0, 6),
		"particle_offset": Vector2(0, 20),
		"particle_rotation": 180.0
	},
	Vector2.RIGHT: {
		"animation": "watering_right",
		"collision_offset": Vector2(18, 0),
		"particle_offset": Vector2(20, 0),
		"particle_rotation": 90.0
	},
	Vector2.LEFT: {
		"animation": "watering_left",
		"collision_offset": Vector2(-18, 0),
		"particle_offset": Vector2(-20, 0),
		"particle_rotation": -90.0
	}
}

var watering_timer: float = 0.0
var is_watering: bool = false
var watered_plants: Array[Node2D] = []  # 記錄已澆水的植物

func _ready() -> void:
	hit_component_collision_shape.disabled = true
	hit_component_collision_shape.position = Vector2.ZERO
	
	# 確保粒子效果存在且初始化
	if water_particles:
		water_particles.emitting = false

func _on_process(delta: float) -> void:
	if is_watering:
		watering_timer += delta
		
		# 檢查澆水區域內的植物
		check_and_water_plants()
		
		# 可選：檢查玩家是否移動過多（取消澆水）
		if player.velocity.length() > 10.0:
			finish_watering()

func _on_physics_process(_delta: float) -> void:
	# 物理更新暫時不需要處理
	pass

func _on_next_transitions() -> void:
	# 檢查動畫是否完成或達到最大澆水時間
	if !animated_sprite_2d.is_playing() or watering_timer >= watering_duration:
		finish_watering()

func _on_enter() -> void:
	is_watering = true
	watering_timer = 0.0
	watered_plants.clear()
	
	# 獲取當前方向配置
	var config = get_direction_config()
	
	# 播放動畫
	animated_sprite_2d.play(config.animation)
	
	# 設置碰撞形狀
	hit_component_collision_shape.position = config.collision_offset
	hit_component_collision_shape.disabled = false
	
	# 設置粒子效果
	setup_water_particles(config)
	
	# 播放澆水音效
	#play_watering_sound()

func _on_exit() -> void:
	is_watering = false
	animated_sprite_2d.stop()
	hit_component_collision_shape.disabled = true
	
	# 停止粒子效果
	if water_particles:
		water_particles.emitting = false
	
	# 重置位置
	hit_component_collision_shape.position = Vector2.ZERO

func get_direction_config() -> Dictionary:
	# 獲取玩家當前方向的配置
	var direction = player.direction
	
	# 如果方向不在配置中，使用默認方向（向下）
	if direction in direction_configs:
		return direction_configs[direction]
	else:
		return direction_configs[Vector2.DOWN]

func setup_water_particles(config: Dictionary) -> void:
	if not water_particles:
		return
	
	# 設置粒子位置和旋轉
	water_particles.position = config.particle_offset
	water_particles.rotation_degrees = config.particle_rotation
	water_particles.emitting = true
	
	# 可選：調整粒子參數
	var material = water_particles.process_material as ParticleProcessMaterial
	if material:
		material.direction = Vector3(0, -1, 0)  # 根據方向調整

func check_and_water_plants() -> void:
	# 檢查澆水範圍內的植物
	var space_state = player.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	
	# 計算澆水位置
	var watering_position = player.global_position + hit_component_collision_shape.position
	
	# 查詢澆水範圍內的物體
	var bodies_in_range = get_plants_in_range(watering_position, water_range)
	
	for plant in bodies_in_range:
		if plant not in watered_plants:
			water_plant(plant)
			watered_plants.append(plant)

func get_plants_in_range(position: Vector2, range: float) -> Array[Node2D]:
	var plants: Array[Node2D] = []
	
	# 獲取所有植物節點
	var crop_fields = get_tree().get_first_node_in_group("crop_fields")
	if not crop_fields:
		return plants
	
	for child in crop_fields.get_children():
		if child is Node2D:
			var distance = child.global_position.distance_to(position)
			if distance <= range:
				plants.append(child)
	
	return plants

func water_plant(plant: Node2D) -> void:
	# 澆水植物邏輯
	if plant.has_method("water"):
		plant.water()
		print("澆水植物: ", plant.name)
		
		# 可選：創建澆水效果
		create_water_splash_effect(plant.global_position)
	
	# 檢查是否有成長組件
	var growth_component = plant.get_node_or_null("GrowthComponent")
	if growth_component and growth_component.has_method("add_water"):
		growth_component.add_water()

func create_water_splash_effect(position: Vector2) -> void:
	# 創建水花效果
	var splash_scene = preload("res://scenes/characters/player/effects/water_splash.tscn")  # 假設有水花效果場景
	if splash_scene:
		var splash = splash_scene.instantiate()
		get_tree().current_scene.add_child(splash)
		splash.global_position = position

#func play_watering_sound() -> void:
	## 播放澆水音效
	#if AudioManager.has_method("play_sound"):
		#AudioManager.play_sound("watering")

func finish_watering() -> void:
	# 完成澆水，轉換到閒置狀態
	transition.emit("Idle")

func can_water() -> bool:
	# 檢查是否可以澆水（例如是否有水）
	if player.has_method("has_water"):
		return player.has_water()
	return true

func consume_water() -> void:
	# 消耗水資源
	if player.has_method("consume_water"):
		player.consume_water(1)
