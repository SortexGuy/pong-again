class_name Ball
extends CharacterBody2D

signal ball_scored(wall_name)

# Max collisions resolved in one physics frame (corner hits need 2)
const MAX_BOUNCES = 4
# How much of the paddle's vertical velocity is passed to the ball
const PADDLE_SPIN = 0.25

@export_range(100.0, 500.0, 5.0) var TARGET_SPEED : float = 320.0
## Speed gained on every paddle hit
@export_range(0.0, 100.0, 1.0) var SPEED_STEP : float = 16.0
## Speed cap, keeps the ball reachable and under one radius per frame
@export_range(300.0, 1000.0, 10.0) var MAX_SPEED : float = 640.0
## Steepest angle from horizontal the ball can travel at
@export_range(15.0, 75.0, 1.0) var MAX_BOUNCE_ANGLE : float = 60.0
@onready var audio_sp: AudioStreamPlayer2D = %AudioSP2D
@onready var sprite: Sprite2D = %Sprite
@onready var radius: float = ($CollShape.shape as CircleShape2D).radius
@onready var init_pos: Vector2 = Globals.vp_size/2

var stop : bool = false
var moving : bool = false
var dir : Vector2 = Vector2.ZERO
var speed : float = 0.0

func _ready():
	await get_tree().physics_frame
	self.position = init_pos
	await get_tree().create_timer(3.0).timeout
	_start()

func _start():
	sprite.show()
	randomize()
	var x_rand : int = 1 if randi_range(0, 3) > 1 else -1
	var y_rand : float = randf_range(-1, 1)
	speed = TARGET_SPEED
	_set_dir(Vector2(x_rand, y_rand))
	moving = true
	stop = false

func _stop():
	sprite.hide()
	dir = Vector2.ZERO
	velocity = Vector2.ZERO
	moving = false
	stop = true
	self.position = init_pos
#	get_tree().paused = true

func _reset():
	sprite.hide()
	dir = Vector2.ZERO
	velocity = Vector2.ZERO
	moving = false
	stop = false
	self.position = init_pos
	if !stop:
		await get_tree().physics_frame
		await get_tree().create_timer(3.0).timeout
		_start()

func _physics_process(delta: float) -> void:
	if stop or not moving: return
	# Spend the whole frame's travel, bouncing as many times as needed,
	# so the ball never sticks to or slides along a surface
	var motion: Vector2 = velocity * delta
	for i in MAX_BOUNCES:
		var coll: KinematicCollision2D = move_and_collide(motion)
		if not coll: break
		if coll.get_collider() is Player:
			_bounce_off_player(coll.get_collider(), coll.get_normal())
		else:
			_bounce_off_wall(coll.get_normal())
		motion = dir * coll.get_remainder().length()

func _bounce_off_wall(normal: Vector2) -> void:
	_set_dir(dir.bounce(normal))
	audio_sp.pitch_scale = randf_range(.7, .8)
	audio_sp.play()

func _bounce_off_player(player: Player, normal: Vector2) -> void:
	speed = minf(speed + SPEED_STEP, MAX_SPEED)
	if abs(normal.x) > abs(normal.y):
		# Hit the flat face: angle comes from where it landed on the paddle,
		# the center sends it straight, the tips at MAX_BOUNCE_ANGLE
		var reach: float = player.half_size.y + radius
		var offset: float = clampf(
			(position.y - player.position.y) / reach, -1.0, 1.0)
		var angle: float = deg_to_rad(MAX_BOUNCE_ANGLE) * offset
		var new_dir := Vector2(signf(normal.x) * cos(angle), sin(angle))
		_set_dir(new_dir * speed + Vector2(0, player.velocity.y * PADDLE_SPIN))
	else:
		# Hit a rounded end: reflect off its real surface normal
		_set_dir(dir.bounce(normal) * speed + Vector2(0, player.velocity.y))
	audio_sp.pitch_scale = randf_range(1.0, 1.2)
	audio_sp.play()

# Keeps speed constant and the angle playable, no near-vertical rallies
func _set_dir(new_dir: Vector2) -> void:
	var max_angle: float = deg_to_rad(MAX_BOUNCE_ANGLE)
	var angle: float = clampf(atan2(abs(new_dir.y), abs(new_dir.x)), 0.0, max_angle)
	var x_sign: float = signf(new_dir.x) if new_dir.x != 0.0 else 1.0
	dir = Vector2(x_sign * cos(angle), signf(new_dir.y) * sin(angle))
	velocity = dir * speed
