extends GameManager

#var players_reseted: int = 0
@onready var pause_menu_l: CanvasLayer = $PauseMenuLayer

func _ready() -> void:
	super()
#	var players: Array[Player] = [%PlayerL, %PlayerR] as Array[Player]
#	for p in players:
#		_goal_reached.connect(p.reset)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause_menu_l.pause()

func _on_goal_reached(right: bool) -> void:
	super(right)
	await get_tree().create_timer(5.0, false).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()
