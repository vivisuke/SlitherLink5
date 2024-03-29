class_name Board7x7

extends Object


const N_HORZ = 5		# 横方向数字セル数
const N_VERT = 5		# 縦方向数字セル数
const N_CELLS = N_HORZ * N_VERT
const ANY = -1
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

var clue_num = []
var links = []			# 各格子点の上下左右連結フラグ
var linkRt = []			# 各格子点の右連結フラグ、1 for 連結、0 for 非連結
var linkDn = []			# 各格子点の下連結フラグ
var non_linkRt = []		# 各格子点の右非連結フラグ、1 for 連結
var non_linkDn = []		# 各格子点の下非連結フラグ、1 for 非連結
var mate = []			# 連結状態保持配列、mate[ix] == ix for 非連結点, 
						# mate[ix] == 0 非端点連結済み点, mate[ix] 反対側端点
var dir_order = [LINK_UP, LINK_DOWN, LINK_LEFT, LINK_RIGHT]
var solved = false		# 解探索成功
var failed = false		# 探索失敗
var n_solved = 0		# 発見解数
var fwd = true
var sx = -1				# 探索位置
var sy = 0

var main_obj

func xyToIX(x, y):		# x, y -> links インデックス、x: [0, N_HORZ]、y: [0, N_VERT]
	return x + (y + 1) * ARY_WIDTH
func is_on_line(ix) -> bool:
	return linkRt[ix] != 0 || linkDn[ix] != 0 || linkRt[ix-1] != 0 || linkDn[ix-ARY_WIDTH] != 0
	#return links[ix] > 0
func n_fixed_edge(ix):
	return (linkRt[ix] + linkDn[ix] + linkRt[ix+ARY_WIDTH] + linkDn[ix+1] + 
			non_linkRt[ix] + non_linkDn[ix] + non_linkRt[ix+ARY_WIDTH] + non_linkDn[ix+1])
func n_edge(ix):
	return linkRt[ix] + linkDn[ix] + linkRt[ix+ARY_WIDTH] + linkDn[ix+1]
func n_non_edge(ix):
	return non_linkRt[ix] + non_linkDn[ix] + non_linkRt[ix+ARY_WIDTH] + non_linkDn[ix+1]
func total_edge_cnt():
	var cnt = 0
	for ix in range(ARY_SIZE):
		cnt += linkRt[ix]
		cnt += linkDn[ix]
	return cnt
func _init():
	solved = false		# 解探索成功
	n_solved = 0
	failed = false		# 探索失敗
	fwd = true
	sx = -1				# 探索位置
	sy = 0
	clue_num.resize(ARY_SIZE)
	clue_num.fill(ANY)
	links.resize(ARY_SIZE)
	links.fill(LINK_WALL)
	linkRt.resize(ARY_SIZE)
	linkRt.fill(0)
	linkDn.resize(ARY_SIZE)
	linkDn.fill(0)
	non_linkRt.resize(ARY_SIZE)
	non_linkRt.fill(0)
	non_linkDn.resize(ARY_SIZE)
	non_linkDn.fill(0)
	mate.resize(ARY_SIZE)
	for y in range(N_VERT+1):
		for x in range(N_HORZ+1):
			var ix = xyToIX(x, y)
			mate[ix] = ix				# 非連結点
			links[ix] = LINK_EMPTY
func print_mate():
	for y in range(N_VERT+1):
		var txt = ""
		for x in range(N_HORZ+1):
			var ix = xyToIX(x, y)
			txt += "%2d " % mate[ix]
		print(txt)
	print()
func make_loop2():		# 大きいループを作る
	for i in range(N_HORZ):
		linkRt[xyToIX(i, 0)] = 1
		linkRt[xyToIX(i, N_VERT)] = 1
		linkDn[xyToIX(0, i)] = 1
		linkDn[xyToIX(N_HORZ, i)] = 1
func make_loop():
	linkDn[xyToIX(1, 1)] = 1
	linkRt[xyToIX(1, 1)] = 1
	linkRt[xyToIX(2, 1)] = 1
	linkRt[xyToIX(3, 1)] = 1
	linkDn[xyToIX(4, 1)] = 1
	linkDn[xyToIX(1, 2)] = 1
	linkDn[xyToIX(4, 2)] = 1
	linkDn[xyToIX(1, 3)] = 1
	linkDn[xyToIX(4, 3)] = 1
	linkRt[xyToIX(1, 4)] = 1
	linkRt[xyToIX(2, 4)] = 1
	linkRt[xyToIX(3, 4)] = 1
func set_clue_num(lst):
	non_linkRt.fill(0)
	non_linkDn.fill(0)
	for y in range(N_VERT):
		for x in range(N_HORZ):
			var i = x + y * N_HORZ
			var ix = xyToIX(x, y)
			clue_num[ix] = lst[i]
			#if clue_num[ix] == 0:
			#	non_linkRt[ix] = 1
			#	non_linkDn[ix] = 1
			#	non_linkDn[ix+1] = 1
			#	non_linkRt[ix+ARY_WIDTH] = 1
	pass
func links_to_nums():
	clue_num.fill(0)
	for y in range(N_VERT):
		for x in range(N_HORZ):
			var k = xyToIX(x, y)
			if linkRt[k] != 0:
				clue_num[k] += 1
			if linkDn[k] != 0:
				clue_num[k] += 1
			if linkDn[k+1] != 0:
				clue_num[k] += 1
			if linkRt[k+ARY_WIDTH] != 0:
				clue_num[k] += 1
# ２セル縦方向ラインを左に１セルずらす
# 前提：links[ix] は空欄
func move_line2_left(ix) -> bool:
	if is_on_line(ix+ARY_WIDTH) || !is_on_line(ix+1) || !is_on_line(ix+ARY_WIDTH+1):
		return false
	if linkDn[ix+1] == 0: return false		# 線分が連続していない場合
	linkDn[ix] = 1
	linkRt[ix] = 1
	linkRt[ix+ARY_WIDTH] = 1
	linkDn[ix+1] = 0
	return true
# ２セル縦方向ラインを右に１セルずらす
# 前提：links[ix] は空欄
func move_line2_right(ix) -> bool:
	if is_on_line(ix+ARY_WIDTH) || !is_on_line(ix-1) || !is_on_line(ix+ARY_WIDTH-1):
		return false
	if linkDn[ix-1] == 0: return false		# 線分が連続していない場合
	linkDn[ix] = 1
	linkRt[ix-1] = 1
	linkDn[ix-1] = 0
	linkRt[ix+ARY_WIDTH-1] = 1
	return true
# ２セル縦方向ラインを上に１セルずらす
# 前提：links[ix] は空欄
func move_line2_up(ix) -> bool:
	if is_on_line(ix+1) || !is_on_line(ix+ARY_WIDTH) || !is_on_line(ix+ARY_WIDTH+1):
		return false
	if linkRt[ix+ARY_WIDTH] == 0: return false		# 線分が連続していない場合
	linkRt[ix] = 1
	linkDn[ix] = 1
	linkDn[ix+1] = 1
	linkRt[ix+ARY_WIDTH] = 0
	return true
# ２セル縦方向ラインを下に１セルずらす
# 前提：links[ix] は空欄
func move_line2_down(ix) -> bool:
	if is_on_line(ix+1) || !is_on_line(ix-ARY_WIDTH) || !is_on_line(ix-ARY_WIDTH+1):
		return false
	if linkRt[ix-ARY_WIDTH] == 0: return false		# 線分が連続していない場合
	linkRt[ix] = 1
	linkRt[ix-ARY_WIDTH] = 0
	linkDn[ix-ARY_WIDTH] = 1
	linkDn[ix-ARY_WIDTH+1] = 1
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
func make_loop_random(big: bool):
	if big: make_loop2()
	else: make_loop()
	for i in range(8):
		var lst = []
		#for ix in range(xyToIX(5, 5)+1):
		for y in range(N_VERT):
			for x in range(N_HORZ):
				var ix = xyToIX(x, y)
				if( linkRt[ix] == 0 && linkDn[ix] == 0 &&
					linkRt[ix-1] == 0 && linkDn[ix-ARY_WIDTH] == 0):
					lst.push_back(ix)
		lst.shuffle()
		var moved = false
		for k in range(lst.size()):
			#var x = lst[k] % ARY_WIDTH
			#var y = lst[k] / ARY_WIDTH - 1
			#print("(%d, %d)" % [x, y])
			if move_line(lst[k]):
				moved = true
				#n_empty -= 2
				break
		if !moved: break
# (0, 0) から順にリンクをランダムに決めていく
func set_link_random():
	for y in range(N_VERT+1):
		for x in range(N_HORZ+1):
			var k = xyToIX(x, y)
			var up = y != 0 && (links[k-ARY_WIDTH] & LINK_DOWN) != 0
			var lt = x != 0 && (links[k-1] & LINK_RIGHT) != 0
			if up && lt:	# 上・左に連結済み
				links[k] = LINK_UP | LINK_LEFT
			elif up || lt:		# 上または左にのみ連結済み
				if up: links[k] = LINK_UP
				else: links[k] = LINK_LEFT
				
	pass
func is_constraint_violation():		# 制約違反状態か？
	for y in range(N_VERT):
		for x in range(N_HORZ):
			var ix = xyToIX(x, y)
			if clue_num[ix] >= 0:
				var n = n_fixed_edge(ix)		# 確定線数
				if n == 4:
					if n_edge(ix) != clue_num[ix]:
						return true
				elif n_non_edge(ix) > 4 - clue_num[ix]:
					return true
				elif n_edge(ix) > clue_num[ix]:
					return true
	return false
func is_solved() -> bool:
	for y in range(N_VERT+1):
		for x in range(N_HORZ+1):
			var ix = xyToIX(x, y)
			if clue_num[ix] >= 0 && n_edge(ix) != clue_num[ix]:
				return false
	return true
func is_looped(x, y) -> int:
	var ix = xyToIX(x, y)
	var ix0 = ix
	var ix9 = -1		# ひとつ前の位置
	var cnt = 0			# ループを構成するエッジ数
	while true:
		cnt += 1
		if linkRt[ix] != 0 && ix + 1 != ix9:
			ix9 = ix
			ix += 1
		elif linkDn[ix] != 0 && ix + ARY_WIDTH != ix9:
			ix9 = ix
			ix += ARY_WIDTH
		elif linkRt[ix-1] != 0 && ix - 1 != ix9:
			ix9 = ix
			ix -= 1
		elif linkDn[ix-ARY_WIDTH] != 0 && ix - ARY_WIDTH != ix9:
			ix9 = ix
			ix -= ARY_WIDTH
		else:
			return 0
		if ix == ix0:
			#print("num edge = ", cnt)
			return cnt
	return 0
func link_right(ix):
	linkRt[ix] = 1
	non_linkRt[ix] = 0
	#if mate[ix] != ix:	# ix が端点の場合
	#	mate[mate[ix]] = ix+1		# 逆側端点
	#	mate[ix+1] = mate[ix]
	#	mate[ix] = 0
	#else:
	#	mate[ix] = ix + 1
	#	mate[ix+1] = ix
func link_down(ix):
	linkDn[ix] = 1
	non_linkDn[ix] = 0
	#if mate[ix] != ix:	# ix が端点の場合
	#	mate[mate[ix]] = ix+ARY_WIDTH		# 逆側端点
	#	mate[ix+ARY_WIDTH] = mate[ix]
	#	mate[ix] = 0
	#else:
	#	mate[ix] = ix + ARY_WIDTH
	#	mate[ix+ARY_WIDTH] = ix
# バックトラッキング探索
func solve_FB():
	#if solved || failed: return
	if failed: return
	if fwd:		# 末端に向かって探索中
		sx += 1
		if sx > N_HORZ:
			sx = 0
			sy += 1
			if sy > N_VERT:
				#if is_solved():
				#	n_solved += 1
				fwd = false
				sy -= 1
				sx = N_HORZ + 1
	if !fwd:		# バックトラッキング中
		sx -= 1
		if sx < 0:
			sx = N_HORZ
			sy -= 1
			if sy < 0:
				print("failed.")
				failed = true
				return
	#print("(%d, %d)" % [sx, sy])
	var ix = xyToIX(sx, sy)
	var up: bool = sy != 0 && linkDn[ix-ARY_WIDTH] != 0
	var lt: bool = sx != 0 && linkRt[ix-1] != 0
	if fwd:		# 末端に向かって探索中
		if up && lt:		# 上・左連結済み
			if sx < N_HORZ: non_linkRt[ix] = 1
			if sy < N_VERT: non_linkDn[ix] = 1
		elif up || lt:		# 上 or 左からの連結あり
			if sx == N_HORZ:	# 右端の場合
				linkDn[ix] = 1
			elif sy == N_VERT:	# 下端の場合
				linkRt[ix] = 1
			else:
				linkRt[ix] = 1
				if sy < N_VERT: non_linkDn[ix] = 1
		else:				# 上からも左からの連結も無い場合
			if sx < N_HORZ && sy < N_VERT:	# 下端でも右端でもない場合
				link_right(ix)
				link_down(ix)
				#linkRt[ix] = 1
				#linkDn[ix] = 1
			elif sy == N_VERT:	# 下端の場合
				non_linkRt[ix] = 1
			elif sx == N_HORZ:	# 右端の場合
				non_linkDn[ix] = 1
			else:
				fwd = false
	else:		# バックトラッキング中
		if up && lt:		# 上・左連結済み
			non_linkRt[ix] = 0
			non_linkDn[ix] = 0
		elif up || lt:		# 上 or 左からの連結あり
			if linkRt[ix] == 1:
				linkRt[ix] = 0
				non_linkRt[ix] = 1
				if sy < N_VERT:	# 下端ではない場合
					linkDn[ix] = 1
					non_linkDn[ix] = 0
				fwd = true
			else:
				non_linkRt[ix] = 0
				linkDn[ix] = 0
		else:				# 上からも左からの連結も無い場合
			if linkRt[ix] == 1:
				linkRt[ix] = 0
				linkDn[ix] = 0
				non_linkRt[ix] = 1
				non_linkDn[ix] = 1
				fwd = true
			else:
				non_linkRt[ix] = 0
				non_linkDn[ix] = 0
	if is_constraint_violation():	# 制約違反あり
		fwd = false
		sx += 1
	else:
		var cnt = is_looped(sx, sy)
		if cnt != 0:
			if cnt == total_edge_cnt():
				if is_solved():
					n_solved += 1
					solved = true
					print("solved!")
				#else:
				fwd = false
				sx += 1
			else:
				fwd = false
				sx += 1

func solve_SBS(x: int, y: int):
	var ix = xyToIX(x, y)
	var up: bool = y != 0 && linkDn[ix-ARY_WIDTH] != 0
	var lt: bool = x != 0 && linkRt[ix-1] != 0
	if up && lt:
		pass
	elif up || lt:
		if linkDn[ix] != 0:		# すでに下方に連結済み
			pass
		elif x < N_HORZ:		# 右端ではない場合
			if clue_num[ix] != 3:
				linkRt[ix] = 1
				if y < N_VERT:
					non_linkDn[ix] = 1
			else:	# clue_num[ix] == 3 の場合
				linkRt[ix] = 1
				linkDn[ix+1] = 1
				linkRt[ix+ARY_WIDTH] = 1
				non_linkDn[ix] = 1
				non_linkRt[ix+ARY_WIDTH+1] = 1
				non_linkDn[ix+ARY_WIDTH+1] = 1
		else:
			linkDn[ix] = 1
		pass
	else:
		linkRt[ix] = 1
		linkDn[ix] = 1
		if clue_num[ix] == 2:
			non_linkDn[ix+1] = 1
			non_linkRt[ix+ARY_WIDTH] = 1
func _ready():
	pass
func _process(delta):
	pass
