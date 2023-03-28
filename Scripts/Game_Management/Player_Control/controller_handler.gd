extends Node

signal player_device_update(player_id)
signal player_device_removed(player_id)

const MAX_PLAYERS : int = 4
var player_input_maps : Array[PlayerInputMap]
var device_id_to_player : Dictionary

func _ready():
	# initalize player_input_maps
	player_input_maps.resize(MAX_PLAYERS)
	player_input_maps.fill(null)
	set_process_unhandled_input(false)

func _unhandled_input(event):
	if event is InputEventJoypadButton:
		if device_id_to_player.has(event.device) or _add_player_device(event.device):
			var player_id = device_id_to_player[event.device]
			#print("EVENT: Player %d has %s button id %d." % [player_id+1, "pressed" if event.pressed else "released", event.button_index])
			player_input_maps[player_id].set_button_pressed(event.button_index, event.pressed)
		get_viewport().set_input_as_handled()
	elif  event is InputEventJoypadMotion:
		if device_id_to_player.has(event.device):
			player_input_maps[device_id_to_player[event.device]].set_joy_motion(event.axis, event.axis_value)
		get_viewport().set_input_as_handled()


func _add_player_device(device_id : int) -> bool:
	for i in range(player_input_maps.size()):
		if player_input_maps[i] == null:
			_set_input_map(i, device_id)
			return true
	return false

func get_player_input_map(player_id : int) -> PlayerInputMap:
	if player_id >= 0 and player_id < MAX_PLAYERS:
		return player_input_maps[player_id]
	return null

# assumes that player_id and device_id have been taken
func _set_input_map(player_id : int, device_id : int):
	# set the device id to be associated with player
	device_id_to_player[device_id] = player_id
	# instance a new player input map and set to player_id position
	var new_player_input : PlayerInputMap = PlayerInputMap.new()
	new_player_input.player_id = player_id
	player_input_maps[player_id] = new_player_input
	add_child(new_player_input)
	GameMaster.attempt_state_transisiton(new_player_input, GameMaster.State.NONE)
	print("New device added : %s" % Input.get_joy_name(device_id))
	emit_signal("player_device_update", player_id)

func _remove_player(player_id : int):
	# remove from device_id_to_player
	device_id_to_player.erase(device_id_to_player.find_key(player_id))
	# then remove the instance from the input_maps
	var removing_input_map = player_input_maps[player_id]
	player_input_maps[player_id] = null
	remove_child(removing_input_map)
	removing_input_map.mark_for_clear()
	removing_input_map.queue_free()
	emit_signal("player_device_removed", player_id)

func run_all_input_maps(function : Callable):
	for i in range(player_input_maps.size()):
		var input_map = player_input_maps[i]
		if not input_map == null:
			function.call(i, input_map)
