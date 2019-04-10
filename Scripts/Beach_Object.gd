extends Sprite

func setup(biome):
	if biome == 0: #Normal sand
		self.texture = asset_loader.beachObjectsList[0]
	else: #Dark Sand
		self.texture = asset_loader.beachObjectsList[2]