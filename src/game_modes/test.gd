extends GameManager

@onready var gui_layer: CanvasLayer = $GuiLayer
var players_reseted: int = 0

func _ready() -> void:
	super()
	var players: Array[Player] = [%PlayerL, %PlayerR] as Array[Player]
	for p in players:
		_goal_reached.connect(p.reset)
		p.reseted.connect(p_reset_done)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		gui_layer.pause()

func _on_goal_reached(right: bool) -> void:
	super(right)
#	get_tree().paused = true
	if right:
		print_rich("[color=red][b]Player 2 or AI wins![/b][/color]")
	else:
		print_rich("[color=red][b]Player 1 wins![/b][/color]")
	await get_tree().create_timer(5.0, true).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()

func p_reset_done() -> void:
	players_reseted += 1
	if not players_reseted >= 2: return
	get_tree().paused = true
