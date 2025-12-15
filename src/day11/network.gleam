import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub opaque type Network {
  Network(connections: Dict(String, List(String)))
}

pub fn new_network(connections: Dict(String, List(String))) -> Network {
  Network(connections)
}

pub type ParseNetworkError {
  MissingColon(msg: String)
}

pub fn parse(input: String) -> Result(Network, ParseNetworkError) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_line)
  |> result.all
  |> result.map(dict.from_list)
  |> result.map(new_network)
}

fn parse_line(
  line: String,
) -> Result(#(String, List(String)), ParseNetworkError) {
  use #(device, outputs) <- result.try(
    string.split_once(line, ": ")
    |> result.replace_error(MissingColon(line)),
  )
  let output_list = string.split(outputs, " ")
  Ok(#(device, output_list))
}

pub fn count_paths(network: Network, start: String, end: String) -> Int {
  count_paths_rec(network, start, end, set.new())
}

fn count_paths_rec(
  network: Network,
  current: String,
  target: String,
  visited: Set(String),
) -> Int {
  case current == target {
    True -> 1
    False -> {
      let new_visited = set.insert(visited, current)
      case dict.get(network.connections, current) {
        Error(_) -> 0
        Ok(outputs) -> {
          outputs
          |> list.filter(fn(node) { !set.contains(visited, node) })
          |> list.map(count_paths_rec(network, _, target, new_visited))
          |> int.sum
        }
      }
    }
  }
}

pub fn count_paths_with_waypoints(
  network: Network,
  start: String,
  end: String,
  waypoints: List(String),
) -> Int {
  count_paths_with_waypoints_rec(
    network,
    start,
    end,
    waypoints,
    set.new(),
    set.new(),
  )
}

fn count_paths_with_waypoints_rec(
  network: Network,
  current: String,
  target: String,
  required_waypoints: List(String),
  visited: Set(String),
  found_waypoints: Set(String),
) -> Int {
  case current == target {
    True -> {
      case
        list.all(required_waypoints, fn(wp) {
          set.contains(found_waypoints, wp)
        })
      {
        True -> 1
        False -> 0
      }
    }
    False -> {
      let new_visited = set.insert(visited, current)
      let new_found_waypoints = case
        list.contains(required_waypoints, current)
      {
        True -> set.insert(found_waypoints, current)
        False -> found_waypoints
      }

      case dict.get(network.connections, current) {
        Error(_) -> 0
        Ok(outputs) -> {
          outputs
          |> list.filter(fn(node) { !set.contains(visited, node) })
          |> list.map(count_paths_with_waypoints_rec(
            network,
            _,
            target,
            required_waypoints,
            new_visited,
            new_found_waypoints,
          ))
          |> int.sum
        }
      }
    }
  }
}
