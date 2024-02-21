extends ColorRect

const N_HORZ = 5
const N_VERT = 5
const CELL_WIDTH = 80
const CWD2 = CELL_WIDTH/2
const R = 3.0
const XWD = 16.0
const XWD2 = XWD/2
# 各格子点の接続状態
const LINK_EMPTY = 0
const LINK_UP = 1
const LINK_LEFT = 2
const LINK_RIGHT = 4
const LINK_DOWN = 8
const LINK_WALL = -16					# 0xfff...fff0
const ARY_WIDTH = N_HORZ + 2		# 壁あり
const ARY_HEIGHT = N_VERT + 3		# 壁あり
const ARY_SIZE = ARY_WIDTH * ARY_HEIGHT
#
const LINK_COL = Color.GREEN
#const LINK_COL = Color.DARK_GREEN

var links = []
var linkRt = []
var linkDn = []
var non_linkRt = []
var non_linkDn = []

func xyToIX(x, y):		# x, y -> links インデックス、x: [0, N_HORZ]、y: [0, N_VERT]
	return x + (y + 1) * ARY_WIDTH
func _draw():
	for y in range(N_VERT+1):
		var py = y * CELL_WIDTH
		for x in range(N_HORZ+1):
			var px = x * CELL_WIDTH
			var ix = xyToIX(x, y)
			if linkRt[ix] != 0:
				draw_line(Vector2(px, py), Vector2(px+CELL_WIDTH, py) , LINK_COL, R*2)
			if linkDn[ix] != 0:
				draw_line(Vector2(px, py), Vector2(px, py+CELL_WIDTH) , LINK_COL, R*2)
			if non_linkRt[ix] != 0:
				draw_line(Vector2(px+CWD2-XWD2, py-XWD2), Vector2(px+CWD2+XWD2, py+XWD2), LINK_COL, 3)
				draw_line(Vector2(px+CWD2-XWD2, py+XWD2), Vector2(px+CWD2+XWD2, py-XWD2), LINK_COL, 3)
			if non_linkDn[ix] != 0:
				draw_line(Vector2(px-XWD2, py+CWD2-XWD2), Vector2(px+XWD2, py+CWD2+XWD2), LINK_COL, 3)
				draw_line(Vector2(px-XWD2, py+CWD2+XWD2), Vector2(px+XWD2, py+CWD2-XWD2), LINK_COL, 3)
			pass
	for y in range(N_VERT+1):
		for x in range(N_HORZ+1):
			draw_circle(Vector2(x*CELL_WIDTH, y*CELL_WIDTH), R, Color.BLACK)
	pass
func _ready():
	pass # Replace with function body.
func _process(delta):
	pass
