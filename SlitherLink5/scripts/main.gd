extends Node2D

const N_HORZ = 5
const N_VERT = 5
const N_CELLS = N_HORZ * N_VERT
const CELL_WIDTH = 80
const q1 = [-1,  3, -1,  3, -1,
			 2, -1, -1, -1,  2,
			-1, -1,  2, -1, -1,
			 3, -1, -1, -1,  1,
			-1,  3, -1,  1, -1,
			]

var bd
var num_labels = []			# 線分数表示用ラベル

var CBoard5x5 = preload("res://classes/Board5x5.gd")

func _ready():
	bd = CBoard5x5.new()
	bd.set_clue_num(q1)
	init_labels()
	update_num_labels()
	pass # Replace with function body.
func init_labels():
	for y in range(N_VERT):
		for x in range(N_HORZ):
			var px = x * CELL_WIDTH
			var py = y * CELL_WIDTH
			# 線分数表示用ラベル
			var label = Label.new()
			num_labels.push_back(label)
			label.add_theme_color_override("font_color", Color.BLACK)
			label.add_theme_font_size_override("font_size", 50)
			label.position = Vector2(px+18, py-3)
			label.text = str((x+y)%4)
			$Board/Grid.add_child(label)
func update_num_labels():
	for ix in range(N_CELLS):
		if bd.clue_num[ix] < 0:
			num_labels[ix].text = ""
		else:
			num_labels[ix].text = "%d" % bd.clue_num[ix]
		pass
func _process(delta):
	pass
