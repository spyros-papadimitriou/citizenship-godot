extends Node2D

const person_scene = preload("res://scenes/PersonScene.tscn")

@onready var communicator = $Communicator
@onready var left_column = $GridContainer/PanelLeft/VBoxContainerLeft
@onready var right_column = $GridContainer/PanelRight/VBoxContainerRight
@onready var info_container = $GridContainer/PanelRight/VBoxContainerRight/LabelInfo
@onready var button_catch = $PanelBottomMenu/HBoxContainer/ButtonCatch
@onready var button_back = $PanelBottomMenu/HBoxContainer/ButtonBack
@onready var lightbox = $Lightbox
@onready var popup_success = $PopupSuccess
@onready var popup_failure = $PopupFailure
@onready var success_scene = $PopupSuccess/SuccessScene
@onready var failure_scene = $PopupFailure/FailureScene

var selected_person: Person;

func _ready():
	communicator.retrieve_persons()	
	
func show_persons(persons: Array):
	var i: int = 0
	for person in persons:
		i = i + 1
		
		var person_scene_instance = person_scene.instantiate()
		left_column.add_child(person_scene_instance)
		person_scene_instance.set_person(person)
		person_scene_instance.connect("person_selected", Callable(self, "show_person_info"))

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
	get_tree().change_scene_to_file("res://scenes/InGame.tscn")
	
func show_feedback(feedback):
	lightbox.visible = true
	if feedback.success:
		popup_success.show()
	else:
		popup_failure.show()

func close_success_feedback():
	call_deferred("go_to_main_menu")

func close_failure_feedback():
	call_deferred("go_to_main_menu")

func _on_popup_success_popup_hide() -> void:
	go_to_main_menu()

func _on_popup_failure_popup_hide() -> void:
	go_to_main_menu()

func go_to_main_menu():
	Globals.game_id = 0
	get_tree().change_scene_to_file("res://scenes/MainMenuScene.tscn")
