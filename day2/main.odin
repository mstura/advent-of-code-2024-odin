package main

import "core:fmt"
import "core:strconv"
import "core:strings"

import utils "../utils"

data :: #load("./data", string)

safe_increasing :: proc(report: []int, remove_count := 0) -> bool {
	rp := report
	prev := report[0]

	for v, i in rp[1:] {
		if prev > v || prev == v || v - prev > 3 {
			if remove_count > 0 {
				for x in 0 ..< len(rp) {
					fr := utils.slice_splice(rp, x)
					res := report_safe(fr)
					delete(fr)
					if (res) {
						return true
					}
				}
			}
			return false
		}
		prev = v
	}

	return true
}

safe_decreasing :: proc(report: []int, remove_count := 0) -> bool {
	rp := report
	prev := report[0]

	for v, i in rp[1:] {
		if prev < v || prev == v || (prev - v) > 3 {
			if remove_count > 0 {
				for x in 0 ..< len(rp) {
					fr := utils.slice_splice(rp, x)
					res := report_safe(fr)
					delete(fr)
					if (res) {
						return true
					}
				}
			}
			return false
		}
		prev = v
	}

	return true
}

report_safe :: proc(report: []int, remove_count := 0) -> bool {
	if report[0] > report[1] {
		return safe_decreasing(report, remove_count)
	}

	if report[0] == report[1] {
		if remove_count > 0 {
			res := report_safe(report[1:], remove_count - 1)
			return res
		}

		return false
	}

	return safe_increasing(report, remove_count)
}

parse_input :: proc(d: ^string, m: ^[dynamic][dynamic]int) {
	i: uint
	for str in strings.split_lines_iterator(d) {
		if len(str) == 0 do continue

		entries, err := strings.split_after(str, " ")
		if err != nil {
			panic("memory allocation error encountered")
		}

		l := make([dynamic]int, context.temp_allocator)

		append_elem(m, l)

		for e in entries {
			v, _ := strconv.parse_int(e)
			append(&m[i], v)
		}

		delete(entries)
		i += 1
	}
}

part1 :: proc(reports: [dynamic][dynamic]int) {
	c: uint
	for report in reports {
		res := report_safe(report[:])
		if res {
			c += 1
		}
	}

	fmt.println("safe reports:", c)
}

part2 :: proc(reports: [dynamic][dynamic]int) {
	c: uint
	for report in reports {
		res := report_safe(report[:], 1)
		if res {
			c += 1
		}
	}

	fmt.println("safe reports:", c)
}

main :: proc() {
	d: string = data[:]
	reports := make([dynamic][dynamic]int, context.temp_allocator)
	parse_input(&d, &reports)

	part1(reports)
	part2(reports)

	free_all(context.temp_allocator)
}
