extends Area3D


var detected := false
var collected := false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		detected = true
	
	if detected and !collected:	
		for group in get_groups():
			match group:
				"trash":
					Global.points += 10
					print(Global.points)
				"food":
					Global.health += 10
			collected = true
			queue_free()
