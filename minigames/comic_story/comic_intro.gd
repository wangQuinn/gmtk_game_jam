extends Control
@onready var panels: Array[TextureRect] = [
	$panel1, $panel2, $panel3, $panel4,
	$panel5, $panel6, $panel7
]
@onready var text_screen: Control = $TextScreen
@onready var story_label: RichTextLabel = $TextScreen/StoryLabel
@onready var fade_overlay: ColorRect = $FadeOverlay

@export var reveal_interval: float = 1.5
@export var story_text: String = "... kitty has been caught for kitty's crimes, and for kitty's crimes, shall kitty be condemned to hell


to regain kitty's nine lives, kitty must shoot through nine levels of hell doing good deeds"

func _ready() -> void:
	for p in panels:
		p.modulate.a = 0.0
	text_screen.modulate.a = 0.0
	text_screen.hide()
	fade_overlay.modulate.a = 0.0
	play_comic()

func play_comic() -> void:
	for p in panels:
		var tween = create_tween()
		tween.tween_property(p, "modulate:a", 1.0, 0.4)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tween.finished
		await get_tree().create_timer(reveal_interval).timeout
	await get_tree().create_timer(0.6).timeout
	show_text_screen()

func show_text_screen() -> void:
	story_label.text = story_text
	text_screen.show()
	var tween = create_tween()
	tween.tween_property(text_screen, "modulate:a", 1.0, 0.6)
	await tween.finished
	await get_tree().create_timer(12).timeout
	_on_intro_finished()

func _on_intro_finished() -> void:
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.6)
	await fade_tween.finished
	get_tree().change_scene_to_file("res://Main.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_S:
		_on_intro_finished()
