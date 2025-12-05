import day2/range
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// range.parse_range
pub fn range_parse_valid_test() {
  let result = range.parse("5-10")
  should.be_ok(result)
}

pub fn range_parse_invalid_format_test() {
  let result = range.parse("5to10")
  should.be_error(result)
}

pub fn range_parse_invalid_numbers_test() {
  let result = range.parse("five-ten")
  should.be_error(result)
}

// range.to_list
pub fn range_to_list_test() {
  let r = should.be_ok(range.parse("3-7"))
  let lst = range.to_list(r)
  assert lst == [3, 4, 5, 6, 7]
}

// range.contains
pub fn range_contains_true_test() {
  let r = should.be_ok(range.parse("10-20"))
  assert range.contains(r, 15)
  assert range.contains(r, 10)
  assert range.contains(r, 20)
}

pub fn range_contains_false_test() {
  let r = should.be_ok(range.parse("10-20"))
  assert !range.contains(r, 9)
  assert !range.contains(r, 21)
}

// range.overlaps
pub fn range_overlaps_true_test() {
  let r1 = should.be_ok(range.parse("5-15"))
  let r2 = should.be_ok(range.parse("10-20"))
  assert range.overlaps(r1, r2)
  assert range.overlaps(r2, r1)
}

pub fn range_overlaps_false_test() {
  let r1 = should.be_ok(range.parse("1-5"))
  let r2 = should.be_ok(range.parse("6-10"))
  assert !range.overlaps(r1, r2)
  assert !range.overlaps(r2, r1)
}

// range.size
pub fn range_size_test() {
  let r = should.be_ok(range.parse("10-15"))
  let sz = range.size(r)
  assert sz == 6
}

// range.merge
pub fn range_merge_test() {
  let r1 = should.be_ok(range.parse("5-10"))
  let r2 = should.be_ok(range.parse("8-15"))
  let merged = range.merge(r1, r2)
  let lst = range.to_list(merged)
  assert lst == [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
}
