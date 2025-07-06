extends PanelContainer

@onready var tool_tilling: Button = $MarginContainer/HBoxContainer/ToolTilling
@onready var tool_watering_can: Button = $MarginContainer/HBoxContainer/ToolWateringCan
@onready var tool_corn: Button = $MarginContainer/HBoxContainer/ToolCorn
@onready var tool_tomato: Button = $MarginContainer/HBoxContainer/ToolTomato


func _on_tool_axe_pressed() -> void:
	ToolManage.select_tool(DataTypes.Tools.AxeWood)


func _on_tool_tilling_pressed() -> void:
	pass # Replace with function body.
