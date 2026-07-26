extends Area3D
signal step_completed

@export var track_time_required: float = 2.0
@export var raycast_length: float = 100.0

var track_progress: float = 0.0
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

	if _is_being_aimed_at():
		track_progress += delta
		if track_progress >= track_time_required:
			_complete()
	else:
		track_progress = max(0.0, track_progress - delta * 2.0)


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
	pass  # hovering is the mechanic here, not clicking
