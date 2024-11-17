extends Node2D

signal person_selected(location)

onready var label = $GridContainer/Label
onready var button = $GridContainer/Button

var person: Person setget set_person

func _ready():
	pass
	
func set_person(_person):
	person = _person
	if person != null:
		label.text = person.given_name + " " + person.family_name


func _on_Button_pressed():
	emit_signal("person_selected", person)