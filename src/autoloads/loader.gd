extends Node

var root: Window
var curr_scene: Node
var curr_scn_path: String
var scene_load_status = 0
@onready var loading: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if not loading: return
	scene_load_status = ResourceLoader.load_threaded_get_status(curr_scn_path)
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene: PackedScene = ResourceLoader.load_threaded_get(curr_scn_path)
		root.add_child(scene.instantiate(1))
		curr_scene.queue_free()
		get_tree().paused = false
		loading = false

func goto_scene(scene_path: String) -> void:
	if not loading:
		loading = true
	curr_scn_path = scene_path
	var _x: = ResourceLoader.load_threaded_request(curr_scn_path)
	root = get_tree().root
	curr_scene = root.get_child(root.get_child_count()-1)
