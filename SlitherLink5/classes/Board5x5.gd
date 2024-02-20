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
var dir_order = [LINK_UP, LINK_DOWN, LINK_LEFT, LINK_RIGHT]

func xyToIX(x, y):		# x, y -> clue_num インデックス、x: [0, N_HORZ)、y: [0, N_VERT)
	return x + y * N_HORZ
func xyToLinkIX(x, y):		# x, y -> links インデックス、x: [0, N_HORZ]、y: [0, N_VERT]
	return x + (y + 1) * LINK_ARY_WIDTH
func is_line(ix) -> bool:
	return links[ix] > 0
func _init():
	clue_num.resize(N_CELLS)
	clue_num.fill(EMPTY)
	links.resize(LINK_ARY_SIZE)
	links.fill(LINK_WALL)
	for y in range(N_VERT+1):
		for x in range(N_HORZ+1):
			links[xyToLinkIX(x, y)] = LINK_EMPTY
func make_loop():
	links[xyToLinkIX(1, 1)] = LINK_RIGHT | LINK_DOWN
	links[xyToLinkIX(2, 1)] = LINK_LEFT | LINK_RIGHT
	links[xyToLinkIX(3, 1)] = LINK_LEFT | LINK_RIGHT
	links[xyToLinkIX(4, 1)] = LINK_LEFT | LINK_DOWN
	links[xyToLinkIX(1, 2)] = LINK_UP | LINK_DOWN
	links[xyToLinkIX(4, 2)] = LINK_UP | LINK_DOWN
	links[xyToLinkIX(1, 3)] = LINK_UP | LINK_DOWN
	links[xyToLinkIX(4, 3)] = LINK_UP | LINK_DOWN
	links[xyToLinkIX(1, 4)] = LINK_RIGHT | LINK_UP
	links[xyToLinkIX(2, 4)] = LINK_LEFT | LINK_RIGHT
	links[xyToLinkIX(3, 4)] = LINK_LEFT | LINK_RIGHT
	links[xyToLinkIX(4, 4)] = LINK_LEFT | LINK_UP
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
# ２セル縦方向ラインを右に１セルずらす
# 前提：links[ix] は空欄
func move_line2_right(ix) -> bool:
	#print("ix = ", ix)
	#print(links[ix+LINK_ARY_WIDTH], " ", links[ix-1], " ", links[ix+LINK_ARY_WIDTH-1])
	if links[ix+LINK_ARY_WIDTH] != LINK_EMPTY || !is_line(ix-1) || !is_line(ix+LINK_ARY_WIDTH-1):
		return false
	if (links[ix-1] & LINK_DOWN) == 0: return false		# 線分が連続していない場合
	links[ix] = LINK_LEFT | LINK_DOWN
	links[ix+LINK_ARY_WIDTH] = LINK_LEFT | LINK_UP
	links[ix-1] ^= LINK_RIGHT | LINK_DOWN
	links[ix+LINK_ARY_WIDTH-1] ^= LINK_RIGHT | LINK_UP
	return true
# ２セル縦方向ラインを左に１セルずらす
# 前提：links[ix] は空欄
func move_line2_left(ix) -> bool:
	if links[ix+LINK_ARY_WIDTH] != LINK_EMPTY || !is_line(ix+1) || !is_line(ix+LINK_ARY_WIDTH+1):
		return false
	if (links[ix+1] & LINK_DOWN) == 0: return false		# 線分が連続していない場合
	links[ix] = LINK_RIGHT | LINK_DOWN
	links[ix+LINK_ARY_WIDTH] = LINK_RIGHT | LINK_UP
	links[ix+1] ^= LINK_LEFT | LINK_DOWN
	links[ix+LINK_ARY_WIDTH+1] ^= LINK_LEFT | LINK_UP
	return true
# ２セル縦方向ラインを上に１セルずらす
# 前提：links[ix] は空欄
func move_line2_up(ix) -> bool:
	if links[ix+1] != LINK_EMPTY || !is_line(ix+LINK_ARY_WIDTH) || !is_line(ix+LINK_ARY_WIDTH+1):
		return false
	if (links[ix+LINK_ARY_WIDTH] & LINK_RIGHT) == 0: return false		# 線分が連続していない場合
	links[ix] = LINK_RIGHT | LINK_DOWN
	links[ix+1] = LINK_LEFT | LINK_DOWN
	links[ix+LINK_ARY_WIDTH] ^= LINK_RIGHT | LINK_UP
	links[ix+LINK_ARY_WIDTH+1] ^= LINK_LEFT | LINK_UP
	return true
# ２セル縦方向ラインを下に１セルずらす
# 前提：links[ix] は空欄
func move_line2_down(ix) -> bool:
	if links[ix+1] != LINK_EMPTY || !is_line(ix-LINK_ARY_WIDTH) || !is_line(ix-LINK_ARY_WIDTH+1):
		return false
	if (links[ix-LINK_ARY_WIDTH] & LINK_RIGHT) == 0: return false		# 線分が連続していない場合
	links[ix] = LINK_RIGHT | LINK_UP
	links[ix+1] = LINK_LEFT | LINK_UP
	links[ix-LINK_ARY_WIDTH] ^= LINK_RIGHT | LINK_DOWN
	links[ix-LINK_ARY_WIDTH+1] ^= LINK_LEFT | LINK_DOWN
	return true
func move_line(ix) -> bool:
	dir_order.shuffle()
	for i in range(dir_order.size()):
		if dir_order[i] == LINK_UP:
			if move_line2_up(ix): return true
		if dir_order[i] == LINK_DOWN:
			if move_line2_down(ix): return true
		if dir_order[i] == LINK_LEFT:
			if move_line2_left(ix): return true
		if dir_order[i] == LINK_RIGHT:
			if move_line2_right(ix): return true
	return false
func make_loop_random():
	make_loop()
	for i in range(10):
		var lst = []
		for ix in range(xyToLinkIX(5, 5)+1):
			if links[ix] == LINK_EMPTY: lst.push_back(ix)
		lst.shuffle()
		var moved = false
		for k in range(lst.size()):
			if move_line(lst[k]):
				moved = true
				#n_empty -= 2
				break
		if !moved: break
func _ready():
	pass
func _process(delta):
	pass
