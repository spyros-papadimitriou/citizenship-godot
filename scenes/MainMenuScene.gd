extends Node2D

onready var communicator = $Communicator
onready var button_continue = $VBoxContainer/ButtonContinue

func _ready():
	button_continue.disabled = Globals.game_id <= 0	
	communicator.connect("game_created", self, "start_game")

func _on_ButtonStart_pressed():
	communicator.create_game()
	
func start_game(game_id: int):
	Globals.game_id = game_id
	load_ingame_scene()

func load_ingame_scene():
	get_tree().change_scene("res://scenes/InGame.tscn")

func _on_ButtonContinue_pressed():
	load_ingame_scene()

func _on_ButtonQuit_pressed():
	get_tree().quit()
