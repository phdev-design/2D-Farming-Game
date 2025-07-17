extends Node

var selected_tool: DataTypes.Tools = DataTypes.Tools.None


signal tool_selected(tool: DataTypes.Tools)
signal enable_tool(tool: DataTypes.Tools)


func select_tool(tool: DataTypes.Tools) -> void:
	# 新增這一行來除錯
	print("2. ToolManage: Emitting tool_selected signal with tool: ", tool)
	tool_selected.emit(tool)
	selected_tool = tool
	
func enable_tool_button(tool: DataTypes.Tools) -> void:
	enable_tool.emit(tool)
