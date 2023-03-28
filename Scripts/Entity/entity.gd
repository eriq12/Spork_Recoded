extends Node2D

class_name Entity

# to hold location of the entity for reference
var location : Vector2i:
	get:
		return location
	set(value):
		location = value
### region appearance
# visual appearance of sprite
@export var sprite : Sprite2D 
const SPRITE_PIXEL_DIM = 16
# coord for sprite
var frame_coord : Vector2i = Vector2i(0,0)
# to hold entity facing direction
var direction : Level.DIRECTION:
	get = get_direction, set = set_direction
# to hold entity walking progress
var walk_progress : int:
	get:
		return walk_progress
	set(value):
		# mod should be sufficient as it should never go backwards
		walk_progress = value % 4
		frame_coord.x = walk_progress
		# update sprite frame
		sprite.set_frame_coords(frame_coord)
# to allow things to hook midway into animation of entity (ie accepting input midway)
signal walk_midpoint

# animation stuff
const animation_names = ["walk_down", "walk_left", "walk_right", "walk_up"]
var running : bool = false:
	get:
		return running
	set(value):
		running = value
		if _walk_tween != null:
			_walk_tween.set_speed_scale(2 if running else 1)
# to make sure that multiple calls to walk will not result in a stuttery appearance for the entity
var _anim_in_progress : bool:
	get:
		return _walk_tween != null and _walk_tween.is_running()
var _walk_tween : Tween
# requests the level manager to move in direction entity is facing
var request_walk : Callable = func():
	LevelManager.move_entity_to_position(self, get_foward_position())
# moves the entity's sprite along it's walk animation visually
var progress_walk : Callable = func():
	walk_progress+=1
# to be called on midpoint of walk
var on_midpoint_walk : Callable = func():
	walk_midpoint.emit()
# to be called on finish to clean up the tween
var cleanup_tween : Callable = func():
	_walk_tween = null

func _start_walk_tween():
	# set parallel for ease of adding tween stuff
	_walk_tween = create_tween().set_parallel(true)
	# set running speed on creation
	if running:
		_walk_tween.set_speed_scale(2)
	# sets intial frame
	_walk_tween.tween_callback(request_walk)
	_walk_tween.tween_callback(progress_walk)
	_walk_tween.tween_callback(set_sprite_displacement)
	# sets end sprite position
	_walk_tween.chain().tween_property(sprite, "position", Vector2.ZERO, 0.5)
	# sets the changepoint in sprite appearance and calls midpoint
	_walk_tween.tween_callback(progress_walk).set_delay(0.25)
	_walk_tween.tween_callback(on_midpoint_walk).set_delay(0.25)
	# put method on complete to clean up tween for new creation
	_walk_tween.finished.connect(cleanup_tween)

# gets the direction of the sprite
func get_direction() -> Level.DIRECTION:
	return direction

# sets the direction that the entity will be facing (updates sprite accordingly)
func set_direction(new_direction : Level.DIRECTION):
	if new_direction == Level.DIRECTION.NONE:
		new_direction = Level.DIRECTION.DOWN
	frame_coord.y = new_direction
	direction = new_direction
	# update sprite frame
	sprite.set_frame_coords(frame_coord)


# to be called to start walk anim
func start_walk_anim(_direction_walk: Level.DIRECTION):
	if not _anim_in_progress:
		_start_walk_tween()

# to get the signal when any animation by the entity finishes
func get_anim_signal_finish() -> Signal:
	return _walk_tween.finished

# sets the sprite to the appropriate location at the start of the tween
func set_sprite_displacement():
	sprite.set_position(-16 * Level.DIRECTION_VECTOR[direction])

# to get the tile in front of entity
func get_foward_position() -> Vector2i:
	return location + Level.DIRECTION_VECTOR[direction]
