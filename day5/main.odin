package main

import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"

data :: #load("./data", string)
data_example :: #load("./data_example", string)

Puzzle :: struct {
	rules:   [dynamic]Order_Rule,
	updates: [dynamic][dynamic]int,
}

Order_Rule :: [2]int

Cmp :: struct {
	val:   int,
	rules: []Order_Rule,
}

parse :: proc(str: ^string) -> ^Puzzle {
	p := new(Puzzle, context.temp_allocator)
	p.rules = make([dynamic]Order_Rule, context.temp_allocator)
	p.updates = make([dynamic][dynamic]int, context.temp_allocator)

	current := 0
	c_row := 0

	for line in strings.split_lines_iterator(str) {
		if len(line) == 0 {
			current = 1
			continue
		}

		if current == 0 {
			if h, _, t := strings.partition(line, "|"); h != "" && t != "" {
				append(&p.rules, Order_Rule{strconv.atoi(h), strconv.atoi(t)})
			}
		} else {
			append(&p.updates, make([dynamic]int, context.temp_allocator))

			s: int
			for c, i in line {
				if c == ',' {
					append(&p.updates[c_row], strconv.atoi(line[s:i]))
					s = i + 1
				} else if i == len(line) - 1 {
					append(&p.updates[c_row], strconv.atoi(line[s:]))
				}
			}
			c_row += 1
		}
	}

	return p
}

order_updates :: proc(p: [dynamic]Order_Rule, i: [dynamic]int) -> [dynamic]int {
	islice := i[:]
	rules := make([dynamic]Order_Rule)
	defer delete(rules)

	for rule in p {
		if slice.contains(islice, rule.x) && slice.contains(islice, rule.y) {
			append(&rules, rule)
		}
	}

	n := make([dynamic]Cmp)
	defer delete(n)

	for e in islice {
		append(&n, Cmp{e, rules[:]})
	}

	sn := n[:]
	slice.sort_by(sn, proc(a, b: Cmp) -> bool {
		for r in a.rules {
			av := a.val
			bv := b.val
			if (av == r.x || av == r.y) && (bv == r.x || bv == r.y) {
				if av == r.x {
					return true
				}

				return false
			}
		}

		return true
	})

	res := make([dynamic]int)

	for e in sn {
		append(&res, e.val)
	}

	return res
}

part1 :: proc(p: ^Puzzle) -> (c: int) {
	for update in p.updates {
		res := order_updates(p.rules, update)
		defer delete(res)
		if slice.equal(res[:], update[:]) do c += update[len(update) / 2]
	}

	return
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	dex: string = data_example[:]
	p := parse(&dex)

	v := part1(p)

	testing.expect_value(t, v, 143)
}

part2 :: proc(p: ^Puzzle) -> (c: int) {
	for update in p.updates {
		res := order_updates(p.rules, update)
		defer delete(res)
		if !slice.equal(res[:], update[:]) do c += res[len(res) / 2]
	}

	return
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	dex: string = data_example[:]
	p := parse(&dex)
	v := part2(p)

	testing.expect_value(t, v, 123)
}

main :: proc() {
	d: string = data[:]

	p := parse(&d)
	c := part1(p)

	fmt.println("sum of middle numbers in correct rule order: ", c)

	c = part2(p)

	fmt.println("sum of middle numbers in incorrect rule order: ", c)

}
