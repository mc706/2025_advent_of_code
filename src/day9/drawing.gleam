import day4/bool_grid
import day9/coordinate
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/set
import gleam/string
import utils

pub opaque type Drawing {
  Drawing(bits: bool_grid.BoolGrid, coords: List(coordinate.Cord))
}

pub fn new(coords: List(coordinate.Cord)) -> Drawing {
  let bits = bool_grid.new()
  Drawing(bits, coords)
  |> draw_points
  |> draw_lines
  |> flood_fill
}

fn draw_points(drawing: Drawing) -> Drawing {
  drawing.coords
  |> list.fold(drawing.bits, fn(acc, coord) {
    bool_grid.set(acc, coord, True)
    |> result.unwrap(acc)
  })
  |> Drawing(drawing.coords)
}

fn line(a: #(Int, Int), b: #(Int, Int)) -> List(#(Int, Int)) {
  let #(ax, ay) = a
  let #(bx, by) = b
  case ax == bx, ay == by {
    True, False -> list.range(ay, by) |> list.map(fn(y) { #(ax, y) })

    False, True -> list.range(ax, bx) |> list.map(fn(x) { #(x, ay) })
    _, _ -> []
  }
}

fn draw_lines(drawing: Drawing) -> Drawing {
  drawing.coords
  |> utils.wrap_one
  |> list.window_by_2
  |> list.fold(drawing.bits, fn(acc, pair) {
    let #(a, b) = pair
    line(a, b)
    |> list.fold(acc, fn(acc2, coord) {
      bool_grid.set(acc2, coord, True)
      |> result.unwrap(acc2)
    })
  })
  |> Drawing(drawing.coords)
}

fn flood_fill(drawing: Drawing) -> Drawing {
  let start_coords =
    drawing.coords
    |> list.max(fn(a, b) {
      let #(ax, ay) = a
      let #(bx, by) = b
      int.compare(ay, by)
      |> order.negate
      |> order.break_tie(order.negate(int.compare(ax, bx)))
    })
    |> result.unwrap(#(0, 0))
    |> fn(coord) {
      let #(x, y) = coord
      #(x + 1, y + 1)
    }

  drawing.bits
  |> flood_fill_rec([start_coords], set.new())
  |> Drawing(drawing.coords)
}

fn flood_fill_rec(
  bits: bool_grid.BoolGrid,
  to_visit: List(coordinate.Cord),
  visited: set.Set(coordinate.Cord),
) -> bool_grid.BoolGrid {
  echo "R"
    <> int.to_string(list.length(to_visit))
    <> "/"
    <> int.to_string(set.size(visited))
  case to_visit {
    [] -> bits
    [first, ..rest] -> {
      case set.contains(visited, first) {
        True -> flood_fill_rec(bits, rest, visited)
        False -> {
          let new_visited = set.insert(visited, first)
          let new_bits =
            bool_grid.set(bits, first, True)
            |> result.unwrap(bits)
          let neighbors =
            bool_grid.get_surrounding_indices(first)
            |> list.filter(fn(coord) {
              bool_grid.get(bits, coord)
              |> result.unwrap(False)
              == False
            })
          flood_fill_rec(new_bits, list.append(rest, neighbors), new_visited)
        }
      }
    }
  }
}

fn rectangle_coordinates(
  a: coordinate.Cord,
  b: coordinate.Cord,
) -> List(coordinate.Cord) {
  let #(ax, ay) = a
  let #(bx, by) = b
  let x_range = list.range(int.min(ax, bx), int.max(ax, bx))
  let y_range = list.range(int.min(ay, by), int.max(ay, by))
  x_range
  |> list.flat_map(fn(x) {
    y_range
    |> list.map(fn(y) { #(x, y) })
  })
}

pub fn overlaps(
  drawing: Drawing,
  a: coordinate.Cord,
  b: coordinate.Cord,
) -> Bool {
  rectangle_coordinates(a, b)
  |> list.all(fn(coord) {
    bool_grid.get(drawing.bits, coord)
    |> result.unwrap(False)
  })
}
