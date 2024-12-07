package main

import "core:bytes"
import "core:fmt"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"
import "core:time"

sum: int
sum_p2: int
data_example :: #load("./data_example", string)

Operator :: enum u8 {
	Add,
	Multiply,
	Concat,
}

p10 :: proc "contextless" (x: int) -> int {
	p := 10
	for x >= p do p *= 10
	return p
}

is_valid :: proc "contextless" (target: int, ops: []int, op_type: Operator = .Add, p2: bool) -> bool {
	if (target == 0 || (target == 1 && op_type == .Multiply)) && len(ops) == 0 do return true
	if len(ops) == 0 do return false
	l := ops[len(ops) - 1]
	next_ops := ops[0:len(ops) - 1]
	if target % l == 0 && is_valid(target / l, next_ops, .Multiply, p2) do return true
	if p2 && (target - l) % p10(l) == 0 && is_valid((target - l) / p10(l), next_ops, .Concat, p2) do return true
	if target - l >= 0 && is_valid(target - l, next_ops, .Add, p2) do return true
	return false
}

part1 :: proc(data: string) {
	sum = 0
	lines := strings.split(data, "\r\n", context.temp_allocator)
	defer free_all(context.temp_allocator)
	for line, i in lines {
		tot, _, tail := strings.partition(line, ": ")
		str_nums := strings.fields(tail)
		defer delete(str_nums)
		expected := strconv.atoi(tot)
		nums := make([dynamic]int, len(str_nums))
		defer delete(nums)

		for x in 0 ..< len(nums) {
			nums[x] = strconv.atoi(str_nums[x])
		}

		if is_valid(expected, nums[:], .Add, false) {
			sum += expected
		}

	}
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	part1(data_example)

	testing.expect_value(t, sum, 3749)
}

part2 :: proc(data: string) {
	sum_p2 = 0
	lines := strings.split(data, "\r\n", context.temp_allocator)
	defer free_all(context.temp_allocator)
	for line, i in lines {
		tot, _, tail := strings.partition(line, ": ")
		str_nums := strings.fields(tail)
		defer delete(str_nums)
		expected := strconv.atoi(tot)
		nums := make([dynamic]int, len(str_nums))
		defer delete(nums)

		for x in 0 ..< len(nums) {
			nums[x] = strconv.atoi(str_nums[x])
		}

		if is_valid(expected, nums[:], .Add, false) {
			sum_p2 += expected
		} else if is_valid(expected, nums[:], .Add, true) {
      sum_p2 += expected
    }
	}
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	part2(data_example)

	testing.expect_value(t, sum_p2, 11387)
}

main :: proc() {
	data :: #load("./data", string)
  part1(data)
	part2(data)

  fmt.println("calibration result: ", sum)
	fmt.println("calibration result: ", sum_p2)
}
