package main

import "../grid"
import "core:bytes"
import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:testing"

data :: #load("./data", []byte)
data_example :: #load("./data_example", []byte)

Point :: [2]i16
Direction :: [2]i16

N := Direction{0, -1}
E := Direction{1, 0}
S := Direction{0, 1}
W := Direction{-1, 0}

Tile_Kind :: enum u8 {
	Empty,
	Block,
	Obstruction,
}

EXAMPLE_DATA_SIZE :: 10
DATA_SIZE :: 130

CLR: byte = 0x2e
BLK: byte = 0x23
GRD_N: byte = 0x5e
GRD_E: byte = 0x3e
GRD_S: byte = 0x76
GRD_W: byte = 0x3c

LB :: []byte{0x0d, 0x0a}

Guard :: struct {
	pos: Point,
	dir: Direction,
}

Tile :: struct {
	visited: bool,
	kind:    Tile_Kind,
}

byte_to_direction :: proc(b: byte) -> (p: Direction) {
	switch b {
	case GRD_N:
		p = N
	case GRD_E:
		p = E
	case GRD_S:
		p = S
	case GRD_W:
		p = W
	}

	return
}

parse :: proc(b: ^[]byte, $h, $w: $uint) -> (o: [h][w]Tile, g: Guard) {
	y := 0
	for row in bytes.split_iterator(b, LB) {
		for t, x in row {
			tl: Tile
			switch t {
			case CLR:
				tl.kind = .Empty
			case BLK:
				tl.kind = .Block
			case GRD_N, GRD_E, GRD_S, GRD_W:
				tl.kind = .Empty
				tl.visited = true
				g.pos = {i16(x), i16(y)}
				g.dir = byte_to_direction(t)
			}
			o[y][x] = tl
		}
		y += 1
	}

	return
}

turn_right :: proc(g: ^Guard) {
	switch g.dir {
	case N:
		g.dir = E
	case E:
		g.dir = S
	case S:
		g.dir = W
	case W:
		g.dir = N
	}
}

in_bounds :: proc(grd: ^[$x][$y]Tile, p: Point) -> bool {
	return p.x >= 0 && p.x < x && p.y >= 0 && p.y < y
}

@(test)
test_in_bounds :: proc(t: ^testing.T) {
	p1 := Point{0, 9}
	p2 := Point{5, 10}
	p3 := Point{9, 9}
	p4 := Point{0, 0}
	p5 := Point{-1, 10}
	g: [10][10]Tile

	testing.expect_value(t, in_bounds(&g, p1), true)
	testing.expect_value(t, in_bounds(&g, p2), false)
	testing.expect_value(t, in_bounds(&g, p3), true)
	testing.expect_value(t, in_bounds(&g, p4), true)
	testing.expect_value(t, in_bounds(&g, p5), false)
}

@(test)
test_parse :: proc(t: ^testing.T) {
	dex: []byte = data_example
	grd, g := parse(&dex, 10, 10)
}

part1 :: proc(grd: ^[$x][$y]Tile, g: ^Guard) -> (c: int) {
	for {
		npos := g.pos + g.dir
		if !in_bounds(grd, npos) do break
		if t := grd[npos.y][npos.x]; t.kind == .Block {
			turn_right(g)
			continue
		} else if t.kind == .Obstruction {

		} else if !t.visited {
			grd^[npos.y][npos.x] = {true, .Empty}
		}
		g.pos = npos
	}

	for i1 in 0 ..< y {
		for i2 in 0 ..< x {
			t := grd[i1][i2]
			if t.visited do c += 1
		}
	}

	return
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	dex := data_example
	grd, g := parse(&dex, 10, 10)
	c := part1(&grd, &g)

	testing.expect_value(t, c, 41)
}

part2 :: proc(grd: ^[$x][$y]Tile, g: ^Guard) -> [dynamic]Point {
	ps := make([dynamic]Point, context.temp_allocator)
	start_pos := g.pos
	start_dir := g.dir

	for _y in 0 ..< y {
		for _x in 0 ..< x {
			hdir: Direction
			hpos: Point
			hit: bool
			p_tile := grd[_y][_x]
			op := Point{i16(_x), i16(_y)}
			if op == g.pos do continue

			if p_tile.kind != .Empty do continue

			grd^[_y][_x] = {false, .Obstruction}

			routes := make(map[Guard]struct{}, context.allocator)
			defer delete(routes)

			for {
				npos := g.pos + g.dir
				if !in_bounds(grd, npos) do break
				if t := grd[npos.y][npos.x]; t.kind == .Block {
					if _, ok := routes[g^]; ok {
						append(&ps, npos)
						break
					} else {
						routes[g^] = struct{}{}
					}
					turn_right(g)
					continue
				} else if t.kind == .Obstruction {
					if hit && hdir == g.dir && hpos == g.pos {
						append(&ps, npos)
						break
					}
					hdir = g.dir
					hpos = g.pos
					hit = true
					turn_right(g)
					continue
				}
				g.pos = npos
			}

			g.pos = start_pos
			g.dir = start_dir
			grd^[_y][_x] = p_tile
		}
	}

	return ps
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	dex := data_example
	grd, g := parse(&dex, 10, 10)
	points := part2(&grd, &g)

	testing.expect_value(t, len(points), 6)
}

main :: proc() {
	dex: []byte = data
	grd, g := parse(&dex, DATA_SIZE, DATA_SIZE)
	// c := part1(&grd, &g)

	ps := part2(&grd, &g)

	fmt.println("number of possible obstructions: ", len(ps))
}
