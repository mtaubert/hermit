extends Node2D

onready var world := $World

func _on_Button_pressed():
	world.create_new_world()

func _ready():
	pass

func _on_World_setup_complete():
	$World/Sorter/player.connect_collectibles()
