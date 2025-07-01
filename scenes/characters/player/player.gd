# player.gd
class_name Player
extends CharacterBody2D

@export var current_tool: DataTypes.Tools = DataTypes.Tools.None

var direction: Vector2 = Vector2.DOWN # 給一個初始方向，避免 idle 狀態一開始沒動畫
