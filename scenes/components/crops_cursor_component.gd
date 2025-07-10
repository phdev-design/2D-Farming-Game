class_name CropsCursorComponent
extends Node

@export var tilled_soil_tilemap_layer: TileMapLayer
@export var interaction_distance: float = 20.0
@export var plant_cooldown: float = 0.2  # 防止過快種植

var player: Player
var corn_plant_scene = preload("res://scenes/objects/plants/corn.tscn")
var tomato_plant_scene = preload("res://scenes/objects/plants/tomato.tscn")

var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var local_cell_position: Vector2
var distance: float
var last_plant_time: float = 0.0

# 緩存變量避免重複計算
var cached_mouse_position: Vector2
var cached_cell_position: Vector2i
var cache_valid: bool = false

func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _unhandled_input(event: InputEvent) -> void:
	# 檢查冷卻時間
	if Time.get_ticks_msec() / 1000.0 - last_plant_time < plant_cooldown:
		return
	
	if event.is_action_pressed("remove_dirt"):
		if ToolManage.selected_tool == DataTypes.Tools.TillGround:
			if get_cell_under_mouse_with_validation():
				remove_crop()
	elif event.is_action_pressed("hit"):
		if ToolManage.selected_tool == DataTypes.Tools.PlantCorn or ToolManage.selected_tool == DataTypes.Tools.PlantTomato:
			if get_cell_under_mouse_with_validation():
				add_crop()

func _process(_delta: float) -> void:
	# 每幀更新緩存，但只在需要時重新計算
	update_mouse_cache()

func update_mouse_cache() -> void:
	var current_mouse_pos = tilled_soil_tilemap_layer.get_local_mouse_position()
	
	# 只有當滑鼠位置變化足夠大時才更新緩存
	if not cache_valid or current_mouse_pos.distance_to(cached_mouse_position) > 1.0:
		cached_mouse_position = current_mouse_pos
		cached_cell_position = tilled_soil_tilemap_layer.local_to_map(cached_mouse_position)
		cache_valid = true

func get_cell_under_mouse_with_validation() -> bool:
	if not cache_valid:
		update_mouse_cache()
	
	mouse_position = cached_mouse_position
	cell_position = cached_cell_position
	cell_source_id = tilled_soil_tilemap_layer.get_cell_source_id(cell_position)
	local_cell_position = tilled_soil_tilemap_layer.map_to_local(cell_position)
	distance = player.global_position.distance_to(local_cell_position)
	
	# 驗證是否在有效範圍內
	return distance < interaction_distance

func add_crop() -> void:
	# 檢查是否已經有作物在這個位置
	if is_position_occupied(local_cell_position):
		return
	
	# 檢查是否在耕地上
	if cell_source_id == -1:
		return
	
	var crop_instance: Node2D = null
	
	match ToolManage.selected_tool:
		DataTypes.Tools.PlantCorn:
			crop_instance = corn_plant_scene.instantiate() as Node2D
		DataTypes.Tools.PlantTomato:
			crop_instance = tomato_plant_scene.instantiate() as Node2D
	
	if crop_instance:
		crop_instance.global_position = local_cell_position
		get_parent().find_child("CropFields").add_child(crop_instance)
		last_plant_time = Time.get_ticks_msec() / 1000.0
		
		# 可選：添加種植音效
		# AudioManager.play_sound("plant_sound")

func remove_crop() -> void:
	var crop_fields = get_parent().find_child("CropFields")
	if not crop_fields:
		return
	
	var crop_nodes = crop_fields.get_children()
	var tolerance = 8.0  # 像素容差，讓選擇更容易
	
	for node: Node2D in crop_nodes:
		if node.global_position.distance_to(local_cell_position) <= tolerance:
			node.queue_free()
			break  # 只刪除第一個找到的作物

func is_position_occupied(position: Vector2) -> bool:
	var crop_fields = get_parent().find_child("CropFields")
	if not crop_fields:
		return false
	
	var crop_nodes = crop_fields.get_children()
	var tolerance = 8.0
	
	for node: Node2D in crop_nodes:
		if node.global_position.distance_to(position) <= tolerance:
			return true
	
	return false

# 可選：添加視覺預覽功能
func get_preview_position() -> Vector2:
	if not cache_valid:
		update_mouse_cache()
	
	var preview_cell = tilled_soil_tilemap_layer.local_to_map(cached_mouse_position)
	return tilled_soil_tilemap_layer.map_to_local(preview_cell)
