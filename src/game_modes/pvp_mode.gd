extends GameManager

@onready var pause_menu_l: CanvasLayer = $PauseMenuLayer
@onready var win_screen_layer: CanvasLayer = $WinScreenLayer

func _ready() -> void:
	super()
	await win_screen_layer.startup_screen()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and pausable:
		pause_menu_l.pause()

func _on_goal_reached(right: bool) -> void:
	super(right)
	pausable = false
	win_screen_layer.on_game_ended(right)
	#win_screen_layer.player_won.emit(right)
