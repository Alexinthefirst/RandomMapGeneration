extends Node2D

onready var tileMap = get_node("TileMap");

var noise = OpenSimplexNoise.new();

const MAP_WIDTH = 512;#512
const MAP_HEIGHT = 300;#300

var mapArray = []

export (int, "Normal", "Single Island", "Islands") var mapType;

var randSeed;

const biomeSetSize = 17 # This is the num of tile in a season set (16) + 1

var biomeArray = []
var random = RandomNumberGenerator.new();


# Called when the node enters the scene tree for the first time.
func _ready():
	random.randomize();
	
	randSeed = random.randi_range(0, 1000);
	
	$HUD/SeedLabel.text = "Seed: " + str(randSeed)
	
	noise.seed = randSeed;
	noise.period = 64;
	noise.octaves = 6;
	
	mapArray = initMap(MAP_WIDTH, MAP_HEIGHT, mapType);
	
	
	
	
	biomeArray = genBiomes();
	genMap(mapArray);

func initMap(width, height, type):
	
	var map = []
	
	#init map array
	for i in range(width):
		map.append([])
		for j in range(height):
			map[i].append(0.0)
	
	# If default map type
	if (type == 0):
		return map;
	
	# If single island map type
	if (type == 1):
		
		var distance = 0.0;
		var centerX = width/2;
		var centerY = height/2;
		
		for x in range(width):
			for y in range(height):
				#squaring
				var distanceX = (centerX - x) * (centerX - x)
				var distanceY = (centerY - y) * (centerY - y)
				
				#distance to the center is the sqrt of the two
				distance = sqrt(distanceX + distanceY);
				distance = distance / (width/2)
				
				# add both the gradient and noise values
				map[x][y] += distance;
				#map[x][y] -= noise.get_noise_2d(x, y);
				
		return map;

func genMap(map):
	tileMap.clear()
	
	for i in MAP_WIDTH:
		
		#print("X: " + str(biomeTickerX));
		
		for j in MAP_HEIGHT:
			
			#if j == MAP_WIDTH - 1:
			#	pass
			
			#print("j: " + str(j))
			#print("Y: " + str(biomeTickerY));
			#print("X: " + str(biomeTickerX));
			#print("");
			
			tileMap.set_cell(i, j, get_tile_index(i, j, noise.get_noise_2d(i, j)))
	

func get_tile_index(i, j, noise_sample):
	#Check for mountains
	#if noise_sample >= 0.5 && noise_sample <= 0.52:
	#	#Check each direction to see if its lower
	#	if noise.get_noise_2d(i-1, j) < noise_sample:
	#		return 10;
	#	elif noise.get_noise_2d(i, j-1) < noise_sample:
	#		return 5;
	#	elif noise.get_noise_2d(i+1, j) < noise_sample:
	#		return 6;
	#	elif noise.get_noise_2d(i, j+1) < noise_sample:
	#		return 8;
	#	else:
	#		return 2;
	
	noise_sample = noise_sample - mapArray[i][j]
		
	if noise_sample > 0:
		return 18;
	elif noise_sample > -0.1:
		return 2;
	elif noise_sample > -0.2:
		return 1;
	elif noise_sample > -0.3:
		return 3;
	else:
		return 0;
	

func genBiomes():
	# 0 is grass, 1 is snow
	var biomeArrayN = [];
	
	var numDiffBiomes = 2; #How many different biomes there is
	var biomeSize = 100; #How many tiles wide a biome is
	var numBiomesWidth = ceil(MAP_WIDTH) / biomeSize;
	var numBiomesHeight = ceil(MAP_HEIGHT) / biomeSize;
	for i in numBiomesWidth:
		biomeArrayN.append([])
		for j in numBiomesHeight:
			biomeArrayN[i].append(random.randi_range(0, 1));
	
	print(numBiomesWidth)
	print(numBiomesHeight)
	print(biomeArrayN);
	return biomeArrayN;
	

func _input(event):
	if event.is_action_pressed("generateMap"):
		print("Generating map...")
		randSeed = random.randi_range(0, 1000);
		
		$HUD/SeedLabel.text = "Seed: " + str(randSeed)
		
		noise.seed = randSeed;
		genMap(mapArray)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

