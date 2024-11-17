extends Node2D

const facility_scene = preload("res://scenes/FacilityScene.tscn")
const candidate_location_scene = preload("res://scenes/CandidateLocationScene.tscn")

const FACILITIES_GROUP = "facilities_group"
const CANDIDATE_LOCATIONS_GROUP = "candidate_locations_group"

onready var communicator = $Communicator
onready var title = $GridContainer/VBoxContainerLeft/Title
onready var description = $GridContainer/VBoxContainerRight/Description

onready var popup_facilities = $PopupFacilities
onready var popup_candidate_locations = $PopupCandidateLocations
onready var popup_npc = $PopupNpc
onready var label_facility = $PopupNpc/LabelFacility
onready var label_npc = $PopupNpc/LabelNpc
onready var label_clue = $PopupNpc/LabelClue

onready var button_candidate_locations = $HBoxContainer/ButtonCandidateLocations
onready var button_facilities = $HBoxContainer/ButtonFacilities
onready var button_computer = $HBoxContainer/ButtonComputer

onready var label_left = $GridContainer/LabelLeft
onready var label_right = $GridContainer/LabelRight
onready var lightbox = $ColorRect
onready var button_close = $ButtonClose

func _ready():
	label_right.text = "Game #" + str(Globals.game_id)
		
	communicator.connect("game_current_status_retrieved", self, "show_current_status")
	communicator.connect("went_to_facility", self, "update_current_facility")
	communicator.retrieve_game_current_status(Globals.game_id)
	
func show_current_status(game_current_status: GameCurrentStatus):
	lightbox.visible = false
	button_close.visible = false
	
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
	button_computer.disabled = !game_current_status.last
	button_candidate_locations.disabled = !button_computer.disabled
	button_facilities.disabled = !button_computer.disabled
		
	var i: int = 0
	for facility in game_current_status.facilities:
		i = i + 1
		
		var facility_scene_instance = facility_scene.instance()
		facility_scene_instance.add_to_group(FACILITIES_GROUP)
		facility_scene_instance.position = Vector2(0, (i - 1) * (50 + 10) + 80)
		popup_facilities.add_child(facility_scene_instance)
		facility_scene_instance.set_facility(facility)
		facility_scene_instance.connect("facility_selected", self, "select_facility")

	i = 0
	for candidate_location in game_current_status.candidate_locations:
		i = i + 1
		
		var candidate_location_scene_instance = candidate_location_scene.instance()
		candidate_location_scene_instance.add_to_group(CANDIDATE_LOCATIONS_GROUP)
		candidate_location_scene_instance.position = Vector2(0, (i - 1) * (50 + 10) + 80)
		popup_candidate_locations.add_child(candidate_location_scene_instance)
		candidate_location_scene_instance.set_location(candidate_location)
		candidate_location_scene_instance.connect("location_selected", self, "select_location")

func _on_ButtonFacilities_pressed():
	popup_candidate_locations.hide()
	if popup_facilities.visible:
		button_close.visible = false
		popup_facilities.hide()
	else:
		lightbox.visible = true
		button_close.visible = true
		button_close.rect_position = Vector2(popup_facilities.rect_position.x, popup_facilities.rect_position.y + 6 * 60)
		popup_facilities.show()

func _on_ButtonCandidateLocations_pressed():
	popup_facilities.hide()
	if popup_candidate_locations.visible:
		popup_candidate_locations.hide()
	else:
		lightbox.visible = true
		button_close.visible = true
		button_close.rect_position = Vector2(popup_facilities.rect_position.x, popup_facilities.rect_position.y + 6 * 60)
		popup_candidate_locations.show()

func select_facility(facility: Facility):
	communicator.go_to_facility(Globals.game_id, facility.id)
	popup_facilities.hide()
	
	label_facility.text = facility.name
	label_npc.text = facility.npcName
	label_clue.text = facility.clue
	popup_npc.show()

func select_location(location: Location):
	communicator.go_to_location(Globals.game_id, location.id);
	button_close.visible = false
	popup_candidate_locations.hide()

func _on_ButtonCloseNpc_pressed():
	popup_npc.hide()

func _on_ButtonMainMenu_pressed():
	get_tree().change_scene("res://scenes/MainMenuScene.tscn")

func _on_ButtonClose_pressed():
	lightbox.visible = false
	button_close.visible = false
	popup_facilities.hide()
	popup_candidate_locations.hide()
	popup_npc.hide()

func create_title_text():
	var title_text: String = ""
	title_text += "Τρεχουσα περιοχη: " + Globals.game_status.current_location.name
	if Globals.game_status.current_facility != null:
		title_text += "\nΤρέχον μερος: " + Globals.game_status.current_facility.name
	
	if Globals.game_status.lost:
		title_text += "\n\nΦαίνεται οτι εχεις μεταβει σε αλλη περιοχη. Δεν υπαρχει κατι ύποπτο εδω."
	elif Globals.game_status.last:
		title_text += "\n\nΟ ύποπτος βρίσκεται καπου εδω!\nΠατα στην 'Αναζητηση ατομων για να εκδωσει ο Δημαρχος επίσημο χαρτί για τον εντοπισμο του υποπτου και την ενσωματωση του σε ειδικο εκπαιδευτικο προγραμμα για βελτιωση της αστικής συνειδησης."	
	title.text = title_text

func update_current_facility(facility: Facility):
	Globals.game_status.current_facility = facility
	create_title_text()


func _on_ButtonComputer_pressed():
	get_tree().change_scene("res://scenes/SearchScene.tscn")
