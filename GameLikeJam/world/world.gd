extends Node3D

@onready var rooms = $rooms
@onready var width = 6
@onready var height = 4
@onready var room_w = 51.2
@onready var room_h = 51.2

@onready var player = preload("res://player/player.tscn").instantiate()

var map = []
var startPos = 0

signal mapGenerated
signal mapDrawn

#TODO: add function for adding doors - with a doors node
func _ready() -> void:
	#add_child(player)
	generate_path()
	await mapGenerated
	print_map()

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
	#player.set_position(Vector3(50.0,50.0,50.0))

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
					
				"2":
					pathName = str("res://world/rooms/2.tscn")
					
				"3":
					pathName = str("res://world/rooms/3.tscn")
					
				"4":
					pathName = str("res://world/rooms/4.tscn")
					
				"E":
					pathName = str("res://world/rooms/E.tscn")
					
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
