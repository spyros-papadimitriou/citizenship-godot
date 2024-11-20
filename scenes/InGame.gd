extends Node2D

const facility_scene = preload("res://scenes/FacilityScene.tscn")
const candidate_location_scene = preload("res://scenes/CandidateLocationScene.tscn")

const FACILITIES_GROUP = "facilities_group"
const CANDIDATE_LOCATIONS_GROUP = "candidate_locations_group"

@onready var communicator = $Communicator
@onready var title = $GridContainer/PanelLeft/VBoxContainerLeft/Title
@onready var description = $GridContainer/PanelRight/VBoxContainerRight/Description

@onready var popup_facilities = $PopupFacilities
@onready var popup_facilites_panel = $PopupFacilities/Panel
@onready var facilities_container = $PopupFacilities/Panel/VBoxContainer

@onready var popup_candidate_locations = $PopupCandidateLocations
@onready var popup_candidate_locations_panel = $PopupCandidateLocations/Panel
@onready var candidate_locations_container = $PopupCandidateLocations/Panel/VBoxContainer

@onready var popup_npc = $PopupNpc
@onready var popup_npc_container = $PopupNpc/Panel/VBoxContainer
@onready var label_facility = $PopupNpc/Panel/LabelFacility
@onready var label_npc = $PopupNpc/Panel/VBoxContainer/LabelNpc
@onready var label_clue = $PopupNpc/Panel/VBoxContainer/LabelClue

@onready var button_candidate_locations = $Panel/HBoxContainer/ButtonCandidateLocations
@onready var button_facilities = $Panel/HBoxContainer/ButtonFacilities
@onready var button_computer = $Panel/HBoxContainer/ButtonComputer

@onready var lightbox = $ColorRect
@onready var button_close_npc = $PopupNpc/Panel/ButtonCloseNpc

var button_close_candidate_locations: Button
var button_close_facilities: Button

func _ready():	
	communicator.retrieve_game_current_status(Globals.game_id)
	
func show_current_status(game_current_status: GameCurrentStatus):
	lightbox.visible = false
	
	button_computer.disabled = !game_current_status.last
	button_candidate_locations.disabled = !button_computer.disabled
	button_facilities.disabled = !button_computer.disabled
	
	var facilities = get_tree().get_nodes_in_group(FACILITIES_GROUP)
	for f in facilities:
		f.remove_from_group(FACILITIES_GROUP)
		facilities_container.remove_child(f)
	var candidate_locations = get_tree().get_nodes_in_group(CANDIDATE_LOCATIONS_GROUP)
	for cl in candidate_locations:
		cl.remove_from_group(CANDIDATE_LOCATIONS_GROUP)
		candidate_locations_container.remove_child(cl)
	
	create_title_text()
	description.text = game_current_status.current_location.description
		
	var position_x: float = popup_facilities.size.x / 2 - 100
	var i: int = 0
	for facility in game_current_status.facilities:
		i = i + 1
		
		var facility_scene_instance = facility_scene.instantiate()
		facility_scene_instance.add_to_group(FACILITIES_GROUP)
		facility_scene_instance.position = Vector2(position_x, (i - 1) * (50 + 10) + 80)
		facilities_container.add_child(facility_scene_instance)
		facility_scene_instance.set_facility(facility)
		facility_scene_instance.connect("facility_selected", Callable(self, "select_facility"))
	popup_facilites_panel.size = Vector2(300, (i + 2) * (50 + 10))
	popup_facilities.size.y = popup_facilites_panel.size.y + 50
	button_close_facilities = Button.new()
	button_close_facilities.size = Vector2(200, 50)
	button_close_facilities.text = "Κλείσιμο"
	button_close_facilities.add_to_group(FACILITIES_GROUP)
	button_close_facilities.custom_minimum_size = Vector2(260, 50)
	button_close_facilities.connect("pressed", Callable(self, "_on_Button_CloseFacilities_pressed"))
	facilities_container.add_child(button_close_facilities)

	i = 0
	for candidate_location in game_current_status.candidate_locations:
		i = i + 1
		
		var candidate_location_scene_instance = candidate_location_scene.instantiate()
		candidate_location_scene_instance.add_to_group(CANDIDATE_LOCATIONS_GROUP)
		#candidate_location_scene_instance.position = Vector2(position_x, (i - 1) * (50 + 10) + 80)
		candidate_locations_container.add_child(candidate_location_scene_instance)
		candidate_location_scene_instance.set_location(candidate_location)
		candidate_location_scene_instance.connect("location_selected", Callable(self, "select_location"))
	popup_candidate_locations_panel.size = Vector2(300, (i + 2) * (50 + 10))
	popup_candidate_locations.size.y = popup_candidate_locations_panel.size.y + 50
	button_close_candidate_locations = Button.new()
	button_close_candidate_locations.text = "Κλείσιμο"
	button_close_candidate_locations.custom_minimum_size= Vector2(260, 50)
	button_close_candidate_locations.add_to_group(CANDIDATE_LOCATIONS_GROUP)
	button_close_candidate_locations.connect("pressed", Callable(self, "_on_Button_CloseCandidateLocations_pressed"))
	candidate_locations_container.add_child(button_close_candidate_locations)

func _on_ButtonFacilities_pressed():
	popup_candidate_locations.hide()
	if popup_facilities.visible:
		button_close_facilities.release_focus()
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
	popup_facilities.hide()
	
	label_facility.text = facility.name
	label_npc.text = facility.npcName
	label_clue.text = facility.clue
	
	communicator.go_to_facility(Globals.game_id, facility.id)

func select_location(location: Location):
	communicator.go_to_location(Globals.game_id, location.id);
	popup_candidate_locations.hide()

func _on_ButtonMainMenu_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenuScene.tscn")

func _on_Button_CloseCandidateLocations_pressed():
	button_candidate_locations.release_focus()
	popup_candidate_locations.hide()
	close_lightbox()
	
func _on_Button_CloseFacilities_pressed():
	button_facilities.release_focus()
	popup_facilities.hide()
	close_lightbox()

func create_title_text():
	var title_text: String = "Παιχνίδι #" + str(Globals.game_id)
	title_text += "\nΤρέχουσα περιοχή: " + Globals.game_status.current_location.name
	if Globals.game_status.current_facility != null:
		title_text += "\nΤρέχον μέρος: " + Globals.game_status.current_facility.name
	
	if Globals.game_status.lost:
		title_text += "\n\nΦαίνεται οτι έχεις μεταβεί σε άλλη περιοχή από εκείνη όπου βρίσκεται ο ύποπτος. Δεν υπάρχει κάτι το αξιοσημείωτο εδώ για την αναζήτησή σου."
	elif Globals.game_status.last:
		title_text += "\n\nΟ ύποπτος βρίσκεται κάπου εδώ!\nΠάτα στην 'Αναζήτηση ατόμων' για να εκδώσει ο Δήμαρχος επίσημο χαρτί για τον εντοπισμό του υπόπτου και την ενσωμάτωσή του σε ειδικό εκπαιδευτικό πρόγραμμα για βελτίωση της αστικής του συνείδησης."
		title_text += "\n\nΠροσοχή! Αν επιλέξεις λάθος άτομο, ο ύποπτος θα ξεφύγει και η αποστολή θα ακυρωθεί!";
	title.text = title_text

func update_current_facility(facility: Facility):
	Globals.game_status.current_facility = facility
	lightbox.visible = true
	popup_npc.show()
	create_title_text()

func _on_ButtonComputer_pressed():
	get_tree().change_scene_to_file("res://scenes/SearchScene.tscn")

func _on_popup_facilities_popup_hide() -> void:
	button_facilities.release_focus()
	if !popup_npc.visible:
		close_lightbox()

func _on_popup_candidate_locations_popup_hide() -> void:
	button_candidate_locations.release_focus()
	close_lightbox()

func _on_popup_npc_popup_hide() -> void:
	close_lightbox()
	
func close_lightbox():
	lightbox.visible = false;


func _on_button_close_npc_pressed() -> void:
	popup_npc.hide()
	close_lightbox()
