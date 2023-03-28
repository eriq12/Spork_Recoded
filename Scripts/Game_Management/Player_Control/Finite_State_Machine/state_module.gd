extends Node

class_name StateModule

const State = preload("res://Scripts/Game_Management/game_master.gd").State

var module_type : State:
    get = get_state_type

# to be called upon each frame by game master for each input_map
func process(_input_map : PlayerInputMap):
    pass

# to get the state module
func get_state_module(_player_id : int) -> StateModule:
    return self

# to get state type
func get_state_type() -> State:
    return State.NONE