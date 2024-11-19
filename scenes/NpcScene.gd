extends Node2D

@onready var label_npc = $LabelNpc
@onready var label_clue = $LabelClue

var npc: Npc: set = set_npc
	
func set_npc(_npc):
	npc = _npc
	if (npc != null):
		label_npc = npc.name
		label_clue = npc.clue
