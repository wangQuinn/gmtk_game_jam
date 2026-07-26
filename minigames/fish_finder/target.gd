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

var hat_nodes: Dictionary = {}

func _ready() -> void:
	add_to_group("targets")
	hat_nodes = {
		"Crown": get_node_or_null("crownHat"),
		"Witch Hat": get_node_or_null("witchHat"),
		"Beach Hat": get_node_or_null("beachHat"),
		"Santa Hat": get_node_or_null("santaHat"),
		"Cowboy Hat": get_node_or_null("cowboyHat"),
		"Top Hat": get_node_or_null("topHat"),
	}
	for hat in hat_nodes.values():
		if hat:
			hat.visible = false

func _process(delta: float) -> void:
	orbit_angle += orbit_speed * delta
	var x = orbit_center.x + cos(orbit_angle) * orbit_radius
	var z = orbit_center.z + sin(orbit_angle) * orbit_radius
	var y = orbit_height + sin(Time.get_ticks_msec() / 1000.0 * height_bob_speed) * height_bob_amount
	var new_position = Vector3(x, y, z)

	var direction = (new_position - global_position)
	if direction.length() > 0.001:
		look_at(global_position + direction, Vector3.UP)

	global_position = new_position

func setup_orbit(center: Vector3, radius: float, start_angle: float, speed: float, height: float) -> void:
	orbit_center = center
	orbit_radius = radius
	orbit_angle = start_angle
	orbit_speed = speed
	orbit_height = height

var current_hat_name: String = ""

func set_hat(hat_name: String) -> void:
	current_hat_name = hat_name
	for name in hat_nodes:
		if hat_nodes[name]:
			hat_nodes[name].visible = (name == hat_name)
	# if hat_name is "None", this loop naturally hides everything since nothing matches

func mark_as_target(is_target: bool) -> void:
	is_correct_target = is_target
	
func clear_hat() -> void:
	for hat in hat_nodes.values():
		if hat:
			hat.visible = false

func hit() -> void:
	emit_signal("target_hit", self)
	if is_correct_target:
		queue_free()
