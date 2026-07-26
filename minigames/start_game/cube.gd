extends Area3D
signal step_completed

@export var hold_time_required: float = 1.5
@export var raycast_length: float = 100.0
@export var min_scale: float = 0.2   # how small it gets right before vanishing

@onready var cube_mesh: Node3D = $MeshInstance3D   # adjust to your actual mesh node name

var hold_progress: float = 0.0
var camera: Camera3D = null
var base_scale: Vector3


func _ready() -> void:
	add_to_group("targets")
	base_scale = cube_mesh.scale


func _process(delta: float) -> void:
	if not visible:
		return

	if camera == null:
		camera = get_viewport().get_camera_3d()
		if camera == null:
			return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _is_being_aimed_at():
		hold_progress += delta
		_update_scale()
		if hold_progress >= hold_time_required:
			_complete()
	else:
		hold_progress = max(0.0, hold_progress - delta * 2.0)
		_update_scale()


func _update_scale() -> void:
	var ratio = 1.0 - (hold_progress / hold_time_required)
	var scale_factor = lerp(min_scale, 1.0, ratio)
	cube_mesh.scale = base_scale * scale_factor


func _is_being_aimed_at() -> bool:
	var space_state = get_world_3d().direct_space_state
	var origin = camera.global_transform.origin
	var forward = -camera.global_transform.basis.z
	var target = origin + forward * raycast_length

	var query = PhysicsRayQueryParameters3D.create(origin, target)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)

	return result and result.collider == self


func _complete() -> void:
	emit_signal("step_completed")
	queue_free()


func hit() -> void:
	pass  # single click alone doesn't count -- only sustained hold via _process()
