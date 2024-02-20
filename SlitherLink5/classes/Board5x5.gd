class_name Board7x7

extends Object


const N_HORZ = 5
const N_VERT = 5
const N_CELLS = N_HORZ * N_VERT
const EMPTY = -1
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

var clue_num = []
var links = []			# 各格子点の上下左右連結フラグ

func xyToLinkIX(x, y):		# x, y -> links インデックス、x: [0, N_HORZ)、y: [0, N_VERT)
	return x + (y + 1) * LINK_ARY_WIDTH
func _init():
	clue_num.resize(N_CELLS)
	clue_num.fill(EMPTY)
	links.resize(LINK_ARY_SIZE)
	links.fill(LINK_WALL)
	for y in range(N_VERT):
		for x in range(N_HORZ):
			links[xyToLinkIX(x, y)] = LINK_EMPTY
	pass
func set_clue_num(lst):
	for i in range(N_CELLS):
		clue_num[i] = lst[i]
	pass
func _ready():
	pass
func _process(delta):
	pass
