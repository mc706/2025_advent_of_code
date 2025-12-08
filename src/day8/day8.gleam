import day8/cartesian
import day8/connected_components
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import shared.{type AppError}

pub fn main() -> Result(#(Int, Int), AppError) {
  use data <- result.try(shared.process_input(
    "src/day8/input.txt",
    "\n",
    cartesian.parse,
    shared.ParseCartesianError,
  ))
  let result_1 = problem_1(data)
  let result_2 = problem_2(data)
  Ok(#(result_1, result_2))
}

fn problem_1(points: List(cartesian.Cartesesian)) -> Int {
  let distances =
    points
    |> list.combination_pairs
    |> list.map(fn(points) {
      let #(a, b) = points

      #(points, cartesian.distance(a, b) |> result.unwrap(0.0))
    })
    |> list.sort(fn(a, b) {
      let #(_, dist_a) = a
      let #(_, dist_b) = b
      float.compare(dist_a, dist_b)
    })
  let components = connected_components.new(points)

  distances
  |> list.take(1000)
  |> list.fold(components, fn(acc, points_distance) {
    let #(#(a, b), _) = points_distance
    connected_components.connect(acc, a, b, cartesian.compare)
  })
  |> connected_components.components
  |> list.map(list.length)
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> int.product
}

fn problem_2(points: List(cartesian.Cartesesian)) -> Int {
  let distances =
    points
    |> list.combination_pairs
    |> list.map(fn(points) {
      let #(a, b) = points

      #(points, cartesian.distance(a, b) |> result.unwrap(0.0))
    })
    |> list.sort(fn(a, b) {
      let #(_, dist_a) = a
      let #(_, dist_b) = b
      float.compare(dist_a, dist_b)
    })
  let components = connected_components.new(points)
  let #(a, b) =
    connect_until_joint(distances, components)
    |> result.unwrap(#(
      cartesian.new_cartesian(0, 0, 0),
      cartesian.new_cartesian(0, 0, 0),
    ))
  let ax = cartesian.x(a)
  let ay = cartesian.x(b)
  ax * ay
}

fn connect_until_joint(
  distances: List(#(#(cartesian.Cartesesian, cartesian.Cartesesian), Float)),
  components: connected_components.ConnectedComponents(cartesian.Cartesesian),
) -> Result(#(cartesian.Cartesesian, cartesian.Cartesesian), Nil) {
  case distances {
    [] -> Error(Nil)
    [first, ..rest] -> {
      let #(#(a, b), _) = first
      let new_components =
        connected_components.connect(components, a, b, cartesian.compare)
      case connected_components.is_fully_connected(new_components) {
        True -> Ok(#(a, b))
        False -> connect_until_joint(rest, new_components)
      }
    }
  }
}
