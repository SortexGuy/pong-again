extends CanvasLayer

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton

@export_file("*.tscn,*.scn") var main_menu_scene: String

func _ready() -> void:
	resume_button.pressed.connect(unpause)
	quit_button.pressed.connect(_quit)

func unpause() -> void:
	anim_player.play("UnPause")
	await anim_player.animation_finished
	get_tree().paused = false

func pause() -> void:
	get_tree().paused = true
	anim_player.play("Pause")
	resume_button.grab_focus()

func _quit() -> void:
	anim_player.play("UnPause")
	await anim_player.animation_finished
	Loader.goto_scene(main_menu_scene)
