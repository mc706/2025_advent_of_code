import day1/day1
import day2/day2
import day3/day3
import day4/day4
import gleam/int
import gleam/io
import gleam/list
import shared

pub fn main() -> Nil {
  io.println("Hello from aoc2025!")
  [
    day1.main(),
    day2.main(),
    day3.main(),
    day4.main(),
  ]
  |> list.index_map(echo_results)
  Nil
}

fn echo_answer(day: Int, problem: Int, answer: Int) -> Nil {
  io.println(
    "Day "
    <> int.to_string(day + 1)
    <> " problem "
    <> int.to_string(problem)
    <> ": "
    <> int.to_string(answer),
  )
  Nil
}

fn echo_results(results: Result(#(Int, Int), shared.AppError), day: Int) -> Nil {
  case results {
    Ok(results) -> {
      let #(problem1, problem2) = results
      echo_answer(day, 1, problem1)
      echo_answer(day, 2, problem2)
    }
    Error(err) -> {
      echo err
      Nil
    }
  }
}
