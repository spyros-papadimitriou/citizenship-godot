extends Node2D



func _on_Button_pressed():
	Globals.game_id = 0
	get_tree().change_scene("res://scenes/MainMenuScene.tscn")
