extends Node2D

var velocity := Vector2(0,0)
var direction := Vector2(0,0)
export (int) var MAX_SPEED = 500
export (int) var ATTACKING_SPEED = 200
export (int) var ATTACK_RANGE = 200
#how long it lasts. shorter is better
export (float) var ATTACK_SPEED = 0.5
export (float) var ATTACK_COOLDOWN = 0.2
var attacking = false
var lock_input = false
var can_attack = true

func _ready():
	$attack_cooldown.wait_time = ATTACK_COOLDOWN + ATTACK_SPEED

func _process(delta):
	if not lock_input:
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

#takes a normalised vector as the attack direction
func attack(target):
	$attack_cooldown.start()
	can_attack = false
	lock_input = true
	$attack_tween.interpolate_property(self, "position", self.position, self.position + target * ATTACK_RANGE,
	 ATTACK_SPEED, Tween.TRANS_BACK, Tween.EASE_IN)
	$attack_tween.start()
	
func _input(event):
# Mouse in viewport coordinates
	if not lock_input:
		var target = (get_global_mouse_position()-$KinematicBody2D.global_position).normalized()
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.pressed:
					attacking = true
					look_to(target)
				elif can_attack:
					attacking = false
					look_to(target)
					attack(target)
		if attacking:
			look_to(target)

#func _on_attack_tween_tween_completed(object, key):
#	lock_input = false


func _on_attack_cooldown_timeout():
	can_attack = true
	lock_input = false
