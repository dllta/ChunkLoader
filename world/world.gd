extends Node2D

const CHUNK = preload("res://world/chunk/chunk.tscn")
const CHUNK_SIZE = 256
const CHUNK_TILES = 64

var world_seed:String = "test"
var RENDER_DISTANCE:int = 4

@onready var player = $Player

var chunks:Dictionary = {}

var current_chunk = null

var noise_map:FastNoiseLite

func _ready():
	noise_map = FastNoiseLite.new()
	noise_map.seed = hash(world_seed)
	noise_map.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise_map.frequency = 0.04
	noise_map.fractal_octaves = 4
	noise_map.fractal_lacunarity = 2
	noise_map.fractal_gain = 0.5
	
	generate()

func get_render_axis(offset,width:int):
	return range(-floor(float(width)/2.0) + offset,ceil(float(width)/2.0) + offset)

func _process(_delta):
	# every frame, check if the player is in a different chunk
	var new_chunk = get_player_chunk()
	if new_chunk != current_chunk:
		current_chunk = new_chunk
		# if so, update chunks
		update_chunks()

func update_chunks():
	var loaded:Array[Vector2i] = []
	
	# iterates over limits of render distance
	for x in get_render_axis(current_chunk.x,RENDER_DISTANCE):
		for y in get_render_axis(current_chunk.y,RENDER_DISTANCE):
			# updates the chunk
			var current = Vector2i(x,y)
			load_chunk(current)
			loaded.append(current)
	
	for i in $Chunk.get_children():
		if !loaded.has(i.pos):
			chunk_write(i.pos,i.chunk_data)
			unload_chunk(i.pos)

func get_player_chunk():
	if (RENDER_DISTANCE%2):
		return Vector2i(round(player.position/CHUNK_SIZE))
	else:
		return Vector2i(ceil(player.position/CHUNK_SIZE))

func chunk_read(pos:Vector2i):
	# will read chunk data or generate new data
	if chunks.has(pos):
		return chunks[pos]
	else:
		var chunk_seed = hash(world_seed + str(pos))
		var data = ChunkData.new()
		#noise_map.seed = chunk_seed
		
		noise_map.offset = Vector3(pos.x*CHUNK_TILES,pos.y*CHUNK_TILES,0)
		data.noise_map = noise_map.get_image(CHUNK_TILES,CHUNK_TILES)
		data.generate(chunk_seed)
		chunk_write(pos,data)
		return data

func chunk_write(pos:Vector2i,data:ChunkData):
	chunks[pos] = data

func chunk_id(pos:Vector2i):
	# serialises coordinates for use as string
	return str(pos.x) + "_" + str(pos.y)

func pos_to_world(pos:Vector2i):
	# gets chunk positions based off of player position
	return pos*CHUNK_SIZE-Vector2i(CHUNK_SIZE/2.0,CHUNK_SIZE/2.0)

func load_chunk(pos):
	# will create a new chunk or reload an existing chunk
	var current = $Chunk.get_node_or_null(chunk_id(pos))
	if current == null:
		var inst = CHUNK.instantiate()
		inst.name = chunk_id(pos)
		inst.pos = pos
		inst.position = pos_to_world(pos)
		inst.load_data(chunk_read(pos))
		$Chunk.add_child(inst)
	else:
		current.load_data(chunk_read(pos))

func get_chunk(pos):
	return $Chunk.get_node_or_null(chunk_id(pos))

func unload_chunk(pos):
	var chunk = $Chunk.get_node_or_null(chunk_id(pos))
	if chunk != null:
		chunk.queue_free()
		return true
	return false


func _on_print_pressed():
	print(chunks)

func _on_reload_pressed():
	chunks = {}
	update_chunks()

func _on_render_value_changed(value):
	RENDER_DISTANCE = value
	update_chunks()

func _on_seed_text_submitted(new_text):
	world_seed = new_text
	chunks = {}
	update_chunks()
	$CanvasLayer/Seed.release_focus()

func generate():
	world_seed = str(randi() % 999999)
	$CanvasLayer/Seed.text = str(world_seed)

func _on_new_pressed():
	generate()
	chunks = {}
	update_chunks()


func _on_save_pressed():
	$CanvasLayer/Save2.popup_centered()

func _on_load_pressed():
	$CanvasLayer/Load2.popup_centered()


func _on_save_2_file_selected(path):
	var f = FileAccess.open(path,FileAccess.WRITE)
	print(FileAccess.get_open_error())
	var format_chunk = {}
	for i in chunks.keys():
		format_chunk[i] = chunks[i].serialize()
	f.store_var([world_seed,format_chunk])

func _on_load_2_file_selected(path):
	var f = FileAccess.open(path,FileAccess.READ)
	var data = f.get_var()
	
	world_seed = data[0]
	$CanvasLayer/Seed.text = str(world_seed)
	
	chunks = {}
	for i in data[1].keys():
		chunks[i] = ChunkData.new()
		chunks[i].deserialize(data[1][i])
	update_chunks()
