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

# 緩存變量
var cached_mouse_position: Vector2
var cached_cell_position: Vector2i
var cache_valid: bool = false

func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

# --- 新增的公開函式 ---
func perform_plant_action():
	if Time.get_ticks_msec() / 1000.0 - last_plant_time < plant_cooldown:
		return
	
	if get_cell_under_mouse_with_validation():
		add_crop()

# 你也可以為移除作物建立一個類似的函式
#func perform_remove_crop_action():
	#if get_cell_under_mouse_with_validation():
		#remove_crop()
# -------------------------

func _process(_delta: float) -> void:
	update_mouse_cache()

func update_mouse_cache() -> void:
	if tilled_soil_tilemap_layer == null: return
	var current_mouse_pos = tilled_soil_tilemap_layer.get_local_mouse_position()
	
	if not cache_valid or current_mouse_pos.distance_to(cached_mouse_position) > 1.0:
		cached_mouse_position = current_mouse_pos
		cached_cell_position = tilled_soil_tilemap_layer.local_to_map(cached_mouse_position)
		cache_valid = true

func get_cell_under_mouse_with_validation() -> bool:
	if player == null: return false
	if not cache_valid: update_mouse_cache()
	
	mouse_position = cached_mouse_position
	cell_position = cached_cell_position
	cell_source_id = tilled_soil_tilemap_layer.get_cell_source_id(cell_position)
	local_cell_position = tilled_soil_tilemap_layer.map_to_local(cell_position)
	distance = player.global_position.distance_to(local_cell_position)
	
	return distance < interaction_distance

func add_crop() -> void:
	if is_position_occupied(local_cell_position): return
	if cell_source_id == -1: return
	
	var crop_instance: Node2D = null
	
	match ToolManage.selected_tool:
		DataTypes.Tools.PlantCorn:
			crop_instance = corn_plant_scene.instantiate() as Node2D
		DataTypes.Tools.PlantTomato:
			crop_instance = tomato_plant_scene.instantiate() as Node2D
	
	if crop_instance:
		crop_instance.global_position = local_cell_position
		# 使用群組來尋找節點，這比 get_parent().find_child() 更穩健
		var crop_fields_node = get_tree().get_first_node_in_group("crop_fields")
		if crop_fields_node:
			crop_fields_node.add_child(crop_instance)
		else:
			print("[錯誤] 找不到 'crop_fields' 群組的節點! 請將 CropFields 節點加入該群組。")
		last_plant_time = Time.get_ticks_msec() / 1000.0

func remove_crop() -> void:
	var crop_fields = get_tree().get_first_node_in_group("crop_fields")
	if not crop_fields: return
	
	var crop_nodes = crop_fields.get_children()
	var tolerance = 8.0
	
	for node: Node2D in crop_nodes:
		if node.global_position.distance_to(local_cell_position) <= tolerance:
			node.queue_free()
			break

func is_position_occupied(position: Vector2) -> bool:
	var crop_fields = get_tree().get_first_node_in_group("crop_fields")
	if not crop_fields: return false
	
	var crop_nodes = crop_fields.get_children()
	var tolerance = 8.0
	
	for node: Node2D in crop_nodes:
		if node.global_position.distance_to(position) <= tolerance:
			return true
	
	return false
