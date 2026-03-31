extends Control

@onready var points_label = $gui/panel/HBoxContainer/score/VBoxContainer/points

func _ready() -> void:
	Global.connect("pointsCollected", _on_points_collected)
	get_node("attack-sprite").play("default")
	
func _on_points_collected(points:int):
	Global.points += points
	points_label.text = str(Global.points)
