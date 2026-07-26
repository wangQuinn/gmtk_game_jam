extends Node3D
## All four tutorial shapes are active and visible from the start, in any order.
## Hitting the final StartBall begins the game.

signal tutorial_complete

@export var ball_path: NodePath = "Ball"
@export var cube_path: NodePath = "Cube"
@export var cylinder_path: NodePath = "Cylinder"
@export var start_ball_path: NodePath = "StartBall"
@export var instructions_label_path: NodePath = "Label3D"   # adjust to your actual label's name

@onready var ball: Node = get_node(ball_path)
@onready var cube: Node = get_node(cube_path)
@onready var cylinder: Node = get_node(cylinder_path)
@onready var start_ball: Node = get_node(start_ball_path)
@onready var instructions_label: Node = get_node_or_null(instructions_label_path)


func _ready() -> void:
	start_ball.start_pressed.connect(_on_start_ball_hit)


func _on_start_ball_hit() -> void:
	if(ball and cube and cylinder):
		ball.hide()
		cube.hide()
		cylinder.hide()
	
	if instructions_label:
		instructions_label.hide()
	emit_signal("tutorial_complete")
