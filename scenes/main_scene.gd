# MainScene.gd
# 這個腳本應該附加到你的主場景根節點上 (例如一個 Node2D 或 Node)
extends Node

# _ready() 函式會在節點進入場景樹時被呼叫一次
# 你可以在這裡放置遊戲開始時需要執行的初始化程式碼
func _ready() -> void:
	pass # 目前不需要做任何事


# _process() 函式會在每一幀被呼叫
func _process(_delta: float) -> void:
	# 【核心】在每一幀的開始，都先假設滑鼠不在任何 UI 面板上。
	# 接著，其他 UI 面板 (如 tools_panel, inventory_panel) 的 _process 函式
	# 會在這一幀的稍後被執行，如果滑鼠在它們上方，它們就有機會把這個旗標設回 true。
	GameInputEvents.is_mouse_over_ui = false
	
	# 你可以在這裡加入其他需要在每一幀都執行的全域遊戲邏輯
	# 例如：檢查遊戲是否暫停、更新全域計時器等。
