import day4/bit_grid
import day4/bool_grid
import gleam/list
import gleam/result
import shared.{type AppError}
import utils

pub fn main() -> Result(#(Int, Int), AppError) {
  use data <- result.try(shared.process_whole_input(
    "src/day4/input.txt",
    bool_grid.parse(_, "@"),
    shared.ParseBoolGridError,
  ))
  let result_1 = problem_1(data)
  let result_2 = problem_2(data)

  use data2 <- result.try(shared.process_whole_input(
    "src/day4/input.txt",
    bit_grid.parse(_, "@"),
    shared.ParseBitGridError,
  ))
  let bit_1 = bit_1(data2)
  let bit_2 = bit_2(data2)
  assert result_1 == bit_1
  assert result_2 == bit_2
  Ok(#(result_1, result_2))
}

fn problem_1(grid: bool_grid.BoolGrid) -> Int {
  grid
  |> bool_grid.active_cords
  |> list.map(bool_grid.neighbors_count(grid, _))
  |> list.count(utils.less_than(_, 4))
}

fn bit_1(grid: bit_grid.BitGrid) -> Int {
  grid
  |> bit_grid.active_cords
  |> list.map(bit_grid.neighbors_count(grid, _))
  |> list.count(utils.less_than(_, 4))
}

fn problem_2(grid: bool_grid.BoolGrid) -> Int {
  let start = bool_grid.count(grid)
  let final_grid = remove_loop(grid, active_neighbor_count_predicate)
  let end = bool_grid.count(final_grid)
  start - end
}

fn bit_2(grid: bit_grid.BitGrid) -> Int {
  let start = bit_grid.count(grid)
  let final_grid = bit_remove_loop(grid, active_neighbor_count_predicate_bit)
  let end = bit_grid.count(final_grid)
  start - end
}

fn active_neighbor_count_predicate(
  grid: bool_grid.BoolGrid,
  cord: bool_grid.Cord,
) -> Bool {
  bool_grid.neighbors_count(grid, cord) < 4
}

fn active_neighbor_count_predicate_bit(
  grid: bit_grid.BitGrid,
  cord: bit_grid.Cord,
) -> Bool {
  bit_grid.neighbors_count(grid, cord) < 4
}

fn remove_loop(
  grid: bool_grid.BoolGrid,
  predicate: fn(bool_grid.BoolGrid, bool_grid.Cord) -> Bool,
) -> bool_grid.BoolGrid {
  let #(new_grid, remove_count) = bool_grid.remove_where(grid, predicate)
  case remove_count {
    0 -> new_grid
    _ -> remove_loop(new_grid, predicate)
  }
}

fn bit_remove_loop(
  grid: bit_grid.BitGrid,
  predicate: fn(bit_grid.BitGrid, bit_grid.Cord) -> Bool,
) -> bit_grid.BitGrid {
  let new_grid = bit_grid.remove_where(grid, predicate)
  case bit_grid.count(grid) - bit_grid.count(new_grid) {
    0 -> new_grid
    _ -> bit_remove_loop(new_grid, predicate)
  }
}
