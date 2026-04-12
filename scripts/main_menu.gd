extends Control

const MAIN_MENU_TITLE = "GOON GURB v1.0"

var current_e_press_count: int = 0
var current_c_press_count: int = 0

@export var is_flashbang_in_progress: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	init_main_menu()
	Stats.load_stats()

func _process(_delta: float) -> void:
	$DebugLabel.text = """
		FLASHBANG IN PROGRESS: %s
		E PRESS COUNT: %d
		C PRESS COUNT: %d
		CURRENT ANIMATION: %s
	""".dedent().strip_edges() % [is_flashbang_in_progress, current_e_press_count, current_c_press_count, $AnimationPlayer.current_animation]

	if current_e_press_count == 3 && current_c_press_count == 3:
		$AnimationPlayer.play("flashbang")
		current_e_press_count = 0
		current_c_press_count = 0

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("nothing") && !is_flashbang_in_progress:
		current_e_press_count += 1
		if current_e_press_count > 3:
			current_e_press_count = 0
			current_c_press_count = 0
	if Input.is_action_just_pressed("nothing_diff_keybind") && !is_flashbang_in_progress:
		current_c_press_count += 1
		if current_c_press_count > 3:
			current_e_press_count = 0
			current_c_press_count = 0

func init_main_menu() -> void:
	$Background/MenuItemPanel/Credits.visible = false
	$Background/MenuItemPanel/Stats.visible = false
	$Background/MenuItemPanel/Manual.visible = false
	
	$Background/MenuItemPanel/Main.visible = true
	$Background/TitleLabel.text = MAIN_MENU_TITLE
	$Background/MenuItemPanel/Main.get_child(0).grab_focus()

func format_with_commas(value: Variant) -> String:
	var str_val = str(value)
	var regex = RegEx.new()
	
	regex.compile("(?<=\\d)(?=(\\d{3})+(?!\\d))")
	
	return regex.sub(str_val, ",", true)

func _on_manhang_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_exit_button_pressed() -> void:
	Stats.save_stats()
	get_tree().quit()

func _on_credits_button_pressed() -> void:
	$Background/MenuItemPanel/Credits.visible = true
	$Background/MenuItemPanel/Main.visible = false
	$Background/MenuItemPanel/Credits.get_child(0).grab_focus()
	$Background/TitleLabel.text = "CREDITS"
	
func _on_stats_button_pressed() -> void:
	$Background/MenuItemPanel/Stats.visible = true
	$Background/MenuItemPanel/Main.visible = false
	$Background/MenuItemPanel/Stats.get_child(0).grab_focus()
	$Background/TitleLabel.text = "STATISTICS"
	$Background/MenuItemPanel/Stats/Label.text = """
		* WINS: %s
		* LOSSES: %s

		* SUCCESSFUL GUESSES: %s
		* MISSES: %s

		* PERFECT WINS: %s
		* (IM)PERFECT LOSSES: %s
	""".dedent().strip_edges() % [format_with_commas(Stats.wins), format_with_commas(Stats.losses), format_with_commas(Stats.guess_successes), format_with_commas(Stats.guess_misses), format_with_commas(Stats.perfect_wins), format_with_commas(Stats.perfect_losses)]
	
func _on_manual_button_pressed() -> void:
	$Background/MenuItemPanel/Manual.visible = true
	$Background/MenuItemPanel/Main.visible = false
	$Background/MenuItemPanel/Manual.get_child(0).grab_focus()
	$Background/TitleLabel.text = "MANUAL"

func _on_credits_back_button_pressed() -> void:
	init_main_menu()
	$Background/MenuItemPanel/Main/CreditsButton.grab_focus()

func _on_manual_back_button_pressed() -> void:
	init_main_menu()
	$Background/MenuItemPanel/Main/ManualButton.grab_focus()

func _on_stats_back_button_pressed() -> void:
	init_main_menu()
	$Background/MenuItemPanel/Main/StatisticsButton.grab_focus()
