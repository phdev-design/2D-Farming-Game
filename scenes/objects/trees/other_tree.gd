extends Sprite2D

@onready var hurt_component: HurtComponent = $HurtComponent
@onready var damage_component: DamageComponent = $DamageComponent
# 【新增】獲取我們剛剛建立的節點
@onready var interaction_area: Area2D = $InteractionArea
@onready var selectbox: Node2D = $Selectbox


var log_scene = preload("res://scenes/objects/trees/wood.tscn")

func _ready() -> void:
	# 【新增】連接 InteractionArea 的信號
	# 當有物體進入時，呼叫 _on_interaction_area_body_entered
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	# 當有物體離開時，呼叫 _on_interaction_area_body_exited
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	hurt_component.hurt.connect(on_hurt)
	damage_component.max_damaged_reached.connect(on_max_damage_reached)
	
func on_hurt(hit_damage: int) -> void:
	damage_component.apply_damage(hit_damage)
	material.set_shader_parameter("shake_intensity", 0.9)
	await get_tree().create_timer(1.0).timeout
	material.set_shader_parameter("shake_intensity", 0.0)
	
func on_max_damage_reached() -> void:
	call_deferred("add_log_scene")
	print("max damaged reached")
	queue_free()

# 【保留修正】這個函式中的座標修正仍然很重要
func add_log_scene() -> void:
	for i in 6:
		var log_instance = log_scene.instantiate() as Node2D
		get_parent().add_child(log_instance)
		log_instance.global_position = self.global_position
		var random_offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))
		log_instance.global_position += random_offset

# --- 新增的選擇框邏輯 ---

# 當有物體進入 InteractionArea 時，這個函式會被觸發
func _on_interaction_area_body_entered(body: Node2D) -> void:
	# 新增這一行，印出進入區域的物體的名稱
	#print("InteractionArea entered by: ", body.name) 
	
	if body is Player or body is Player2:
		# 新增這一行，確認是否成功判斷為玩家
		#print("Body is the player! Showing selectbox.")
		selectbox.show()

# 當有物體離開 InteractionArea 時，這個函式會被觸發
func _on_interaction_area_body_exited(body: Node2D) -> void:
	# 檢查離開的物體是否是玩家
	if body is Player or body is Player2:
		# 如果是玩家，就隱藏選擇框
		selectbox.hide()
