import day1/day1
import day2/day2
import gleam/int
import gleam/io
import gleam/list
import shared

pub fn main() -> Nil {
  io.println("Hello from aoc2025!")
  [
    day1.main(),
    day2.main(),
  ]
  |> list.index_map(echo_results)
  Nil
}

fn echo_results(results: Result(#(Int, Int), shared.AppError), day: Int) -> Nil {
  case results {
    Ok(results) -> {
      let #(problem1, problem2) = results
      io.println(
        "Day "
        <> int.to_string(day + 1)
        <> " problem 1: "
        <> int.to_string(problem1),
      )
      io.println(
        "Day "
        <> int.to_string(day + 1)
        <> " problem 2: "
        <> int.to_string(problem2),
      )
      Nil
    }
    Error(err) -> {
      echo err
      Nil
    }
  }
}
