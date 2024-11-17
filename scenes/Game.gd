extends Node2D

onready var communicator = $Communicator
onready var title = $VBoxContainer/Title
onready var description = $VBoxContainer/Description

func _ready():
	communicator.connect("game_retrieved", self, "show_mission_info")
	communicator.retrieve_game(32)

func show_mission_info(mission: Mission):
	title.text = mission.title
	description.text = mission.description
