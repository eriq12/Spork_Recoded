extends StateModule

const ButtonAction = PlayerInputMap.ButtonAction

# to be called upon each frame by game master for each input_map
func process(input_map : PlayerInputMap):
    if LevelManager.is_in_main_menu():
        return
    if input_map.is_button_action_pressed(ButtonAction.ACCEPT):
        GameMaster.attempt_state_transisiton(input_map, GameMaster.State.PLAYER)

# to get state type
func get_state_type() -> State:
    return State.NONE