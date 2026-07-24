extends MinigameBase

const FISH_SCENE = preload("res://minigames/fish_finder/Target.tscn")

var speed_multiplier: float = 1.0
var fish_count: int = 5
var fish_list: Array = []
const PLAYER_CENTER: Vector3 = Vector3.ZERO

func setup(level: int, speed: float = 1.0) -> void:
	speed_multiplier = speed
	super.setup(level)

func start_minigame() -> void:
	super.start_minigame()
	fish_list.clear()

	var angle_step = TAU / fish_count
	for i in fish_count:
		var fish = FISH_SCENE.instantiate()
		add_child(fish)
		var start_angle = i * angle_step
		var radius = randf_range(6.0, 10.0)
		var height = randf_range(0.5, 2.5)
		var speed = randf_range(0.2, 0.4) * speed_multiplier
		fish.setup_orbit(PLAYER_CENTER, radius, start_angle, speed, height)
		fish.target_hit.connect(_on_fish_hit)
		fish_list.append(fish)

	var correct = fish_list[randi() % fish_list.size()]
	for f in fish_list:
		f.mark_as_target(f == correct)

func _on_fish_hit(fish: Node) -> void:
	if fish.is_correct_target:
		finish_minigame()
	else:
		pass  # decide: fail, penalty, or ignore
