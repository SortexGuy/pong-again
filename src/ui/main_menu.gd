extends Node2D

@export_range(0.1, 2.0, 0.05)
var tw_time: float = 1.0 
@export_file("*.tscn,*.scn") var pvp_scene: String

@onready var menu_layer: CanvasLayer = $MainMenuLayer
@onready var game_choice_layer: CanvasLayer = $GameChoiceLayer

@onready var mm_button_group: ButtonGroup = preload("res://src/ui/main_menu_button_group.res")
@onready var play_button: Button = $%PlayButton
@onready var options_button: Button = $%OptionsButton
@onready var quit_button: Button = $%QuitButton
@onready var pvp_button: Button = %PvPButton
@onready var pvai_button: Button = %PvAIButton
@onready var back_button: Button = %BackButton

func _ready() -> void:
	_fade_main_in()

func _fade_main_in() -> void:
	menu_layer.process_mode = Node.PROCESS_MODE_INHERIT
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(menu_layer, "offset", Vector2(0, 0), tw_time)\
		.from(Vector2(0, 540)).set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_ELASTIC)
	fade_tween.tween_callback(play_button.grab_focus)
	fade_tween.tween_callback(fade_tween.kill)
	await fade_tween.finished

func _fade_main_out() -> void:
	menu_layer.process_mode = Node.PROCESS_MODE_DISABLED
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(menu_layer, "offset", Vector2(0, 540), tw_time)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	fade_tween.tween_callback(fade_tween.kill)
	await fade_tween.finished

func _fade_gm_in() -> void:
	menu_layer.process_mode = Node.PROCESS_MODE_INHERIT
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(game_choice_layer, "offset", Vector2(0, 0), tw_time)\
		.from(Vector2(960, 0)).set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_ELASTIC)
	fade_tween.tween_callback(pvp_button.grab_focus)
	fade_tween.tween_callback(fade_tween.kill)
	await fade_tween.finished

func _fade_gm_out() -> void:
	menu_layer.process_mode = Node.PROCESS_MODE_DISABLED
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(game_choice_layer, "offset", Vector2(960, 0), tw_time)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	fade_tween.tween_callback(fade_tween.kill)
	await fade_tween.finished

func _fade_option_in() -> void:
	pass
func _fade_option_out() -> void:
	pass

# Main Menu Buttons
func _on_play_button_pressed() -> void:
#	play_button.release_focus()
	_fade_main_out()
	_fade_gm_in()

func _on_quit_button_pressed() -> void:
#	quit_button.release_focus()
	await _fade_main_out()
	get_tree().quit()

# Game Choice Buttons
func _on_pvp_button_pressed() -> void:
#	pvp_button.release_focus()
	await _fade_main_out()
	Loader.goto_scene(pvp_scene)

func _on_pvai_button_pressed() -> void:
	pass # Replace with function body.

func _on_back_button_pressed() -> void:
#	back_button.release_focus()
	_fade_gm_out()
	_fade_main_in()
