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
      let start = int.parse(start_str)
      let end = int.parse(end_str)
      case start, end {
        Ok(s), Ok(e) -> Ok(new_range(s, e))
        Error(_), _ ->
          Error(InvalidNumber("Invalid start number: " <> start_str))
        _, Error(_) -> Error(InvalidNumber("Invalid end number: " <> end_str))
      }
    }
    _ -> Error(InvalidFormat(input <> " is not in the format start-end"))
  }
}

pub fn to_list(range: Range) -> List(Int) {
  list.range(range.start, range.end)
}
