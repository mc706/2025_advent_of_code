import day1/dial
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// dail.new_position
pub fn dail_new_position_negatives_wrap_test() {
  let pos1 = dial.new_position(-1)
  let pos2 = dial.new_position(99)
  assert pos1 == pos2
}

pub fn dial_new_position_wrap_test() {
  let pos1 = dial.new_position(100)
  let pos2 = dial.new_position(0)
  assert pos1 == pos2
}

pub fn dial_new_position_large_value_wrap_test() {
  let pos1 = dial.new_position(2050)
  let pos2 = dial.new_position(50)
  assert pos1 == pos2
}

// dial.parse_rotation
pub fn dial_parse_rotation_left_test() {
  let result = dial.parse_rotation("L30")
  should.be_ok(result)
}

pub fn dial_parse_rotation_right_test() {
  let result = dial.parse_rotation("R45")
  should.be_ok(result)
}

pub fn dial_parse_rotation_invalid_prefix_test() {
  let result = dial.parse_rotation("X20")
  should.be_error(result)
}

pub fn dial_parse_rotation_invalid_number_test() {
  let result = dial.parse_rotation("LXX")
  should.be_error(result)
}

// dial.apply_rotation
pub fn dial_apply_rotation_left_test() {
  let position = dial.new_position(50)
  let rotation = should.be_ok(dial.parse_rotation("L30"))
  let new_position = dial.apply_rotation(position, rotation)
  assert new_position == dial.new_position(20)
}

pub fn dial_apply_rotation_right_test() {
  let position = dial.new_position(80)
  let rotation = should.be_ok(dial.parse_rotation("R50"))
  let new_position = dial.apply_rotation(position, rotation)
  assert new_position == dial.new_position(30)
}

// dial.is_zero
pub fn dial_is_zero_true_test() {
  let position = dial.new_position(0)
  assert dial.is_zero(position) == True
}

pub fn dial_is_zero_false_test() {
  let position = dial.new_position(25)
  assert dial.is_zero(position) == False
}

// dial.apply_rotation_counting_zeros
pub fn dial_apply_rotation_counting_zeros_left_past_zero_test() {
  let position = dial.new_position(10)
  let rotation = should.be_ok(dial.parse_rotation("L20"))
  let #(new_position, zero_count) =
    dial.apply_rotation_counting_zeros(#(position, 0), rotation)
  assert new_position == dial.new_position(90)
  assert zero_count == 1
}
