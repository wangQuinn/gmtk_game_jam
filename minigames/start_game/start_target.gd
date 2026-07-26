extends Node3D
signal tutorial_complete

@export var ball_path: NodePath = "Ball"
@export var cube_path: NodePath = "Cube"
@export var cylinder_path: NodePath = "Cylinder"
@export var start_ball_path: NodePath = "StartBall"
@export var instructions_label_path: NodePath = "Label3D"

@onready var ball: Node = get_node(ball_path)
@onready var cube: Node = get_node(cube_path)
@onready var cylinder: Node = get_node(cylinder_path)
@onready var start_ball: Node = get_node(start_ball_path)
@onready var instructions_label: Node = get_node_or_null(instructions_label_path)


func _ready() -> void:
	start_ball.start_pressed.connect(_on_start_ball_hit)


func _on_start_ball_hit() -> void:
	if is_instance_valid(ball):
		ball.hide()
	if is_instance_valid(cylinder):
		cylinder.hide()
	if is_instance_valid(cube):
		cube.hide()

	if instructions_label:
		instructions_label.hide()

	emit_signal("tutorial_complete")
