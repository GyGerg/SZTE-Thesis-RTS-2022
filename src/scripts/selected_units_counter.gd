extends Label

func _on_selected_count_change(amount:int):
	text="Selected Units: {amount}".format({"amount": amount})
