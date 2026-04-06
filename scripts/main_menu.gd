extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_on_credits_back_button_pressed() # yes, I just did that
	#$Background/MenuItemPanel/Main.get_child(0).grab_focus()

func _on_manhang_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_credits_button_pressed() -> void:
	$Background/MenuItemPanel/Credits.visible = true
	$Background/MenuItemPanel/Main.visible = false
	$Background/MenuItemPanel/Credits.get_child(0).grab_focus()

func _on_credits_back_button_pressed() -> void:
	$Background/MenuItemPanel/Credits.visible = false
	$Background/MenuItemPanel/Main.visible = true
	$Background/MenuItemPanel/Main.get_child(0).grab_focus()
