# player.gd
class_name Player
extends CharacterBody2D

@onready var hit_component: HitComponent = $HitComponent

@export var current_tool: DataTypes.Tools = DataTypes.Tools.None

var direction: Vector2 = Vector2.DOWN # 給一個初始方向，避免 idle 狀態一開始沒動畫

func _ready() -> void:
	ToolManage.tool_selected.connect(on_tool_selected)
	
func on_tool_selected(tool: DataTypes.Tools) -> void:
	# 新增這一行來除錯
	print("3. Player received tool_selected signal! New tool is: ", tool)
	current_tool = tool
	hit_component.current_tool = tool
