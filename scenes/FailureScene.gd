extends Node2D

signal feedback_failure_closed

func _on_button_pressed() -> void:
	emit_signal("feedback_failure_closed")
