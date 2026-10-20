extends Node

@onready var vp : Viewport = get_viewport()
@onready var vp_size : = vp.get_visible_rect().size

enum Difficulty { EASY, NORMAL, HARD }
var ai_difficulty: Difficulty = Difficulty.NORMAL

#func _ready():
#	self.pause_mode = Node.PAUSE_MODE_PROCESS
