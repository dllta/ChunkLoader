extends CharacterBody2D

const friction = 300
const max_speed = 250
const acceleration = 700

var zoomed = true

func _process(_delta):
	# handle zooming for testing
	if Input.is_action_just_pressed("cam_toggle"):
		zoomed = !zoomed
		if zoomed:
			create_tween().tween_property($Camera2D, "zoom", Vector2(2, 2), 0.2)
		else:
			create_tween().tween_property($Camera2D, "zoom", Vector2(0.5, 0.5), 0.2)

func _physics_process(delta):
	var input = get_input()
	
	apply_movement(input, delta)
	apply_friction(input, delta)
	
	move_and_slide()

func apply_movement(input_vector, delta):
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector*max_speed, acceleration * delta)

func apply_friction(input_vector, delta):
	if input_vector == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func get_input():
	var axis = Vector2(
		Input.get_axis("player_left", "player_right"),
		Input.get_axis("player_up", "player_down"))
	return axis.normalized()
