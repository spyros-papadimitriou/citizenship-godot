extends Node2D

signal feedback_success_closed

func _on_button_pressed() -> void:
	emit_signal("feedback_success_closed")
