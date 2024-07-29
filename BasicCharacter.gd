extends Sprite2D

@export var movement_speed: float = 1.0
@export var display_scale: int = 4
@export var tile_size: int = 16
@export var barrier_layer_index: int = 1

# Position Variables
var current_tile: Vector2i
var origin_position: Vector2
var target_position: Vector2

# Movement Variables
var is_moving: bool
var movement_parameter: float
var real_tile_distance: int

# Animation Variables
var base_frame: int
var current_frame_offset: int
var frame_has_advanced: bool

# Tilemap handling
@onready var first_grass_tile_map = $"../FirstGrassTileMap"

# Called when the node enters the scene tree for the first time.
func _ready():
	real_tile_distance = display_scale * tile_size
	current_tile = Vector2i(floor(position.x / real_tile_distance), floor(position.y / real_tile_distance))
	is_moving = false
	movement_parameter = 0.0
	base_frame = 0
	current_frame_offset = 0
	frame_has_advanced = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handle movement
	if is_moving:
		movement_parameter = movement_parameter + delta * movement_speed
		# Multiply and divide with scale keeps it pixel perfect
		position = floor(origin_position.lerp(target_position, \
			min(movement_parameter, 1.0)) / display_scale) * display_scale
		#position = origin_position.lerp(target_position, min(movement_parameter, 1.0))
		
		if !frame_has_advanced && movement_parameter >= 0.5:
			advance_frame_offset()
			frame_has_advanced = true
		
		if movement_parameter >= 1.0:
			is_moving = false
			current_tile = Vector2i(floor(position.x / real_tile_distance), floor(position.y / real_tile_distance))
	
	if !is_moving:
		if Input.is_action_pressed("up"):
			base_frame = 12
			if is_tile_traversable(current_tile + Vector2i.UP):
				is_moving = true
				origin_position = position
				target_position = position + Vector2.UP * real_tile_distance
				movement_parameter = maxf(movement_parameter - 1.0, 0.0)
				advance_frame_offset()
				frame_has_advanced = false
			else:
				frame = base_frame + current_frame_offset
		elif Input.is_action_pressed("down"):
			base_frame = 0
			if is_tile_traversable(current_tile + Vector2i.DOWN):
				is_moving = true
				origin_position = position
				target_position = position + Vector2.DOWN * real_tile_distance
				movement_parameter = maxf(movement_parameter - 1.0, 0.0)
				advance_frame_offset()
				frame_has_advanced = false
			else:
				frame = base_frame + current_frame_offset
		elif Input.is_action_pressed("left"):
			base_frame = 4
			if is_tile_traversable(current_tile + Vector2i.LEFT):
				is_moving = true
				origin_position = position
				target_position = position + Vector2.LEFT * real_tile_distance
				movement_parameter = maxf(movement_parameter - 1.0, 0.0)
				advance_frame_offset()
				frame_has_advanced = false
			else:
				frame = base_frame + current_frame_offset
		elif Input.is_action_pressed("right"):
			base_frame = 8
			if is_tile_traversable(current_tile + Vector2i.RIGHT):
				is_moving = true
				origin_position = position
				target_position = position + Vector2.RIGHT * real_tile_distance
				movement_parameter = maxf(movement_parameter - 1.0, 0.0)
				advance_frame_offset()
				frame_has_advanced = false
			else:
				frame = base_frame + current_frame_offset
		else:
			movement_parameter = 0.0


func advance_frame_offset() -> void:
	current_frame_offset += 1
	if current_frame_offset >= 4:
		current_frame_offset -= 4
	frame = base_frame + current_frame_offset


func is_tile_traversable(tile_coords: Vector2i) -> bool:
	return not first_grass_tile_map.get_cell_tile_data(barrier_layer_index, tile_coords) is TileData
