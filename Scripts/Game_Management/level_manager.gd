extends Node

# main menu
var main_menu_scene : PackedScene = preload("res://Assets/NodeScenes/User_Interfaces/main_menu.tscn")

@export_group("Default Scene")
@export var default_scene : PackedScene
@export var default_scene_position : Vector2i

@export_group("Player Entity")
@export var player_scene : PackedScene = preload("res://Assets/NodeScenes/Entities/player.tscn")

var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	GameMaster.player_character = player_scene.instantiate()

func start_new_game():
	call_deferred("_deferred_goto_level", default_scene, default_scene_position)

# taken from singletons (Autoload) documentation
func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)

# derived from documentation to adapt to my game with maps and levels
func goto_level(level_path, position:Vector2i=Vector2i.ZERO):
	call_deferred("_deferred_goto_level", level_path, position)

# helper method to load a generic scene
func _deferred_goto_scene(new_scene):
	if GameMaster.player_character.get_parent() == current_scene:
		current_scene.remove_child(GameMaster.player_character)
	# free current scene
	current_scene.free()
	
	
	# load and instance new scene
	var s = new_scene if new_scene is PackedScene else ResourceLoader.load(new_scene)
	current_scene = s.instantiate()
	
	# add to active scene
	get_tree().root.add_child(current_scene)
	
	# make compatible with SceneTreee.change_scene_to_file() API
	get_tree().current_scene = current_scene

	# if it is any other scene than the main menu, then enable the controller handler
	if current_scene != main_menu_scene:
		ControllerHandler.set_process_unhandled_input(true)

# helper method to load level
func _deferred_goto_level(level, position:Vector2i=Vector2i.ZERO):
	_deferred_goto_scene(level)
	
	# if the new scene is a Level, say it is a level
	if current_scene is Level:
		print("This is a level")
		current_scene.add_child(GameMaster.player_character)
		move_entity_to_position(GameMaster.player_character, position)

# to be called when a entity should be moved
func move_entity_to_position(entity : Entity, position : Vector2i):
		current_scene.set_to_grid_position(entity, position)

# to get whether a position is open in the overworld
func is_position_open(position : Vector2i) -> bool:
	if not current_scene == null:
		return current_scene.is_grid_position_open(position)
	return false
