import day2/product_id
import day2/range.{type Range}
import gleam/int
import gleam/list
import gleam/result
import shared.{type AppError}

pub fn main() -> Result(#(Int, Int), AppError) {
  use data <- result.try(shared.process_input(
    "src/day2/input.txt",
    ",",
    range.parse,
    shared.ParseRangeError,
  ))
  let result_1 = problem_1(data)
  let result_2 = problem_2(data)
  Ok(#(result_1, result_2))
}

fn problem_1(ranges: List(Range)) -> Int {
  ranges
  |> list.flat_map(range.to_list)
  |> list.filter(product_id.is_same_halves)
  |> int.sum
}

fn problem_2(ranges: List(Range)) -> Int {
  ranges
  |> list.flat_map(range.to_list)
  |> list.filter(product_id.is_repeating_sequence)
  |> int.sum
}
