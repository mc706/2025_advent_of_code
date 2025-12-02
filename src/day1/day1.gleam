import gleam/int
import gleam/list
import gleam/pair
import gleam/result

import day1/dial.{type Position, type Rotation}
import shared

pub fn main() -> Result(#(Int, Int), shared.AppError) {
  use data <- result.try(shared.process_input(
    "src/day1/input.txt",
    "\n",
    dial.parse_rotation,
    shared.ParseRotationError,
  ))
  let result_1 = problem_1(data)
  let result_2 = problem_2(data)
  Ok(#(result_1, result_2))
}

fn problem_1(turns: List(Rotation)) -> Int {
  turns
  |> apply_turns
  |> list.count(dial.is_zero)
}

fn problem_2(turns: List(Rotation)) -> Int {
  turns
  |> apply_turns_counting_zeros
}

fn apply_turns(turns: List(Rotation)) -> List(Position) {
  list.scan(turns, dial.new_position(50), dial.apply_rotation)
}

fn apply_turns_counting_zeros(turns: List(Rotation)) -> Int {
  let results =
    list.scan(
      turns,
      #(dial.new_position(50), 0),
      dial.apply_rotation_counting_zeros,
    )
  let positional_zeros =
    results
    |> list.map(pair.first)
    |> list.count(dial.is_zero)
  let counted_zeros =
    results
    |> list.map(pair.second)
    |> int.sum
  positional_zeros + counted_zeros
}
