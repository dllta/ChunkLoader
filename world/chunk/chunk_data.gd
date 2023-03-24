class_name ChunkData extends Node

var number:int
var color:Array

var noise_map:Image

func generate(_seed:int):
	# generate chunk data based off of a seed
	var gen = RandomNumberGenerator.new()
	gen.seed = _seed
	number = gen.randi() % 100
	color = [gen.randi()%255,gen.randi()%255,gen.randi()%255]

# executes when str(ChunkData) is called
func _to_string():
	return "Chunk({number}, {color})".format({"number":number,"color":color})

func serialize():
	return [number,color]

func deserialize(data):
	number = data[0]
	color = data[1]
