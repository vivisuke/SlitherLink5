extends ColorRect

const N_HORZ = 5
const N_VERT = 5
const CELL_WIDTH = 80
const R = 4

func _draw():
	for y in range(N_VERT+1):
		for x in range(N_HORZ+1):
			draw_circle(Vector2(x*CELL_WIDTH, y*CELL_WIDTH), R, Color.BLACK)
	pass
func _ready():
	pass # Replace with function body.
func _process(delta):
	pass
