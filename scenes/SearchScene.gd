extends Node2D

const person_scene = preload("res://scenes/PersonScene.tscn")

onready var communicator = $Communicator
onready var left_column = $VBoxContainer/GridContainer/LeftColumn
onready var right_column = $VBoxContainer/GridContainer/RightColumn
onready var info_container = $VBoxContainer/GridContainer/RightColumn/Label
onready var button_catch = $HBoxContainer/ButtonCatch
onready var button_back = $HBoxContainer/ButtonBack

var selected_person: Person;

func _ready():
	communicator.connect("persons_retrieved", self, "show_persons")
	communicator.connect("person_caught", self, "show_feedback")
	communicator.retrieve_persons()	
	
func show_persons(persons: Array):
	var i: int = 0
	for person in persons:
		i = i + 1
		
		var person_scene_instance = person_scene.instance()
		person_scene_instance.position = Vector2(100, (i - 1) * (50 + 10))
		left_column.add_child(person_scene_instance)
		person_scene_instance.set_person(person)
		person_scene_instance.connect("person_selected", self, "show_person_info")

func show_person_info(person: Person):
	selected_person = person
	
	var info: String = ""
	info += "Ονοματεπωνυμο: " + person.given_name + " " + person.family_name
	info += " (id: " + str(person.id) + ")"
	info += "\n"
	for feature in person.features:
		info += feature.feature_name + ":"
		info += " " + feature.feature_value_name
		info += "\n"
	info_container.text = info
	
	button_catch.visible = Globals.game_status != null and Globals.game_status.last
	button_catch.visible = true
	button_catch.disabled = selected_person == null


func _on_ButtonCatch_pressed():
	communicator.catch_person(Globals.game_id, selected_person.id)

func _on_ButtonBack_pressed():
	get_tree().change_scene("res://scenes/InGame.tscn")
	
func show_feedback(feedback):
	if feedback.success:
		get_tree().change_scene("res://scenes/SuccessScene.tscn")
	else:
		get_tree().change_scene("res://scenes/FailureScene.tscn")
