import day2/product_id
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// product_id.is_same_halves
pub fn is_same_halves_true_test() {
  assert product_id.is_same_halves(1212)
  assert product_id.is_same_halves(123_123)
  assert product_id.is_same_halves(11)
}

pub fn is_same_halves_false_test() {
  assert !product_id.is_same_halves(1234)
  assert !product_id.is_same_halves(123_124)
  assert !product_id.is_same_halves(1)
}

// product_id.is_repeating_sequence
pub fn is_repeating_sequence_true_test() {
  assert product_id.is_repeating_sequence(1212)
  assert product_id.is_repeating_sequence(123_123)
  assert product_id.is_repeating_sequence(1111)
  assert product_id.is_repeating_sequence(121_212)
}

pub fn is_repeating_sequence_false_test() {
  assert !product_id.is_repeating_sequence(1234)
  assert !product_id.is_repeating_sequence(123_124)
  assert !product_id.is_repeating_sequence(1)
}
