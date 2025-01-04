class_name Ball
extends CharacterBody2D

signal ball_scored(wall_name)

@export_range(100.0, 500.0, 5.0) var TARGET_SPEED : float = 320.0
@onready var hurtbox: Area2D = %HurtBox
@onready var audio_sp: AudioStreamPlayer2D = %AudioSP2D
@onready var sprite: Sprite2D = %Sprite
@onready var init_pos: Vector2 = Globals.vp_size/2
@onready var MIN_SPEED: float = TARGET_SPEED*.75

var stop : bool = false
var moving : bool = false
var dir : Vector2 = Vector2.ZERO

func _ready():
	await get_tree().physics_frame
	self.position = init_pos
	hurtbox.area_entered.connect(_on_player_entered)
	await get_tree().create_timer(3.0).timeout
	_start()

func _start():
	sprite.show()
	randomize()
	var x_rand : int = 1 if randi_range(0, 3) > 1 else -1
	var y_rand : float = randf_range(-1, 1)
	dir = Vector2(x_rand, y_rand).normalized()
	velocity = dir * TARGET_SPEED
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

func _physics_process(_delta: float) -> void:
	if stop: return
	var collided: bool = move_and_slide()
	if collided:
		var coll: KinematicCollision2D = get_last_slide_collision()
		if coll.get_collider() is Player: return
		var normal: Vector2 = coll.get_normal()
		
		velocity = velocity.bounce(normal)
		velocity += velocity.normalized() * MIN_SPEED*.125
		
		velocity.x += coll.get_collider_velocity().length()
		velocity.y += coll.get_collider_velocity().length()
		
		audio_sp.pitch_scale = randf_range(.7, .8)
		audio_sp.play()
	
	normalize_speed()

func normalize_speed():
	if abs(velocity.x) < MIN_SPEED:
		var accel_x: float = 40.0
		if velocity.x > .0 and velocity.x < MIN_SPEED:
			velocity.x += accel_x
		elif velocity.x < .0 and velocity.x > -MIN_SPEED:
			velocity.x -= accel_x
	elif abs(velocity.x) > TARGET_SPEED:
		var deaccel_x: float = 60.0
		if velocity.x > .0 and velocity.x > TARGET_SPEED:
			velocity.x -= deaccel_x
		elif velocity.x < .0 and velocity.x < -TARGET_SPEED:
			velocity.x += deaccel_x
	
	if abs(velocity.y) < MIN_SPEED:
		var accel_x: float = 40.0
		if velocity.y > .0 and velocity.y < MIN_SPEED/2:
			velocity.y += accel_x
		elif velocity.y < .0 and velocity.y > -MIN_SPEED/2:
			velocity.y -= accel_x
	elif abs(velocity.y) > TARGET_SPEED:
		var deaccel_x: float = 60.0
		if velocity.y > .0 and velocity.y > TARGET_SPEED:
			velocity.y -= deaccel_x
		elif velocity.y < .0 and velocity.y < -TARGET_SPEED:
			velocity.y += deaccel_x

func _on_player_entered(hitbox: Area2D) -> void:
	var collider := hitbox.get_parent()
	if not collider is Player: return
	
	var normal: Vector2 = (Vector2.LEFT + 
			(collider.velocity.normalized() * .25)).normalized()
	
	if collider._id == collider.PlayerType.PLAYER_1:
		normal = (Vector2.RIGHT +
			(collider.velocity.normalized() * .25)).normalized()
	
	#print("Normal: " + str(normal) + ", Velocity: " + str(velocity))
	velocity = velocity.bounce(normal)
	velocity += velocity.normalized() * MIN_SPEED*.125
	#print("Velocity bounced: " + str(velocity))
	
	audio_sp.pitch_scale = randf_range(1.0, 1.2)
	audio_sp.play()
