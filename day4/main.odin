package main

import "core:fmt"
import "core:testing"
import "core:unicode/utf8"

data :: #load("./data", string)
data_example :: #load("./data_example", string)

parse :: proc(str: string, allocator := context.allocator) -> Search_Matrix {
	m, _ := make([dynamic][dynamic]rune, allocator)
	append(&m, make([dynamic]rune, allocator))

	c_row := 0

	for c, i in str {
		switch c {
		case '\n':
			if len(str[i:]) > 1 {
				append(&m, make([dynamic]rune, allocator))
				c_row += 1
			}
		case 'X', 'M', 'A', 'S':
			append(&m[c_row], c)
		}
	}

	return m
}

@(test)
test_parse :: proc(t: ^testing.T) {
	dex: string = data_example[:]

	m := parse(dex, context.temp_allocator)

	e := [dynamic][dynamic]rune {
		[dynamic]rune{'M', 'M', 'M', 'S', 'X', 'X', 'M', 'A', 'S', 'M'},
		[dynamic]rune{'M', 'S', 'A', 'M', 'X', 'M', 'S', 'M', 'S', 'A'},
		[dynamic]rune{'A', 'M', 'X', 'S', 'X', 'M', 'A', 'A', 'M', 'M'},
		[dynamic]rune{'M', 'S', 'A', 'M', 'A', 'S', 'M', 'S', 'M', 'X'},
		[dynamic]rune{'X', 'M', 'A', 'S', 'A', 'M', 'X', 'A', 'M', 'M'},
		[dynamic]rune{'X', 'X', 'A', 'M', 'M', 'X', 'X', 'A', 'M', 'A'},
		[dynamic]rune{'S', 'M', 'S', 'M', 'S', 'A', 'S', 'X', 'S', 'S'},
		[dynamic]rune{'S', 'A', 'X', 'A', 'M', 'A', 'S', 'A', 'A', 'A'},
		[dynamic]rune{'M', 'A', 'M', 'M', 'M', 'X', 'M', 'M', 'M', 'M'},
		[dynamic]rune{'M', 'X', 'M', 'X', 'A', 'X', 'M', 'A', 'S', 'X'},
	}

	for x, xi in e {
		for v, yi in e[xi] {
			actual := m[xi][yi]

			testing.expect_value(t, actual, v)
		}
	}

	for &x in e {
		delete(x)
	}
	delete(e)

	free_all(context.temp_allocator)
}

Search_Matrix :: [dynamic][dynamic]rune
Point :: [2]int

Direction :: enum {
	N,
	NE,
	E,
	SE,
	S,
	SW,
	W,
	NW,
}

point_ne := point_from_direction(.NE)
point_nw := point_from_direction(.NW)
point_se := point_from_direction(.SE)
point_sw := point_from_direction(.SW)

point_from_direction :: proc(d: Direction) -> (p: Point) {
	switch d {
	case .N:
		p.y = -1
	case .NE:
		p.x = 1
		p.y = -1
	case .E:
		p.x = 1
	case .SE:
		p.x = 1
		p.y = 1
	case .S:
		p.y = 1
	case .SW:
		p.y = 1
		p.x = -1
	case .W:
		p.x = -1
	case .NW:
		p.x = -1
		p.y = -1
	}

	return
}

search :: proc(mtrx: Search_Matrix, p: Point, d: Direction, next: rune = 'X') -> bool {
	if p.y < 0 || p.y > len(mtrx) - 1 {
		return false
	}

	if p.x < 0 || p.x > len(mtrx[p.y]) - 1 {
		return false
	}

	if mtrx[p.y][p.x] == next {
		x := next
		switch next {
		case 'X':
			x = 'M'
		case 'M':
			x = 'A'
		case 'A':
			x = 'S'
		case 'S':
			return true
		}
		return search(mtrx, p + point_from_direction(d), d, x)
	}

	return false
}

srcp :: proc(m: Search_Matrix, p: Point) -> rune {
	return m[p.y][p.x]
}

search_x :: proc(m: Search_Matrix, p: Point) -> bool {
	if p.y <= 0 || p.y >= len(m) - 1 {
		return false
	}

	if p.x <= 0 || p.x >= len(m[p.y]) - 1 {
		return false
	}

	if srcp(m, p) == 'A' {
		if ((srcp(m, p + point_ne) == 'M' && srcp(m, p + point_sw) == 'S') ||
			   (srcp(m, p + point_sw) == 'M' && srcp(m, p + point_ne) == 'S')) &&
		   ((srcp(m, p + point_nw) == 'M' && srcp(m, p + point_se) == 'S') ||
				   (srcp(m, p + point_se) == 'M' && srcp(m, p + point_nw) == 'S')) {
			return true
		}
	}

	return false
}

part1 :: proc(str: string) -> int {
	m := parse(str, context.temp_allocator)

	count: int

	for _, y in m {
		for _, x in m[y] {
			p := Point{x, y}

			for d in Direction {
				if search(m, p, d) do count += 1
			}
		}
	}

	return count
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	dex: string = data_example[:]

	count := part1(dex)

	testing.expect_value(t, count, 18)
	free_all(context.temp_allocator)
}

part2 :: proc(str: string) -> int {
	m := parse(str, context.temp_allocator)

	count: int

	for _, y in m {
		for _, x in m[y] {
			p := Point{x, y}
			if search_x(m, p) do count += 1
		}
	}

	return count
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	dex: string = data_example[:]

	count := part2(dex)

	testing.expect_value(t, count, 9)
	free_all(context.temp_allocator)
}

main :: proc() {
	d: string = data[:]

	m := parse(d)

	count := part1(d)
	fmt.println("counted instances of xmas: ", count)
	count = part2(d)
	fmt.println("counted instances of xmas: ", count)

	free_all(context.temp_allocator)
}
