extends Area3D


var detected := false
var opened := false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		detected = true

func _input(event: InputEvent) -> void:
	if detected and !opened:
		if event.is_action_pressed("interact"):
			if self.name.begins_with("bin"):
				remove_child(get_node("bin-lid"))
				Global.emit_signal("pointsCollected",50)
			else:
				Global.emit_signal("pointsCollected",100)
			opened = true
			print("opened!")

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		detected = false
