import gleam/dict
import gleam/function
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub opaque type BoolGrid {
  BoolGrid(grid: dict.Dict(Int, dict.Dict(Int, Bool)))
}

pub type ParseGridError {
  InvalidFormat(msg: String)
}

pub type Cord =
  #(Int, Int)

pub fn parse(
  raw: String,
  true_value: String,
) -> Result(BoolGrid, ParseGridError) {
  raw
  |> string.split("\n")
  |> list.index_map(fn(row, y) {
    row
    |> string.to_graphemes
    |> list.index_map(fn(char, x) { #(x, char == true_value) })
    |> dict.from_list
    |> pair.new(y, _)
  })
  |> dict.from_list
  |> BoolGrid
  |> Ok
}

pub fn get(grid: BoolGrid, cord: Cord) -> Result(Bool, Nil) {
  let #(x, y) = cord
  dict.get(grid.grid, y)
  |> result.map(dict.get(_, x))
  |> result.flatten
}

pub fn set(grid: BoolGrid, cord: Cord, value: Bool) -> Result(BoolGrid, Nil) {
  let #(x, y) = cord
  let row =
    dict.get(grid.grid, y)
    |> result.map(dict.merge(_, dict.from_list([#(x, value)])))
  let new_grid =
    result.map(row, fn(new_row) {
      dict.merge(grid.grid, dict.from_list([#(y, new_row)]))
    })
  result.map(new_grid, BoolGrid)
}

pub fn to_list(grid: BoolGrid) -> List(#(Cord, Bool)) {
  grid.grid
  |> dict.to_list
  |> list.flat_map(fn(indexed_row) {
    let #(y, row) = indexed_row
    row
    |> dict.to_list
    |> list.map(fn(index_value) {
      let #(x, v) = index_value
      #(#(x, y), v)
    })
  })
}

pub fn count(grid: BoolGrid) -> Int {
  to_list(grid)
  |> list.count(pair.second)
}

pub fn active_cords(grid: BoolGrid) -> List(Cord) {
  to_list(grid)
  |> list.filter(pair.second)
  |> list.map(pair.first)
}

fn get_surrounding_indices(cord: Cord) -> List(Cord) {
  let #(x, y) = cord
  [
    #(x - 1, y - 1),
    #(x, y - 1),
    #(x + 1, y - 1),
    #(x - 1, y),
    #(x + 1, y),
    #(x - 1, y + 1),
    #(x, y + 1),
    #(x + 1, y + 1),
  ]
}

pub fn neighbors_count(grid: BoolGrid, cord: Cord) -> Int {
  get_surrounding_indices(cord)
  |> list.filter_map(get(grid, _))
  |> list.count(function.identity)
}

pub fn remove_where(
  grid: BoolGrid,
  predicate: fn(BoolGrid, Cord) -> Bool,
) -> #(BoolGrid, Int) {
  let to_remove =
    active_cords(grid)
    |> list.filter(predicate(grid, _))
  let new_grid =
    to_remove
    |> list.fold(grid, fn(acc, cord) {
      set(acc, cord, False)
      |> result.unwrap(acc)
    })
  #(new_grid, list.length(to_remove))
}
