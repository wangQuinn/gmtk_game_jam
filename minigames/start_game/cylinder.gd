extends Area3D
signal step_completed

@export var track_time_required: float = 2.0
@export var raycast_length: float = 100.0

@export var bar_fill_path: NodePath = "bar_fill"
@export var bar_bg_path: NodePath = "bar_bg"
@export var left_anchor_path: NodePath = "Node3D"

var track_progress: float = 0.0
var camera: Camera3D = null

@onready var bar_fill: MeshInstance3D = get_node_or_null(bar_fill_path)
@onready var bar_bg: MeshInstance3D = get_node_or_null(bar_bg_path)
@onready var left_anchor: Node3D = get_node_or_null(left_anchor_path)

var bar_mesh: QuadMesh
var bar_full_width: float = 0.5


func _ready() -> void:
	add_to_group("targets")

	if bar_fill and bar_fill.mesh is QuadMesh:
		bar_mesh = bar_fill.mesh.duplicate()
		bar_fill.mesh = bar_mesh
		bar_full_width = bar_mesh.size.x

	_update_progress_bar()


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

	_update_progress_bar()


func _is_being_aimed_at() -> bool:
	var space_state = get_world_3d().direct_space_state
	var origin = camera.global_transform.origin
	var forward = -camera.global_transform.basis.z
	var target = origin + forward * raycast_length

	var query = PhysicsRayQueryParameters3D.create(origin, target)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)

	return result and result.collider == self


func _update_progress_bar() -> void:
	if not bar_fill or not bar_mesh or not left_anchor:
		return

	var fraction = clamp(track_progress / track_time_required, 0.0, 1.0)
	var new_width = max(bar_full_width * fraction, 0.001)

	bar_mesh.size.x = new_width
	bar_fill.position.x = left_anchor.position.x + new_width / 2.0


func _complete() -> void:
	emit_signal("step_completed")
	queue_free()


func hit() -> void:
	pass  # hovering is the mechanic here, not clicking
