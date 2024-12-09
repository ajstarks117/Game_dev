extends Node2D


@onready var tilescene = preload("res://scene/tile.tscn")
@onready var score_label = $score 
@onready var lives_label = $Lives_LABEL
@onready var game_over_label = $GameOverLabel
@onready var music_player = $BEAT

var beat_sequence = []  # Holds the list of beats
var current_beat_index = 0  # Tracks which beat to play next


var screen_width = 1024
var screen_height = 768
var column_count = 4
var column_width = screen_width / column_count

var current_problem = ""
var correct_answer = 0
var possible_answer = []
var correct_answer_spawned = false

var score = 0
var Lives = 3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()
	generate_problem()
	update_score()
	
	beat_sequence = [
		load("res://assets/MUSIC/Timeline 1.mp3"),
		load("res://assets/MUSIC/beat_time2.mp3"),
	]
	current_beat_index = 0
	
	
func play_next_beat():
	if current_beat_index < beat_sequence.size():
		music_player.stream = beat_sequence[current_beat_index]
		music_player.play()
		current_beat_index += 1
	else:
		current_beat_index = 0
		play_next_beat()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	if not correct_answer_spawned:
		spawn_tile(correct_answer)
		correct_answer_spawned = true
		
	else:
		if possible_answer.size() > 0:
			var random_answer = possible_answer.pop_back()
			spawn_tile(random_answer)
			
	if correct_answer_spawned and possible_answer.is_empty():
		$Timer.stop()
		await(get_tree().create_timer(2))
		generate_problem()
		$Timer.start()
		
func spawn_tile(answer: int) -> void:
	var tile_instance = tilescene.instantiate()
	
	var column_index = randi() % column_count

	tile_instance.position = Vector2(column_index * column_width + column_width / 2, -50)
	add_child(tile_instance)
	
	tile_instance.set_answer(answer)
	tile_instance.set_random_color()

		
func generate_problem():
	var a = randi() % 10 
	var b = randi() % 10
	var operation = ["+", "-", "*"].pick_random()
	
	match operation:
		"+":
			current_problem = str(a, " + ", b)
			correct_answer = a + b
		"-":
			a = max(a, b)
			b = min(a, b)
			current_problem = str(a, " - ", b)
			correct_answer = a - b
		"*":
			current_problem = str(a, " × ", b)  # Display multiplication with ×
			correct_answer = a * b
	
	possible_answer = [correct_answer]
	while possible_answer.size() < 4: #considering 4 tiles
		var random_wrong_answer = randi() % 100
		if random_wrong_answer != correct_answer and not random_wrong_answer in possible_answer:
			possible_answer.append(random_wrong_answer)
			
		possible_answer.shuffle()
		
		$questions.text = current_problem
		correct_answer_spawned = false

func update_score() -> void:
	score_label.text = "Score: " + str(score)

func increase_score() -> void:
	score += 10
	update_score()

func update_lives_label():
	lives_label.text = "Lives: " + str(Lives)

func update_lives(is_correct: bool):
	if not is_correct:
		Lives -= 0.5

		
	if Lives <= 0:
		game_over()
	
	update_lives_label()
	
	
func game_over():
	game_over_label.text = "Game Over!"
	$Timer.stop()
	get_tree().paused = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	pass
	
