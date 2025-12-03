import day3/joltage
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// joltage.parse
pub fn joltage_parse_valid_test() {
  should.be_ok(joltage.parse("15"))
  should.be_ok(joltage.parse("0"))
  should.be_ok(joltage.parse("123"))
}

pub fn joltage_parse_invalid_test() {
  should.be_error(joltage.parse("abc"))
  should.be_error(joltage.parse("five"))
  should.be_error(joltage.parse("12.3"))
}

// joltage.max_activation
pub fn joltage_max_activation_2_test() {
  let joltage = should.be_ok(joltage.parse("11191910"))
  let max_activation = joltage.max_activation(joltage, 2)
  assert max_activation == 99
}

pub fn joltage_max_activation_3_test() {
  let joltage = should.be_ok(joltage.parse("9876543210"))
  let max_activation = joltage.max_activation(joltage, 3)
  assert max_activation == 987
}

pub fn joltage_edge_case_test() {
  let joltage = should.be_ok(joltage.parse("1"))
  let max_activation_2 = joltage.max_activation(joltage, 3)
  assert max_activation_2 < -1
  // Not enough digits
}
