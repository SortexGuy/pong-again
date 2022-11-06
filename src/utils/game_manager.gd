extends Node2D
class_name GameManager

signal _goal_reached(right: bool)

enum GAME_MODE {TEST = -1, PVP, PVAI}

#@export_file("*.tscn,*.scn") var main_menu_scene: String
@export var pausable: bool = true
@export var goal: int = 2 # (int, 1, 20)
@onready var ball: Ball = $%Ball
@onready var score_p1 : int = 0
@onready var score_p2 : int = 0

var current_game_mode : int = GAME_MODE.TEST
var players_in_game : int = 0

var gui : Control = null : 
	set(node):
		gui = node
		gui.p1_label.text = str(score_p1)
		gui.p2_label.text = str(score_p2)

func _ready() -> void:
	var wall_gen := $WallGenerator as WallGenerator
	wall_gen.goal_touched.connect(_on_ball_scored)
	_goal_reached.connect(_on_goal_reached)

# Scoring
func _on_ball_scored(right: bool):
	if right:
		score_p1 += 1
#		gui.p1_label.text = str(score_p1)
	else:
		score_p2 += 1
#		gui.p2_label.text = str(score_p2)
	if score_p1 == goal or score_p2 == goal:
		_goal_reached.emit(not right)
		ball._stop()
		return
	ball._reset()

func _on_goal_reached(_right: bool) -> void:
	pass
