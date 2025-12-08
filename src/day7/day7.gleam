import day7/laser_grid
import gleam/pair
import gleam/result
import shared.{type AppError}

pub fn main() -> Result(#(Int, Int), AppError) {
  use data <- result.try(shared.process_whole_input(
    "src/day7/input.txt",
    laser_grid.parse,
    shared.ParseLaserGridError,
  ))
  let result_1 = problem_1(data)
  let result_2 = problem_2(data)
  Ok(#(result_1, result_2))
}

fn problem_1(lg: laser_grid.LaserGrid) -> Int {
  lg
  |> laser_grid.simulate_counting_splits
  |> pair.second
}

fn problem_2(lg: laser_grid.LaserGrid) -> Int {
  lg
  |> laser_grid.count_timelines
}
