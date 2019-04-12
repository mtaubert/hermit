extends KinematicBody2D

var navigation:Navigation2D
var path
var habitat #Tiles the shark likes and will patrol the area

export(int) var speed = 100

func _ready():
	randomize()
	set_process(false)

func setup(nav, waterTiles):
	navigation = nav
	habitat = waterTiles
	
	var nextPoint = habitat[randi()%habitat.size()] #Grabs a random point of water
	move_to(nextPoint)

func move_to(pos:Vector2):
	path = navigation.get_simple_path(self.position, pos, true)
	print(path)
	set_process(true)

func _process(delta):
	if !path:
		set_process(false)
		var nextPoint = habitat[randi()%habitat.size()] #Grabs a random point of water
		move_to(nextPoint)
	
	if path.size() > 0:
		var distance: float = self.position.distance_to(path[0])
		if distance > 10:
			self.position = self.position.linear_interpolate(path[0], (speed * delta)/distance)
		else:
			path.remove(0)