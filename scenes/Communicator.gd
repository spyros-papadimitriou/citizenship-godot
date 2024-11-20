extends Node2D

signal game_created(game_id)
signal game_retrieved(mission)
signal game_current_status_retrieved(game_current_status)
signal features_retrieved(features)
signal persons_retrieved(persons)
signal went_to_facility(facility)
signal person_caught(feedback)

@onready var loader = $Loader

@onready var lightbox = $Lightbox
@onready var error_title = $ErrorTitle
@onready var error_panel = $ErrorPanel

var loading: bool: set = set_loading
var base_url = "http://localhost:8080/"

func _ready() -> void:
	hide_error()
	loader.position = Vector2(20, 580)

func _process(delta: float) -> void:
	loader.rotation += 2.0 * delta

func set_loading(value: bool) -> void:
	loading = value
	lightbox.visible = loading
	loader.visible = lightbox.visible

func create_game():
	set_loading(true)
	
	var url = base_url + "test"
	var error = $HTTPRequestGameCreate.request(url)
	if error != OK:
		print("Error creating game")

func retrieve_game(game_id: int):
	set_loading(true)
	
	var url = base_url + "game/mission/" + str(game_id)
	var error = $HTTPRequestGameRetrieve.request(url)
	if error != OK:
		print("Error retrieving game")
		
func retrieve_game_current_status(game_id: int):	
	set_loading(true)
	
	var url = base_url + "game/current/" + str(game_id)
	var error = $HTTPRequestGameCurrentStatus.request(url)
	if error != OK:
		print("Error retrieving game")
		
func go_to_facility(game_id: int, facility_id: int):
	set_loading(true)
	
	var url = base_url + "game/go-to-facility/" + str(game_id) + "/" + str(facility_id)
	var error = $HTTPRequestGoToFacility.request(url)
	if error != OK:
		print("Error going to facility") 
		
func go_to_location(game_id: int, location_id: int):
	set_loading(true)
	
	var url = base_url + "game/go-to-location/" + str(game_id) + "/" + str(location_id)
	var error = $HTTPRequestGoToLocation.request(url)
	if error != OK:
		print("Error going to location")
		
func retrieve_features():
	set_loading(true)
	
	var url = base_url + "features"
	var error = $HTTPRequestFeaturesRetrieve.request(url)
	if error != OK:
		print("Error retrieving features and their values")
		
func retrieve_persons():
	set_loading(true)
	
	var url = base_url + "persons"
	var error = $HTTPRequestPersonsRetrieve.request(url)
	if error != OK:
		print("Error retrieving persons and their feature values")
		
func catch_person(game_id: int, person_id: int):
	set_loading(true)
	
	var url = base_url + "game/catch/" + str(game_id) + "/" + str(person_id)
	var error = $HTTPRequestCatchPerson.request(url)
	if error != OK:
		print("Error trying to catch the person")

func _on_HTTPRequestGameRetrieve_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		show_error()
		return
	set_loading(false)
	
	var test_json_conv = JSON.new()
	test_json_conv.parse(body.get_string_from_utf8())
	var json:JSON = test_json_conv.get_data()
	
	var mission: Mission = Mission.new()
	mission.id = json.result.id
	mission.title = json.result.title
	mission.description = json.result.description
	
	emit_signal("game_retrieved", mission)


func _on_HTTPRequestGameCurrentStatus_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		show_error()
		return
	set_loading(false)
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	var game_current_status: GameCurrentStatus = GameCurrentStatus.new()
	
	var mission = Mission.new()
	mission.id = response.mission.id
	mission.title = response.mission.title
	mission.description = response.mission.description
	game_current_status.mission = mission
	
	var current_location: Location = Location.new()
	current_location.id = response.currentLocation.id
	current_location.name = response.currentLocation.name
	current_location.description = response.currentLocation.description
	game_current_status.current_location = current_location
	
	if response.currentFacility != null:
		var current_facility: Facility = Facility.new()
		current_facility.id = response.currentFacility.id
		current_facility.name = response.currentFacility.name
		game_current_status.current_facility = current_facility
		
	for f in response.facilities:
		var facility: Facility = Facility.new()
		facility.id = f.id
		facility.name = f.name
		facility.clue = f.clue
		facility.npcId = f.npc.id
		facility.npcName = f.npc.name
		game_current_status.facilities.append(facility)
		
	for l in response.candidateLocations:
		var candidate_location: Location = Location.new()
		candidate_location.id = l.id
		candidate_location.name = l.name
		game_current_status.candidate_locations.append(candidate_location)
	
	game_current_status.last = response.last
	game_current_status.lost = response.lost
	
	Globals.game_status = game_current_status
	emit_signal("game_current_status_retrieved", game_current_status)


func _on_HTTPRequestGoToFacility_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		show_error()
		return
	set_loading(false)
		
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	var facility: Facility = Facility.new()
	facility.id = response.facility.id
	facility.name = response.facility.name
	emit_signal("went_to_facility", facility)

func _on_HTTPRequestGoToLocation_request_completed(_result, response_code, _headers, _body):
	if response_code != 200:
		show_error()
		return
	set_loading(false)
	
	retrieve_game_current_status(Globals.game_id)

func _on_HTTPRequestFeaturesRetrieve_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		show_error()
		return
	set_loading(false)
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	var features: Array = []
	for f in response.features:
		var feature: Feature = Feature.new()
		feature.id = f.id
		feature.name = f.name
		
		for fv in f.featureValues:
			var feature_value: FeatureValue = FeatureValue.new()
			feature_value.id = fv.id
			feature_value.value = fv.value
			feature.feature_values.append(feature_value)
		features.append(feature)
	emit_signal("features_retrieved", features)


func _on_HTTPRequestPersonsRetrieve_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		show_error()
		return
	set_loading(false)
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	var persons: Array = []
	for p in response.persons:
		var person: Person = Person.new()
		person.id = p.id
		person.given_name = p.givenName
		person.family_name = p.familyName
	
		for pf in p.personFeatures:
			var person_feature: PersonFeature = PersonFeature.new()
			person_feature.feature_id = pf.featureId
			person_feature.feature_name = pf.featureName
			person_feature.feature_value_id = pf.featureValueId
			person_feature.feature_value_name = pf.featureValueName
			person.features.append(person_feature)
		persons.append(person)
	emit_signal("persons_retrieved", persons)


func _on_HTTPRequestCatchPerson_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		show_error()
		return
	set_loading(false)
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	var feedback: Feedback = Feedback.new()
	feedback.success = response.success
	feedback.message = response.message
	emit_signal("person_caught", feedback)


func _on_HTTPRequestGameCreate_request_completed(_result, response_code, _headers, body):	
	if response_code != 200:
		show_error()
		return
	set_loading(false)
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	var game_id: int = response.id
	emit_signal("game_created", game_id)

func _on_button_pressed() -> void:
	hide_error()
	get_tree().change_scene_to_file("res://scenes/MainMenuScene.tscn")

func show_error() -> void:
	loader.visible = false
	error_title.visible = true
	error_panel.visible = true
	
func hide_error() -> void:
	set_loading(false)
	error_title.visible = false
	error_panel.visible = false
