# player2.gd
class_name Player2
extends CharacterBody2D

@onready var hit_component: HitComponent = $HitComponent

@export var current_tool: DataTypes.Tools = DataTypes.Tools.None

var direction: Vector2 = Vector2.DOWN # 給一個初始方向，避免 idle 狀態一開始沒動畫

func _ready() -> void:
	# 【注意】這裡假設 ToolManage 是全域的工具管理器。
	# 只要 Player 1 和 Player 2 不同時在場，這個連接就沒有問題。
	ToolManage.tool_selected.connect(on_tool_selected)
	
func on_tool_selected(tool: DataTypes.Tools) -> void:
	# 新增這一行來除錯
	print("3. Player received tool_selected signal! New tool is: ", tool)
	current_tool = tool
	hit_component.current_tool = tool
