extends Camera2D

const MIDDLE_CLICK = 3
const SCROLL_UP = 4
const SCROLL_DOWN = 5

func _input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			SCROLL_UP:		# zoom out
				self.zoom *= 0.5
			SCROLL_DOWN: 	# zoom in
				self.zoom *= 1.5
			MIDDLE_CLICK:
				self.zoom.x = 1
				self.zoom.y = 1
				
