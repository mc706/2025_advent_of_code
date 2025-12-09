import gleam/list
import gleam/order
import gleam/result
import gleam/set
import utils

pub opaque type ConnectedComponents(a) {
  ConnectedComponents(
    components: List(set.Set(a)),
    cmp: fn(a, a) -> order.Order,
  )
}

pub fn new(
  items: List(a),
  compare: fn(a, a) -> order.Order,
) -> ConnectedComponents(a) {
  items
  |> list.map(list.wrap)
  |> list.map(set.from_list)
  |> ConnectedComponents(compare)
}

pub fn connect(
  cc: ConnectedComponents(a),
  left: a,
  right: a,
) -> ConnectedComponents(a) {
  let #(lower, higher) = utils.min_max(left, right, cc.cmp)
  let component_to_remove =
    cc.components
    |> list.find(fn(component) { set.contains(component, higher) })
    |> result.unwrap(set.new())
  cc.components
  |> list.filter_map(fn(component) {
    case set.contains(component, lower), set.contains(component, higher) {
      True, _ -> Ok(set.union(component, component_to_remove))
      False, True -> Error(Nil)
      _, _ -> Ok(component)
    }
  })
  |> ConnectedComponents(cc.cmp)
}

pub fn component_sizes(cc: ConnectedComponents(a)) -> List(Int) {
  cc.components
  |> list.map(set.size)
}

pub fn component_count(cc: ConnectedComponents(a)) -> Int {
  list.length(cc.components)
}

pub fn is_fully_connected(cc: ConnectedComponents(a)) -> Bool {
  component_count(cc) == 1
}
