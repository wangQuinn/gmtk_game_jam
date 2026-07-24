extends MinigameBase

const TARGET_SCENE = preload("res://minigames/timer_countdown/timer_countdown.tscn")

var target: Node3D
var time_remaining: float = 3.0

func start_minigame() -> void:
	super.start_minigame()
	time_remaining = _time_limit if _time_limit > 0 else 3.0


	target.position = Vector3(0, 1.5, -10)
	target.target_hit.connect(_on_target_hit)
	HUD.set_countdown("%.1f" % time_remaining)

func _process(delta: float) -> void:
	if not _is_active:
		return
	time_remaining -= delta
	if time_remaining <= 0.0:
		_fail()

func _on_target_hit(_target: Node) -> void:
	HUD.set_countdown("HIT!")
	finish_minigame()

func _fail() -> void:
	HUD.set_countdown("MISS!")
	if target:
		target.queue_free()
	finish_minigame()
