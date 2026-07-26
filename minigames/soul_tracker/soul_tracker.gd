extends MinigameBase
## Player aims at ghosts (no clicking) to calm them from angry to happy.
## Win by calming all ghosts before the timer runs out.

@export var ghost_scene: PackedScene
@export var ghost_container_path: NodePath = "SoulContainer"
@export var ghost_count: int = 4
@export var stay_duration: float = 20.0
@export var spawn_radius: float = 2.0
@export var spawn_distance_forward: float = -6.0  # how far in front of the player
@export var raycast_length: float = 100.0

var speed_multiplier: float = 1.0
var time_remaining: float = 0.0
var active_ghosts: Array = []

var camera: Camera3D = null

@onready var ghost_container: Node = get_node(ghost_container_path)


func setup(level: int, speed: float = 1.0) -> void:
	speed_multiplier = speed
	
	if level >= 7:
		ghost_count = 2
	elif level >= 5:
		ghost_count = 3
	elif level >= 3:
		ghost_count = 4
	else:
		ghost_count = 5
	
	super.setup(level)


func start_minigame() -> void:
	super.start_minigame()
	time_remaining = stay_duration
	active_ghosts.clear()

	camera = get_viewport().get_camera_3d()

	_spawn_ghosts()


func _spawn_ghosts() -> void:
	const PLAYER_CENTER: Vector3 = Vector3.ZERO

	for i in range(ghost_count):
		var ghost = ghost_scene.instantiate()
		ghost_container.add_child(ghost)

		var start_angle = randf_range(0.0, TAU)
		var radius = randf_range(5.0, 10.0)
		var height = randf_range(0.5, 2.5)
		var speed = randf_range(0.2, 0.5) * speed_multiplier

		ghost.setup_orbit(PLAYER_CENTER, radius, start_angle, speed, height)
		ghost.ghost_completed.connect(_on_ghost_completed)
		active_ghosts.append(ghost)


func _generate_spread_positions(count: int) -> Array:
	var positions: Array = []
	var min_distance = 1.5  # tune this -- minimum spacing between ghosts
	var attempts = 0
	var max_attempts = count * 40

	while positions.size() < count and attempts < max_attempts:
		attempts += 1
		var offset = Vector3(
			randf_range(-spawn_radius, spawn_radius),
			randf_range(0.5, 2.0),
			randf_range(-1.0, 1.0)
		)
		var candidate = Vector3(offset.x, offset.y, spawn_distance_forward + offset.z)

		var far_enough = true
		for existing in positions:
			if existing.distance_to(candidate) < min_distance:
				far_enough = false
				break

		if far_enough:
			positions.append(candidate)

	return positions


func _process(delta: float) -> void:
	if not _is_active:
		return

	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		_fail()
		return

	_update_aim_tracking()


func _update_aim_tracking() -> void:
	if camera == null:
		return

	var space_state = get_world_3d().direct_space_state
	var origin = camera.global_transform.origin
	var forward = -camera.global_transform.basis.z
	var target = origin + forward * raycast_length

	var query = PhysicsRayQueryParameters3D.create(origin, target)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)

	if result and result.collider.is_in_group("ghosts"):
		result.collider.set_tracked(true)


func _on_ghost_completed(ghost: Node) -> void:
	active_ghosts.erase(ghost)
	if active_ghosts.is_empty():
		_win()


func _win() -> void:
	finish_minigame()


func _fail() -> void:
	for ghost in active_ghosts:
		if is_instance_valid(ghost):
			ghost.queue_free()
	finish_minigame()
