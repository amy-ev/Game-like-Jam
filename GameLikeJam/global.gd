extends Node

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
