extends Node2D

@export_range(0.1, 2.0, 0.05)
var tw_time: float = 1.0 
@export_file("*.tscn,*.scn") var test_scene: String

@onready var menu_layer: CanvasLayer = $MainMenuLayer
@onready var play_button: Button = $%PlayButton
@onready var options_button: Button = $%OptionsButton
@onready var quit_button: Button = $%QuitButton

func _ready() -> void:
	play_button.grab_focus()
	_fade_in()

func _fade_in() -> void:
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(menu_layer, "offset", Vector2(0, 0), tw_time)\
		.from(Vector2(0, 540)).set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_ELASTIC)
	fade_tween.tween_callback(fade_tween.kill)
	print(fade_tween)
	await fade_tween.finished
	print(fade_tween)

func _fade_out(f_call: Callable) -> void:
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(menu_layer, "offset", Vector2(0, 540), tw_time)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	fade_tween.tween_callback(f_call)
	fade_tween.tween_callback(fade_tween.kill)

func _on_play_button_pressed() -> void:
	_fade_out(Loader.goto_scene.bind(test_scene))

func _on_quit_button_pressed() -> void:
	_fade_out(get_tree().quit)
