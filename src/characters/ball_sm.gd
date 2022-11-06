extends StateMachine

@onready var ball: = parent as Ball

func _ready():
	add_state("idle")
	add_state("move")
	add_state("stop")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	if state == states.move:
		parent.process_movement(delta)

func _get_transition(delta):
	match state:
		"idle":
			if parent.stop == false:
				if parent.moving == true:
					return states.move
			elif parent.stop == true:
				return states.stop
		"move":
			if parent.stop == false:
				if parent.moving == false:
					return states.idle
			elif parent.stop == true:
				return states.stop
		"stop":
			if parent.stop == false:
				if parent.moving == false:
					return states.idle
#				elif parent.moving == true:
#					return states.move
	return null

func _enter_state(new_state, old_state):
	pass

func _exit_state(old_state, new_state):
	pass
#	if old_state == states.move or old_state == states.stop:
#		yield(get_tree(), "idle_frame")
#		yield(get_tree().create_timer(3.0), "timeout")
#		parent._start()
