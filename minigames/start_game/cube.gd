extends Area3D
signal step_completed

@export var hold_time_required: float = 1.5
@export var raycast_length: float = 100.0

var hold_progress: float = 0.0
var camera: Camera3D = null


func _ready() -> void:
	add_to_group("targets")


func _process(delta: float) -> void:
	if not visible:
		return

	if camera == null:
		camera = get_viewport().get_camera_3d()
		if camera == null:
			return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _is_being_aimed_at():
		hold_progress += delta
		if hold_progress >= hold_time_required:
			_complete()
	else:
		hold_progress = max(0.0, hold_progress - delta * 2.0)


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
