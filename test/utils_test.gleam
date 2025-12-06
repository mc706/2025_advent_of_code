import gleam/int
import gleam/set
import gleeunit
import utils

pub fn main() -> Nil {
  gleeunit.main()
}

// utils.div_mod
pub fn div_mod_exact_test() {
  let #(quotient, remainder) = utils.div_mod(11, 2)
  assert quotient == 5
  assert remainder == 1
}

// utils.bool_to_int
pub fn bool_to_int_test() {
  assert utils.bool_to_int(True) == 1
  assert utils.bool_to_int(False) == 0
}

// utils.first_max_with_index_between
pub fn first_max_with_index_between_test() {
  let lst = [1, 3, 2, 5, 4, 5]
  let #(max_value, index) = utils.first_max_with_index_between(lst, 1, 4)
  assert max_value == 5
  assert index == 3
}

// utils.digits
pub fn digits_test() {
  let lst = utils.digits(12_345)
  assert lst == [1, 2, 3, 4, 5]
}

// utils.undigits
pub fn undigits_test() {
  let number = utils.undigits([9, 8, 7, 6, 5])
  assert number == 98_765
}

// utiuls.greater_than
pub fn greater_than_test() {
  assert utils.greater_than(5, 3) == True
  assert utils.greater_than(2, 4) == False
}

// utils.less_than
pub fn less_than_test() {
  assert utils.less_than(3, 5) == True
  assert utils.less_than(6, 2) == False
}

// utils.count_set_bits
pub fn count_set_bits_test() {
  assert utils.count_set_bits(0b1011) == 3
  assert utils.count_set_bits(0b11111111) == 8
}

// utils.bit_positions
pub fn bit_positions_test() {
  let positions = utils.bit_positions(0b10110)
  assert positions == [4, 2, 1]
}

// utils.combinations_pairs_with_replacement
pub fn combination_pairs_with_replacement_test() {
  let pairs = utils.combination_pairs_with_replacement([1, 2, 3])
  assert set.from_list(pairs)
    == set.from_list([
      #(1, 1),
      #(1, 2),
      #(1, 3),
      #(2, 1),
      #(2, 2),
      #(2, 3),
      #(3, 1),
      #(3, 2),
      #(3, 3),
    ])
}

// utils.pair_add
pub fn pair_add_test() {
  let result = utils.pair_add(#(2, 3), #(4, 5))
  assert result == #(6, 8)
}

// utils.not_equal_to
pub fn not_equal_to_test() {
  assert utils.not_equal_to(3, 4) == True
  assert utils.not_equal_to(5, 5) == False
}

// utils.head_tail
pub fn head_tail_test() {
  let result = utils.head_tail([10, 20, 30, 40])
  assert result == Ok(#(10, [20, 30, 40]))
}

pub fn head_tail_test_empty_list() {
  let result = utils.head_tail([])
  assert result == Error(Nil)
}

// utils.chunk_at_indicies
pub fn chunk_at_indicies_test() {
  let lst = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  let indicies = [0, 2, 5, 7]
  let chunks = utils.chunk_at_indicies(lst, indicies)
  assert chunks == [[1, 2], [3, 4, 5], [6, 7], [8, 9]]
}

// utils.validate
pub fn validate_success_test() {
  let result =
    utils.validate("42", fn(s) { int.parse(s) }, fn(_) { "NotAnInt" })
  assert result == Ok("42")
}

pub fn validate_failure_test() {
  let result =
    utils.validate("not_a_number", fn(s) { int.parse(s) }, fn(_) { "NotAnInt" })
  assert result == Error("NotAnInt")
}

// utils.success_indicies
pub fn success_indicies_test() {
  let list = ["1", "two", "3", "four", "5"]
  let indicies = utils.success_indicies(list, fn(s) { int.parse(s) })
  assert indicies == [0, 2, 4]
}
