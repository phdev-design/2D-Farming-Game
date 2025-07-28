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
	print("Player found: ", player) # 檢查是否成功找到 Player 節點

# --- _unhandled_input 函式已被移除 ---

# 這是一個新的公開函式，將由 Player 腳本來呼叫
func perform_till_action():
	# 檢查冷卻時間
	if Time.get_ticks_msec() / 1000.0 - last_till_time < till_cooldown:
		return
		
	print("\n--- [偵錯] perform_till_action() 被呼叫 ---")

	# 1. 驗證滑鼠位置和距離
	var is_valid = get_cell_under_mouse_with_validation()
	print("[偵錯] 1. 驗證滑鼠位置與距離... 結果: ", is_valid)

	if is_valid:
		print("[偵錯] 2. 驗證成功. 嘗試執行 add_tilled_soil()")
		add_tilled_soil()
	else:
		if player == null:
			print("[偵錯] X. 驗證失敗: 'player' 變數是空的!")
			return
		print("[偵錯] X. 驗證失敗: 可能是距離太遠。")
		print("    - 玩家位置: ", player.global_position)
		print("    - 目標格子世界位置: ", local_cell_position)
		print("    - 距離: ", distance, " / 需要小於: ", interaction_distance)


func _process(_delta: float) -> void:
	update_mouse_cache()

func update_mouse_cache() -> void:
	if grass_tilemap_layer == null: return
	var current_mouse_pos = grass_tilemap_layer.get_local_mouse_position()
	
	if not cache_valid or current_mouse_pos.distance_to(cached_mouse_position) > 1.0:
		cached_mouse_position = current_mouse_pos
		cached_cell_position = grass_tilemap_layer.local_to_map(cached_mouse_position)
		cache_valid = true

func get_cell_under_mouse_with_validation() -> bool:
	if player == null: return false
	if not cache_valid: update_mouse_cache()
	
	mouse_position = cached_mouse_position
	cell_position = cached_cell_position
	
	if grass_tilemap_layer == null:
		print("[偵錯] X. 嚴重錯誤: grass_tilemap_layer 未設定!")
		return false
		
	cell_source_id = grass_tilemap_layer.get_cell_source_id(cell_position)
	local_cell_position = grass_tilemap_layer.map_to_local(cell_position)
	distance = player.global_position.distance_to(local_cell_position)
	
	return distance < interaction_distance

func add_tilled_soil() -> void:
	print("[偵錯] --- 進入 add_tilled_soil ---")
	if cell_source_id == -1:
		print("[偵錯] 3a. 無法耕作: 此處沒有草地。")
		return
	
	if is_already_tilled(cell_position):
		print("[偵錯] 3b. 無法耕作: 此處已經是耕地了。")
		return
	
	print("[偵錯] 3c. 條件滿足! 執行耕地操作。")
	
	if area_till_size == 1:
		till_single_cell(cell_position)
	else:
		till_area(cell_position, area_till_size)
	
	last_till_time = Time.get_ticks_msec() / 1000.0
	print("[偵錯] 4. 耕作完成!")


func remove_tilled_soil() -> void:
	if not is_already_tilled(cell_position):
		return
	
	if area_till_size == 1:
		untill_single_cell(cell_position)
	else:
		untill_area(cell_position, area_till_size)
	
	last_till_time = Time.get_ticks_msec() / 1000.0

func till_single_cell(position: Vector2i) -> void:
	if grass_tilemap_layer.get_cell_source_id(position) != -1:
		tilled_soil_tilemap_layer.set_cells_terrain_connect([position], terrain_set, terrain, true)

func untill_single_cell(position: Vector2i) -> void:
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
			
			if player.global_position.distance_to(grass_tilemap_layer.map_to_local(target_position)) > interaction_distance:
				continue
			
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
			
			if player.global_position.distance_to(tilled_soil_tilemap_layer.map_to_local(target_position)) > interaction_distance:
				continue
			
			if (is_already_tilled(target_position) and
				not has_crop_at_position(target_position)):
				cells_to_untill.append(target_position)
	
	if cells_to_untill.size() > 0:
		tilled_soil_tilemap_layer.set_cells_terrain_connect(cells_to_untill, 0, -1, true)

func is_already_tilled(position: Vector2i) -> bool:
	if tilled_soil_tilemap_layer == null:
		print("[偵錯] X. 嚴重錯誤: tilled_soil_tilemap_layer 未設定!")
		return false
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

# ... 其他函式保持不變 ...
