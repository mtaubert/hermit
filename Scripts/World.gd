extends TileMap

var world = []
export(Vector2) var worldSize = Vector2(70,50)

export(int) var octaves = 4
export(float) var period = 35.0
export(float) var persistence = 0.8

func _ready():
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

onready var rock = load("res://Scenes/Prefabs/Rocks.tscn")
func spawn_objects():
	for x in range(worldSize.x)