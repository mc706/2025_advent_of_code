import day2/errors
import day2/range.{type Range}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import shared.{type AppError}

pub fn main() -> Result(#(Int, Int), AppError) {
  use result_1 <- result.try(problem_1())
  use result_2 <- result.try(problem_2())
  Ok(#(result_1, result_2))
}

fn problem_1() -> Result(Int, AppError) {
  use ranges <- result.try(read_and_parse_input())
  ranges
  |> list.flat_map(range.to_list)
  |> list.filter(is_invalid_product_id)
  |> int.sum
  |> Ok
}

fn problem_2() -> Result(Int, AppError) {
  use ranges <- result.try(read_and_parse_input())
  ranges
  |> list.flat_map(range.to_list)
  |> list.filter(is_part_two_invalid)
  |> int.sum
  |> Ok
}

fn read_and_parse_input() -> Result(List(Range), AppError) {
  use content <- result.try(
    shared.read_input("src/day2/input.txt")
    |> result.map_error(shared.FileError),
  )
  use ranges <- result.try(
    parse_input(content)
    |> result.map_error(shared.ParseRangeError),
  )
  Ok(ranges)
}

fn parse_input(input: String) -> Result(List(Range), errors.ParseRangeError) {
  input
  |> string.split(",")
  |> list.map(range.parse)
  |> result.all
}

fn split_halfway(s: String) -> #(String, String) {
  let length = string.length(s)
  let first_half = string.slice(s, 0, length / 2)
  let second_half = string.slice(s, length / 2, length)
  #(first_half, second_half)
}

fn is_invalid_product_id(product_id: Int) -> Bool {
  let #(first_half, second_half) = split_halfway(int.to_string(product_id))
  first_half == second_half
}

fn is_part_two_invalid(product_id: Int) -> Bool {
  let product_id_str = int.to_string(product_id)
  is_made_of_repeating_sequences(product_id_str, 1)
}

fn is_made_of_repeating_sequences(string: String, sequence_length: Int) -> Bool {
  let length = string.length(string)
  let segment = string.slice(string, 0, sequence_length)
  case string.repeat(segment, length / sequence_length) {
    _ if length == 1 -> False
    _ if sequence_length * 2 > length -> False
    repeated if repeated == string -> True
    _ -> is_made_of_repeating_sequences(string, sequence_length + 1)
  }
}
