extends CanvasLayer

signal player_won(player2: bool)

@export_file("*.tscn","*.scn") var main_menu_scene: String

@onready var color_rect: ColorRect = %ColorRect
@onready var content_layer: CanvasLayer = %ContentLayer
@onready var restart_button: Button = %RestartButton
@onready var title_label: Label = %TitleLabel

func _ready() -> void:
	player_won.connect(on_game_ended)

func on_game_ended(p2: bool) -> void:
	var player = "1"
	if p2:
		player = "2"
	title_label.text = "Player "+player+" Wins!!"
	pop_up_screen()

func startup_screen() -> void:
	content_layer.offset = Vector2(0, -540)
	var _tween: Tween = create_tween().set_parallel()\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(color_rect.material, "shader_parameter/blur", .0, 1.0)
	_tween.tween_property(color_rect.material, "shader_parameter/brightness", 1.0, 1.0)
	await _tween.finished
	visible = false

func pop_up_screen() -> void:
	visible = true
	var _tween: Tween = create_tween()\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	_tween.parallel().tween_property(color_rect.material, "shader_parameter/blur", 3.0, 1.0)
	_tween.parallel().tween_property(color_rect.material, "shader_parameter/brightness", .4, 1.0)
	_tween.parallel().tween_interval(.4)
	_tween.tween_property(content_layer, "offset", Vector2.ZERO, .9)
	_tween.tween_callback(restart_button.grab_focus)
	await _tween.finished

func pop_off_screen() -> void:
	var _tween: Tween = create_tween().set_parallel()\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(color_rect.material, "shader_parameter/blur", 4.0, 1.0)
	_tween.tween_property(color_rect.material, "shader_parameter/brightness", .0, 1.0)
	_tween.chain().tween_property(content_layer, "offset", Vector2(0, -540), .9)
	await _tween.finished

func _on_restart_button_pressed() -> void:
	await pop_off_screen()
	get_tree().paused = false
	#get_tree().reload_current_scene()
	Loader.reload_scene()

func _on_quit_button_pressed() -> void:
	await pop_off_screen()
	Loader.goto_scene(main_menu_scene)
