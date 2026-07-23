#extends MinigameBase
#
#var speed_multiplier: float = 1.0
#
#func setup(level: int, speed: float = 1.0) -> void:
	#speed_multiplier = speed
	#super.setup(level)
#
#func start_minigame() -> void:
	#super.start_minigame()
	## spawn your cavity-shooter-specific targets/objects here
	## connect their "hit" signals to a handler, similar to fish_finder's _on_target_hit
#
#func _on_target_hit(_target: Node) -> void:
	## decrement remaining count, call finish_minigame() when done
	#pass
	
	
extends MinigameBase

var speed_multiplier: float = 1.0
var countdown_time: float = 5.0  # seconds — placeholder, tune later
var time_remaining: float = 0.0
var is_running: bool = false

func setup(level: int, speed: float = 1.0) -> void:
	speed_multiplier = speed
	super.setup(level)

func start_minigame() -> void:
	super.start_minigame()
	time_remaining = countdown_time
	is_running = true

func _process(delta: float) -> void:
	if not is_running:
		return
	time_remaining -= delta
	if time_remaining <= 0.0:
		is_running = false
		finish_minigame()
