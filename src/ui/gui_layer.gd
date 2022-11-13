extends CanvasLayer

signal score_changed(p1_score: int, p2_score: int)

@onready var p1_score_label: Label = %P1ScoreLabel
@onready var p2_score_label: Label = %P2ScoreLabel

func _ready() -> void:
	score_changed.connect(update_score)

func update_score(p1_score: int, p2_score: int) -> void:
	p1_score_label.text = str(p1_score)
	p2_score_label.text = str(p2_score)
