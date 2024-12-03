package main

import "core:fmt"
import "core:sort"
import "core:strconv"
import "core:strings"

data :: #load("./data", string)

part1 :: proc(sl: []uint, sr: []uint) {
	total_dist: uint = 0

	for i in 0 ..< len(sl) {
		l := sl[i]
		r := sr[i]
		x := min(l, r)
		y := max(l, r)
		total_dist += y - x
	}

	fmt.println(total_dist)
}

part2 :: proc(sl: []uint, sr: []uint) {
	tot: uint = 0

	ridx := 0
	left_loop: for left_value in sl {
		count: uint = 0
		for right_value, ri in sr[ridx:] {
			
			if left_value < right_value {
				ridx += ri
				tot += left_value * count
				continue left_loop
			}
			
			if right_value == left_value {
				count += 1
			}
		}
	}

	fmt.println("similarity score:", tot)
}

main :: proc() {
	d: string = data[:]
	
	lleft := [dynamic]uint{}
	lright := [dynamic]uint{}

	for line in strings.split_lines_iterator(&d) {
		l, _ := strconv.parse_uint(line[0:5])
		r, _ := strconv.parse_uint(line[8:13])

		append(&lleft, l)
		append(&lright, r)
	}

	sl := lleft[:]
	sr := lright[:]

	sort.quick_sort(sl)
	sort.quick_sort(sr)

	part1(sl, sr)
	part2(sl, sr)
}
