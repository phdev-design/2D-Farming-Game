# watering_state_player2.gd
extends NodeState

@export var player: CharacterBody2D # 建議使用通用的 CharacterBody2D，或你自己的 Player2 類別
@export var animated_sprite_2d: AnimatedSprite2D
@export var hit_component_collision_shape: CollisionShape2D
@export var watering_duration: float = 1.0  # 澆水持續時間
@export var water_particles: GPUParticles2D  # 水粒子效果
@export var water_range: float = 32.0  # 澆水範圍

var watering_timer: float = 0.0
var is_watering: bool = false
var watered_plants: Array[Node2D] = []  # 記錄已澆水的植物

func _ready() -> void:
	hit_component_collision_shape.disabled = true
	# 確保粒子效果存在且初始化
	if water_particles:
		water_particles.emitting = false

func _on_process(delta: float) -> void:
	if is_watering:
		watering_timer += delta
		check_and_water_plants()

func _on_next_transitions() -> void:
	# 檢查動畫是否完成或達到最大澆水時間
	if !animated_sprite_2d.is_playing() or watering_timer >= watering_duration:
		finish_watering()

func _on_enter() -> void:
	is_watering = true
	watering_timer = 0.0
	watered_plants.clear()
	
	# 根據玩家最後的移動方向，決定澆水的動畫、碰撞體和粒子效果
	var direction = player.direction

	# 【核心修改】使用 if/else 邏輯處理方向和翻轉
	if abs(direction.x) > abs(direction.y):
		# 水平方向
		animated_sprite_2d.play("watering_side")
		if direction.x > 0:
			# 向右
			animated_sprite_2d.flip_h = false
			hit_component_collision_shape.position = Vector2(18, 0)
			setup_water_particles(Vector2(20, 0), 90.0)
		else:
			# 向左
			animated_sprite_2d.flip_h = true
			hit_component_collision_shape.position = Vector2(-18, 0)
			setup_water_particles(Vector2(-20, 0), -90.0)
	else:
		# 垂直方向
		animated_sprite_2d.flip_h = false # 垂直方向不翻轉
		if direction.y > 0:
			# 向下
			animated_sprite_2d.play("watering_front")
			hit_component_collision_shape.position = Vector2(0, 6)
			setup_water_particles(Vector2(0, 20), 180.0)
		else:
			# 向上 (或方向為零的預設情況)
			animated_sprite_2d.play("watering_back")
			hit_component_collision_shape.position = Vector2(0, -36)
			setup_water_particles(Vector2(0, -20), 0.0)

	hit_component_collision_shape.disabled = false

func _on_exit() -> void:
	is_watering = false
	animated_sprite_2d.stop()
	hit_component_collision_shape.disabled = true
	
	if water_particles:
		water_particles.emitting = false

# --- Helper Functions ---

func finish_watering() -> void:
	# 完成澆水，轉換到 Player 2 的閒置狀態
	transition.emit("Idle_P2")

func setup_water_particles(particle_offset: Vector2, particle_rotation_degrees: float) -> void:
	if not water_particles:
		return
	
	water_particles.position = particle_offset
	water_particles.rotation_degrees = particle_rotation_degrees
	water_particles.emitting = true

func check_and_water_plants() -> void:
	# 這部分的邏輯是針對遊戲世界的，不需要為 Player 2 做特別修改
	var watering_position = player.global_position + hit_component_collision_shape.position
	
	var crop_fields = get_tree().get_first_node_in_group("crop_fields")
	if not crop_fields:
		return
	
	for plant in crop_fields.get_children():
		if plant is Node2D and plant not in watered_plants:
			if plant.global_position.distance_to(watering_position) <= water_range:
				water_plant(plant)
				watered_plants.append(plant)

func water_plant(plant: Node2D) -> void:
	if plant.has_method("water"):
		plant.water()
		print("Player 2 澆水植物: ", plant.name)
