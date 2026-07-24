extends Node3D

var mouse_sensitivity = 0.002
var yaw_limit = deg_to_rad(360)   # how far left/right you can look
var pitch_limit = deg_to_rad(30) # how far up/down you can look

var yaw = 0.0
var pitch = 0.0

@onready var camera: Camera3D = $Camera3D
@onready var boom: AudioStreamPlayer = $boom

func _ready():
	get_window().grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity

		yaw = clampf(yaw, -yaw_limit, yaw_limit)
		pitch = clampf(pitch, -pitch_limit, pitch_limit)

		rotation.y = yaw
		camera.rotation.x = pitch

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot()

func shoot():
	
	boom.play() #vineboom
	var from = camera.global_transform.origin
	var to = from + camera.global_transform.basis.z * -100.0

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	print(result)

	if result:
		print("Hit:", result.collider.name)
		print("Groups:", result.collider.get_groups())

		if result.collider.is_in_group("targets"):
			print("TARGET HIT!")
			result.collider.hit()
			
			
	print("Camera:", camera.global_position)
	print("Basis Z:", camera.global_transform.basis.z)
	print("From:", from)
	print("To:", to)
