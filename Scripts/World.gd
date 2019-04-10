extends TileMap

var world = []
export(Vector2) var worldSize = Vector2(70,50)

export(int) var octaves = 4
export(float) var period = 35.0
export(float) var persistence = 0.8

signal setup_complete()

func _ready():
	randomize()
	create_new_world()

func create_new_world():
	world.clear()
	for cell in get_used_cells():
		set_cell(cell.x, cell.y, -1)
	
	World_Generator.generate_world(octaves, period, persistence, worldSize)
	
	for x in range(worldSize.x):
		world.append([])
		for y in range(worldSize.y):
			
			var cellData = {
				"depth": World_Generator.get_depth(x,y),
				"biome": World_Generator.get_biome(x,y)
			}
			
			world[x].append(cellData)
	
	paint_cells()

func paint_cells():
	for x in range(worldSize.x):
		for y in range(worldSize.y):
			var depth = world[x][y]["depth"]
			var biome = world[x][y]["biome"]
			var cell
			 #Checks the depth and sets the tile accordingly
			if depth <= -0.1:
				cell = 2
				if biome <= 0:
					set_cell(x,y,cell+3)
				else:
					set_cell(x,y,cell)
			elif depth <= 0.3:
				cell = 1
				if biome <= 0:
					set_cell(x,y,cell+3)
				else:
					set_cell(x,y,cell)
			else:
				cell = 0
				if biome <= 0:
					set_cell(x,y,cell+3)
				else:
					set_cell(x,y,cell)
	setup_water()

func setup_water():
	spawn_objects()

onready var beachObject = load("res://Scenes/Prefabs/Beach_Object.tscn")
onready var shellObject = load("res://Scenes/Prefabs/collectible_shell.tscn")
export(float) var objectChance = 0.05
export(float) var shellChance = 0.001
var cellSize = get_cell_size()


func spawn_objects():
	print(cellSize)
	for x in range(worldSize.x):
		for y in range(worldSize.y):
			if get_cell(x,y) in [0,3]:
				if rand_range(0,1) <= objectChance:
					var newBeachObject = beachObject.instance()
					newBeachObject.scale = Vector2(2,2)
					newBeachObject.setup(get_cell(x,y))
					$Sorter.add_child(newBeachObject)
					var spawnPos =  map_to_world(Vector2(x,y))
					newBeachObject.position = Vector2(spawnPos.x + rand_range(0, cellSize.x), spawnPos.y + rand_range(0, cellSize.y))
				if rand_range(0,1) <= shellChance:
					var newBeachObject = shellObject.instance()
					#newBeachObject.scale = Vector2(2,2)
					#newBeachObject.setup(get_cell(x,y))
					$Sorter.add_child(newBeachObject)
					var spawnPos =  map_to_world(Vector2(x,y))
					newBeachObject.position = Vector2(spawnPos.x + rand_range(0, cellSize.x), spawnPos.y + rand_range(0, cellSize.y))
	emit_signal("setup_complete")