extends CanvasLayer

@export_file("*.tscn","*.scn") var main_menu_scene: String
@onready var MUSIC_BUS_ID := AudioServer.get_bus_index("Music")

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton
@onready var contents_layer: CanvasLayer = $ContentsLayer
@onready var sfxsp_2d: AudioStreamPlayer2D = %SFXSP2D

func _ready() -> void:
	resume_button.pressed.connect(unpause)
	quit_button.pressed.connect(_quit)

func unpause() -> void:
	sfxsp_2d.position = resume_button.get_global_rect().position
	sfxsp_2d.play()
	var effect := AudioServer.get_bus_effect(MUSIC_BUS_ID, 1)
	if effect is AudioEffectLowPassFilter:
		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(effect, "cutoff_hz", 20500, 1.0)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
		fade_tween.tween_callback(fade_tween.kill)
	
	contents_layer.process_mode = Node.PROCESS_MODE_DISABLED
	anim_player.play("UnPause")
	await anim_player.animation_finished
	if resume_button.has_focus(): resume_button.release_focus()
	get_tree().paused = false

func pause() -> void:
	sfxsp_2d.position = resume_button.get_global_rect().position
	sfxsp_2d.play()
	var effect := AudioServer.get_bus_effect(MUSIC_BUS_ID, 1)
	if effect is AudioEffectLowPassFilter:
		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(effect, "cutoff_hz", 680, 1.0)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		fade_tween.tween_callback(fade_tween.kill)
	
	contents_layer.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().paused = true
	anim_player.play("Pause")
	resume_button.grab_focus()

func _quit() -> void:
	sfxsp_2d.position = quit_button.get_global_rect().position
	sfxsp_2d.play()
	anim_player.play("UnPause")
	await anim_player.animation_finished
	Loader.goto_scene(main_menu_scene)
