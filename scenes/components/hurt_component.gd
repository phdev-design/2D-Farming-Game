# hurt_component.gd
class_name HurtComponent
extends Area2D

# 這個 tool 變數非常重要！
# 你需要在 Godot 編輯器中，為每一棵樹的 HurtComponent，
# 將這個值設定為對應的工具 (例如 DataTypes.Tools.AxeWood)。
@export var tool : DataTypes.Tools = DataTypes.Tools.None

signal hurt

# 這個函式會在有另一個 Area2D 進入時被觸發
func _on_area_entered(area: Area2D) -> void:
	# 【最終除錯】如果這行 print 沒有出現，就代表物理層設定 100% 有問題。
	print("!!! HURTBOX DETECTED AN AREA: ", area.name, " !!!")

	var hit_component = area as HitComponent
	
	if hit_component == null:
		print("--- The entering area is NOT a HitComponent. ---")
		return

	print("--- Checking tool. Required: ", tool, " | Player has: ", hit_component.current_tool, " ---")
	
	if tool == hit_component.current_tool:
		print("--- Tools match! Emitting hurt signal. ---")
		hurt.emit(hit_component.hit_damage)
	else:
		print("--- Tools DO NOT match. No damage. ---")
