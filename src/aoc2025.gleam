import day1/day1
import day2/day2
import day3/day3
import day4/day4
import day5/day5
import day6/day6
import day7/day7
import day8/day8
import gleam/int
import gleam/io
import gleam/list
import gleam/time/duration
import gleam/time/timestamp
import shared

pub fn main() -> Nil {
  io.println("Hello from aoc2025!")
  [
    measure_performance(day1.main, "Day 1"),
    measure_performance(day2.main, "Day 2"),
    measure_performance(day3.main, "Day 3"),
    measure_performance(day4.main, "Day 4"),
    measure_performance(day5.main, "Day 5"),
    measure_performance(day6.main, "Day 6"),
    measure_performance(day7.main, "Day 7"),
    measure_performance(day8.main, "Day 8"),
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

fn measure_performance(func: fn() -> a, name: String) -> a {
  let start = timestamp.system_time()
  let result = func()
  let end = timestamp.system_time()
  let duration = timestamp.difference(start, end)
  let #(seconds, nano_seconds) = duration.to_seconds_and_nanoseconds(duration)
  io.println(
    "Execution time ("
    <> name
    <> "): "
    <> int.to_string(seconds)
    <> "s "
    <> int.to_string(nano_seconds / 1_000_000)
    <> "ms",
  )
  result
}
