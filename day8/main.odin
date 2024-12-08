package day8

import "core:bytes"
import sa "core:container/small_array"
import "core:fmt"
import "core:testing"

Small_Array :: sa.Small_Array

Point :: [2]int
LB :: []byte{0x0d, 0x0a}
CLR: byte : 0x2e

Antenna :: struct {
	pos:  Point,
	freq: u8,
}

when ODIN_TEST {
	len_x :: 12
	len_y :: 12
} else {
	len_x :: 50
	len_y :: 50
}

p1_antenna_positions: Small_Array(237, Antenna)
p2_antenna_positions: Small_Array(237, Antenna)

parse :: proc(data: ^[]byte, acc: ^Small_Array(237, Antenna)) -> []Antenna {
	sa.clear(acc)
	y := 0
	for line in bytes.split_iterator(data, LB) {
		for c, x in line {
			if c != CLR do sa.append(acc, Antenna{{x, y}, c})
		}
		y += 1
	}

	return sa.slice(acc)
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

part1 :: proc(apos: []Antenna) -> int {
	c: int = 0
	l := len(apos)
	m := [len_y][len_x]bool{}
	for i1 in 0 ..< l do for i2 in i1 + 1 ..< l {
		a := apos[i1]
		b := apos[i2]

		if a.freq != b.freq do continue

		pdif1 := point_diff(a.pos, b.pos)
		pdif2 := pdif1 * -1

		an1 := antinode_pos(a.pos, pdif1)
		an2 := antinode_pos(b.pos, pdif2)

		if in_grid(an1) && !m[an1.y][an1.x] {
			m[an1.y][an1.x] = true
			c += 1
		}
		if in_grid(an2) && !m[an2.y][an2.x] {
			m[an2.y][an2.x] = true
			c += 1
		}
	}

	return c
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	data_example := #load("./data_example", []byte)
	a := parse(&data_example, &p1_antenna_positions)
	c := part1(a)

	testing.expect_value(t, c, 14)
}

calculate_antinodes :: #force_inline proc(a, diff: Point, m: ^[len_y][len_x]bool, acc: ^int) {
	p := a

	for {
		if !in_grid(p) do break
		if !m[p.y][p.x] {
			m[p.y][p.x] = true
			acc^ += 1
		}
		p = antinode_pos(p, diff)
	}
}

part2 :: proc(apos: []Antenna) -> int {
	c: int = 0
	l := len(apos)
	m := [len_y][len_x]bool{}
	for i1 in 0 ..< l do for i2 in i1 + 1 ..< l {
		a := apos[i1]
		b := apos[i2]

		if a.freq != b.freq do continue

		pdif1 := point_diff(a.pos, b.pos)
		pdif2 := pdif1 * -1

		calculate_antinodes(a.pos, pdif1, &m, &c)
		calculate_antinodes(b.pos, pdif2, &m, &c)
	}

	return c
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	data_example := #load("./data_example", []byte)
	o := parse(&data_example, &p2_antenna_positions)
	c := part2(o)

	testing.expect_value(t, c, 34)
}

solve_part1 :: proc(input: []byte) -> int {
	data := input
	a := parse(&data, &p1_antenna_positions)
	return part1(a)
}

solve_part2 :: proc(input: []byte) -> int {
	data := input
	a := parse(&data, &p2_antenna_positions)
	return part2(a)
}

main :: proc() {
	data := #load("./data", []byte)

	// part 1 benchmark 13.7us
	c := solve_part1(data)

	fmt.println("antinodes found: ", c)

	// part 2 benchmark 16.2us
	c = solve_part2(data)

	fmt.println("antinodes found: ", c)
}
