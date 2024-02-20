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

func xyToIX(x, y):		# x, y -> clue_num インデックス、x: [0, N_HORZ)、y: [0, N_VERT)
	return x + y * N_HORZ
func xyToLinkIX(x, y):		# x, y -> links インデックス、x: [0, N_HORZ]、y: [0, N_VERT]
	return x + (y + 1) * LINK_ARY_WIDTH
func _init():
	clue_num.resize(N_CELLS)
	clue_num.fill(EMPTY)
	links.resize(LINK_ARY_SIZE)
	links.fill(LINK_WALL)
	for y in range(N_VERT+1):
		for x in range(N_HORZ+1):
			links[xyToLinkIX(x, y)] = LINK_EMPTY
	# for Test
	links[xyToLinkIX(1, 1)] = LINK_RIGHT | LINK_DOWN
	links[xyToLinkIX(2, 1)] = LINK_LEFT | LINK_RIGHT
	links[xyToLinkIX(3, 1)] = LINK_LEFT | LINK_DOWN
	links[xyToLinkIX(1, 2)] = LINK_UP | LINK_DOWN
	links[xyToLinkIX(3, 2)] = LINK_UP | LINK_DOWN
	links[xyToLinkIX(1, 3)] = LINK_RIGHT | LINK_UP
	links[xyToLinkIX(2, 3)] = LINK_LEFT | LINK_RIGHT
	links[xyToLinkIX(3, 3)] = LINK_LEFT | LINK_UP
	#
	pass
func set_clue_num(lst):
	for i in range(N_CELLS):
		clue_num[i] = lst[i]
	pass
func links_to_nums():
	clue_num.fill(0)
	var ix = 0
	for y in range(N_VERT):
		for x in range(N_HORZ):
			#var ix = xyToIX(x, y)
			var k = xyToLinkIX(x, y)
			if (links[k] & LINK_RIGHT) != 0:
				clue_num[ix] += 1
			if (links[k] & LINK_DOWN) != 0:
				clue_num[ix] += 1
			if (links[k+1] & LINK_DOWN) != 0:
				clue_num[ix] += 1
			if (links[k+LINK_ARY_WIDTH] & LINK_RIGHT) != 0:
				clue_num[ix] += 1
			ix += 1
func _ready():
	pass
func _process(delta):
	pass
