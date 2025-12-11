import day10/machine
import gleam/int
import gleam/list
import gleam/result
import shared.{type AppError}

pub fn main() -> Result(#(Int, Int), AppError) {
  use data <- result.try(shared.process_input(
    "src/day10/input.txt",
    "\n",
    machine.parse,
    shared.ParseMachineError,
  ))
  let result_1 = problem_1(data)
  let result_2 = problem_2(data)
  Ok(#(result_1, result_2))
}

fn problem_1(machines: List(machine.Machine)) -> Int {
  //   machines
  //   |> list.map(machine.find_shortest_button_sequence_length)
  //   |> int.sum
  -1
}

fn problem_2(machines: List(machine.Machine)) -> Int {
  machines
  |> list.map(machine.find_shortest_joltage_sequence)
  |> int.sum
}
