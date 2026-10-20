class_name Ball
extends CharacterBody2D

signal ball_scored(wall_name)

# Max collisions resolved in one physics frame (corner hits need 2)
const MAX_BOUNCES = 4
# Moment of inertia as a fraction of m*r^2, 2/5 is a solid sphere
const INERTIA_FACTOR = 0.4
# Frames ahead predict_y_at() is willing to simulate
const PREDICT_MAX_STEPS = 600

@export_range(100.0, 500.0, 5.0) var TARGET_SPEED : float = 320.0
## Speed gained on every paddle hit
@export_range(0.0, 100.0, 1.0) var SPEED_STEP : float = 16.0
## Speed cap, a hit below it can overshoot it, then it settles back
@export_range(300.0, 1000.0, 10.0) var MAX_SPEED : float = 640.0
## Steepest angle from horizontal the ball can travel at
@export_range(15.0, 75.0, 1.0) var MAX_BOUNCE_ANGLE : float = 60.0
## Seconds a speed or spin peak above its cap takes to settle back to it
@export_range(0.0, 5.0, 0.05) var PEAK_SETTLE_TIME : float = 1.5

@export_group("Spin")
## How hard spin bends the path (Magnus effect), radians of turn
## per second for each rad/s of spin
@export_range(0.0, 0.1, 0.001) var CURVE_STRENGTH : float = 0.018
## Spin decay rate from air drag, higher stops spinning sooner
@export_range(0.0, 2.0, 0.05) var SPIN_DAMPING : float = 0.3
## Spin cap in rad/s, a hit below it can overshoot it, then it settles back
@export_range(0.0, 60.0, 1.0) var MAX_SPIN : float = 30.0
## How much of the sliding a paddle hit turns into spin, 0 is ice, 1 is rubber
@export_range(0.0, 1.0, 0.05) var PADDLE_GRIP : float = 0.95
## Same as PADDLE_GRIP but for the top and bottom walls
@export_range(0.0, 1.0, 0.05) var WALL_GRIP : float = 0.65
## Draws seams on the ball so its rotation can be seen
@export var show_spin_marks : bool = true

@onready var audio_sp: AudioStreamPlayer2D = %AudioSP2D
@onready var sprite: Sprite2D = %Sprite
@onready var radius: float = ($CollShape.shape as CircleShape2D).radius
@onready var init_pos: Vector2 = Globals.vp_size/2

var stop : bool = false
var moving : bool = false
var dir : Vector2 = Vector2.ZERO
var speed : float = 0.0
## Angular velocity in rad/s, positive turns +x towards +y (clockwise on screen)
var spin : float = 0.0
# Units per second a peak above the cap loses until it is back on the cap
var _speed_settle_rate : float = 0.0
var _spin_settle_rate : float = 0.0

func _ready():
	if show_spin_marks: sprite.draw.connect(_draw_spin_marks)
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
	_speed_settle_rate = 0.0
	_reset_spin()
	_set_dir(Vector2(x_rand, y_rand))
	moving = true
	stop = false

func _stop():
	sprite.hide()
	dir = Vector2.ZERO
	velocity = Vector2.ZERO
	_reset_spin()
	moving = false
	stop = true
	self.position = init_pos
#	get_tree().paused = true

func _reset():
	sprite.hide()
	dir = Vector2.ZERO
	velocity = Vector2.ZERO
	_reset_spin()
	moving = false
	stop = false
	self.position = init_pos
	if !stop:
		await get_tree().physics_frame
		await get_tree().create_timer(3.0).timeout
		_start()

func _reset_spin() -> void:
	spin = 0.0
	_spin_settle_rate = 0.0
	sprite.rotation = 0.0

func _physics_process(delta: float) -> void:
	if stop or not moving: return
	# Peaks above the caps ease back onto them
	speed = _settle(speed, MAX_SPEED, _speed_settle_rate, delta)
	# Spin bends the path and slowly dies off in the air
	_set_dir(_curve(dir, spin, delta))
	spin = _spin_step(spin, _spin_settle_rate, delta)
	sprite.rotation = wrapf(sprite.rotation + spin * delta, -PI, PI)
	# Spend the whole frame's travel, bouncing as many times as needed,
	# so the ball never sticks to or slides along a surface
	var motion: Vector2 = velocity * delta
	for i in MAX_BOUNCES:
		var coll: KinematicCollision2D = move_and_collide(motion)
		if not coll: break
		var normal: Vector2 = coll.get_normal()
		# Already leaving it (e.g. a paddle sliding into us), don't bounce twice
		if dir.dot(normal) >= 0.0: pass
		elif coll.get_collider() is Player:
			_bounce_off_player(coll.get_collider(), normal)
		else:
			_bounce_off_wall(normal)
		motion = dir * coll.get_remainder().length()

func _bounce_off_wall(normal: Vector2) -> void:
	var result: Array = _wall_bounce(dir, speed, spin, _spin_settle_rate, normal)
	spin = result[1]
	_spin_settle_rate = result[2]
	_set_dir(result[0])
	audio_sp.pitch_scale = randf_range(.7, .8)
	audio_sp.play()

func _bounce_off_player(player: Player, normal: Vector2) -> void:
	var vel_in: Vector2 = velocity
	var pushed: Array = _push_capped(
		speed, speed + SPEED_STEP, MAX_SPEED, _speed_settle_rate)
	speed = pushed[0]
	_speed_settle_rate = pushed[1]
	var vel_out: Vector2
	if abs(normal.x) > abs(normal.y):
		# Hit the flat face: angle comes from where it landed on the paddle,
		# the center sends it straight, the tips at MAX_BOUNCE_ANGLE
		var reach: float = player.half_size.y + radius
		var offset: float = clampf(
			(position.y - player.position.y) / reach, -1.0, 1.0)
		var angle: float = deg_to_rad(MAX_BOUNCE_ANGLE) * offset
		vel_out = Vector2(signf(normal.x) * cos(angle), sin(angle)) * speed
	else:
		# Hit a rounded end: reflect off its real surface normal
		vel_out = vel_in.bounce(normal)
	# Rubbing against a moving paddle is what puts spin on the ball
	var result: Array = _friction(vel_in, spin, normal, player.velocity, PADDLE_GRIP)
	pushed = _push_capped(spin, result[1], MAX_SPIN, _spin_settle_rate)
	spin = pushed[0]
	_spin_settle_rate = pushed[1]
	_set_dir(vel_out + result[0])
	audio_sp.pitch_scale = randf_range(1.0, 1.2)
	audio_sp.play()

# Keeps speed constant and the angle playable, no near-vertical rallies
func _set_dir(new_dir: Vector2) -> void:
	dir = _clamp_dir(new_dir)
	velocity = dir * speed

func _clamp_dir(new_dir: Vector2) -> Vector2:
	var max_angle: float = deg_to_rad(MAX_BOUNCE_ANGLE)
	var angle: float = clampf(atan2(abs(new_dir.y), abs(new_dir.x)), 0.0, max_angle)
	var x_sign: float = signf(new_dir.x) if new_dir.x != 0.0 else 1.0
	return Vector2(x_sign * cos(angle), signf(new_dir.y) * sin(angle))

# Magnus effect, the path turns towards the side spin x velocity points to
func _curve(d: Vector2, w: float, delta: float) -> Vector2:
	return d.rotated(CURVE_STRENGTH * w * delta)

# Over the cap spin eases back onto it, under it air drag slowly bleeds it off
func _spin_step(w: float, settle_rate: float, delta: float) -> float:
	if abs(w) > MAX_SPIN: return _settle(w, MAX_SPIN, settle_rate, delta)
	return w * exp(-SPIN_DAMPING * delta)

# Something can only be added while under the cap, but that addition may
# overshoot it. Returns [new value, settle rate], a new peak gets a rate
# that brings it back onto the cap in PEAK_SETTLE_TIME
func _push_capped(old: float, new: float, cap: float, settle_rate: float) -> Array:
	var grows: bool = signf(new) == signf(old) and abs(new) > abs(old)
	if abs(old) >= cap and grows: return [old, settle_rate]
	if abs(new) > cap and (grows or signf(new) != signf(old)):
		settle_rate = (abs(new) - cap) / maxf(PEAK_SETTLE_TIME, 0.001)
	return [new, settle_rate]

# Linearly brings a value above its cap back down, leaves it alone otherwise
func _settle(value: float, cap: float, settle_rate: float, delta: float) -> float:
	if abs(value) <= cap: return value
	return signf(value) * maxf(abs(value) - settle_rate * delta, cap)

# Returns [new dir, new spin, new spin settle rate] after bouncing off a static wall
func _wall_bounce(d: Vector2, s: float, w: float, w_rate: float, normal: Vector2) -> Array:
	var vel_in: Vector2 = d * s
	var result: Array = _friction(vel_in, w, normal, Vector2.ZERO, WALL_GRIP)
	var pushed: Array = _push_capped(w, result[1], MAX_SPIN, w_rate)
	return [vel_in.bounce(normal) + result[0], pushed[0], pushed[1]]

# Friction impulse at the contact point, returns [velocity change, new spin].
# The point touching the surface slides at the ball's tangential velocity
# minus spin*radius, friction removes part of that slide and splits the
# impulse between the ball's motion and its spin like a real rigid body
func _friction(vel_in: Vector2, w: float, normal: Vector2,
		surface_vel: Vector2, grip: float) -> Array:
	var tangent := Vector2(-normal.y, normal.x)
	var slip: float = (vel_in - surface_vel).dot(tangent) - w * radius
	var impulse: float = -grip * slip / (1.0 + 1.0/INERTIA_FACTOR)
	return [tangent * impulse, w - impulse / (INERTIA_FACTOR * radius)]

## Where the ball's center will be when it reaches x, following the curve
## and bouncing off the top and bottom walls. spin_read scales how much of
## the current spin is taken into account, 0 assumes a straight shot
func predict_y_at(x: float, spin_read: float = 1.0) -> float:
	var step: float = get_physics_process_delta_time()
	var top: float = WallGenerator.THICKNESS/2 + radius
	var bottom: float = Globals.vp_size.y - top
	var pos: Vector2 = position
	var d: Vector2 = dir
	var s: float = speed
	var w: float = spin * spin_read
	var w_rate: float = _spin_settle_rate * spin_read
	for i in PREDICT_MAX_STEPS:
		if (x - pos.x) * d.x <= 0.0: break
		s = _settle(s, MAX_SPEED, _speed_settle_rate, step)
		d = _clamp_dir(_curve(d, w, step))
		w = _spin_step(w, w_rate, step)
		pos += d * s * step
		if pos.y < top or pos.y > bottom:
			var normal: Vector2 = Vector2.DOWN if pos.y < top else Vector2.UP
			var edge: float = top if pos.y < top else bottom
			pos.y = edge*2 - pos.y
			var result: Array = _wall_bounce(d, s, w, w_rate, normal)
			d = _clamp_dir(result[0])
			w = result[1]
			w_rate = result[2]
	return pos.y

func _draw_spin_marks() -> void:
	var mark_color := Color(1, 1, 1, .3)
	sprite.draw_arc(Vector2.ZERO, radius*.6, -.7, .7, 8, mark_color, 3.0)
	sprite.draw_arc(Vector2.ZERO, radius*.6, PI - .7, PI + .7, 8, mark_color, 3.0)
