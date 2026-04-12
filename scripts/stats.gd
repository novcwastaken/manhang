extends Node

var save_path = "user://manhang.save"

var wins: int = 0
var losses: int = 0

var guess_successes: int = 0
var guess_misses: int = 0

var perfect_wins: int = 0
var perfect_losses: int = 0

func save_stats() -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	file.store_var(wins)
	file.store_var(losses)
	file.store_var(guess_successes)
	file.store_var(guess_misses)
	file.store_var(perfect_wins)
	file.store_var(perfect_losses)
	
	file.close()
	
func load_stats() -> void:
	if !FileAccess.file_exists(save_path):
		save_stats()
	var file = FileAccess.open(save_path, FileAccess.READ)

	wins = file.get_var(wins)
	losses = file.get_var(losses)
	guess_successes = file.get_var(guess_successes)
	guess_misses = file.get_var(guess_misses)
	perfect_wins = file.get_var(perfect_wins)
	perfect_losses = file.get_var(perfect_losses)

	file.close()
