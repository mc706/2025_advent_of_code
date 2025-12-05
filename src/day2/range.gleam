import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub opaque type Range {
  Range(start: Int, end: Int)
}

pub fn new_range(start: Int, end: Int) -> Range {
  Range(start, end)
}

pub type ParseRangeError {
  InvalidFormat(msg: String)
  InvalidNumber(msg: String)
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

pub fn contains(range: Range, value: Int) -> Bool {
  value >= range.start && value <= range.end
}

pub fn overlaps(range1: Range, range2: Range) -> Bool {
  contains(range1, range2.start)
  || contains(range1, range2.end)
  || contains(range2, range1.start)
  || contains(range2, range1.end)
}

pub fn size(range: Range) -> Int {
  range.end - range.start + 1
}

pub fn merge(range1: Range, range2: Range) -> Range {
  new_range(
    int.min(range1.start, range2.start),
    int.max(range1.end, range2.end),
  )
}

pub fn compare(range1: Range, range2: Range) -> order.Order {
  int.compare(range1.start, range2.start)
}

pub fn merge_all(ranges: List(Range)) -> List(Range) {
  let sorted_ranges = list.sort(ranges, compare)
  merge_all_loop(sorted_ranges, [])
}

fn merge_all_loop(ranges: List(Range), merged: List(Range)) -> List(Range) {
  case ranges {
    [] -> merged
    [first, ..rest] -> {
      case merged {
        [] -> merge_all_loop(rest, [first])
        [last_merged, ..merged_rest] -> {
          case overlaps(last_merged, first) {
            True -> {
              let new_merged = merge(last_merged, first)
              merge_all_loop(rest, [new_merged, ..merged_rest])
            }
            False -> {
              merge_all_loop(rest, [first, last_merged, ..merged_rest])
            }
          }
        }
      }
    }
  }
}
