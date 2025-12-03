import day3/joltage
import gleam/int
import gleam/list
import gleam/result
import shared.{type AppError}

pub fn main() -> Result(#(Int, Int), AppError) {
  use data <- result.try(shared.process_input(
    "src/day3/input.txt",
    "\n",
    joltage.parse,
    shared.ParseJoltageError,
  ))
  let result_1 = problem_1(data)
  let result_2 = problem_2(data)
  Ok(#(result_1, result_2))
}

fn problem_1(joltages: List(joltage.Joltage)) -> Int {
  joltages
  |> list.map(joltage.max_activation(_, 2))
  |> int.sum
}

fn problem_2(joltages: List(joltage.Joltage)) -> Int {
  joltages
  |> list.map(joltage.max_activation(_, 12))
  |> int.sum
}
