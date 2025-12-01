import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

import day1/dial.{type ParseRotationError, type Position, type Rotation}

pub fn main() -> Result(#(Int, Int), AppError) {
  use result_1 <- result.try(problem_1())
  use result_2 <- result.try(problem_2())
  Ok(#(result_1, result_2))
}

pub type AppError {
  FileError(err: simplifile.FileError)
  ParseRotationError(err: ParseRotationError)
}

fn problem_1() -> Result(Int, AppError) {
  use turns <- result.try(read_and_parse_input())
  turns
  |> apply_turns
  |> list.count(dial.is_zero)
  |> Ok
}

fn problem_2() -> Result(Int, AppError) {
  use turns <- result.try(read_and_parse_input())
  turns
  |> apply_turns_counting_zeros
  |> Ok
}

fn read_and_parse_input() -> Result(List(Rotation), AppError) {
  use content <- result.try(
    read_input()
    |> result.map_error(FileError),
  )
  use turns <- result.try(
    parse_input(content)
    |> result.map_error(ParseRotationError),
  )
  Ok(turns)
}

fn read_input() -> Result(String, simplifile.FileError) {
  simplifile.read("src/day1/input-1.txt")
}

fn parse_input(input: String) -> Result(List(Rotation), ParseRotationError) {
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
