extends Node

var room_w = 51.2
var room_h = 51.2

var width = 4
var height = 4

var raccoon_vision = false
var player: CharacterBody3D = null
var points = 0

var level = 1
var lives = 3

var health:int
var player_max_health = 100

var fox_damage:= 10
var fox_health:= 40

var start_pos:Vector3

signal pointsCollected(point:int)

@export var max_enemies = 6:
	set = set_max_enemies
@onready var enemy_number = 2:
	get:
		return enemy_number
	set(value):
		enemy_number = value
		if enemy_number >= max_enemies:
			enemy_number = max_enemies
		else:
			enemy_number = enemy_number
			
func set_max_enemies(value):
	max_enemies = value
	
	
func next_level():
	set_max_enemies(max_enemies+2)
	fox_damage += 5
	fox_health += 10
