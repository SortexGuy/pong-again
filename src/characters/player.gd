class_name Player
extends CharacterBody2D

#signal reseted

const SPEED = 300.0
enum PlayerType {
	PLAYER_1,
	PLAYER_2,
	PLAYER_AI
}
# [reaction_time, error, speed_scale, spin_read] per Globals.Difficulty
const AI_PRESETS = {
	Globals.Difficulty.EASY: [0.3, 100.0, 0.65, 0.0],
	Globals.Difficulty.NORMAL: [0.15, 70.0, 0.85, 0.5],
	Globals.Difficulty.HARD: [0.06, 60.0, 1.0, 1.0],
}

@export var _id: PlayerType = PlayerType.PLAYER_1
@export var init_pos: Vector2 = Vector2(480, 270)

@export_group("AI", "ai_")
@export var ai_ball: Ball
## Seconds between target updates, higher is easier
@export_range(0.0, 1.0, 0.01) var ai_reaction_time: float = 0.15
## Aim error in pixels, grows with shot steepness. Higher is easier
@export_range(0.0, 150.0, 1.0) var ai_error: float = 70.0
## Fraction of SPEED the AI can use
@export_range(0.1, 1.0, 0.05) var ai_speed_scale: float = 0.85
## How well the AI reads the ball's curve, 0 expects straight shots
@export_range(0.0, 1.0, 0.05) var ai_spin_read: float = 0.5

@onready var audio_sp: AudioStreamPlayer2D = %AudioSP2D
@onready var half_size: Vector2 = _get_half_size()
#@onready var reseting: bool = false

var _ai_target_y: float = 0.0
var _ai_offset: float = 0.0
var _ai_timer: float = 0.0
var _ai_ball_incoming: bool = false

func  _ready() -> void:
	position = init_pos
	_ai_target_y = init_pos.y
	if _id == PlayerType.PLAYER_AI:
		apply_ai_difficulty(Globals.ai_difficulty)

# Capsule height already includes both rounded ends
func _get_half_size() -> Vector2:
	var shape := $CollShape.shape as CapsuleShape2D
	return Vector2(shape.radius, shape.height/2)

func apply_ai_difficulty(difficulty: Globals.Difficulty) -> void:
	var preset: Array = AI_PRESETS[difficulty]
	ai_reaction_time = preset[0]
	ai_error = preset[1]
	ai_speed_scale = preset[2]
	ai_spin_read = preset[3]

func _physics_process(delta: float) -> void:
#	if not reseting:
	var input: Dictionary = _get_input(delta)
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

func _get_input(delta: float) -> Dictionary:
	var v_dir: float = 0.0
	match _id:
		PlayerType.PLAYER_1:
			v_dir = Input.get_axis("p1_move_up", "p1_move_down")
		PlayerType.PLAYER_2:
			v_dir = Input.get_axis("p2_move_up", "p2_move_down")
		PlayerType.PLAYER_AI:
			v_dir = _ai_input(delta)
	return { "dir": v_dir }

func _ai_input(delta: float) -> float:
	if not ai_ball: return 0.0
	# Only re-think every ai_reaction_time seconds
	_ai_timer -= delta
	if _ai_timer <= 0.0:
		_ai_timer = ai_reaction_time
		_ai_update_target()
	
	var diff: float = _ai_target_y - position.y
	if abs(diff) < 6.0: return 0.0
	# Ease into the target instead of overshooting it
	return clampf(diff / 40.0, -1.0, 1.0) * ai_speed_scale

func _ai_update_target() -> void:
	var ball_vel: Vector2 = ai_ball.velocity
	var incoming: bool = ai_ball.moving and ball_vel.x != 0.0 and \
		sign(ball_vel.x) == sign(position.x - ai_ball.position.x)
	
	if not incoming:
		# Ball going away or waiting to serve, drift back to center
		_ai_ball_incoming = false
		_ai_target_y = init_pos.y
		return
	
	# New shot towards us, roll a new aim error
	# Angled shots are harder to read than flat ones
	if not _ai_ball_incoming:
		_ai_ball_incoming = true
		var steepness: float = abs(ball_vel.y) / ball_vel.length()
		_ai_offset = randf_range(-ai_error, ai_error) * (0.5 + steepness)
	
	# Aim for the ball center when it touches our face, not our center
	var contact_x: float = position.x - \
		sign(position.x - ai_ball.position.x) * (half_size.x + ai_ball.radius)
	_ai_target_y = ai_ball.predict_y_at(contact_x, ai_spin_read) + _ai_offset

#func reset(_right: bool) -> void:
#	reseting = true
