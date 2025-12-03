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
