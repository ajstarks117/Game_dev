extends Control


@onready var sprite: AnimatedSprite2D = $volume/AnimatedSprite2D
@onready var muted = false

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_volume_pressed() -> void:
	if muted:
		unmute()
	else:
		mute()


func mute():
	muted = true
	sprite.animation = "mute"
	print("muted")
	$AudioStreamPlayer2D.stop()

func unmute():
	muted = false
	sprite.animation = "unmute"
	print("unmuted")
	$AudioStreamPlayer2D.play()
