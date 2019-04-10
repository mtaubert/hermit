extends Node2D

var velocity := Vector2(0,0)
var direction := Vector2(0,0)
export (int) var MAX_SPEED = 500

func _ready():
	pass # Replace with function body.

func _process(delta):
	handle_movement()
	
	$KinematicBody2D.move_and_slide(velocity)

"""
assess user inputs to get movement direction
"""
func handle_movement():
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	velocity = (direction.normalized() * MAX_SPEED)