extends Area3D

signal target_hit(target)

@export var is_correct_target: bool = false

var orbit_center: Vector3 = Vector3.ZERO
var orbit_radius: float = 8.0
var orbit_speed: float = 0.3
var orbit_angle: float = 0.0
var orbit_height: float = 1.0
var height_bob_amount: float = 0.3
var height_bob_speed: float = 1.5

func _ready() -> void:
	add_to_group("targets")   # <-- this was missing

func _process(delta: float) -> void:
	orbit_angle += orbit_speed * delta
	var x = orbit_center.x + cos(orbit_angle) * orbit_radius
	var z = orbit_center.z + sin(orbit_angle) * orbit_radius
	var y = orbit_height + sin(Time.get_ticks_msec() / 1000.0 * height_bob_speed) * height_bob_amount
	global_position = Vector3(x, y, z)
	look_at(orbit_center, Vector3.UP)

func setup_orbit(center: Vector3, radius: float, start_angle: float, speed: float, height: float) -> void:
	orbit_center = center
	orbit_radius = radius
	orbit_angle = start_angle
	orbit_speed = speed
	orbit_height = height

func mark_as_target(is_target: bool) -> void:
	is_correct_target = is_target
	var mesh = get_node_or_null("MeshInstance3D")
	if mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color.GOLD if is_target else Color.STEEL_BLUE
		mesh.material_override = mat

func hit() -> void:
	emit_signal("target_hit", self)
	if is_correct_target:
		queue_free()
