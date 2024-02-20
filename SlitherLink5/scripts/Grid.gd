extends ColorRect

const N_HORZ = 5
const N_VERT = 5
const CELL_WIDTH = 80
const R = 3.0
# 各格子点の接続状態
const LINK_EMPTY = 0
const LINK_UP = 1
const LINK_LEFT = 2
const LINK_RIGHT = 4
const LINK_DOWN = 8
const LINK_WALL = -16					# 0xfff...fff0
const LINK_ARY_WIDTH = N_HORZ + 2		# 壁あり
const LINK_ARY_HEIGHT = N_VERT + 3		# 壁あり
const LINK_ARY_SIZE = LINK_ARY_WIDTH * LINK_ARY_HEIGHT
#
const LINK_COL = Color.GREEN
#const LINK_COL = Color.DARK_GREEN

var links = []

func xyToLinkIX(x, y):		# x, y -> links インデックス、x: [0, N_HORZ]、y: [0, N_VERT]
	return x + (y + 1) * LINK_ARY_WIDTH
func _draw():
	if !links.is_empty():
		for y in range(N_VERT+1):
			var py = y * CELL_WIDTH
			for x in range(N_HORZ+1):
				var px = x * CELL_WIDTH
				var ix = xyToLinkIX(x, y)
				if links[ix] != 0:
					draw_circle(Vector2(px, py), R, LINK_COL)
					if (links[ix] & LINK_LEFT) != 0:
						draw_line(Vector2(px, py), Vector2(px-CELL_WIDTH/2, py) , LINK_COL, R*2)
					if (links[ix] & LINK_RIGHT) != 0:
						draw_line(Vector2(px, py), Vector2(px+CELL_WIDTH/2, py) , LINK_COL, R*2)
					if (links[ix] & LINK_UP) != 0:
						draw_line(Vector2(px, py), Vector2(px, py-CELL_WIDTH/2) , LINK_COL, R*2)
					if (links[ix] & LINK_DOWN) != 0:
						draw_line(Vector2(px, py), Vector2(px, py+CELL_WIDTH/2) , LINK_COL, R*2)
				pass
		pass
	for y in range(N_VERT+1):
		for x in range(N_HORZ+1):
			draw_circle(Vector2(x*CELL_WIDTH, y*CELL_WIDTH), R, Color.BLACK)
	pass
func _ready():
	pass # Replace with function body.
func _process(delta):
	pass
