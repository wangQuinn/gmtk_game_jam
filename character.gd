extends Node3D
var mouse_sensitivity = 0.002
var pitch_limit = deg_to_rad(50) # how far up/down you can look
var yaw = 0.0
var pitch = 0.0
var spraying = false
@export var hold_mode = false
@export var invert_controls = false   # NEW: toggle per level
@onready var camera: Camera3D = $Camera3D
@onready var boom: AudioStreamPlayer = $boom
@onready var muzzle_particles: GPUParticles3D = $"Camera3D/Muzzle Particles"

const BULLET_PARTICLE_SCENE = preload("res://Bullet.tscn")
@onready var muzzle_marker: Marker3D = $"Camera3D/MuzzleMarker"


func _ready():
	get_window().grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var invert_multiplier = -1.0 if invert_controls else 1.0

		yaw -= event.relative.x * mouse_sensitivity * invert_multiplier
		pitch -= event.relative.y * mouse_sensitivity * invert_multiplier

		pitch = clampf(pitch, -pitch_limit, pitch_limit)
		rotation.y = yaw
		camera.rotation.x = pitch
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot()

func _physics_process(_delta):
	if hold_mode and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		shoot()

func shoot():
	var from = camera.global_transform.origin
	var to = from + camera.global_transform.basis.z * -100.0
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
#<<<<<<< Updated upstream
	#print(result)
	#if result:
		#print("Hit:", result.collider.name)
		#print("Groups:", result.collider.get_groups())
		#if result.collider.is_in_group("targets"):
			#print("TARGET HIT!")
			#result.collider.hit()
	#print("Camera:", camera.global_position)
	#print("Basis Z:", camera.global_transform.basis.z)
	#print("From:", from)
	#print("To:", to)
#=======

	var target_point = to
	if result:
		target_point = result.position

	if result and result.collider.is_in_group("targets"):
		result.collider.hit()

	var bullet = BULLET_PARTICLE_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle_marker.global_position
	bullet.look_at(target_point, Vector3.UP)   # aim muzzle → crosshair target
	await get_tree().create_timer(bullet.lifetime).timeout
	if is_instance_valid(bullet):
		bullet.queue_free()
#>>>>>>> Stashed changes
