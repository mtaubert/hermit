extends Node

func _ready():
	randomize()

var depthNoise
var biomeNoise
var size

func generate_world(octaves, period, persistence, worldSize:Vector2):
	depthNoise = OpenSimplexNoise.new()
	size = worldSize
	# Configure
	depthNoise.seed = randi()
	depthNoise.octaves = octaves
	depthNoise.period = period
	depthNoise.persistence = persistence

func get_depth(x,y):
	var gradientOffset = (((((x/size.x)+(y/size.y))/2)*2)-1)*(-1)
	var depth = (gradientOffset+depthNoise.get_noise_2d(x,y))/2
	return depth