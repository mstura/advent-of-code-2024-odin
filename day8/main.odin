package main

import "core:bytes"
import sa "core:container/small_array"
import "core:fmt"
import "core:testing"

data_example :: #load("./data_example", string)

Small_Array :: sa.Small_Array

Point :: [2]int
LB :: []byte{0x0d, 0x0a}
CLR: byte : 0x2e

Antenna :: struct {
	pos:  Point,
	freq: u8,
}

sum: int
sum_p2: int

len_x: int
len_y: int

antenna_positions: Small_Array(237, Antenna)
an_pos: map[Point]struct {}

parse :: proc(data: ^[]byte) {
	y := 0
	for line in bytes.split_iterator(data, LB) {
		if len_x == 0 do len_x = len(line)
		for c, x in line {
			if c != CLR do sa.append(&antenna_positions, Antenna{{x, y}, c})
		}
		y += 1
	}
	len_y = y
}

in_grid :: #force_inline proc(p: Point) -> bool {
	return p.x >= 0 && p.x < len_x && p.y >= 0 && p.y < len_y
}

point_diff :: #force_inline proc(p1, p2: Point) -> Point {
	return Point{p1.x - p2.x, p1.y - p2.y}
}

@(test)
test_point_diff :: proc(t: ^testing.T) {
	p1 := Point{8, 1}
	p2 := Point{5, 2}

	diff := point_diff(p1, p2)

	testing.expect_value(t, diff, Point{3, -1})
}

antinode_pos :: #force_inline proc(p, diff: Point) -> Point {
	return p + diff
}

@(test)
test_antinode_pos :: proc(t: ^testing.T) {
	p1 := Point{8, 1}
	p2 := Point{5, 2}
	pdif1 := point_diff(p1, p2)
	pdif2 := point_diff(p2, p1)

	testing.expect_value(t, antinode_pos(p1, pdif1), Point{11, 0})
	testing.expect_value(t, antinode_pos(p2, pdif2), Point{2, 3})
}

part1 :: proc() {
	l := sa.len(antenna_positions)
	for i1 in 0 ..< l do for i2 in i1 + 1 ..< l {
		a := sa.get(antenna_positions, i1)
		b := sa.get(antenna_positions, i2)

		if a.freq != b.freq do continue

		pdif1 := point_diff(a.pos, b.pos)
		pdif2 := pdif1 * -1

		an1 := antinode_pos(a.pos, pdif1)
		an2 := antinode_pos(b.pos, pdif2)

		if _, ok := an_pos[an1]; !ok && in_grid(an1) do an_pos[an1] = struct {}{}
		if _, ok := an_pos[an2]; !ok && in_grid(an2) do an_pos[an2] = struct {}{}
	}

	sum = len(an_pos)
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	defer delete(an_pos)
	data_example := #load("./data_example", []byte)
	parse(&data_example)
	part1()

	testing.expect_value(t, sum, 14)
}

calculate_antinodes :: #force_inline proc(a, diff: Point) {
	p := a

	for {
		if _, ok := an_pos[p]; !ok do an_pos[p] = struct {}{}
		p = antinode_pos(p, diff)
		if !in_grid(p) do break
	}
}

part2 :: proc() {
	l := sa.len(antenna_positions)
	for i1 in 0 ..< l do for i2 in i1 + 1 ..< l {
		a := sa.get(antenna_positions, i1)
		b := sa.get(antenna_positions, i2)

		if a.freq != b.freq do continue

		pdif1 := point_diff(a.pos, b.pos)
		pdif2 := pdif1 * -1

		calculate_antinodes(a.pos, pdif1)
		calculate_antinodes(b.pos, pdif2)
	}

	sum_p2 = len(an_pos)
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	defer delete(an_pos)
	data_example := #load("./data_example", []byte)
	parse(&data_example)
	part2()

	testing.expect_value(t, sum_p2, 34)
}

main :: proc() {
	data := #load("./data", []byte)

	parse(&data)
	time
	part1()
	part2()

	fmt.println("antinodes found: ", sum)
	fmt.println("antinodes found: ", sum_p2)
}
