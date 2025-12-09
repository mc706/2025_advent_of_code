//// Disjoint set unit (union find)

import gleam/dict
import gleam/int
import gleam/list
import gleam/result

pub opaque type DSU(a) {
  DSU(parents: dict.Dict(a, a))
}

pub fn new(elements: List(a)) -> DSU(a) {
  elements
  |> list.map(fn(element) { #(element, element) })
  |> dict.from_list
  |> DSU
}

pub fn find(dsu: DSU(a), element: a) -> #(DSU(a), a) {
  {
    use parent <- result.try(dict.get(dsu.parents, element))
    case parent == element {
      True -> Ok(#(dsu, parent))
      False -> {
        let #(updated_dsu, new_parent) = find(dsu, parent)
        let flattend_dsu = dict.insert(updated_dsu.parents, element, new_parent)
        Ok(#(DSU(flattend_dsu), new_parent))
      }
    }
  }
  |> result.unwrap(#(dsu, element))
}

pub fn union(dsu: DSU(a), left: a, right: a) -> DSU(a) {
  let #(dsu1, left_parent) = find(dsu, left)
  let #(dsu2, right_parent) = find(dsu1, right)
  let new_parents = dict.insert(dsu2.parents, left_parent, right_parent)
  DSU(new_parents)
}

pub fn connected(dsu: DSU(a), left: a, right: a) -> Bool {
  let #(dsu1, left_parent) = find(dsu, left)
  let #(_, right_parent) = find(dsu1, right)
  left_parent == right_parent
}

fn parent_list(dsu: DSU(a)) -> List(a) {
  dsu.parents
  |> dict.keys
  |> list.map(fn(element) {
    let #(_, parent) = find(dsu, element)
    parent
  })
}

pub fn component_sizes(dsu: DSU(a)) -> List(Int) {
  dsu
  |> parent_list
  |> list.fold(dict.new(), fn(acc, parent) {
    let count =
      dict.get(acc, parent)
      |> result.unwrap(0)
      |> int.add(1)
    dict.insert(acc, parent, count)
  })
  |> dict.values
}

pub fn component_count(dsu: DSU(a)) -> Int {
  dsu
  |> parent_list
  |> list.unique
  |> list.length
}

pub fn is_fully_connected(dsu: DSU(a)) -> Bool {
  component_count(dsu) == 1
}
