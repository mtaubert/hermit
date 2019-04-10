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
var collectibles
var pickup_option = null
var shell
var dead = false

signal drop_shell(item)

func _ready():
	$attack_cooldown.wait_time = ATTACK_COOLDOWN + ATTACK_SPEED
	connect_collectibles()

func _process(delta):
	if not dead:
		if not lock_input:
			velocity = handle_movement()
			handle_other_controls()
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
	
#handle mouse inputs for attacks
func _input(event):
# Mouse in viewport coordinates
	if not dead:
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


#when the attack cooldown is finished
func _on_attack_cooldown_timeout():
	can_attack = true
	lock_input = false
	
"""
handle all non movement player controls. interaction hide and attack
"""
func handle_other_controls():
	if pickup_option and Input.is_action_pressed("interact"):
		if shell:
			#drop the current shell
			emit_signal("drop_shell", shell)
		shell = pickup_option.shell_texture
		$KinematicBody2D/Node2D/shell.texture = shell
		pickup_option.queue_free()
		

func pickup(item):
	pickup_option = item
	$CanvasLayer/UI/interact_label.visible = true

func cant_pickup():
	pickup_option = null
	
	$CanvasLayer/UI/interact_label.visible = false

func game_over(cause):
	$CanvasLayer/UI/game_over.text = "you "+ str(cause) + "\ngame over"
	dead = true

func connect_collectibles():
	collectibles = get_tree().get_nodes_in_group("collectible")
	for item in collectibles:
		item.connect("can_pickup", self, "pickup")
		item.connect("cant_pickup", self, "cant_pickup")
	print("no of shells: " + str(collectibles.size()))

#every second decrease the timer by one and lose one hunger, gmae over at 0 hunger.
func _on_hunger_timer_timeout():
	$CanvasLayer/UI/hunger_bar.value -= 1
	if $CanvasLayer/UI/hunger_bar.value <= 0:
		game_over("starved")
	$CanvasLayer/UI/hunger_bar/hunger_timer.start()
