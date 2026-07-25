extends Area3D
signal ghost_completed(ghost: Node)

enum State { ANGRY, HAPPY, DONE }

@export var track_time_required: float = 3.0
@export var angry_material: Material
@export var happy_material: Material

## Orbit settings
var orbit_center: Vector3 = Vector3.ZERO
var orbit_radius: float = 8.0
var orbit_speed: float = 0.3
var orbit_angle: float = 0.0
var orbit_height: float = 1.0
var height_bob_amount: float = 0.3
var height_bob_speed: float = 1.5

## Direction-switching
@export var min_direction_hold_time: float = 1.5
@export var max_direction_hold_time: float = 4.0
var direction: float = 1.0   # 1.0 = CCW, -1.0 = CW
var direction_switch_timer: float = 0.0

var state: State = State.ANGRY
var track_progress: float = 0.0
var is_being_tracked: bool = false

@onready var mesh_instance: MeshInstance3D = get_node_or_null("ghostAngry/Cylinder")
@onready var bar_fill: MeshInstance3D = get_node_or_null("ProgressBar/FillAnchor/BarFill")
@onready var progress_bar_root: Node3D = get_node_or_null("ProgressBar")

var bar_full_width: float = 1.0


func _ready() -> void:
	add_to_group("ghosts")
	_pick_new_direction_hold_time()
	_update_visual()


func setup_orbit(center: Vector3, radius: float, start_angle: float, speed: float, height: float) -> void:
	orbit_center = center
	orbit_radius = radius
	orbit_angle = start_angle
	orbit_speed = speed
	orbit_height = height


func _process(delta: float) -> void:
	if state == State.DONE:
		return

	_orbit(delta)
	_face_camera()

	if state == State.ANGRY:
		if is_being_tracked:
			track_progress += delta
			if track_progress >= track_time_required:
				_become_happy()
		else:
			track_progress = max(0.0, track_progress - delta * 2.0)

	_update_progress_bar()
	is_being_tracked = false


func set_tracked(tracked: bool) -> void:
	is_being_tracked = tracked


func _orbit(delta: float) -> void:
	direction_switch_timer -= delta
	if direction_switch_timer <= 0.0:
		direction *= -1.0
		_pick_new_direction_hold_time()

	orbit_angle += orbit_speed * direction * delta

	var x = orbit_center.x + cos(orbit_angle) * orbit_radius
	var z = orbit_center.z + sin(orbit_angle) * orbit_radius
	var y = orbit_height + sin(Time.get_ticks_msec() / 1000.0 * height_bob_speed) * height_bob_amount

	global_position = Vector3(x, y, z)


func _pick_new_direction_hold_time() -> void:
	direction_switch_timer = randf_range(min_direction_hold_time, max_direction_hold_time)


func _face_camera() -> void:
	var cam = get_viewport().get_camera_3d()
	if cam:
		look_at(cam.global_transform.origin, Vector3.UP)


func _update_progress_bar() -> void:
	if not bar_fill:
		return
	var fraction = clamp(track_progress / track_time_required, 0.0, 1.0)
	bar_fill.scale.x = fraction


func _become_happy() -> void:
	state = State.HAPPY
	_update_visual()
	emit_signal("ghost_completed", self)
	await get_tree().create_timer(0.6).timeout
	state = State.DONE
	queue_free()


func _update_visual() -> void:
	if not mesh_instance:
		return
	if state == State.ANGRY and angry_material:
		mesh_instance.set_surface_override_material(0, angry_material)
	elif state == State.HAPPY and happy_material:
		mesh_instance.set_surface_override_material(0, happy_material)
