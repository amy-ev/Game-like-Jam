extends Node3D

@onready var rooms = $rooms
@onready var width = Global.width
@onready var height = Global.height
@onready var room_w = Global.room_w
@onready var room_h = Global.room_h

@onready var fox = preload("res://enemies/fox.tscn")

var map = []
var startPos = 0

signal mapGenerated
signal edgesGenerated
signal mapDrawn
signal enemiesSpawned


func _ready() -> void:

	generate_path()
	await mapGenerated
	define_edges()
	await edgesGenerated
	print_map()
	await mapDrawn
	spawn_enemies()
	var root = get_tree().get_root()
	if root.has_node("/root/animation"):
		var anim = root.get_node("/root/animation")
		root.remove_child(anim)
	if root.has_node("/root/transition"):
		var anim = root.get_node("/root/transition")
		root.remove_child(anim)
		
func generate_path():
	# ensure a path from start room to end room is created
	# clearing the grid
	map = []

	for y in height:
		map.append([])
		for x in width:
			# turn grid into 'fillable' rooms
			map[y].append("0")

	var x = 0
	var y= 0
	
	startPos = randi_range(0,height-1)
	if startPos == 0:
		map[startPos][0] = "S.1"
	elif startPos == height - 1:
		map[startPos][0] = "S.2"
	else:
		map[startPos][0] = "S"
	y = startPos
	
	var nextRoom = 0 
	var finished = false
	var movedOnce = false
	while !finished:
		# ensure the rooms are placed one after the other, instead of all at once
		await get_tree().create_timer(0.0001).timeout
		if !movedOnce:
			if y > 0 && y < height - 1:
				nextRoom = randi_range(0,100)
				if nextRoom % 2 == 0:
					y -= 1
				else:
					y += 1
			elif y == 0:
					y += 1
			elif y == height - 1:
					y -= 1
			map[y][x] = "1"
			movedOnce = true

		elif movedOnce && x < width - 1:
				if y == 0 || y == height -1:
					if x > 0 && map[y][x-1] == "2" || x > 0 && map[y][x-1] == "4":
						map[y][x] = "4"
					else:
						map[y][x] = "2"
						x+= 1
					map[y][x] = "3"
					movedOnce = false
				else:
					nextRoom = randi_range(0,100)
					if nextRoom % 2 == 0:
						# check if above is free
						if map[y-1][x] == "0":
							y -= 1
							map[y][x] = "1"
						# else below is free
						else:
							y += 1
							map[y][x] = "1"
					
					#down
					else:
						if x > 0 && map[y][x-1] == "2" || x > 0 && map[y][x-1] == "4":
							map[y][x] = "4"
						else:
							map[y][x] = "2"
					
						x += 1
						map[y][x] = "3"
						movedOnce = false
		else:
			if y > 0 && x < width - 1:
				nextRoom = randi_range(0,100)
				if nextRoom % 2 == 0:
						y -= 1
				else:
						x += 1
				map[y][x] = "1"
			else: 
				map[y][x] = "E"
				finished = true	
				emit_signal("mapGenerated")	
func define_edges():
	var changeRoom = 0
	for y in height:
		for x in width:
			await get_tree().create_timer(0.0001).timeout
			if y == 0:
				match map[y][x]:
					"1":
						map[y][x] = "1.1"
					"2":
						map[y][x] = "2.1"
					"3":
						map[y][x] = "3.1"
					"4":
						map[y][x] = "4.1"
					"E":
						map[y][x] = "E.1"
			elif y == height - 1:
				match map[y][x]:
					"1":
						map[y][x] = "1.2"
					"2":
						map[y][x] = "2.2"
					"3":
						map[y][x] = "3.2"
					"4":
						map[y][x] = "4.2"
					"E":
						map[y][x] = "E.2"
			else:
				changeRoom = randi_range(0,100)
				if changeRoom % 2 == 0:
					if map[y-1][x] == "0":
						map[y-1][x] = "1.1"
					elif map[y+1][x] == "0":
						map[y+1][x] = "1.2"
				else:
					if map[y-1][x] == "0":
						match map[y][x]:
							"S":
								map[y][x] = "S.1"
							"1":
								map[y][x] = "1.1"
							"2":
								map[y][x] = "2.1"
							"3":
								map[y][x] = "3.1"
							"4":
								map[y][x] = "4.1"
							"E":
								map[y][x] = "E.1"
					elif map[y+1][x] == "0":
						match map[y][x]:
							"S":
								map[y][x] = "S.2"
							"1":
								map[y][x] = "1.2"
							"2":
								map[y][x] = "2.2"
							"3":
								map[y][x] = "3.2"
							"4":
								map[y][x] = "4.2"
							"E":
								map[y][x] = "E.2"
					else:
						map[y][x] = map[y][x]
	emit_signal("edgesGenerated")
					
func print_map():
	#loop through grid
	for y in height:
		for x in width:
			await get_tree().create_timer(0.0001).timeout
			#variable to path
			var pathName = ""
			#TODO: add dead end rooms
			match map[y][x]:
				"S":
					pathName = str("res://world/rooms/S.tscn")
				"S.1":
					pathName = str("res://world/rooms/S.1.tscn")
				"S.2":
					pathName = str("res://world/rooms/S.2.tscn")
					
				"1":
					pathName = str("res://world/rooms/1.tscn")
				"1.1":
					pathName = str("res://world/rooms/1.1.tscn")
				"1.2":
					pathName = str("res://world/rooms/1.2.tscn")
					
				"2":
					pathName = str("res://world/rooms/2.tscn")
				"2.1":
					pathName = str("res://world/rooms/2.1.tscn")
				"2.2":
					pathName = str("res://world/rooms/2.2.tscn")
					
				"3":
					pathName = str("res://world/rooms/3.tscn")
				"3.1":
					pathName = str("res://world/rooms/3.1.tscn")
				"3.2":
					pathName = str("res://world/rooms/3.2.tscn")
					
				"4":
					pathName = str("res://world/rooms/4.tscn")
				"4.1":
					pathName = str("res://world/rooms/4.1.tscn")
				"4.2":
					pathName = str("res://world/rooms/4.2.tscn")
					
				"E":
					pathName = str("res://world/rooms/E.tscn")
				"E.1":
					pathName = str("res://world/rooms/E.1.tscn")
				"E.2":
					pathName = str("res://world/rooms/E.2.tscn")
					
				"0":
					pathName = str("res://world/rooms/0.tscn")
					
			place_map(pathName, x * room_w, y * room_h)
	# print out the array 
	for i in height:
		print(map[i])
	emit_signal("mapDrawn")

func place_map(path, offsetX, offsetY):
	var scene = load(path)
	var instance = scene.instantiate()
	instance.position = Vector3(offsetX, 0.0, offsetY)
	rooms.add_child(instance)


func enemy_inst(y,x):
	var enemy_num = randi_range(Global.enemy_number, Global.max_enemies)
	for i in range(enemy_num):
		var new_enemy = fox.instantiate()
		add_child(new_enemy)
		new_enemy.name = "fox"
		var global_y = y * room_h
		var global_x = x * room_w
		
		new_enemy.position = Vector3(randi_range(global_x,global_x+room_w),0.0,randi_range(global_y,global_y+room_h))

func spawn_enemies():
	for y in range(height):
		for x in width:
			if map[y][x] == "S" || map[y][x] == "E":
				pass
			elif map[y][x] == "S.1" || map[y][x] == "E.1":
				pass
			elif map[y][x] == "S.2" || map[y][x] == "E.2":
				pass
			else:
				enemy_inst(y,x)
	emit_signal("enemiesSpawned")
