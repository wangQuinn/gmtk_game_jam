class_name MinigameBase
extends Node3D

signal minigame_finished

var _level: int = 1
var _time_limit: float = 5.0
var _is_active: bool = false

func setup(level: int) -> void:
	_level = level
	_time_limit = clamp(6.0 - (10 - level) * 0.3, 1.5, 6.0)

func start_minigame() -> void:
	_is_active = true

func finish_minigame() -> void:
	if not _is_active:
		return
	_is_active = false
	minigame_finished.emit()

func _on_target_hit(_target: Node) -> void:
	pass
