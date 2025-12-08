import gleam/list
import gleam/order
import gleam/result
import utils

pub type ConnectedComponents(a) {
  ConnectedComponents(components: List(List(a)))
}

pub fn new(items: List(a)) -> ConnectedComponents(a) {
  items
  |> list.map(list.wrap)
  |> ConnectedComponents
}

pub fn components(cc: ConnectedComponents(a)) -> List(List(a)) {
  cc.components
}

pub fn connect(
  cc: ConnectedComponents(a),
  left: a,
  right: a,
  compare: fn(a, a) -> order.Order,
) -> ConnectedComponents(a) {
  let #(lower, higher) = utils.min_max(left, right, compare)
  let component_to_remove =
    cc.components
    |> list.find(fn(component) { list.contains(component, higher) })
    |> result.unwrap([])
  cc.components
  |> list.filter_map(fn(component) {
    case list.contains(component, lower), list.contains(component, higher) {
      True, _ -> Ok(list.append(component, component_to_remove) |> list.unique)
      False, True -> Error(Nil)
      _, _ -> Ok(component)
    }
  })
  |> ConnectedComponents
}

pub fn is_fully_connected(cc: ConnectedComponents(a)) -> Bool {
  case cc.components {
    [_] -> True
    _ -> False
  }
}
