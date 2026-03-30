extends Control

@onready var points_label = $gui/panel/HBoxContainer/score/Label

func _ready() -> void:
	Global.connect("pointsCollected", _on_points_collected)
	
	
func _on_points_collected(points:int):
	Global.points += points
	points_label.text = str(Global.points)
