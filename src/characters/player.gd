class_name Player
extends CharacterBody2D

#signal reseted

const SPEED = 300.0
enum PlayerType {
	PLAYER_1,
	PLAYER_2,
	PLAYER_AI
}

@export var _id: PlayerType = PlayerType.PLAYER_1
@export var init_pos: Vector2 = Vector2(480, 270)

@onready var audio_sp: AudioStreamPlayer2D = %AudioSP2D
#@onready var reseting: bool = false

func  _ready() -> void:
	position = init_pos

func _physics_process(_delta: float) -> void:
#	if not reseting:
	var input: Dictionary = _get_input()
	var direction: float = input.get("dir", 0.0)
	if direction:
		var target_y: float = direction * SPEED
		velocity.y = move_toward(velocity.y, target_y, SPEED*.2)
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
#	else:
#		if position.y == init_pos.y: 
#			reseting = false
#			reseted.emit()
#		move_toward(velocity.y, init_pos.y, SPEED*.15)
	var collided: bool = move_and_slide()
	if position.x != init_pos.x: position.x = init_pos.x
	
	if not collided: return
	if (not get_last_slide_collision().get_collider() \
		is StaticBody2D or audio_sp.playing) or \
		velocity.y == 0: return
	audio_sp.pitch_scale = randf_range(.95, 1.1)
	audio_sp.play()

func _get_input() -> Dictionary:
	var v_dir: float = 0.0
	match _id:
		PlayerType.PLAYER_1:
			v_dir = Input.get_axis("p1_move_up", "p1_move_down")
		PlayerType.PLAYER_2:
			v_dir = Input.get_axis("p2_move_up", "p2_move_down")
		PlayerType.PLAYER_AI:
#			dir_vec.y = _ai_input(parent.ball_pos)
			v_dir = 0.0
	return { "dir": v_dir }

#func reset(_right: bool) -> void:
#	reseting = true
