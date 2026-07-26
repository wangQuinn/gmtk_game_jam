extends MinigameBase


@export var fire_target_scene: PackedScene = preload("res://minigames/fire/FireTarget.tscn")
@export var floor_size: Vector2 = Vector2(10, 10)  # match your actual floor dimensions
@export var min_fires: int = 3
@export var max_fires: int = 6

var active_fires: Array = []
var level := 1
var speed := 1.0

func setup(current_level: int, spd: float = 1.0) -> void:
	super.setup(current_level)
	level = current_level
	speed = spd

func start_minigame() -> void:
	super.start_minigame()
	var count = randi_range(min_fires, max_fires)
	for i in count:
		_spawn_fire()

func _spawn_fire() -> void:
	var fire = fire_target_scene.instantiate()
	add_child(fire)
	var x = randf_range(-floor_size.x / 2, floor_size.x / 2)
	var z = randf_range(-floor_size.y / 2, floor_size.y / 2)
	fire.position = Vector3(x, 0, z)
	fire.extinguished.connect(_on_fire_extinguished.bind(fire))
	active_fires.append(fire)

func _on_fire_extinguished(fire) -> void:
	active_fires.erase(fire)
	if active_fires.is_empty():
		finish_minigame()
