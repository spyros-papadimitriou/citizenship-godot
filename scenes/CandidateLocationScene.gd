extends Node2D

signal location_selected(location)

onready var button = $Button

var location: Location setget set_location

func _ready():
	pass
	
func set_location(_location):
	location = _location
	if location != null:
		button.text = location.name


func _on_Button_pressed():
	emit_signal("location_selected", location)
