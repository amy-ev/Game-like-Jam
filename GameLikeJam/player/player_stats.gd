extends Node

signal noHealth
signal healthChanged
signal maxHealthChanged

@onready var player = $".."
@onready var level = Global.level
@onready var max_health = Global.player_max_health:
	set = set_max_health

@onready var health = max_health:
	get:
		return health
	set(value):
		health = value
		emit_signal("healthChanged")
		if health <= 0:
			emit_signal("noHealth") 
		if health >= max_health:
			health = max_health
			
func set_max_health(value):
	max_health = value
	emit_signal("maxHealthChanged")
	
func _ready() -> void:
	print(player)
