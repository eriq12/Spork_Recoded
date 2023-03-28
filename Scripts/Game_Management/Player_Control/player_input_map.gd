extends Node

### a player input map replacement for the built in input map
class_name PlayerInputMap

var player_id : int = -1

#region config and action variables and constants

@export_group("Buttons")
enum ButtonAction {NONE=-1, ACCEPT, REJECT, SECONDARY_ONE, SECONDARY_TWO, START, SELECT, L_SHOULDER, R_SHOULDER, DPAD_DOWN, DPAD_LEFT, DPAD_RIGHT, DPAD_UP}
@export var accept_button : JoyButton = JOY_BUTTON_A
@export var reject_button : JoyButton = JOY_BUTTON_B
@export var secondary_one_button : JoyButton = JOY_BUTTON_X
@export var secondary_two_button : JoyButton = JOY_BUTTON_Y
@export var start_button : JoyButton = JOY_BUTTON_START
@export var select_button : JoyButton = JOY_BUTTON_BACK
@export var left_shoulder_button : JoyButton = JOY_BUTTON_LEFT_SHOULDER
@export var right_shoudler_button : JoyButton = JOY_BUTTON_RIGHT_SHOULDER
@export var dpad_up_button : JoyButton = JOY_BUTTON_DPAD_UP
@export var dpad_down_button : JoyButton = JOY_BUTTON_DPAD_DOWN
@export var dpad_left_button : JoyButton = JOY_BUTTON_DPAD_LEFT
@export var dpad_right_button : JoyButton = JOY_BUTTON_DPAD_RIGHT
var button_mappings : Dictionary 
var action_pressed : Dictionary

@export_group("JoySticks")
@export_range(0, 1, 0.02) var threshold : float = 0.8
var joy_l : Vector2 = Vector2.ZERO
var joy_r : Vector2 = Vector2.ZERO

#endregion

#finite state machine module object
var module : StateModule

func _init():
	var buttons_config = [accept_button, reject_button, secondary_one_button, secondary_two_button, start_button, select_button, left_shoulder_button, right_shoudler_button, dpad_up_button, dpad_down_button, dpad_left_button, dpad_right_button]
	var actions_config : Array[ButtonAction] = [ButtonAction.ACCEPT, ButtonAction.REJECT, ButtonAction.SECONDARY_ONE, ButtonAction.SECONDARY_TWO, ButtonAction.START, ButtonAction.SELECT, ButtonAction.L_SHOULDER, ButtonAction.R_SHOULDER, ButtonAction.DPAD_UP, ButtonAction.DPAD_DOWN, ButtonAction.DPAD_LEFT, ButtonAction.DPAD_RIGHT]
	for i in range(min(buttons_config.size(), actions_config.size())):
		add_mapping(buttons_config[i], actions_config[i])

#region processing input
func _ready():
	pass
func _process(_delta):
	if module != null:
		module.process(self)
#endregion

#region mapping related

# adds a mapping for an action, allows overlaping
func add_mapping(button : JoyButton, action : ButtonAction):
	if button_mappings.has(button):
		button_mappings[button].append(action)
	else:
		button_mappings[button] = [action]

# to set a button pressed, and in turn the associated actions
func set_button_pressed(button : JoyButton, pressed : bool):
	if button_mappings.has(button):
		for action in button_mappings[button]:
			action_pressed[action] = pressed

# sets a joy motion
func set_joy_motion(axis : JoyAxis, value : float):
	if abs(value) < threshold:
		value = 0
	# hard coded joy axis numbers for convenience at the moment
	match axis:
		JoyAxis.JOY_AXIS_LEFT_X:
			joy_l.x = value
		JoyAxis.JOY_AXIS_LEFT_Y:
			joy_l.y = value
		JoyAxis.JOY_AXIS_RIGHT_X:
			joy_r.x = value
		JoyAxis.JOY_AXIS_RIGHT_Y:
			joy_r.y = value

# checks if an action was pressed
func is_button_action_pressed(action : ButtonAction) -> bool:
	if action_pressed.has(action):
		return action_pressed[action]
	return false

# checks if a direction is pressed
func get_direction(right_joy:bool=false, dpad:bool=true) -> Level.DIRECTION:
	# priority of directions: up, down, left, then right
	var joy : Vector2 = joy_r if right_joy else joy_l
	# first check joy directions
	if joy.y != 0:
		return Level.DIRECTION.UP if joy.y < 0 else Level.DIRECTION.DOWN 
	elif joy.x != 0:
		return Level.DIRECTION.LEFT if joy.x < 0 else Level.DIRECTION.RIGHT
	if dpad:
		if is_button_action_pressed(ButtonAction.DPAD_UP):
			return Level.DIRECTION.UP
		elif is_button_action_pressed(ButtonAction.DPAD_DOWN):
			return Level.DIRECTION.DOWN
		elif is_button_action_pressed(ButtonAction.DPAD_LEFT):
			return Level.DIRECTION.LEFT
		elif is_button_action_pressed(ButtonAction.DPAD_RIGHT):
			return Level.DIRECTION.RIGHT
	# then check dpad directions
	return Level.DIRECTION.NONE

# to be called when input_map is deallocated
func mark_for_clear():
	GameMaster.attempt_state_transisiton(self, GameMaster.State.NONE)

#endregion