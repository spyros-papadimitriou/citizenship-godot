extends Control

signal facility_selected(facility)

@onready var button = $Button

var facility: Facility: set = set_facility

func _ready():
	pass

	
func set_facility(_facility):
	facility = _facility
	if facility != null:
		button.text = facility.name


func _on_Button_pressed():
	emit_signal("facility_selected", facility)
