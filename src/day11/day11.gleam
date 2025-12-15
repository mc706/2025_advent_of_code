import day11/network
import gleam/result
import shared.{type AppError}

pub fn main() -> Result(#(Int, Int), AppError) {
  use data <- result.try(shared.process_whole_input(
    "src/day11/input.txt",
    network.parse,
    shared.ParseNetworkError,
  ))
  let result_1 = problem_1(data)
  let result_2 = problem_2(data)
  Ok(#(result_1, result_2))
}

fn problem_1(net: network.Network) -> Int {
  network.count_paths(net, "you", "out")
}

fn problem_2(net: network.Network) -> Int {
  network.count_paths_with_waypoints(net, "svr", "out", ["dac", "fft"])
}
