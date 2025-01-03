extends CanvasLayer

@export_file("*.tscn","*.scn") var main_menu_scene: String

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton
@onready var contents_layer: CanvasLayer = $ContentsLayer

func _ready() -> void:
	resume_button.pressed.connect(unpause)
	quit_button.pressed.connect(_quit)

func unpause() -> void:
	contents_layer.process_mode = Node.PROCESS_MODE_DISABLED
	anim_player.play("UnPause")
	await anim_player.animation_finished
	if resume_button.has_focus(): resume_button.release_focus()
	get_tree().paused = false

func pause() -> void:
	contents_layer.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().paused = true
	anim_player.play("Pause")
	resume_button.grab_focus()

func _quit() -> void:
	anim_player.play("UnPause")
	await anim_player.animation_finished
	Loader.goto_scene(main_menu_scene)
