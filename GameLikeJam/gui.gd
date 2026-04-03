extends Control

@onready var points_label = $gui/panel/HBoxContainer/score/VBoxContainer/points
@onready var level_label = $gui/panel/HBoxContainer/level/VBoxContainer/level
@onready var lives_label = $gui/panel/HBoxContainer/lives/VBoxContainer/lives
@onready var health_label = $gui/panel/HBoxContainer/health/VBoxContainer/health

func _ready() -> void:
	Global.connect("pointsCollected", _on_points_collected)
	get_node("attack-sprite").play("default")
	level_label.text = str(Global.level)
	lives_label.text = str(Global.lives)
	points_label.text = str(Global.points)
	health_label.text = str(Global.player_max_health) + "%"
	
func _on_points_collected(points:int):
	Global.points += points
	points_label.text = str(Global.points)

func _on_player_stats_health_changed() -> void:
	health_label.text = str(Global.health)+ "%"

func _on_player_stats_no_health() -> void:
	lives_label.text = str(Global.lives)
