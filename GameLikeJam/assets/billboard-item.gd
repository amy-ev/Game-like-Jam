extends Sprite3D


func _ready() -> void:
	var i:int
	var path_name:String
	for group in get_groups():
		match group:
			"grass":
				i = randi_range(0,5)
				path_name = str("res://assets/grass/grass_",i,".png")
			"trash":
				i = randi_range(0,3)
				path_name = str("res://assets/trash/trash_",i,".png")
			"food":
				i = randi_range(0,3)
				path_name = str("res://assets/food/food_",i,".png")
	set_texture(load(path_name))
