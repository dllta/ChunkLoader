extends Node2D

@export var pos:Vector2i = Vector2i.ZERO

@onready var world:Node = get_node("/root/World/")

var chunk_data:ChunkData

func _ready():
	# set scale to the chunk size
	$Sprite2D.scale = Vector2(world.CHUNK_SIZE/8,world.CHUNK_SIZE/8)

func load_data(new_data):
	# load new chunk data
	chunk_data = new_data
	update()

func update():
	# update the chunk visuals
	$Label.text = "Chunk" + str(pos) + "\n" + str(chunk_data)
	$Sprite2D.modulate = Color8(chunk_data.color[0],chunk_data.color[1],chunk_data.color[2],255)

func _on_number_pressed():
	# increments the number counter
	chunk_data.number += 1
	update()

func _on_color_pressed():
	# generates random color
	chunk_data.color = [randi()%255,randi()%255,randi()%255]
	update()
