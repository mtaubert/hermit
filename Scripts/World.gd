extends TileMap

var world = []
export(Vector2) var worldSize = Vector2(50,50)

export(int) var octaves = 4
export(float) var period = 35.0
export(float) var persistence = 0.8

signal setup_complete()

func _ready():
	randomize()
	create_new_world()

#Creates the world and sets up all the other world objects
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
	#setup_water()
	spawn_objects()
	spawn_player()
	spawn_other_entities()

#Draws the tiles to each cell according to the water depth and biome
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

func setup_water():
	var waterTiles = get_used_cells_by_id(1)
	$Polygon2D.polygon = PoolVector2Array(waterTiles)

onready var beachObject = load("res://Scenes/Prefabs/Beach_Object.tscn")
onready var shellObject = load("res://Scenes/Prefabs/collectible_shell.tscn")
export(float) var objectChance = 0.05
export(float) var shellChance = 0.005
var cellSize = get_cell_size()

#Spawns the random objects in the world
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
					$Sorter.add_child(newBeachObject)
					var spawnPos =  map_to_world(Vector2(x,y))
					newBeachObject.position = Vector2(spawnPos.x + rand_range(0, cellSize.x), spawnPos.y + rand_range(0, cellSize.y))

onready var player = load("res://Scenes/Prefabs/player_crab.tscn")
func spawn_player():
	var spawned = false
	while !spawned: #Tries to find a suitable spawn position
		var spawn = Vector2(randi()%(int(0.2*worldSize.x)), randi()%(int(0.2*worldSize.y))) #Check top left 20% of the map for a spawn point
		if get_cell(spawn.x, spawn.y) in [0,3]: #Only spawns on sand
			var newPlayer = player.instance()
			$Sorter.add_child(newPlayer)
			newPlayer.position = map_to_world(spawn)
			newPlayer.set_name("player")
			spawned = true
	emit_signal("setup_complete")

export(int) var smallSharkNum = 1 
onready var shark = load("res://Scenes/Prefabs/Shark.tscn")

func spawn_other_entities():
	for i in range(smallSharkNum):
		var newShark = shark.instance()
		$Sorter.add_child(newShark)
		var suitableCells = get_used_cells_by_id(1) + get_used_cells_by_id(4) #List of shallow water cells of all kinds
		var habitatAsWorldCoordinates = []
		
		for cell in suitableCells:
			habitatAsWorldCoordinates.append(map_to_world(cell))
		
		newShark.position = habitatAsWorldCoordinates[randi()%habitatAsWorldCoordinates.size()] #Random spawn point
		newShark.setup(get_parent(), habitatAsWorldCoordinates) #Sets up the shark