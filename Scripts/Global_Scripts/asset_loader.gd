extends Node

var shell_list = {}
var beachObjectsList = [load("res://Assets/rocks_1.png"), load("res://Assets/rocks_2.png"), load("res://Assets/grass_1.png"), load("res://Assets/grass_2.png")]

# Called when the node enters the scene tree for the first time.
func _ready():
	for item in range(1,4):
		print(item)
		shell_list["shell" + str(item)] = load("res://Assets/shell_"+str(item)+".png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
