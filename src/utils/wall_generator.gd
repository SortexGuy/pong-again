class_name WallGenerator
extends Node2D

signal goal_touched(right: bool)

@export var up_down_texture: Texture2D

@export_group("Walls Collision", "walls_")
@export_flags_2d_physics @onready
var walls_bit_layer: int = 1
@export_flags_2d_physics @onready
var walls_bit_mask: int = 2+4
@export_group("Area2D Collision", "area_")
@export_flags_2d_physics @onready
var area_bit_layer: int = 8
@export_flags_2d_physics @onready
var area_bit_mask: int = 4

func _ready():
	var make_wall := func(dir: Vector2):
		# Create StaticBody with layer/mask set
		var wall_node := StaticBody2D.new()
		wall_node.collision_layer = walls_bit_layer
		wall_node.collision_mask = walls_bit_mask
		# Calculate node position
		var x_pos := Globals.vp_size.x/2
		if dir.x < 0: x_pos = 0
		elif dir.x > 0: x_pos *= 2
		var y_pos = Globals.vp_size.y/2
		if dir.y < 0: y_pos = 0
		elif dir.y > 0: y_pos *= 2
		wall_node.position = Vector2(x_pos, y_pos)
		# Create StaticBody CollisionShape
		var coll_shape_node := CollisionShape2D.new()
		coll_shape_node.shape = RectangleShape2D.new()
		# Calculate CollShape size
		var x_size: float = 60
		var y_size: float = 60 
		if dir.x == 0: x_size += Globals.vp_size.x
		if dir.y == 0: y_size += Globals.vp_size.y
		coll_shape_node.shape.size = Vector2(x_size, y_size)
		# Add CollShape to Wall
		wall_node.add_child(coll_shape_node, true)
		# If is wall left or right (Goal)
		if dir.x != 0:
			# Create Area2D with layer/mask set
			var area2d_node := Area2D.new()
			area2d_node.collision_layer = area_bit_layer
			area2d_node.collision_mask = area_bit_mask
			# Create Area2D CollisionShape with its size
			var area_coll_shape_node := CollisionShape2D.new()
			area_coll_shape_node.shape = RectangleShape2D.new()
			area_coll_shape_node.shape.size = Vector2(x_size + 16, y_size)
			area_coll_shape_node.debug_color.r = 1.0
			# Connect area_entered signal to goal_touched emitter
			area2d_node.area_entered.connect(_emit_goal_touched)
			# Add CollShape to Area2D and Area2D to Wall
			area2d_node.add_child(area_coll_shape_node, true)
			wall_node.add_child(area2d_node, true)
		# Add wall to scene tree
		add_child(wall_node, true)
	# Call lambda
	for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		make_wall.call(dir)
	
	var create_sprites := func():
		var sprite_batch: CanvasGroup = CanvasGroup.new()
		sprite_batch.use_mipmaps = true
		var sprite_up: Sprite2D = Sprite2D.new()
		sprite_up.texture = up_down_texture
		var x_pos := Globals.vp_size.x/2
		sprite_up.position = Vector2(x_pos, 0)
		var sprite_down: Sprite2D = Sprite2D.new()
		sprite_down.texture = up_down_texture
		var y_pos := Globals.vp_size.y
		sprite_down.position = Vector2(x_pos, y_pos)
		
		sprite_batch.add_child(sprite_up, true)
		sprite_batch.add_child(sprite_down, true)
		add_child(sprite_batch, true)
	
	create_sprites.call()

func _emit_goal_touched(area: Area2D) -> void:
	var node := area.get_parent()
	if not node is Ball: return
	goal_touched.emit((node.position.x > Globals.vp_size.x/2))
