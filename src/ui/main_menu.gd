extends Node2D

@export_range(0.1, 2.0, 0.05) var tw_time: float = 0.85
@export_file("*.tscn", "*.scn") var pvp_scene: String
@onready var sfxsp_2d: AudioStreamPlayer2D = %SFXSP2D
@onready var slider_sfxsp_2d: AudioStreamPlayer2D = %SliderSFXSP2D
@onready var version_label: Label = %VersionLabel

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
	version_label.text = "v" + ProjectSettings.get_setting("application/config/version")
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SFX_BUS_ID))
	sfx_percent_label.text = str(sfx_slider.value * 100) + "%"
	var effect := AudioServer.get_bus_effect(MUSIC_BUS_ID, 1)
	if effect is AudioEffectLowPassFilter:
		effect.cutoff_hz = 20500
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
	sfxsp_2d.position = play_button.get_global_rect().position
	sfxsp_2d.play()
	await _fade_out(menu_layer, Vector2(0, 540))
	_fade_in(game_choice_layer, Vector2(960, 0), pvp_button)

func _on_options_button_pressed() -> void:
	sfxsp_2d.position = %OptionsButton.get_global_rect().position
	sfxsp_2d.play()
	await _fade_out(menu_layer, Vector2(0, 540))
	_fade_in(options_layer, Vector2(-960, 0), sfx_slider)

func _on_quit_button_pressed() -> void:
	sfxsp_2d.position = %QuitButton.get_global_rect().position
	sfxsp_2d.play()
	await _fade_out(menu_layer, Vector2(0, 540))
	get_tree().quit()

# Game Choice Buttons
func _on_pvp_button_pressed() -> void:
	sfxsp_2d.position = pvp_button.get_global_rect().position
	sfxsp_2d.play()
	await _fade_out(game_choice_layer, Vector2(960, 0))
	Loader.goto_scene(pvp_scene)

func _on_pvai_button_pressed() -> void:
	sfxsp_2d.position = %PvAIButton.get_global_rect().position
	sfxsp_2d.play()
	pass # Replace with function body.

func _on_back_button_pressed() -> void:
	sfxsp_2d.position = %BackButton.get_global_rect().position
	sfxsp_2d.play()
	await _fade_out(game_choice_layer, Vector2(960, 0))
	_fade_in(menu_layer, Vector2(0, 540), play_button)

# Options Buttons
func modify_bus_volume(value: float, bus_id: int, slider: Slider, label: Label) -> void:
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(value))
	if (value <= .039):
		AudioServer.set_bus_mute(bus_id, true)
		slider.value = 0
		value = 0
	label.text = str(value * 100) + "%"

func _on_master_slider_value_changed(value: float) -> void:
	modify_bus_volume(value, MASTER_BUS_ID, master_slider, master_percent_label)

func _on_sfx_slider_value_changed(value: float) -> void:
	slider_sfxsp_2d.position = sfx_slider.get_global_rect().position
	slider_sfxsp_2d.play()
	modify_bus_volume(value, SFX_BUS_ID, sfx_slider, sfx_percent_label)

func _on_music_slider_value_changed(value: float) -> void:
	modify_bus_volume(value, MUSIC_BUS_ID, music_slider, music_percent_label)

func _on_options_back_button_pressed() -> void:
	sfxsp_2d.position = %OptionsBackButton.get_global_rect().position
	sfxsp_2d.play()
	await _fade_out(options_layer, Vector2(-960, 0))
	_fade_in(menu_layer, Vector2(0, 540), play_button)
