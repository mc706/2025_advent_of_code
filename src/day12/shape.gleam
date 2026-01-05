import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

pub type Shape {
  Shape(id: Int, cells: Set(Coordinate))
}

pub fn new_shape(id: Int, cells: Set(Coordinate)) -> Shape {
  Shape(id: id, cells: cells)
}

pub fn parse_shape(id: Int, lines: List(String)) -> Shape {
  let cells =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(char, x) {
        case char {
          "#" -> Ok(Coordinate(x, y))
          _ -> Error(Nil)
        }
      })
      |> list.filter_map(fn(r) { r })
    })
    |> list.flatten
    |> set.from_list

  new_shape(id, cells)
}

pub fn rotate_90(shape: Shape) -> Shape {
  let new_cells =
    shape.cells
    |> set.to_list
    |> list.map(fn(coord) { Coordinate(-coord.y, coord.x) })
    |> set.from_list
  Shape(..shape, cells: new_cells)
}

pub fn flip_horizontal(shape: Shape) -> Shape {
  let new_cells =
    shape.cells
    |> set.to_list
    |> list.map(fn(coord) { Coordinate(-coord.x, coord.y) })
    |> set.from_list
  Shape(..shape, cells: new_cells)
}

pub fn normalize(shape: Shape) -> Shape {
  let cells_list = set.to_list(shape.cells)
  case cells_list {
    [] -> shape
    _ -> {
      let min_x =
        cells_list
        |> list.map(fn(c) { c.x })
        |> list.fold(999_999, int_min)
      let min_y =
        cells_list
        |> list.map(fn(c) { c.y })
        |> list.fold(999_999, int_min)

      let normalized_cells =
        cells_list
        |> list.map(fn(coord) { Coordinate(coord.x - min_x, coord.y - min_y) })
        |> set.from_list

      Shape(..shape, cells: normalized_cells)
    }
  }
}

fn int_min(a: Int, b: Int) -> Int {
  case a < b {
    True -> a
    False -> b
  }
}

pub fn translate(shape: Shape, dx: Int, dy: Int) -> Shape {
  let new_cells =
    shape.cells
    |> set.to_list
    |> list.map(fn(coord) { Coordinate(coord.x + dx, coord.y + dy) })
    |> set.from_list
  Shape(..shape, cells: new_cells)
}

pub fn all_orientations(shape: Shape) -> List(Shape) {
  let rotations = [
    shape,
    rotate_90(shape),
    rotate_90(rotate_90(shape)),
    rotate_90(rotate_90(rotate_90(shape))),
  ]

  let flipped =
    rotations
    |> list.map(flip_horizontal)

  list.append(rotations, flipped)
  |> list.map(normalize)
  |> list.unique
}

pub fn fits_in_region(
  shape: Shape,
  width: Int,
  height: Int,
  occupied: Set(Coordinate),
) -> Bool {
  shape.cells
  |> set.to_list
  |> list.all(fn(coord) {
    coord.x >= 0
    && coord.x < width
    && coord.y >= 0
    && coord.y < height
    && !set.contains(occupied, coord)
  })
}
