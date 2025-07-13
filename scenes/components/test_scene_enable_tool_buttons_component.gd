extends Node

func _ready() -> void:
	call_deferred("enable_tool_button")
	
func enable_tool_button() -> void:
	ToolManage.enable_tool_button(DataTypes.Tools.TillGround)
	ToolManage.enable_tool_button(DataTypes.Tools.WaterCrops)
	ToolManage.enable_tool_button(DataTypes.Tools.PlantCorn)
	ToolManage.enable_tool_button(DataTypes.Tools.PlantTomato)
