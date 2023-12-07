extends Button


signal click_end()


func _on_pressed():
	emit_signal("click_end")
