import day9/coordinate
import day9/drawing
import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import shared.{type AppError}

pub fn main() -> Result(#(Int, Int), AppError) {
  use data <- result.try(shared.process_input(
    "src/day9/input.txt",
    "\n",
    coordinate.parse,
    shared.ParseCoordinateError,
  ))
  let result_1 = problem_1(data)
  let result_2 = problem_2(data)
  Ok(#(result_1, result_2))
}

fn problem_1(coords: List(coordinate.Cord)) -> Int {
  coords
  |> list.combination_pairs
  |> list.map(fn(pair) {
    let #(a, b) = pair
    coordinate.rect_area(a, b)
  })
  |> list.max(int.compare)
  |> result.unwrap(-1)
}

fn problem_2(coords: List(coordinate.Cord)) -> Int {
  let drawing =
    coords
    |> drawing.new
  echo "Drawing done"
  coords
  |> list.combination_pairs
  |> list.filter_map(fn(pair) {
    let #(a, b) = pair
    case drawing.intersects_shell(drawing, a, b) {
      True -> Error(Nil)
      False -> Ok(coordinate.rect_area(a, b))
    }
  })
  |> list.max(int.compare)
  |> result.unwrap(-1)
}
