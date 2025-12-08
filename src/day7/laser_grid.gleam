import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import utils

pub type LaserCell {
  Empty
  Splitter
  Laser
}

pub type PaserLaserGridError {
  InvalidCharacter(msg: String)
}

fn paser_laser_cell(char: String) -> Result(LaserCell, PaserLaserGridError) {
  case char {
    "." -> Ok(Empty)
    "^" -> Ok(Splitter)
    "|" -> Ok(Laser)
    "S" -> Ok(Laser)
    _ -> Error(InvalidCharacter(char))
  }
}

pub opaque type LaserGrid {
  LaserGrid(grid: List(List(LaserCell)))
}

fn new_laser_grid(grid: List(List(LaserCell))) -> LaserGrid {
  LaserGrid(grid)
}

pub fn rows(grid: LaserGrid) -> List(List(LaserCell)) {
  grid.grid
}

pub fn output(grid: LaserGrid) -> List(LaserCell) {
  grid.grid
  |> list.last
  |> result.unwrap([])
}

pub fn parse(raw: String) -> Result(LaserGrid, PaserLaserGridError) {
  raw
  |> string.split("\n")
  |> list.try_map(fn(row) {
    row
    |> string.to_graphemes
    |> list.try_map(paser_laser_cell)
  })
  |> result.map(LaserGrid)
}

pub fn simulate(grid: LaserGrid) -> LaserGrid {
  grid.grid
  |> list.fold([], simulate_step)
  |> list.reverse()
  |> new_laser_grid
}

fn simulate_step(
  acc: List(List(LaserCell)),
  row: List(LaserCell),
) -> List(List(LaserCell)) {
  case acc {
    [] -> [row]
    [prev, ..] -> [propogate_laser(prev, row), ..acc]
  }
}

fn propogate_laser(
  prev_row: List(LaserCell),
  row: List(LaserCell),
) -> List(LaserCell) {
  let previous_map = utils.indexed_dict_from_list(prev_row)
  let row_map = utils.indexed_dict_from_list(row)
  row
  |> list.index_map(fn(cell, index) {
    case cell {
      Empty -> {
        case
          dict.get(previous_map, index),
          // above
          dict.get(row_map, index + 1),
          // right
          dict.get(row_map, index - 1)
        {
          // left
          Ok(Laser), _, _ -> Laser
          _, Ok(Splitter), _ -> {
            dict.get(previous_map, index + 1) |> result.unwrap(Empty)
          }
          _, _, Ok(Splitter) -> {
            dict.get(previous_map, index - 1) |> result.unwrap(Empty)
          }
          _, _, _ -> cell
        }
      }
      _ -> cell
    }
  })
}

pub fn simulate_counting_splits(grid: LaserGrid) -> #(LaserGrid, Int) {
  let #(new_grid, split_count) =
    grid.grid
    |> list.fold(#([], 0), simulate_step_counting_splits)
  let final_grid = new_grid |> list.reverse() |> new_laser_grid
  #(final_grid, split_count)
}

fn simulate_step_counting_splits(
  acc: #(List(List(LaserCell)), Int),
  row: List(LaserCell),
) -> #(List(List(LaserCell)), Int) {
  let #(grid_acc, split_count) = acc
  case grid_acc {
    [] -> #([row], split_count)
    [prev, ..] -> {
      let #(new_row, new_splits) = propogate_laser_counting_splits(prev, row)
      #([new_row, ..grid_acc], split_count + new_splits)
    }
  }
}

fn propogate_laser_counting_splits(
  prev_row: List(LaserCell),
  row: List(LaserCell),
) -> #(List(LaserCell), Int) {
  let previous_map = utils.indexed_dict_from_list(prev_row)
  let row_map = utils.indexed_dict_from_list(row)
  let #(new_row, new_splits) =
    row
    |> list.index_map(fn(cell, index) {
      case cell {
        Empty -> {
          case
            dict.get(previous_map, index),
            // above
            dict.get(row_map, index + 1),
            // right
            dict.get(row_map, index - 1)
          {
            // left
            Ok(Laser), _, _ -> #(Laser, 0)
            _, Ok(Splitter), _ -> {
              let new_cell =
                dict.get(previous_map, index + 1) |> result.unwrap(Empty)
              #(new_cell, 0)
            }
            _, _, Ok(Splitter) -> {
              let new_cell =
                dict.get(previous_map, index - 1) |> result.unwrap(Empty)
              #(new_cell, 0)
            }
            _, _, _ -> #(cell, 0)
          }
        }
        Splitter -> {
          case dict.get(previous_map, index) {
            Ok(Laser) -> #(cell, 1)
            _ -> #(cell, 0)
          }
        }
        _ -> #(cell, 0)
      }
    })
    |> list.unzip
  #(new_row, int.sum(new_splits))
}

pub fn count_timelines(grid: LaserGrid) -> Int {
  grid
  |> simulate
  |> rows
  |> list.fold(dict.new(), propagate_timelines)
  |> dict.values
  |> int.sum
}

fn propagate_timelines(
  acc: dict.Dict(Int, Int),
  row: List(LaserCell),
) -> dict.Dict(Int, Int) {
  row
  |> list.index_fold(acc, fn(acc_dict, cell, index) {
    case cell {
      Empty -> acc_dict
      Splitter -> {
        case dict.get(acc_dict, index) {
          Ok(input_value) -> {
            acc_dict
            |> dict.drop([index])
            |> dict.upsert(index - 1, fn(existing_value) {
              case existing_value {
                option.Some(v) -> v + input_value
                option.None -> input_value
              }
            })
            |> dict.upsert(index + 1, fn(existing_value) {
              case existing_value {
                option.Some(v) -> v + input_value
                option.None -> input_value
              }
            })
          }

          _ -> acc_dict
        }
      }
      Laser -> {
        case dict.is_empty(acc_dict) {
          True -> dict.insert(acc_dict, index, 1)
          False -> acc_dict
        }
      }
    }
  })
}

pub fn debug(grid: LaserGrid) -> LaserGrid {
  grid.grid
  |> list.map(fn(row) {
    row
    |> list.map(fn(cell) {
      case cell {
        Empty -> "."
        Splitter -> "^"
        Laser -> "|"
      }
    })
    |> string.join("")
  })
  |> list.map(io.println)
  grid
}
