import day1/day1
import day10/day10
import day2/day2
import day3/day3
import day4/day4
import day5/day5
import day6/day6
import day7/day7
import day8/day8
import day9/day9
import gleam/int
import gleam/io
import gleam/list
import gleam/time/duration
import gleam/time/timestamp
import shared

pub fn main() -> Nil {
  io.println("Hello from aoc2025!")
  [
    // day1.main,
    // day2.main,
    // day3.main,
    // day4.main,
    // day5.main,
    // day6.main,
    // day7.main,
    // day8.main,
    // day9.main,
    day10.main,
  ]
  |> list.index_map(evalutate)
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

fn evalutate(
  func: fn() -> Result(#(Int, Int), shared.AppError),
  day: Int,
) -> Nil {
  let day_str = int.to_string(day + 1)
  io.println("Evaluating Day " <> day_str <> "...")
  echo_results(measure_performance(func), day)
  io.println("-------------------------------------")
}

fn measure_performance(func: fn() -> a) -> a {
  let start = timestamp.system_time()
  let result = func()
  let end = timestamp.system_time()
  let duration = timestamp.difference(start, end)
  let #(seconds, nano_seconds) = duration.to_seconds_and_nanoseconds(duration)
  io.println(
    "Execution time: "
    <> int.to_string(seconds)
    <> "s "
    <> int.to_string(nano_seconds / 1_000_000)
    <> "ms",
  )
  result
}
