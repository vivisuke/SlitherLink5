extends Node2D

signal cont_search()		# 探索継続指示シグナル

const N_HORZ = 5
const N_VERT = 5
const N_CELLS = N_HORZ * N_VERT
const CELL_WIDTH = 80
const ARY_WIDTH = N_HORZ + 2		# 壁あり
const ARY_HEIGHT = N_VERT + 3		# 壁あり
const ARY_SIZE = ARY_WIDTH * ARY_HEIGHT
const q1 = [-1,  3, -1,  3, -1,
			 2, -1, -1, -1,  2,
			-1, -1,  2, -1, -1,
			 3, -1, -1, -1,  1,
			-1,  3, -1,  1, -1,
			]
const q2 = [-1,  3, -1,  2, -1,
			 1, -1,  2, -1,  3,
			-1,  2, -1,  0, -1,
			 2, -1,  3, -1,  3,
			-1,  2, -1,  2, -1,
			]
const q3 = [ 1,  3,  2,  2,  3,
			 2, -1, -1, -1,  3,
			 2, -1, -1, -1,  2,
			 2, -1, -1, -1,  2,
			 3,  1,  1,  1,  3,
			]
const q4 = [-1,  3, -1,  1, -1,
			 3,  0, -1,  2,  3,
			-1, -1, -1, -1, -1,
			 2,  2, -1,  2,  2,
			-1,  1, -1,  1, -1,
			]

var n_steps = 0
var bd
var sx = 0
var sy = 0
var satisfied = true		# 数字周囲線分数条件を満たしている
var num_labels = []			# 線分数表示用ラベル

var CBoard5x5 = preload("res://classes/Board5x5.gd")

func xyToIX(x, y):		# x, y -> links インデックス、x: [0, N_HORZ]、y: [0, N_VERT]
	return x + (y + 1) * ARY_WIDTH
func _ready():
	bd = CBoard5x5.new()
	bd.main_obj = self
	#bd.make_loop()
	#bd.move_line2_left(xyToIX(0, 1))
	#bd.move_line2_right(xyToIX(5, 2))
	#bd.move_line2_up(xyToIX(0, 0))
	#bd.move_line2_down(xyToIX(2, 2))
	#bd.make_loop_random()
	#bd.links_to_nums()
	bd.set_clue_num(q4)
	init_labels()
	update_num_labels()
	$Board/Grid.linkRt = bd.linkRt
	$Board/Grid.linkDn = bd.linkDn
	$Board/Grid.non_linkRt = bd.non_linkRt
	$Board/Grid.non_linkDn = bd.non_linkDn
	#$Board/Grid.links = bd.links
	#
	#bd.solve_coroutine(-1, -1)
	bd.solve_FB()
	n_steps = 1
	$NStepLabel.text = "#%d" % n_steps
	$Board/Grid.queue_redraw()
	#bd.print_mate()
	pass # Replace with function body.
func init_labels():
	num_labels.resize(ARY_SIZE)
	for y in range(N_VERT):
		for x in range(N_HORZ):
			var ix = xyToIX(x, y)
			var px = x * CELL_WIDTH
			var py = y * CELL_WIDTH
			# 線分数表示用ラベル
			var label = Label.new()
			num_labels[ix] = label
			label.add_theme_color_override("font_color", Color.BLACK)
			label.add_theme_font_size_override("font_size", 64)
			label.position = Vector2(px+24, py-5)
			label.text = str((x+y)%4)
			$Board/Grid.add_child(label)
func update_num_labels():
	for y in range(N_VERT):
		for x in range(N_HORZ):
			var ix = xyToIX(x, y)
			if bd.clue_num[ix] < 0:
				num_labels[ix].text = ""
			else:
				num_labels[ix].text = "%d" % bd.clue_num[ix]
func update_num_color():
	satisfied = true
	for y in range(N_VERT):
		for x in range(N_HORZ):
			var ix = xyToIX(x, y)
			if bd.clue_num[ix] >= 0:
				var col = Color.BLACK
				var n = bd.n_fixed_edge(ix)		# 確定線数
				if bd.n_edge(ix) == bd.clue_num[ix]:
					col = Color.GRAY
				elif n == 4:
					if bd.n_edge(ix) != bd.clue_num[ix]:
						col = Color.RED
						satisfied = false
				elif bd.n_non_edge(ix) > 4 - bd.clue_num[ix]:
					col = Color.RED
					satisfied = false
				elif bd.n_edge(ix) > bd.clue_num[ix]:
					col = Color.RED
					satisfied = false
				num_labels[ix].add_theme_color_override("font_color", col)
				#if bd.clue_num[ix] == 0:
				#	print("０:")
				#	print("n = ", n)		# 確定線数
				#	print("n_edge = ", bd.n_edge(ix))
				#	print("n_non_edge = ", bd.n_non_edge(ix))
func _input(event):
	#if event is InputEventMouseButton && event.is_pressed():
		#if false:
		#	emit_signal("cont_search")
		#else:
		#	bd.solve_FB()
		#	n_steps += 1
		#	$NStepLabel.text = "#%d" % n_steps
		#	#bd.print_mate()
		#	#bd.solve_SBS(sx, sy)
		#	$Board/Grid.queue_redraw()
		#	update_num_color()
		#	#print("is_looped() = ", bd.is_looped(bd.sx, bd.sy))
		#	#print("is_solved = ", bd.is_solved())
		#	#print("saticefied = ", satisfied)
		#	#if !satisfied || (bd.is_looped(bd.sx, bd.sy) && !bd.is_solved()):
		#	#	bd.fwd = false
		#	#	bd.sx += 1
	pass
func _process(delta):
	pass


func _on_button_1_steps_pressed():
	bd.solve_FB()
	n_steps += 1
	$NStepLabel.text = "#%d" % n_steps
	$Board/Grid.queue_redraw()
	update_num_color()
func do_n_steps(N):
	var start = Time.get_ticks_msec()
	for i in range(N):
		bd.solve_FB()
		n_steps += 1
		if bd.solved || bd.failed: break
	var end = Time.get_ticks_msec()
	print("dur = ", end - start, "msec")
	$NStepLabel.text = "#%d" % n_steps
	$Board/Grid.queue_redraw()
	update_num_color()
func _on_button_10_steps_pressed():
	do_n_steps(10)
func _on_button_100_steps_pressed():
	do_n_steps(100)
func _on_button_1000_steps_pressed():
	do_n_steps(1000)
