extends Panel

@onready var animated_sprite_2d: AnimatedSprite2D = $Emotes/AnimatedSprite2D
@onready var emote_idle_timer: Timer = $EmoteIdleTimer

var idle_emotes:Array = ["emote_1_idle", "emote_2_smile", "emote_3_ear_wave", "emote_4_blink"]

func _ready() -> void:
	animated_sprite_2d.play("emote_1_idle")
	
	InventoryManager.inventory_changed.connect(on_inventory_changed)
	GameDialogueManager.feed_the_animals.connect(on_feed_the_animals)


# 【新增】每一幀都檢查滑鼠是否在此面板上
func _process(_delta: float) -> void:
	# 如果滑鼠在面板的矩形範圍內，就設定全域旗標。
	# 這會和 tools_panel, inventory_panel 一起運作，
	# 只要滑鼠在任何一個 UI 面板上，旗標就會是 true。
	if get_global_rect().has_point(get_global_mouse_position()):
		GameInputEvents.is_mouse_over_ui = true


func play_emote(animation: String) -> void:
	animated_sprite_2d.play(animation)


func _on_emote_idle_timer_timeout() -> void:
	var index = randi_range(0, 3)
	var emote = idle_emotes[index]
	
	animated_sprite_2d.play(emote)

func on_inventory_changed() -> void:
	animated_sprite_2d.play("emote_7_excited")

func on_feed_the_animals() -> void:
	animated_sprite_2d.play("emote_6_love_kiss")
