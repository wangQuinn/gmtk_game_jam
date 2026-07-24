extends CanvasLayer

@onready var countdown_label: Label = $CountdownLabel

func set_countdown(text: String) -> void:
	countdown_label.text = text
	countdown_label.show()

func hide_countdown() -> void:
	countdown_label.hide()
