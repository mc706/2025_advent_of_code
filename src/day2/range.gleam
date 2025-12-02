import day2/errors.{type ParseRangeError, InvalidFormat, InvalidNumber}
import gleam/int
import gleam/list
import gleam/string

pub type Range {
  Range(start: Int, end: Int)
}

pub fn new_range(start: Int, end: Int) -> Range {
  Range(start, end)
}

pub fn parse(input: String) -> Result(Range, ParseRangeError) {
  case string.split(input, "-") {
    [start_str, end_str] -> {
      case int.parse(start_str), int.parse(end_str) {
        Ok(s), Ok(e) -> Ok(new_range(s, e))
        _, _ -> Error(InvalidNumber("Invalid numbers in range: " <> input))
      }
    }
    _ -> Error(InvalidFormat(input <> " is not in the format start-end"))
  }
}

pub fn to_list(range: Range) -> List(Int) {
  list.range(range.start, range.end)
}
