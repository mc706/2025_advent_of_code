//// Utility functions

import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/pair

/// integer division with remainder
pub fn div_mod(a: Int, b: Int) -> #(Int, Int) {
  #(a / b, a % b)
}

/// Converts a Bool to an Int (True -> 1, False -> 0)
pub fn bool_to_int(b: Bool) -> Int {
  case b {
    True -> 1
    False -> 0
  }
}

/// Finds the first maximum value and its index in a sublist of the given list
pub fn first_max_with_index_between(
  ints: List(Int),
  from_index: Int,
  to_index: Int,
) -> #(Int, Int) {
  list.index_fold(ints, #(-1, -1), fn(acc, i, index) {
    case { from_index <= index && index < to_index }, i > acc.0 {
      False, _ -> acc
      True, True -> #(i, index)
      True, False -> acc
    }
  })
}

/// Converts an integer to a list of its digits to replace int.digits(_, 10)
pub fn digits(x: Int) -> List(Int) {
  digits_loop(x, [])
}

fn digits_loop(x: Int, acc: List(Int)) -> List(Int) {
  case x < 10 {
    True -> [x, ..acc]
    False -> digits_loop(x / 10, [x % 10, ..acc])
  }
}

/// Converts a list of digits to an integer to replace int.undigits(_ ,10)
pub fn undigits(numbers: List(Int)) -> Int {
  undigits_loop(numbers, 0)
}

fn undigits_loop(numbers: List(Int), acc: Int) -> Int {
  case numbers {
    [] -> acc
    [first, ..rest] -> undigits_loop(rest, acc * 10 + first)
  }
}

/// Preidcate greater than for use in pipelines
pub fn greater_than(a: Int, b: Int) -> Bool {
  a > b
}

/// Predicate less than for use in pipelines
pub fn less_than(a: Int, b: Int) -> Bool {
  a < b
}

/// Counts the number of set bits (1s) in the binary representation of n
pub fn count_set_bits(n: Int) -> Int {
  count_set_bits_loop(n, 0)
}

fn count_set_bits_loop(n: Int, count: Int) -> Int {
  // Brian Kernighan’s Algorithm
  case n == 0 {
    True -> count
    False -> count_set_bits_loop(int.bitwise_and(n, n - 1), count + 1)
  }
}

pub fn bit_positions(n: Int) -> List(Int) {
  bit_positions_loop(n, 0, [])
}

fn bit_positions_loop(n: Int, position: Int, acc: List(Int)) -> List(Int) {
  case n == 0 {
    True -> acc
    False -> {
      let new_acc = case int.bitwise_and(n, 1) != 0 {
        True -> [position, ..acc]
        False -> acc
      }
      bit_positions_loop(int.bitwise_shift_right(n, 1), position + 1, new_acc)
    }
  }
}

// Int.combinations does not allow replacement
pub fn combination_pairs_with_replacement(list: List(a)) -> List(#(a, a)) {
  combination_pairs_with_replacement_loop(list, list, [])
}

fn combination_pairs_with_replacement_loop(
  base: List(a),
  remaining: List(a),
  acc: List(#(a, a)),
) -> List(#(a, a)) {
  case remaining {
    [] -> acc
    [first, ..rest] -> {
      let new_acc =
        list.fold(base, acc, fn(ac, second) { [#(first, second), ..ac] })
      combination_pairs_with_replacement_loop(base, rest, new_acc)
    }
  }
}

// add tuples
pub fn pair_add(a: #(Int, Int), b: #(Int, Int)) -> #(Int, Int) {
  #(a.0 + b.0, a.1 + b.1)
}

pub fn not_equal_to(a: a, b: a) -> Bool {
  a != b
}

pub fn head_tail(list: List(a)) -> Result(#(a, List(a)), Nil) {
  case list {
    [] -> Error(Nil)
    [first, ..rest] -> Ok(#(first, rest))
  }
}

// Chunks a list at the given indicies
pub fn chunk_at_indicies(list: List(a), indicies: List(Int)) -> List(List(a)) {
  chunk_at_indicies_loop(list, list.window_by_2(indicies), [])
  |> list.reverse
}

fn chunk_at_indicies_loop(
  list: List(a),
  indicies: List(#(Int, Int)),
  acc: List(List(a)),
) -> List(List(a)) {
  case indicies {
    [] -> {
      [list, ..acc]
    }
    [first_range, ..rest_indices] -> {
      let #(from_index, to_index) = first_range
      let chunk = list.take(list, to_index - from_index)
      let remaining = list.drop(list, to_index - from_index)
      chunk_at_indicies_loop(remaining, rest_indices, [chunk, ..acc])
    }
  }
}

// validate a value and throw error if validation fails else return original value
pub fn validate(
  value: a,
  validator: fn(a) -> Result(b, c),
  error: fn(c) -> d,
) -> Result(a, d) {
  case validator(value) {
    Ok(_) -> Ok(value)
    Error(e) -> Error(error(e))
  }
}

// Get the indicies of all successful operations in a list
pub fn success_indicies(
  list: List(a),
  operation: fn(a) -> Result(b, c),
) -> List(Int) {
  list.index_fold(list, [], fn(acc, item, index) {
    case operation(item) {
      Ok(_) -> [index, ..acc]
      Error(_) -> acc
    }
  })
  |> list.reverse
}

pub fn indexed_dict_from_list(list: List(a)) -> dict.Dict(Int, a) {
  list
  |> list.index_map(pair.new)
  |> list.map(pair.swap)
  |> dict.from_list
}

pub fn min_max(
  left: a,
  right: a,
  comparator: fn(a, a) -> order.Order,
) -> #(a, a) {
  case comparator(left, right) {
    order.Lt -> #(left, right)
    order.Gt -> #(right, left)
    order.Eq -> #(left, right)
  }
}
