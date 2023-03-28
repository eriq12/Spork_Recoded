extends Node

enum State {NONE, PLAYER, UI, PROMPT}
var state_module_parents : Array[StateModule]
var player_states : Array[State]

# to make getting player more readable
var player : Player:
	get:
		if int(State.PLAYER) > state_module_parents.size():
			return null
		return state_module_parents[int(State.PLAYER)]

# to help keep track of controlling player in overworld
var _controlling_player_id : int = -1

# to make getting player character much easier in code and more readable
var player_character : Entity:
	get:
		if player == null:
			return null
		return player.entity
	set(value):
		player.entity = value

func _ready():
	# initialize player_state
	for i in range(ControllerHandler.MAX_PLAYERS):
		player_states.append(State.NONE)
	for children in $States.get_children():
		state_module_parents.append(children)

# state manangement method, does checks to make sure valid
func attempt_state_transisiton(input_map : PlayerInputMap, destination_state : State) -> bool:
	print("Attempting to move state for player %d from %d to %d" % [input_map.player_id, player_states[input_map.player_id], destination_state])
	# if no input map was passed, do nothing
	if(input_map == null):
		return false
	match destination_state:
		State.PLAYER:
			# check if player character already has a controller
			# assumption: asking player does not have control already, so if asking and not empty, then reject
			if _controlling_player_id == -1:
				call_deferred("_deferred_change_input_map_state", input_map, State.PLAYER)
				return true
		_:
			call_deferred("_deferred_change_input_map_state", input_map, destination_state)
	return false

# to be called to actually change values, assumes input_map to be not null
func _deferred_change_input_map_state(input_map : PlayerInputMap, new_state:State):
	# get origin state, and do required stuff
	var origin_state : State = player_states[input_map.player_id]
	match origin_state:
		State.PLAYER:
			# remove from player
			pass
	print("Moved state for player %d to %d" % [input_map.player_id, new_state])
	# sets new state and associated module for input map to call
	player_states[input_map.player_id] = new_state
	match new_state:
		State.PLAYER:
			# for player, update controlling player id and set associated 
			_controlling_player_id = input_map.player_id
			input_map.module = player
		_:
			input_map.module = state_module_parents[new_state].get_state_module(input_map.player_id) if new_state < state_module_parents.size() else null
