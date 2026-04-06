extends Control

const PICTURES: Array[String] = ['''
  +---+
  |   |
      |
      |
      |
      |
=========''', '''
  +---+
  |   |
  O   |
      |
      |
      |
=========''', '''
  +---+
  |   |
  O   |
  |   |
      |
      |
=========''', '''
  +---+
  |   |
  O   |
 /|   |
      |
      |
=========''', '''
  +---+
  |   |
  O   |
 /|\\  |
      |
      |
=========''', '''
  +---+
  |   |
  O   |
 /|\\  |
 /    |
      |
=========''', '''
  +---+
  |   |
  X   |
 /|\\  |
 / \\  |
      |
=========''']

const WIN_PICTURE: String = '''
  +---+
      |
      |
 :)   |
 /|\\  |
 / \\  |
========='''

const VALID_LETTERS: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var WORDS: Array[String]

const LETTER_BUFFER_BB_PREFIX: String = "[pulse freq=2.0 color=#ffffff00 ease=-1000.0]"

var current_word: String
var letter_buffer: String = ""
var missed_letters: Array[String]

var guess_input_enabled: bool = true
var won: bool = false

var is_paused: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	load_words()

	current_word = WORDS[randi_range(0, WORDS.size() - 1)]
	print("Word: " + current_word)

	$GameOverScreen/MainScreen/RantLabel.text = "A critical failure has occurred (you). I'm not collecting any error info, fuck you. What am I to you, a charity? Just get better at the game and don't flail around guessing letters like a coked up chimpanzee. I'd have more faith in a lobotomized sunfish than you to figure out that the word was %s. Sincerely, eat shit." % current_word.to_upper()

	$GameThings/WordLabel.text = "_".repeat(len(current_word))
	$GameThings/ArtLabel.text = PICTURES[0]

	$GameThings.visible = true
	$BufferThings.visible = false
	$GameOverScreen.visible = false
	$WinThings.visible = false
	$PauseMenu.visible = false

	update_buffer_displays()
	update_misses_displays()

func _input(event: InputEvent) -> void:
	if guess_input_enabled:
		# Buffer input
		if letter_input_is_valid(event):
			var input = event.as_text().to_upper()

			if input in missed_letters:
				play_sfx_with_random_pitch($SFX/BufferAlreadyGuessed)
				$GameThings/MissesLabel.label_settings.font_color = Color(255, 255, 0)
				await get_tree().create_timer(0.1).timeout
				$GameThings/MissesLabel.label_settings.font_color = Color(255, 0, 0)
			elif input in $GameThings/WordLabel.text:
				play_sfx_with_random_pitch($SFX/BufferAlreadyGuessed)
				$GameThings/WordLabel.label_settings.font_color = Color(255, 255, 0)
				await get_tree().create_timer(0.1).timeout
				$GameThings/WordLabel.label_settings.font_color = Color(255, 255, 255)
			else:
				letter_buffer = input
				update_buffer_displays()
				play_sfx_with_random_pitch($SFX/BufferSelect)

		# Buffer actions
		if Input.is_action_just_pressed("buffer_guess") && letter_buffer != "":
			guess_letter(letter_buffer.to_upper())
			letter_buffer = ""
			update_buffer_displays()

			if missed_letters.size() >= PICTURES.size() - 1:
				game_over()

		if Input.is_action_just_pressed("buffer_cancel"):
			letter_buffer = ""
			update_buffer_displays()
			play_sfx_with_random_pitch($SFX/BufferCancel)

	# Game over
	if $GameOverScreen/MainScreen.visible || won:
		if Input.is_action_just_pressed("play_again"):
			get_tree().reload_current_scene()
		if Input.is_action_just_pressed("escape"):
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

	# Pause
	if Input.is_action_just_pressed("escape") && !$GameOverScreen/MainScreen.visible && !won:
		is_paused = true
		guess_input_enabled = false
		
		$GameThings.visible = false
		$BufferThings.visible = false

		$PauseMenu.visible = true
		$PauseMenu/MenuItemPanel/VBoxContainer.get_child(0).grab_focus()

func letter_input_is_valid(event: InputEvent) -> bool:
	if event is not InputEventKey: return false
	if event.echo: return false
	if !event.pressed: return false
	if event.as_text().to_upper() not in VALID_LETTERS: return false
	return true

func guess_letter(letter: String) -> bool:
	var is_match: bool = false

	for i in len(current_word):
		var character: String = current_word[i]
		if character == letter:
			$GameThings/WordLabel.text[i] = character
			is_match = true
			if "_" in $GameThings/WordLabel.text: play_sfx_with_random_pitch($SFX/BufferHit)

	if !is_match && letter not in missed_letters:
		missed_letters.append(letter)
		missed_letters.sort()
		update_misses_displays()
		$AnimationPlayer.play("miss_flash")
		if missed_letters.size() < PICTURES.size(): play_sfx_with_random_pitch($SFX/BufferMiss)

	if $GameThings/WordLabel.text.to_upper() == current_word.to_upper():
		won = true
		game_won()
		play_sfx_with_random_pitch($SFX/Win)

	return is_match

func update_buffer_displays() -> void:
	if letter_buffer == "":
		$BufferThings/BufferLabel.text = letter_buffer
		$BufferThings.visible = false
		if !won: $GameThings/BufferLetterHint.visible = true
	else:
		$BufferThings/BufferLabel.text = LETTER_BUFFER_BB_PREFIX + letter_buffer
		$BufferThings.visible = true
		$GameThings/BufferLetterHint.visible = false

func update_misses_displays() -> void:
	$GameThings/MissesLabel.text = ", ".join(missed_letters)
	if missed_letters.size() <= PICTURES.size() - 1 && missed_letters.size() > 0: $GameThings/ArtLabel.text = PICTURES[missed_letters.size()]

func game_over() -> void:
	guess_input_enabled = false
	print("yuo ded lol")

	$AnimationPlayer.play("game_over")
	play_sfx_with_random_pitch($SFX/BufferMissFinal)

func game_won() -> void:
	guess_input_enabled = false
	$GameThings/ArtLabel.text = WIN_PICTURE
	$GameThings/BufferLetterHint.visible = false
	$BufferThings.visible = false
	$WinThings.visible = true

func play_sfx_with_random_pitch(stream: AudioStreamPlayer) -> void:
	stream.pitch_scale = randf_range(0.8, 1.2)
	stream.play()

func load_words() -> void:
	var file = FileAccess.open("res://assets/word_bank.txt", FileAccess.READ)
	var content = file.get_as_text()

	for word in content.split(","):
		WORDS.append(word.strip_edges().to_upper())


func _on_pause_continue_button_pressed() -> void:
	is_paused = false
	guess_input_enabled = true

	$GameThings.visible = true

	var is_letter_buffer_empty: bool = letter_buffer == ""

	$BufferThings.visible = !is_letter_buffer_empty
	$GameThings/BufferLetterHint.visible = is_letter_buffer_empty

	$PauseMenu.visible = false

func _on_pause_new_game_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_pause_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_pause_continue_button_focus_exited() -> void:
	play_sfx_with_random_pitch($SFX/GameOverMainScreen)

func _on_pause_new_game_button_focus_exited() -> void:
	play_sfx_with_random_pitch($SFX/GameOverMainScreen)

func _on_pause_main_menu_button_focus_exited() -> void:
	play_sfx_with_random_pitch($SFX/GameOverMainScreen)
