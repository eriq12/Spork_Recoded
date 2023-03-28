extends StateModule

class_name Player

var _input_direction : Level.DIRECTION = Level.DIRECTION.NONE

var entity : Entity:
	get:
		return entity
	set(value):
		# disconnect if need be
		if entity != null and entity.walk_midpoint.is_connected(accept_input):
			entity.walk_midpoint.disconnect(accept_input)
		# set new entity to such and connect signal to callable accept_input
		entity = value
		entity.walk_midpoint.connect(accept_input)


# input map variables
var _ready_to_process_input : bool = true
var _ready_to_accept_input : bool = true


# helper method to allow accepting input to be later processed
var accept_input : Callable = func():
	_ready_to_accept_input = true

# Called every frame.
func process(input_map):
	# set input processing
	if input_map != null:
		# setting outside to give player more agency over speed (resulting in a more responsive feeling)
		entity.set("running", input_map.is_button_action_pressed(PlayerInputMap.ButtonAction.REJECT))
		# allows input buffering (input a move before the previous action has finished)
		if _ready_to_accept_input:
			var new_direction : Level.DIRECTION = input_map.get_direction()
			if new_direction != Level.DIRECTION.NONE:
				_input_direction = new_direction 
		# if ready to do movement and have movement, do
		if _ready_to_process_input and _input_direction != Level.DIRECTION.NONE:
			consume_input()
	pass

# consumes input and resets input direction
func consume_input():
	_ready_to_process_input = false
	_ready_to_accept_input = false
	# set direction and consume
	entity.direction = _input_direction
	_input_direction = Level.DIRECTION.NONE
	# check if you can move to the spot ahead
	if LevelManager.is_position_open(entity.get_foward_position()):
		# if can move, then move
		entity.start_walk_anim(entity.direction)
		await entity.get_anim_signal_finish()
	# allow processing input again
	_ready_to_process_input = true
	# in case, make sure it's put on
	if not _ready_to_accept_input:
		accept_input.call()


# to get state type
func get_state_type() -> State:
	return State.PLAYER