import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import utils

pub opaque type BitGrid {
  BitGrid(data: Int, width: Int, size: Int)
}

pub fn new_bit_grid(width: Int, height: Int) -> BitGrid {
  BitGrid(0, width, width * height)
}

pub type Cord =
  #(Int, Int)

pub type BitGridParseError {
  InvalidFormat(Nil)
}

fn get_parse_size(raw: String) -> Result(#(Int, Int), BitGridParseError) {
  let size =
    raw
    |> string.replace("\n", "")
    |> string.length()
  use width <- result.try(
    raw
    |> string.split("\n")
    |> list.first()
    |> result.map(string.length)
    |> result.map_error(InvalidFormat),
  )
  Ok(#(width, size))
}

fn get_parse_bits(
  raw: String,
  true_value: String,
) -> Result(Int, BitGridParseError) {
  raw
  |> string.replace("\n", "")
  |> string.to_graphemes
  |> list.map(fn(char) {
    case char == true_value {
      True -> "1"
      False -> "0"
    }
  })
  |> string.join("")
  |> int.base_parse(2)
  |> result.map_error(InvalidFormat)
}

pub fn parse(
  raw: String,
  true_value: String,
) -> Result(BitGrid, BitGridParseError) {
  use #(width, size) <- result.try(get_parse_size(raw))
  use bits <- result.try(get_parse_bits(raw, true_value))
  Ok(BitGrid(bits, width, size))
}

/// convert x,y cord to int bitmask
fn cord_to_int(cord: Cord, grid: BitGrid) -> Int {
  let #(x, y) = cord
  let grid_pos = y * grid.width + x
  let left_shift = grid.size - grid_pos - 1
  int.bitwise_shift_left(1, left_shift)
}

/// predicate to ensure x,y cord is within grid bounds (cant relay on dict.get to error)
fn cord_in_bounds(cord: Cord, grid: BitGrid) -> Bool {
  let #(x, y) = cord
  x >= 0 && x < grid.width && y >= 0 && y < { grid.size / grid.width }
}

/// convert a power of 2 into x,y cord
fn int_to_cord(pos: Int, grid: BitGrid) -> Cord {
  let right_shift = grid.size - pos - 1
  let y = right_shift / grid.width
  let x = right_shift % grid.width
  #(x, y)
}

pub fn get(grid: BitGrid, cord: Cord) -> Result(Bool, Nil) {
  case cord_in_bounds(cord, grid) {
    False -> Error(Nil)
    True -> {
      let bit_mask = cord_to_int(cord, grid)
      Ok(int.bitwise_and(grid.data, bit_mask) != 0)
    }
  }
}

pub fn set(grid: BitGrid, cord: Cord, value: Bool) -> Result(BitGrid, Nil) {
  case cord_in_bounds(cord, grid) {
    False -> Error(Nil)
    True -> {
      let bit_mask = cord_to_int(cord, grid)
      let new_data = case value {
        True -> int.bitwise_or(grid.data, bit_mask)
        False -> int.bitwise_and(grid.data, int.bitwise_not(bit_mask))
      }
      Ok(BitGrid(new_data, grid.width, grid.size))
    }
  }
}

pub fn subtract(grid: BitGrid, mask: Int) -> BitGrid {
  BitGrid(
    int.bitwise_and(grid.data, int.bitwise_not(mask)),
    grid.width,
    grid.size,
  )
}

pub fn count(grid: BitGrid) -> Int {
  utils.count_set_bits(grid.data)
}

pub fn active_cords(grid: BitGrid) -> List(Cord) {
  grid.data
  |> utils.bit_positions
  |> list.map(int_to_cord(_, grid))
}

fn get_surrounding_mask(grid: BitGrid, cord: Cord) -> Int {
  utils.combination_pairs_with_replacement([-1, 0, 1])
  |> list.filter(utils.not_equal_to(#(0, 0), _))
  |> list.map(utils.pair_add(cord, _))
  |> list.filter(cord_in_bounds(_, grid))
  |> list.map(cord_to_int(_, grid))
  |> int.sum()
}

pub fn neighbors_count(grid: BitGrid, cord: Cord) -> Int {
  get_surrounding_mask(grid, cord)
  |> int.bitwise_and(grid.data, _)
  |> BitGrid(grid.width, grid.size)
  |> count
}

pub fn remove_where(
  grid: BitGrid,
  predicate: fn(BitGrid, Cord) -> Bool,
) -> BitGrid {
  active_cords(grid)
  |> list.filter(predicate(grid, _))
  |> list.map(cord_to_int(_, grid))
  |> int.sum()
  |> subtract(grid, _)
}

pub fn debug(grid: BitGrid) -> BitGrid {
  echo "BitGrid Debug:"
  echo grid
  echo active_cords(grid)
  grid
}
