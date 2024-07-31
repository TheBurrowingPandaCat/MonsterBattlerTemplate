extends Sprite2D

@export var movement_speed: float = 1.0
@export var display_scale: int = 4
@export var tile_size: int = 16
@export var barrier_layer_index: int = 1
@export var event_layer_index: int = 2

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
@onready var second_grass_tile_map = $"../SecondGrassTileMap"
var current_tile_map

# Called when the node enters the scene tree for the first time.
func _ready():
	real_tile_distance = display_scale * tile_size
	current_tile = Vector2i(floor(position.x / real_tile_distance), floor(position.y / real_tile_distance))
	is_moving = false
	movement_parameter = 0.0
	base_frame = 0
	current_frame_offset = 0
	frame_has_advanced = false
	current_tile_map = first_grass_tile_map


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
			if is_tile_event(current_tile):
				swap_tile_maps()
	
	if !is_moving:
		if Input.is_action_pressed("up"):
			base_frame = 12
			move_to_new_tile(current_tile + Vector2i.UP, Vector2.UP)
		elif Input.is_action_pressed("down"):
			base_frame = 0
			move_to_new_tile(current_tile + Vector2i.DOWN, Vector2.DOWN)
		elif Input.is_action_pressed("left"):
			base_frame = 4
			move_to_new_tile(current_tile + Vector2i.LEFT, Vector2.LEFT)
		elif Input.is_action_pressed("right"):
			base_frame = 8
			move_to_new_tile(current_tile + Vector2i.RIGHT, Vector2.RIGHT)
		else:
			movement_parameter = 0.0


func move_to_new_tile(new_tile: Vector2i, direction: Vector2) -> void:
	if is_tile_traversable(new_tile):
		is_moving = true
		origin_position = position
		target_position = position + direction * real_tile_distance
		movement_parameter = maxf(movement_parameter - 1.0, 0.0)
		advance_frame_offset()
		frame_has_advanced = false
	else:
		frame = base_frame + current_frame_offset


func advance_frame_offset() -> void:
	current_frame_offset += 1
	if current_frame_offset >= 4:
		current_frame_offset -= 4
	frame = base_frame + current_frame_offset


func is_tile_traversable(tile_coords: Vector2i) -> bool:
	return not current_tile_map.get_cell_tile_data(barrier_layer_index, tile_coords) is TileData


func is_tile_event(tile_coords: Vector2i) -> bool:
	return current_tile_map.get_cell_tile_data(event_layer_index, tile_coords) is TileData

func swap_tile_maps() -> void:
	if current_tile_map == first_grass_tile_map:
		current_tile_map = second_grass_tile_map
	else:
		current_tile_map = first_grass_tile_map
	
	first_grass_tile_map.visible = not first_grass_tile_map.visible
	second_grass_tile_map.visible = not second_grass_tile_map.visible
