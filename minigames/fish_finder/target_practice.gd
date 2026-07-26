extends MinigameBase
const FISH_SCENE = preload("res://minigames/fish_finder/Target.tscn")

var speed_multiplier: float = 1.0
var fish_count: int = 5
var fish_list: Array = []
const PLAYER_CENTER: Vector3 = Vector3.ZERO

const NO_HAT: String = "None"
var all_hat_names: Array[String] = ["Crown", "Witch Hat", "Beach Hat", "Christmas Hat", "Cowboy Hat", "Top Hat"]

signal hat_prompt_ready(hat_name: String)

func setup(level: int, speed: float = 1.0) -> void:
	speed_multiplier = speed
	var difficulty = 1.0 - (float(level) / 10.0)
	fish_count = int(lerp(6, 16, difficulty))
	super.setup(level)

func start_minigame() -> void:
	super.start_minigame()
	fish_list.clear()

	for i in fish_count:
		var fish = FISH_SCENE.instantiate()
		add_child(fish)

		var start_angle = randf_range(0.0, TAU)
		var radius = randf_range(5.0, 12.0)
		var height = randf_range(0.3, 3.0)
		var base_speed = randf_range(0.15, 0.6)
		var direction = 1.0 if randf() < 0.5 else -1.0
		var speed = base_speed * direction * speed_multiplier

		fish.setup_orbit(PLAYER_CENTER, radius, start_angle, speed, height)
		fish.target_hit.connect(_on_fish_hit)
		fish_list.append(fish)

	var correct = fish_list[randi() % fish_list.size()]

	# target always wears an actual hat (not "None"), so there's something to identify
	var target_hat_name = all_hat_names[randi() % all_hat_names.size()]
	correct.set_hat(target_hat_name)

	# everyone else picks from all hats PLUS "no hat", excluding the target's specific hat
	var remaining_options = all_hat_names.filter(func(h): return h != target_hat_name)
	remaining_options.append(NO_HAT)

	for f in fish_list:
		if f != correct:
			f.set_hat(remaining_options[randi() % remaining_options.size()])

	for f in fish_list:
		f.mark_as_target(f == correct)

	emit_signal("hat_prompt_ready", target_hat_name)

func _on_fish_hit(fish: Node) -> void:
	if fish.is_correct_target:
		finish_minigame()
	else:
		pass
