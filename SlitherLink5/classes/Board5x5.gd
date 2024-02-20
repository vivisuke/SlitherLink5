class_name Board7x7

extends Object

const N_HORZ = 5
const N_VERT = 5
const N_CELLS = N_HORZ * N_VERT
const EMPTY = -1

var clue_num = []

func _init():
	clue_num.resize(N_CELLS)
	clue_num.fill(EMPTY)
	pass
func set_clue_num(lst):
	for i in range(N_CELLS):
		clue_num[i] = lst[i]
	pass
func _ready():
	pass
func _process(delta):
	pass
