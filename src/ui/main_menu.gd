extends Node2D

@export_range(0.1, 2.0, 0.05) var tw_time: float = 1.0 
@export_file("*.tscn", "*.scn") var pvp_scene: String

@onready var MASTER_BUS_ID := AudioServer.get_bus_index("Master")
@onready var SFX_BUS_ID := AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID := AudioServer.get_bus_index("Music")

@onready var menu_layer: CanvasLayer = $MainMenuLayer
@onready var game_choice_layer: CanvasLayer = $GameChoiceLayer
@onready var options_layer: CanvasLayer = $OptionsLayer

@onready var play_button: Button = %PlayButton
@onready var pvp_button: Button = %PvPButton
@onready var master_slider: HSlider = %MasterSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var music_slider: HSlider = %MusicSlider

@onready var master_percent_label: Label = %MasterPercentLabel
@onready var sfx_percent_label: Label = %SFXPercentLabel
@onready var music_percent_label: Label = %MusicPercentLabel

func _ready() -> void:
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SFX_BUS_ID))
	sfx_percent_label.text = str(sfx_slider.value * 100) + "%"
	_fade_in(menu_layer, Vector2(0, 540), play_button)

func _fade_in(layer: CanvasLayer, from: Vector2, button_to_focus: Control) -> void:
	layer.process_mode = Node.PROCESS_MODE_INHERIT
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(layer, "offset", Vector2(0, 0), tw_time)\
		.from(from).set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_ELASTIC)
	fade_tween.tween_callback(button_to_focus.grab_focus)
	fade_tween.tween_callback(fade_tween.kill)
	await fade_tween.finished

func _fade_out(layer: CanvasLayer, to: Vector2) -> void:
	layer.process_mode = Node.PROCESS_MODE_DISABLED
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(layer, "offset", to, tw_time)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	fade_tween.tween_callback(fade_tween.kill)
	await fade_tween.finished

# Main Menu Buttons
func _on_play_button_pressed() -> void:
	await _fade_out(menu_layer, Vector2(0, 540))
	_fade_in(game_choice_layer, Vector2(960, 0), pvp_button)

func _on_options_button_pressed() -> void:
	await _fade_out(menu_layer, Vector2(0, 540))
	_fade_in(options_layer, Vector2(-960, 0), sfx_slider)

func _on_quit_button_pressed() -> void:
	await _fade_out(menu_layer, Vector2(0, 540))
	get_tree().quit()

# Game Choice Buttons
func _on_pvp_button_pressed() -> void:
	await _fade_out(game_choice_layer, Vector2(960, 0))
	Loader.goto_scene(pvp_scene)

func _on_pvai_button_pressed() -> void:
	pass # Replace with function body.

func _on_back_button_pressed() -> void:
	await _fade_out(game_choice_layer, Vector2(960, 0))
	_fade_in(menu_layer, Vector2(0, 540), play_button)

# Options Buttons
func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS_ID, linear_to_db(value))
	if (value <= .039):
		AudioServer.set_bus_mute(MASTER_BUS_ID, true)
		master_slider.value = 0
		value = 0
	master_percent_label.text = str(value * 100) + "%"

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	if (value <= .039):
		AudioServer.set_bus_mute(SFX_BUS_ID, true)
		sfx_slider.value = 0
		value = 0
	sfx_percent_label.text = str(value * 100) + "%"

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	if (value <= .039):
		AudioServer.set_bus_mute(MUSIC_BUS_ID, true)
		music_slider.value = 0
		value = 0
	music_percent_label.text = str(value * 100) + "%"

func _on_options_back_button_pressed() -> void:
	await _fade_out(options_layer, Vector2(-960, 0))
	_fade_in(menu_layer, Vector2(0, 540), play_button)
