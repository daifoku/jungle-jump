extends Node2D # Base class, defining inheritance

# Class properties (variables)
var _items: TileMapLayer = null
var _world: TileMapLayer = null

var _player: Node2D = null
var _spawn_point: Marker2D = null
var _camera_2d: Camera2D = null

# Lazy initialization with error handling for the World layer
func get_world() -> TileMapLayer:
	# Retrieves the World node; initializes and caches it on first access
	if _world == null:
		if $TML_World:
			_world = $TML_World
		else:
			push_error("Node 'TML_World' not found!")
	return _world

# Lazy initialization with error handling for the Items layer
func get_items() -> TileMapLayer:
	# Retrieves the TML_Items node; initializes and caches it on first access
	if _items == null:
		if $TML_Items:
			_items = $TML_Items
		else:
			push_error("Node 'TML_Items' not found!")
	return _items

# Lazy initialization with error handling for the Player node
func get_player() -> Node2D:
	# Retrieves the Player node; initializes and caches it on first access
	if _player == null:
		if $Player:
			_player = $Player
		else:
			push_error("Node 'Player' not found!")
	return _player

# Lazy initialization with error handling for the SpawnPoint marker
func get_spawn_point() -> Marker2D:
	# Retrieves the SpawnPoint node; initializes and caches it on first access
	if _spawn_point == null:
		if $SpawnPoint:
			_spawn_point = $SpawnPoint
		else:
			push_error("Node 'SpawnPoint' not found!")
	return _spawn_point

# Lazy initialization with error handling for the Camera2D node
func get_camera_2d() -> Camera2D:
	# Retrieves the Camera2D node; initializes and caches it on first access
	if _camera_2d == null:
		var player = get_player()
		if player.has_node("Camera2D"):
			_camera_2d = player.get_node("Camera2D") as Camera2D
		else:
			push_error("Node 'Camera2D' not found as a child of 'Player'!")
	return _camera_2d

# Called when the node and its children are fully initialized
func _ready() -> void:
	get_items().hide()
	get_player().reset(get_spawn_point().position)
	set_camera_limits()
	spawn_items()

# Function to set camera limits
func set_camera_limits() -> void:
	# Sets the camera limits based on the world tilemap's size and tile size
	var map_size: Rect2 = get_world().get_used_rect()
	var cell_size: Vector2 = get_world().tile_set.tile_size

	# Set camera limits based on the tilemap dimensions
	get_camera_2d().limit_left = int((map_size.position.x - 5) * cell_size.x)
	get_camera_2d().limit_right = int((map_size.end.x + 5) * cell_size.x)

# Signal definition
signal score_changed

# Scene resource
var item_scene: PackedScene = load("res://items/item.tscn")

# Score with setter
var score: int: set = set_score

# Spawns items based on the TileMapLayer's used cells
func spawn_items() -> void:
	# Use the lazy-initialized getter for Items
	var item_cells: Array[Vector2i] = get_items().get_used_cells()

	for cell in item_cells:
		var data: TileData = get_items().get_cell_tile_data(cell)
		var type: String = data.get_custom_data("type") # Assuming "type" is stored as String
		var item: Node = item_scene.instantiate()
		add_child(item)
		item.init(type, get_items().map_to_local(cell))
		item.picked_up.connect(self._on_item_picked_up)

# Handles item pickup and increments score
func _on_item_picked_up() -> void:
	score += 1

# Sets the score and emits the signal
func set_score(value: int) -> void:
	score = value
	score_changed.emit(score)


func _on_player_died() -> void:
	GameState.restart()
