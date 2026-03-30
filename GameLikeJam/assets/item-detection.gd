extends Area3D


var detected := false
var collected := false


	
func _on_body_entered(body: Node3D) -> void:
	print(body)
	if body.is_in_group("player"):
		detected = true
	
	if detected and !collected:
		for group in get_groups():
			match group:
				"trash":
					Global.emit_signal("pointsCollected",10)

				"food":
					var stats = body.get_node("player_stats")
					stats.health += 10
					print(stats.health)
					
			collected = true
			queue_free()
