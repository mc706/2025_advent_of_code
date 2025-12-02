import gleam/int
import gleam/list
import gleam/result
import gleam/string

import day1/dial.{type Position, type Rotation}
import day1/errors
import shared

pub fn main() -> Result(#(Int, Int), shared.AppError) {
  use result_1 <- result.try(problem_1())
  use result_2 <- result.try(problem_2())
  Ok(#(result_1, result_2))
}

fn problem_1() -> Result(Int, shared.AppError) {
  use turns <- result.try(read_and_parse_input())
  turns
  |> apply_turns
  |> list.count(dial.is_zero)
  |> Ok
}

fn problem_2() -> Result(Int, shared.AppError) {
  use turns <- result.try(read_and_parse_input())
  turns
  |> apply_turns_counting_zeros
  |> Ok
}

fn read_and_parse_input() -> Result(List(Rotation), shared.AppError) {
  use content <- result.try(
    shared.read_input("src/day1/input-1.txt")
    |> result.map_error(shared.FileError),
  )
  use turns <- result.try(
    parse_input(content)
    |> result.map_error(shared.ParseRotationError),
  )
  Ok(turns)
}

fn parse_input(
  input: String,
) -> Result(List(Rotation), errors.ParseRotationError) {
  input
  |> string.split("\n")
  |> list.map(dial.parse_rotation)
  |> result.all
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
    |> list.count(fn(result) { dial.is_zero(result.0) })
  let counted_zeros =
    results
    |> list.map(fn(result) { result.1 })
    |> int.sum
  positional_zeros + counted_zeros
}
