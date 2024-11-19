extends Node2D

const facility_scene = preload("res://scenes/FacilityScene.tscn")
const candidate_location_scene = preload("res://scenes/CandidateLocationScene.tscn")

const FACILITIES_GROUP = "facilities_group"
const CANDIDATE_LOCATIONS_GROUP = "candidate_locations_group"

@onready var communicator = $Communicator
@onready var title = $GridContainer/VBoxContainerLeft/Panel/Title
@onready var description = $GridContainer/VBoxContainerRight/Panel/Description

@onready var popup_facilities = $PopupFacilities
@onready var popup_candidate_locations = $PopupCandidateLocations
@onready var popup_npc = $PopupNpc
@onready var label_facility = $PopupNpc/LabelFacility
@onready var label_npc = $PopupNpc/LabelNpc
@onready var label_clue = $PopupNpc/LabelClue

@onready var button_candidate_locations = $Panel/HBoxContainer/ButtonCandidateLocations
@onready var button_facilities = $Panel/HBoxContainer/ButtonFacilities
@onready var button_computer = $Panel/HBoxContainer/ButtonComputer

@onready var label_left = $LabelLeft
@onready var label_right = $LabelRight
@onready var lightbox = $ColorRect

var button_close_candidate_locations: Button
var button_close_facilities: Button
var button_close_npc: Button

func _ready():
	label_right.text = "Game #" + str(Globals.game_id)
		
	communicator.connect("game_current_status_retrieved", Callable(self, "show_current_status"))
	communicator.connect("went_to_facility", Callable(self, "update_current_facility"))
	communicator.retrieve_game_current_status(Globals.game_id)
	
func show_current_status(game_current_status: GameCurrentStatus):
	lightbox.visible = false
	
	button_computer.disabled = !game_current_status.last
	button_candidate_locations.disabled = !button_computer.disabled
	button_facilities.disabled = !button_computer.disabled
	
	var facilities = get_tree().get_nodes_in_group(FACILITIES_GROUP)
	for f in facilities:
		f.remove_from_group(FACILITIES_GROUP)
		popup_facilities.remove_child(f)
	var candidate_locations = get_tree().get_nodes_in_group(CANDIDATE_LOCATIONS_GROUP)
	for cl in candidate_locations:
		cl.remove_from_group(CANDIDATE_LOCATIONS_GROUP)
		popup_candidate_locations.remove_child(cl)
	
	create_title_text()
	description.text = game_current_status.current_location.description
		
	var position_x: float = popup_facilities.size.x / 2 - 100
	var i: int = 0
	for facility in game_current_status.facilities:
		i = i + 1
		
		var facility_scene_instance = facility_scene.instantiate()
		facility_scene_instance.add_to_group(FACILITIES_GROUP)
		facility_scene_instance.position = Vector2(position_x, (i - 1) * (50 + 10) + 80)
		popup_facilities.add_child(facility_scene_instance)
		facility_scene_instance.set_facility(facility)
		facility_scene_instance.connect("facility_selected", Callable(self, "select_facility"))
	button_close_facilities = Button.new()
	button_close_facilities.size = Vector2(200, 50)
	button_close_facilities.text = "Κλείσιμο"
	button_close_facilities.add_to_group(FACILITIES_GROUP)
	button_close_facilities.position = Vector2(position_x, i * (50 + 10) + 80)
	button_close_facilities.connect("pressed", Callable(self, "_on_Button_CloseFacilities_pressed"))
	popup_facilities.add_child(button_close_facilities)
	popup_facilities.size = Vector2(300, $PopupFacilities/LabelFacilities.size.y + i * (50 + 10) + 100)

	i = 0
	for candidate_location in game_current_status.candidate_locations:
		i = i + 1
		
		var candidate_location_scene_instance = candidate_location_scene.instantiate()
		candidate_location_scene_instance.add_to_group(CANDIDATE_LOCATIONS_GROUP)
		candidate_location_scene_instance.position = Vector2(position_x, (i - 1) * (50 + 10) + 80)
		popup_candidate_locations.add_child(candidate_location_scene_instance)
		candidate_location_scene_instance.set_location(candidate_location)
		candidate_location_scene_instance.connect("location_selected", Callable(self, "select_location"))
	button_close_candidate_locations = Button.new()
	button_close_candidate_locations.size = Vector2(200, 50)
	button_close_candidate_locations.text = "Κλείσιμο"
	button_close_candidate_locations.add_to_group(CANDIDATE_LOCATIONS_GROUP)
	button_close_candidate_locations.position = Vector2(position_x, i * (50 + 10) + 80)
	button_close_candidate_locations.connect("pressed", Callable(self, "_on_Button_CloseCandidateLocations_pressed"))
	popup_candidate_locations.add_child(button_close_candidate_locations)
	popup_candidate_locations.size = Vector2(300, $PopupCandidateLocations/LabelCandidateLocations.size.y + i * (50 + 10) + 100)

func _on_ButtonFacilities_pressed():
	popup_candidate_locations.hide()
	if popup_facilities.visible:
		popup_facilities.hide()
	else:
		lightbox.visible = true
		popup_facilities.show()

func _on_ButtonCandidateLocations_pressed():
	popup_candidate_locations.hide()
	if popup_candidate_locations.visible:
		popup_candidate_locations.hide()
	else:
		lightbox.visible = true
		popup_candidate_locations.show()

func select_facility(facility: Facility):
	communicator.go_to_facility(Globals.game_id, facility.id)
		
	label_facility.text = facility.name
	label_npc.text = facility.npcName
	label_clue.text = facility.clue
	
	button_close_npc = Button.new()
	button_close_npc.size = Vector2(200, 50)
	button_close_npc.text = "Κλείσιμο"
	button_close_npc.connect("pressed", Callable(self, "_on_ButtonCloseNpc_pressed"))
	button_close_npc.position = Vector2(popup_npc.size.x / 2 - 100, popup_npc.size.y - 50 - 20)
	popup_npc.add_child(button_close_npc)
	
	popup_npc.show()
	popup_facilities.hide()

func select_location(location: Location):
	communicator.go_to_location(Globals.game_id, location.id);
	popup_candidate_locations.hide()

func _on_ButtonCloseNpc_pressed():
	popup_npc.hide()
	close_lightbox()

func _on_ButtonMainMenu_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenuScene.tscn")

func _on_Button_CloseCandidateLocations_pressed():
	popup_candidate_locations.hide()
	close_lightbox()
	
func _on_Button_CloseFacilities_pressed():
	popup_facilities.hide()
	close_lightbox()

func create_title_text():
	var title_text: String = ""
	title_text += "Τρέχουσα περιοχή: " + Globals.game_status.current_location.name
	if Globals.game_status.current_facility != null:
		title_text += "\nΤρέχον μέρος: " + Globals.game_status.current_facility.name
	
	if Globals.game_status.lost:
		title_text += "\n\n\nΦαίνεται οτι έχεις μεταβεί σε άλλη περιοχή από εκείνη όπου βρίσκεται ο ύποπτος. Δεν υπάρχει κάτι το αξιοσημείωτο εδώ για την αναζήτησή σου."
	elif Globals.game_status.last:
		title_text += "\n\nΟ ύποπτος βρίσκεται κάπου εδώ!\nΠάτα στην 'Αναζήτηση ατόμων' για να εκδώσει ο Δήμαρχος επίσημο χαρτί για τον εντοπισμό του υπόπτου και την ενσωμάτωσή του σε ειδικό εκπαιδευτικό πρόγραμμα για βελτίωση της αστικής του συνείδησης."
		title_text += "\n\nΠροσοχή! Αν επιλέξεις λάθος άτομο, ο ύποπτος θα ξεφύγει και η αποστολή θα ακυρωθεί!";
	title.text = title_text

func update_current_facility(facility: Facility):
	Globals.game_status.current_facility = facility
	create_title_text()

func _on_ButtonComputer_pressed():
	get_tree().change_scene_to_file("res://scenes/SearchScene.tscn")

func _on_popup_facilities_popup_hide() -> void:
	if !popup_npc.visible:
		close_lightbox()

func _on_popup_candidate_locations_popup_hide() -> void:
	close_lightbox()

func _on_popup_npc_popup_hide() -> void:
	close_lightbox()
	
func close_lightbox():
	lightbox.visible = false;
