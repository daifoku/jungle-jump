extends Node

var num_levels: int = 2
var current_level: int = 0
var game_scene: String = "res://main/main.tscn"
var title_screen: String = "res://ui/title_scene.tscn"


func restart() -> void:
	current_level = 0
	get_tree().change_scene_to_file(title_screen)

func next_level() -> void:
	current_level += 1
	if current_level <= num_levels:
		get_tree().change_scene_to_file(game_scene)
