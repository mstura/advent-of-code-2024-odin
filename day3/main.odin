package main

import "core:fmt"
import "core:strconv"
import "core:text/regex"
// import "../talloc"

import utils "../utils"

data :: #load("./data", string)

part1 :: proc(str: string) {
	rx, err := regex.create(`mul\((\d{1,3}),(\d{1,3})\)`, {.Global, .Multiline})
	c := regex.preallocate_capture()

	_str := str[:]

	sum: int

	for utils.regex_iterator(rx, &_str, &c) {
		g := c.groups[1:3]
		a, _ := strconv.parse_int(g[0])
		b, _ := strconv.parse_int(g[1])
		sum += a * b
	}

	regex.destroy(rx)
	regex.destroy(c)

	fmt.println("instruction sum:", sum)
}

part2 :: proc(str: string) {
	rx, err := regex.create(`mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)`, {.Global, .Multiline})
	c := regex.preallocate_capture()

	_str := str[:]

	sum: int
	flag := 1

	for utils.regex_iterator(rx, &_str, &c) {
		prev_flag := flag

		switch c.groups[0] {
		case "don't()":
			flag = 0
			continue
		case "do()":
			flag = 1
			continue
		}

		if flag == 1 {
			g := c.groups[1:3]
			a, _ := strconv.parse_int(g[0])
			b, _ := strconv.parse_int(g[1])
			sum += a * b
		}
	}

	regex.destroy(rx)
	regex.destroy(c)

	fmt.println("instruction sum:", sum)
}

main :: proc() {
	d: string = data[:]

	test_str := `xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))`

	part1(d)
	part2(d)
	
	free_all(context.temp_allocator)
}
