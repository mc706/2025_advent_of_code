import day8/cartesian
import day8/connected_components
import day8/dsu
import gleam/int
import gleam/list
import gleam/order
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
  let result_1_dsu = problem_1_dsu(data)
  let result_2_dsu = problem_2_dsu(data)
  assert result_1 == result_1_dsu
  assert result_2 == result_2_dsu
  Ok(#(result_1, result_2))
}

fn problem_1_dsu(points: List(cartesian.Cartesesian)) -> Int {
  let distances =
    points
    |> list.combination_pairs
    |> list.map(fn(points) {
      let #(a, b) = points
      #(points, cartesian.distance_squared(a, b))
    })
    |> list.sort(fn(a, b) {
      let #(_, dist_a) = a
      let #(_, dist_b) = b
      int.compare(dist_a, dist_b)
    })
  let components = dsu.new(points)

  distances
  |> list.take(1000)
  |> list.fold(components, fn(acc, points_distance) {
    let #(#(a, b), _) = points_distance
    dsu.union(acc, a, b)
  })
  |> dsu.component_sizes
  |> list.sort(fn(a, b) { order.negate(int.compare(a, b)) })
  |> list.take(3)
  |> int.product
}

fn problem_2_dsu(points: List(cartesian.Cartesesian)) -> Int {
  let distances =
    points
    |> list.combination_pairs
    |> list.map(fn(points) {
      let #(a, b) = points

      #(points, cartesian.distance_squared(a, b))
    })
    |> list.sort(fn(a, b) {
      let #(_, dist_a) = a
      let #(_, dist_b) = b
      int.compare(dist_a, dist_b)
    })
  let dsu = dsu.new(points)
  let #(a, b) =
    connect_until_joint_dsu(distances, dsu)
    |> result.unwrap(#(
      cartesian.new_cartesian(0, 0, 0),
      cartesian.new_cartesian(0, 0, 0),
    ))
  let ax = cartesian.x(a)
  let ay = cartesian.x(b)
  ax * ay
}

fn problem_1(points: List(cartesian.Cartesesian)) -> Int {
  let distances =
    points
    |> list.combination_pairs
    |> list.map(fn(points) {
      let #(a, b) = points
      #(points, cartesian.distance_squared(a, b))
    })
    |> list.sort(fn(a, b) {
      let #(_, dist_a) = a
      let #(_, dist_b) = b
      int.compare(dist_a, dist_b)
    })
  let components = connected_components.new(points, cartesian.compare)

  distances
  |> list.take(1000)
  |> list.fold(components, fn(acc, points_distance) {
    let #(#(a, b), _) = points_distance
    connected_components.connect(acc, a, b)
  })
  |> connected_components.component_sizes
  |> list.sort(fn(a, b) { order.negate(int.compare(a, b)) })
  |> list.take(3)
  |> int.product
}

fn problem_2(points: List(cartesian.Cartesesian)) -> Int {
  let distances =
    points
    |> list.combination_pairs
    |> list.map(fn(points) {
      let #(a, b) = points

      #(points, cartesian.distance_squared(a, b))
    })
    |> list.sort(fn(a, b) {
      let #(_, dist_a) = a
      let #(_, dist_b) = b
      int.compare(dist_a, dist_b)
    })
  let components = connected_components.new(points, cartesian.compare)
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
  distances: List(#(#(cartesian.Cartesesian, cartesian.Cartesesian), Int)),
  components: connected_components.ConnectedComponents(cartesian.Cartesesian),
) -> Result(#(cartesian.Cartesesian, cartesian.Cartesesian), Nil) {
  case distances {
    [] -> Error(Nil)
    [first, ..rest] -> {
      let #(#(a, b), _) = first
      let new_components = connected_components.connect(components, a, b)
      case connected_components.is_fully_connected(new_components) {
        True -> {
          Ok(#(a, b))
        }
        False -> connect_until_joint(rest, new_components)
      }
    }
  }
}

fn connect_until_joint_dsu(
  distances: List(#(#(cartesian.Cartesesian, cartesian.Cartesesian), Int)),
  dsu: dsu.DSU(cartesian.Cartesesian),
) -> Result(#(cartesian.Cartesesian, cartesian.Cartesesian), Nil) {
  case distances {
    [] -> Error(Nil)
    [first, ..rest] -> {
      let #(#(a, b), _) = first
      let new_dsu = dsu.union(dsu, a, b)
      case dsu.is_fully_connected(new_dsu) {
        True -> Ok(#(a, b))
        False -> connect_until_joint_dsu(rest, new_dsu)
      }
    }
  }
}
