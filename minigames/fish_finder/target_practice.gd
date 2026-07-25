extends MinigameBase
const FISH_SCENE = preload("res://minigames/fish_finder/Target.tscn")
var speed_multiplier: float = 1.0
var fish_count: int = 5
var fish_list: Array = []
const PLAYER_CENTER: Vector3 = Vector3.ZERO

func setup(level: int, speed: float = 1.0) -> void:
	speed_multiplier = speed
	var difficulty = 1.0 - (float(level) / 10.0)
	fish_count = int(lerp(6, 16, difficulty))   # more fish overall, higher ceiling for hard levels
	super.setup(level)

func start_minigame() -> void:
	super.start_minigame()
	fish_list.clear()

	for i in fish_count:
		var fish = FISH_SCENE.instantiate()
		add_child(fish)

		var start_angle = randf_range(0.0, TAU)              # fully random position around the circle, not evenly spaced
		var radius = randf_range(5.0, 12.0)                   # wider radius range = more depth variation, some closer/farther
		var height = randf_range(0.3, 3.0)                    # wider vertical spread
		var base_speed = randf_range(0.15, 0.6)                # much wider speed range = some slow, some fast
		var direction = 1.0 if randf() < 0.5 else -1.0          # some orbit clockwise, some counter-clockwise
		var speed = base_speed * direction * speed_multiplier

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
		pass
