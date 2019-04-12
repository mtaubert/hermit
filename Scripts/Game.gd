extends Node2D

onready var world := $World
onready var shell = load("res://Scenes/Prefabs/collectible_shell.tscn")

func _ready():
	pass

func _on_World_setup_complete():
	$Nav/World/Sorter/player.connect_collectibles()


func _on_player_drop_shell(item):
	var drop = shell.instance()
	drop.init(item)
	#$World/Sorter.add_child(drop)
	print($Nav/World/Sorter/player.global_position)
	#drop.position = $World/Sorter/player.global_position
	drop.set_position($Nav/World/Sorter/player.global_position)
	
	$Nav/World/Sorter.add_child(drop)
	$Nav/World/Sorter/player.connect_collectibles()