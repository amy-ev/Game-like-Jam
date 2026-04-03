extends Node

signal noHealth
signal healthChanged
signal maxHealthChanged

@onready var player = $".."
@onready var max_health = Global.player_max_health:
	set = set_max_health

@onready var health = max_health:
	get:
		return health
	set(value):
		health = value
		Global.health = health
		if health <= 30:
			player.avatar_h_blood.play("30")
			player.avatar_l_blood.play("100")
		elif health <= 50:
			player.avatar_l_blood.play("50")
			player.avatar_h_blood.play("100")
		else:
			player.avatar_l_blood.play("100")
			player.avatar_h_blood.play("100")
		emit_signal("healthChanged")
		if health <= 0:
			emit_signal("noHealth") 
		if health >= max_health:
			health = max_health
			
func set_max_health(value):
	max_health = value
	emit_signal("maxHealthChanged")
	
