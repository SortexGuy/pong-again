extends CanvasLayer

signal score_changed(p1_score: int, p2_score: int)

@onready var p1_score_label: Label = %P1ScoreLabel
@onready var p2_score_label: Label = %P2ScoreLabel
@onready var p_1v_box_container: VBoxContainer = %P1VBoxContainer
@onready var p_2v_box_container: VBoxContainer = %P2VBoxContainer

func set_indicator_tweens(cont: VBoxContainer) -> void:
	var fade_tween: Tween = create_tween()
	var color := Color.WHITE
	color.a = 0.0
	fade_tween.tween_property(cont, "modulate", color, 7.0)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	fade_tween.tween_callback(cont.hide)
	fade_tween.tween_callback(fade_tween.kill)
	await fade_tween.finished

func _ready() -> void:
	score_changed.connect(update_score)
	set_indicator_tweens(p_1v_box_container)
	set_indicator_tweens(p_2v_box_container)

func update_score(p1_score: int, p2_score: int) -> void:
	p1_score_label.text = str(p1_score)
	p2_score_label.text = str(p2_score)
