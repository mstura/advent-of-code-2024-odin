package grid

import "core:bytes"

LB :: []byte{0x0d, 0x0a}

rep :: proc(b: ^[]byte) -> ([2]int, bool) {
	x := -1
	y := 0
	for row in bytes.split_iterator(b, LB) {
		l := len(row)
		if x == -1 do x = l
		else if l != x do return {}, false
		y += 1
	}

	return {x, y}, true
}
