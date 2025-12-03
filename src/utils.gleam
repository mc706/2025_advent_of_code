//// Utility functions

import gleam/list

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
