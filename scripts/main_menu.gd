extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Background/MenuItemPanel/VBoxContainer.get_child(0).grab_focus()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_manhang_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
