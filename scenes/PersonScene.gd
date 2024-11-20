extends Control

signal person_selected(location)

@onready var label = $GridContainer/Label
@onready var button = $GridContainer/Button

var person: Person: set = set_person

func _ready():
	pass
	
func set_person(_person):
	person = _person
	if person != null:
		label.text = person.given_name + "\n" + person.family_name


func _on_Button_pressed():
	emit_signal("person_selected", person)
