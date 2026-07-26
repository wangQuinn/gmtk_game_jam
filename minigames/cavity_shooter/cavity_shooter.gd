extends MinigameBase
## Cavity shooter: shows the head, cycles mouth open/close.
## Ends when all cavities are hit. Timing is now handled externally by level_manager.gd.

@export var mouth_controller_path: NodePath = "MouthControl"
@export var cavity_spawn_path: NodePath = "ToothSlots"

var speed_multiplier: float = 1.0
var mylevel: int

@onready var mouth_controller: Node = get_node(mouth_controller_path)
@onready var cavity_spawner: Node = get_node(cavity_spawn_path)


func setup(level: int, speed: float = 1.0) -> void:
	speed_multiplier = speed
	mylevel = level
	super.setup(level)


func start_minigame() -> void:
	super.start_minigame()

	cavity_spawner.generate(self, mylevel)
	cavity_spawner.set_visible_and_shootable(false)
	mouth_controller.mouth_opened.connect(_on_mouth_opened)
	mouth_controller.mouth_closed.connect(_on_mouth_closed)
	mouth_controller.start_cycle(speed_multiplier)


func _on_mouth_opened() -> void:
	cavity_spawner.set_visible_and_shootable(true)


func _on_mouth_closed() -> void:
	cavity_spawner.set_visible_and_shootable(false)


func register_cavity_hit(_cavity: Node) -> void:
	if not _is_active:
		return
	print("Cavity hit registered! Remaining: ", cavity_spawner.remaining_cavities())
	if cavity_spawner.remaining_cavities() <= 0:
		print("All cavities cleared, finishing minigame")
		mouth_controller.stop_cycle()
		finish_minigame()


func register_tooth_hit(_tooth: Node) -> void:
	pass
