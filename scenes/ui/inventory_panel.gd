extends PanelContainer

@onready var log_label: Label = $MarginContainer/VBoxContainer/Logs/LogLabel
@onready var stone_label: Label = $MarginContainer/VBoxContainer/Stone/StoneLabel
@onready var corn_label: Label = $MarginContainer/VBoxContainer/Corn/CornLabel
@onready var tomato_label: Label = $MarginContainer/VBoxContainer/Tomato/TomatoLabel
@onready var egg_label: Label = $MarginContainer/VBoxContainer/Egg/EggLabel
@onready var milk_label: Label = $MarginContainer/VBoxContainer/Milk/MilkLabel

func _ready() -> void:
	InventoryManager.inventory_changed.connect(on_inventory_changed)

# 【新增】每一幀都檢查滑鼠是否在此面板上
func _process(_delta: float) -> void:
	# 如果滑鼠在面板的矩形範圍內，就設定全域旗標。
	# 注意：我們只將旗標設為 true，從不設為 false。
	# 這樣可以避免和 tools_panel 產生衝突。
	if get_global_rect().has_point(get_global_mouse_position()):
		GameInputEvents.is_mouse_over_ui = true

func on_inventory_changed() -> void:
	var inventory: Dictionary = InventoryManager.inventory

	if inventory.has("log"):
		log_label.text = str(inventory["log"])

	if inventory.has("stone"):
		stone_label.text = str(inventory["stone"])
		
	if inventory.has("corn"):
		corn_label.text = str(inventory["corn"])
		
	if inventory.has("tomato"):
		tomato_label.text = str(inventory["tomato"])
		
	if inventory.has("egg"):
		egg_label.text = str(inventory["egg"])
		
	if inventory.has("milk"):
		milk_label.text = str(inventory["milk"])
