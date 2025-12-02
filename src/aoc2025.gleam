import day1/day1
import day2/day2
import gleam/int
import gleam/io

pub fn main() -> Nil {
  io.println("Hello from aoc2025!")
  case day1.main() {
    Ok(results) -> {
      let #(problem1, problem2) = results
      io.println("Day 1 problem 1: " <> int.to_string(problem1))
      io.println("Day 1 problem 2: " <> int.to_string(problem2))
      Nil
    }
    Error(err) -> {
      echo err
      Nil
    }
  }

  case day2.main() {
    Ok(results) -> {
      let #(problem1, problem2) = results
      io.println("Day 2 problem 1: " <> int.to_string(problem1))
      io.println("Day 2 problem 2: " <> int.to_string(problem2))
      Nil
    }
    Error(err) -> {
      echo err
      Nil
    }
  }
}
