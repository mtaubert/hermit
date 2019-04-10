extends Node2D

var velocity := Vector2(0,0)
var direction := Vector2(0,0)
export (int) var MAX_SPEED = 500
export (int) var ATTACKING_SPEED = 200
var attacking = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	velocity = handle_movement()
	$KinematicBody2D.move_and_slide(velocity)

"""
assess user inputs to get movement direction, returns what the players velocity should be from user input
"""
func handle_movement():
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	direction = direction.normalized()
	
	update_look_direction()
	if attacking:
		return (direction.normalized() * ATTACKING_SPEED)
	else:
		return (direction.normalized() * MAX_SPEED)
	
	
"""
we want the crab by default to look in the direction its moving, on click for an attack look in the direction of the mouse
"""
func update_look_direction():
	#oly update the look direction if there is input
	if velocity.x or velocity.y:
		if not attacking:
			look_to(velocity)
		
		#set the crab to scuttle if moving
		if not $KinematicBody2D/Node2D/AnimationPlayer.is_playing():
			$KinematicBody2D/Node2D/AnimationPlayer.play("scuttle")
	else:
		#stop scuttling if stationary
		$KinematicBody2D/Node2D/AnimationPlayer.stop()


#add a magical 90 degree offset for the rotation of the crab
func look_to(vect):
	$KinematicBody2D/Node2D.rotation_degrees = rad2deg(vect.angle()) + 90

func _input(event):
# Mouse in viewport coordinates
	if event is InputEventMouseButton:
		attacking = not attacking
		print("Mouse Click/Unclick at: ", get_global_mouse_position())
		look_to(get_global_mouse_position()-$KinematicBody2D.global_position)
	if event is InputEventMouseMotion and attacking:
		look_to(get_global_mouse_position()-$KinematicBody2D.global_position)