class_name FieldsCursorComponent
extends Node

@export var grass_tilemap_layer: TileMapLayer
@export var tilled_soil_tilemap_layer: TileMapLayer
@export var terrain_set: int = 0
@export var terrain: int = 3
@export var interaction_distance: float = 20.0
@export var till_cooldown: float = 0.1  # 防止過快耕作
@export var area_till_size: int = 1  # 1 = 單格，3 = 3x3區域

var player: Player
var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var local_cell_position: Vector2
var distance: float
var last_till_time: float = 0.0

# 緩存變量避免重複計算
var cached_mouse_position: Vector2
var cached_cell_position: Vector2i
var cache_valid: bool = false

func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _unhandled_input(event: InputEvent) -> void:
	# 檢查冷卻時間
	if Time.get_ticks_msec() / 1000.0 - last_till_time < till_cooldown:
		return
	
	if event.is_action_pressed("remove_dirt"):
		if ToolManage.selected_tool == DataTypes.Tools.TillGround:
			if get_cell_under_mouse_with_validation():
				remove_tilled_soil()
	elif event.is_action_pressed("hit"):
		if ToolManage.selected_tool == DataTypes.Tools.TillGround:
			if get_cell_under_mouse_with_validation():
				add_tilled_soil()

func _process(_delta: float) -> void:
	# 每幀更新緩存，但只在需要時重新計算
	update_mouse_cache()

func update_mouse_cache() -> void:
	var current_mouse_pos = grass_tilemap_layer.get_local_mouse_position()
	
	# 只有當滑鼠位置變化足夠大時才更新緩存
	if not cache_valid or current_mouse_pos.distance_to(cached_mouse_position) > 1.0:
		cached_mouse_position = current_mouse_pos
		cached_cell_position = grass_tilemap_layer.local_to_map(cached_mouse_position)
		cache_valid = true

func get_cell_under_mouse_with_validation() -> bool:
	if not cache_valid:
		update_mouse_cache()
	
	mouse_position = cached_mouse_position
	cell_position = cached_cell_position
	cell_source_id = grass_tilemap_layer.get_cell_source_id(cell_position)
	local_cell_position = grass_tilemap_layer.map_to_local(cell_position)
	distance = player.global_position.distance_to(local_cell_position)
	
	# 驗證是否在有效範圍內
	return distance < interaction_distance

func add_tilled_soil() -> void:
	# 檢查是否有有效的草地可以耕作
	if cell_source_id == -1:
		return
	
	# 檢查是否已經被耕作過
	if is_already_tilled(cell_position):
		return
	
	if area_till_size == 1:
		# 單格耕作
		till_single_cell(cell_position)
	else:
		# 區域耕作
		till_area(cell_position, area_till_size)
	
	last_till_time = Time.get_ticks_msec() / 1000.0
	
	# 可選：添加耕作音效
	# AudioManager.play_sound("till_sound")

func remove_tilled_soil() -> void:
	# 檢查是否有耕地可以移除
	if not is_already_tilled(cell_position):
		return
	
	if area_till_size == 1:
		# 單格移除
		untill_single_cell(cell_position)
	else:
		# 區域移除
		untill_area(cell_position, area_till_size)
	
	last_till_time = Time.get_ticks_msec() / 1000.0

func till_single_cell(position: Vector2i) -> void:
	# 檢查是否有草地存在
	if grass_tilemap_layer.get_cell_source_id(position) != -1:
		tilled_soil_tilemap_layer.set_cells_terrain_connect([position], terrain_set, terrain, true)

func untill_single_cell(position: Vector2i) -> void:
	# 檢查是否有作物在這個位置
	if has_crop_at_position(position):
		print("無法移除耕地：此處有作物")
		return
	
	tilled_soil_tilemap_layer.set_cells_terrain_connect([position], 0, -1, true)

func till_area(center_position: Vector2i, size: int) -> void:
	var cells_to_till: Array[Vector2i] = []
	var half_size = size / 2
	
	for x in range(-half_size, half_size + 1):
		for y in range(-half_size, half_size + 1):
			var target_position = center_position + Vector2i(x, y)
			
			# 檢查距離限制
			var world_pos = grass_tilemap_layer.map_to_local(target_position)
			if player.global_position.distance_to(world_pos) > interaction_distance:
				continue
			
			# 檢查是否有草地且未被耕作
			if (grass_tilemap_layer.get_cell_source_id(target_position) != -1 and 
				not is_already_tilled(target_position)):
				cells_to_till.append(target_position)
	
	if cells_to_till.size() > 0:
		tilled_soil_tilemap_layer.set_cells_terrain_connect(cells_to_till, terrain_set, terrain, true)

func untill_area(center_position: Vector2i, size: int) -> void:
	var cells_to_untill: Array[Vector2i] = []
	var half_size = size / 2
	
	for x in range(-half_size, half_size + 1):
		for y in range(-half_size, half_size + 1):
			var target_position = center_position + Vector2i(x, y)
			
			# 檢查距離限制
			var world_pos = tilled_soil_tilemap_layer.map_to_local(target_position)
			if player.global_position.distance_to(world_pos) > interaction_distance:
				continue
			
			# 檢查是否已耕作且沒有作物
			if (is_already_tilled(target_position) and 
				not has_crop_at_position(target_position)):
				cells_to_untill.append(target_position)
	
	if cells_to_untill.size() > 0:
		tilled_soil_tilemap_layer.set_cells_terrain_connect(cells_to_untill, 0, -1, true)

func is_already_tilled(position: Vector2i) -> bool:
	return tilled_soil_tilemap_layer.get_cell_source_id(position) != -1

func has_crop_at_position(tile_position: Vector2i) -> bool:
	var crop_fields = get_parent().find_child("CropFields")
	if not crop_fields:
		return false
	
	var world_position = tilled_soil_tilemap_layer.map_to_local(tile_position)
	var crop_nodes = crop_fields.get_children()
	var tolerance = 8.0
	
	for node: Node2D in crop_nodes:
		if node.global_position.distance_to(world_position) <= tolerance:
			return true
	
	return false

# 可選：獲取預覽位置，用於顯示耕作預覽
func get_preview_positions() -> Array[Vector2i]:
	if not cache_valid:
		update_mouse_cache()
	
	var preview_positions: Array[Vector2i] = []
	var center_position = cached_cell_position
	
	if area_till_size == 1:
		preview_positions.append(center_position)
	else:
		var half_size = area_till_size / 2
		for x in range(-half_size, half_size + 1):
			for y in range(-half_size, half_size + 1):
				var target_position = center_position + Vector2i(x, y)
				var world_pos = grass_tilemap_layer.map_to_local(target_position)
				if player.global_position.distance_to(world_pos) <= interaction_distance:
					preview_positions.append(target_position)
	
	return preview_positions

# 可選：切換耕作模式
func toggle_till_mode() -> void:
	area_till_size = 3 if area_till_size == 1 else 1
	print("耕作模式: ", "區域" if area_till_size > 1 else "單格")
