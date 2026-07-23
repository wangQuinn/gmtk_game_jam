extends MinigameBase
const TARGET_SCENE = preload("res://minigames/Target.tscn")
var targets_remaining: int = 3
var speed_multiplier: float = 1.0
var spawn_positions: Array[Vector3] = [
	Vector3(-2, 1, -10),
	Vector3(0, 1.5, -10),
	Vector3(2, 1, -10),
]

func setup(level: int, speed: float = 1.0) -> void:
	speed_multiplier = speed
	super.setup(level)

func start_minigame() -> void:
	super.start_minigame()
	targets_remaining = spawn_positions.size()
	for pos in spawn_positions:
		var t = TARGET_SCENE.instantiate()
		add_child(t)
		t.position = pos
		t.target_hit.connect(_on_target_hit)
		print("Spawned target at global position: ", t.global_position)

func _on_target_hit(_target: Node) -> void:
	targets_remaining -= 1
	if targets_remaining <= 0:
		finish_minigame()
