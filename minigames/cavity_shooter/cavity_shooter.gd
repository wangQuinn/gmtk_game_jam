extends MinigameBase
## Minimal version: shows the head, cycles mouth open/close.
## Ends automatically after a fixed duration.

@export var mouth_controller_path: NodePath = "MouthControl"
@export var stay_duration: float = 7.0

var speed_multiplier: float = 1.0
var time_remaining: float = 0.0

@onready var mouth_controller: Node = get_node(mouth_controller_path)


func setup(level: int, speed: float = 1.0) -> void:
	speed_multiplier = speed
	super.setup(level)


func start_minigame() -> void:
	super.start_minigame()
	time_remaining = stay_duration

	mouth_controller.mouth_opened.connect(_on_mouth_opened)
	mouth_controller.mouth_closed.connect(_on_mouth_closed)
	mouth_controller.start_cycle(speed_multiplier)


func _process(delta: float) -> void:
	if not _is_active:
		return

	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		mouth_controller.stop_cycle()
		finish_minigame()


func _on_mouth_opened() -> void:
	print("Mouth opened")


func _on_mouth_closed() -> void:
	print("Mouth closed")
