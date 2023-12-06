extends Panel

@onready var player = get_tree().get_first_node_in_group("player")

func _input(event):
	if event.is_action("esc"):
		
