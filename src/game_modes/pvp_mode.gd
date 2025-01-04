extends GameManager

@onready var pause_menu_l: CanvasLayer = $PauseMenuLayer
@onready var win_screen_layer: CanvasLayer = $WinScreenLayer
@onready var win_sp_2d: AudioStreamPlayer2D = %WinSP2D

func _ready() -> void:
	super()
	win_sp_2d.position.y = Globals.vp_size.y/2
	await win_screen_layer.startup_screen()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and pausable:
		pause_menu_l.pause()

func _on_ball_scored(right: bool):
	super(right)
	win_sp_2d.position.x = Globals.vp_size.x if not right else 0
	win_sp_2d.play()

func _on_goal_reached(right: bool) -> void:
	super(right)
	pausable = false
	win_screen_layer.on_game_ended(right)
