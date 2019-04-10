extends Node

var shell_list = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for item in range(1,4):
		print(item)
		shell_list["shell" + str(item)] = load("res://Assets/shell_"+str(item)+".png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
