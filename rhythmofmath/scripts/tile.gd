extends Area2D

@onready var tile_visual = $Sprite2D
@onready var particle_effect = $stars
@onready var camera = get_tree().root.get_camera_2d()  # Get the main camera for shaking
var answer = 0
var speed =250
var shake_duration = 0.3  # Duration of the screen shake
var shake_intensity = 10  # Intensity of the screen shake
var main_scene = null

var color_palette = [
	preload("res://assets/red.jpg"),
	preload("res://assets/orange.jpg"),
	preload("res://assets/yellow.jpg"),
	preload("res://assets/green.jpg"),
	preload("res://assets/blue.jpg"),
]

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_scene = get_tree().current_scene

func set_random_color():
	var random_index = randi() % color_palette.size()
	tile_visual.texture = color_palette[random_index]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += speed * delta
	
	if position.y > 800:
		if answer == get_parent().correct_answer:
			print("Correct answer missed!")
			get_parent().generate_problem()
		queue_free()



func set_answer(value):
	answer = value
	$Label.text = str(answer)
	

func play_incorrect_sound():
	var incorrect_sound = $wrong
	if incorrect_sound and not incorrect_sound.playing:
		incorrect_sound.play()

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if answer == get_parent().correct_answer:
			print("Correct!")
			get_parent().generate_problem()
			get_parent().play_next_beat()
			trigger_particles()
			queue_free()
			if main_scene:
				main_scene.increase_score()
				

		else:
			print("Wrong!")
			get_parent().update_lives(false)
			play_incorrect_sound()
			shake_screen()
			
			
func trigger_particles() -> void:
	# Update the particle color dynamically
	particle_effect.emitting = true
	
	await(get_tree().create_timer(particle_effect.lifetime))
	particle_effect.emitting = false
	
func shake_screen():
	var original_offset = camera.offset
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = shake_duration
	add_child(timer)
	
	timer.connect("timeout", Callable(self, "_stop_shake").bind(original_offset))
	timer.start()
	
	var elapsed_time = 0.0
	
	
	while elapsed_time < shake_duration:
		var random_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
			)
		camera.offset = original_offset + random_offset
		elapsed_time += get_process_delta_time()
		await(get_tree())


func _stop_shake(original_offset: Vector2):
		camera.offset = original_offset
