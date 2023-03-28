extends Node2D

class_name Level

@export var _level_tilemap : TileMap

@export_group("Interactables")
enum LAYERS {GROUND, WALL, INTERACTABLES}
@export var _interactable_group : Node

@export_group("Default Spawn")
enum DIRECTION {NONE=-1, DOWN, LEFT, RIGHT, UP}
const DIRECTION_VECTOR = [Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]


func _ready():
	# if there exists an interactable 
	if _interactable_group != null:
		# do something with interactables
		pass

# get local position for grid position
func grid_to_local_position(grid_position : Vector2i) -> Vector2:
	return _level_tilemap.map_to_local(grid_position)

# set position of object to related position in grid
func set_to_grid_position(object : Entity, grid_position : Vector2i):
	var grid_to_local := grid_to_local_position(grid_position)
	if object.get_parent() == self:
		object.set_position(grid_to_local)
	else:
		object.set_global_transform(Transform2D(0, to_global(grid_to_local)))
	# update Entity position
	object.location = grid_position

#region helper methods to make checking layers readable

func has_no_wall(grid_position : Vector2i) -> bool:
	return _level_tilemap.get_cell_tile_data(LAYERS.WALL, grid_position) == null

func has_ground(grid_position : Vector2i) -> bool:
	return not (_level_tilemap.get_cell_tile_data(LAYERS.GROUND, grid_position) == null)

func has_no_interactable(grid_position : Vector2i) -> bool:
	return _level_tilemap.get_cell_tile_data(LAYERS.INTERACTABLES, grid_position) == null

#endregion

# check if position is a valid position
func is_grid_position_open(grid_position : Vector2i) -> bool:
	return has_no_wall(grid_position) and has_ground(grid_position) and has_no_interactable(grid_position)
