extends Node2D

signal game_created(game_id)
signal game_retrieved(mission)
signal game_current_status_retrieved(game_current_status)
signal features_retrieved(features)
signal persons_retrieved(persons)
signal went_to_facility(facility)
signal person_caught(feedback)

var base_url = "http://localhost:8080/"

func _ready():
	pass

func create_game():
	var url = base_url + "test"
	var error = $HTTPRequestGameCreate.request(url)
	if error != OK:
		print("Error creating game")

func retrieve_game(game_id: int):
	var url = base_url + "game/mission/" + str(game_id)
	var error = $HTTPRequestGameRetrieve.request(url)
	if error != OK:
		print("Error retrieving game")
		
func retrieve_game_current_status(game_id: int):	
	var url = base_url + "game/current/" + str(game_id)
	var error = $HTTPRequestGameCurrentStatus.request(url)
	if error != OK:
		print("Error retrieving game")
		
func go_to_facility(game_id: int, facility_id: int):
	var url = base_url + "game/go-to-facility/" + str(game_id) + "/" + str(facility_id)
	var error = $HTTPRequestGoToFacility.request(url)
	if error != OK:
		print("Error going to facility") 
		
func go_to_location(game_id: int, location_id: int):
	var url = base_url + "game/go-to-location/" + str(game_id) + "/" + str(location_id)
	var error = $HTTPRequestGoToLocation.request(url)
	if error != OK:
		print("Error going to location")
		
func retrieve_features():
	var url = base_url + "features"
	var error = $HTTPRequestFeaturesRetrieve.request(url)
	if error != OK:
		print("Error retrieving features and their values")
		
func retrieve_persons():
	var url = base_url + "persons"
	var error = $HTTPRequestPersonsRetrieve.request(url)
	if error != OK:
		print("Error retrieving persons and their feature values")
		
func catch_person(game_id: int, person_id: int):
	var url = base_url + "game/catch/" + str(game_id) + "/" + str(person_id)
	var error = $HTTPRequestCatchPerson.request(url)
	if error != OK:
		print("Error trying to catch the person")

func _on_HTTPRequestGameRetrieve_request_completed(result, response_code, headers, body):
	var json:JSONParseResult = JSON.parse(body.get_string_from_utf8())
	
	var mission: Mission = Mission.new()
	mission.id = json.result.id
	mission.title = json.result.title
	mission.description = json.result.description
	
	emit_signal("game_retrieved", mission)


func _on_HTTPRequestGameCurrentStatus_request_completed(result, response_code, headers, body):
	var json:JSONParseResult = JSON.parse(body.get_string_from_utf8())
	
	var game_current_status: GameCurrentStatus = GameCurrentStatus.new()
	
	var mission = Mission.new()
	mission.id = json.result.mission.id
	mission.title = json.result.mission.title
	mission.description = json.result.mission.description
	game_current_status.mission = mission
	
	var current_location: Location = Location.new()
	current_location.id = json.result.currentLocation.id
	current_location.name = json.result.currentLocation.name
	current_location.description = json.result.currentLocation.description
	game_current_status.current_location = current_location
	
	if json.result.currentFacility != null:
		var current_facility: Facility = Facility.new()
		current_facility.id = json.result.currentFacility.id
		current_facility.name = json.result.currentFacility.name
		game_current_status.current_facility = current_facility
		
	for f in json.result.facilities:
		var facility: Facility = Facility.new()
		facility.id = f.id
		facility.name = f.name
		facility.clue = f.clue
		facility.npcId = f.npc.id
		facility.npcName = f.npc.name
		game_current_status.facilities.append(facility)
		
	for l in json.result.candidateLocations:
		var candidate_location: Location = Location.new()
		candidate_location.id = l.id
		candidate_location.name = l.name
		game_current_status.candidate_locations.append(candidate_location)
	
	game_current_status.last = json.result.last
	game_current_status.lost = json.result.lost
	
	Globals.game_status = game_current_status
	emit_signal("game_current_status_retrieved", game_current_status)


func _on_HTTPRequestGoToFacility_request_completed(result, response_code, headers, body):
	var json:JSONParseResult = JSON.parse(body.get_string_from_utf8())
	var facility: Facility = Facility.new()
	facility.id = json.result.facility.id
	facility.name = json.result.facility.name
	emit_signal("went_to_facility", facility)
	


func _on_HTTPRequestGoToLocation_request_completed(result, response_code, headers, body):
	retrieve_game_current_status(Globals.game_id)


func _on_HTTPRequestFeaturesRetrieve_request_completed(result, response_code, headers, body):
	var json:JSONParseResult = JSON.parse(body.get_string_from_utf8())
	
	var features: Array = []
	for f in json.result.features:
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


func _on_HTTPRequestPersonsRetrieve_request_completed(result, response_code, headers, body):
	var json:JSONParseResult = JSON.parse(body.get_string_from_utf8())
	
	var persons: Array = []
	for p in json.result.persons:
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


func _on_HTTPRequestCatchPerson_request_completed(result, response_code, headers, body):
	var json:JSONParseResult = JSON.parse(body.get_string_from_utf8())
	var feedback: Feedback = Feedback.new()
	feedback.success = json.result.success
	feedback.message = json.result.message
	emit_signal("person_caught", feedback)


func _on_HTTPRequestGameCreate_request_completed(result, response_code, headers, body):
	var json:JSONParseResult = JSON.parse(body.get_string_from_utf8())
	var game_id: int = json.result.id	
	emit_signal("game_created", game_id)
