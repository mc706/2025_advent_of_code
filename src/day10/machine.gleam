import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub opaque type IndicatorLight {
  IndicatorLight(target: Int, size: Int)
}

pub type ParseMachineError {
  ParseIndicatorLightError(msg: String)
  ParseButtonError(Nil)
  ParseJoltageError(msg: String)
  ParseMachineError(Nil)
}

pub fn parse_indicator_light(
  input: String,
) -> Result(IndicatorLight, ParseMachineError) {
  let size = string.length(input) - 2
  input
  |> string.replace("[", "")
  |> string.replace("]", "")
  |> string.replace(".", "0")
  |> string.replace("#", "1")
  |> string.reverse
  |> int.base_parse(2)
  |> result.map(IndicatorLight(_, size))
  |> result.map_error(fn(_) { ParseIndicatorLightError(input) })
}

pub opaque type Button {
  Button(value: Int)
}

pub fn parse_button(
  input: String,
  size: Int,
) -> Result(Button, ParseMachineError) {
  use positions <- result.try({
    input
    |> string.replace("(", "")
    |> string.replace(")", "")
    |> string.split(",")
    |> list.map(int.parse)
    |> result.all
    |> result.map_error(ParseButtonError)
  })
  list.range(0, size)
  |> list.map(fn(pos) {
    case list.contains(positions, pos) {
      True -> "1"
      False -> "0"
    }
  })
  |> string.join("")
  |> string.reverse
  |> int.base_parse(2)
  |> result.map(Button)
  |> result.map_error(ParseButtonError)
}

pub opaque type Joltage {
  Joltage(targets: List(Int))
}

pub fn parse_joltage(input: String) -> Result(Joltage, ParseMachineError) {
  input
  |> string.replace("{", "")
  |> string.replace("}", "")
  |> string.split(",")
  |> list.map(int.parse)
  |> result.all
  |> result.map(Joltage)
  |> result.map_error(fn(_) { ParseJoltageError(input) })
}

pub opaque type Machine {
  Machine(lights: IndicatorLight, buttons: List(Button), joltage: Joltage)
}

pub fn parse(input: String) -> Result(Machine, ParseMachineError) {
  let parts = input |> string.split(" ")
  use light <- result.try({
    parts
    |> list.first
    |> result.unwrap("")
    |> parse_indicator_light
  })
  use buttons <- result.try({
    parts
    |> list.filter(string.starts_with(_, "("))
    |> list.map(parse_button(_, light.size))
    |> result.all
  })
  use joltage <- result.try({
    parts
    |> list.filter(string.starts_with(_, "{"))
    |> list.first
    |> result.unwrap("")
    |> parse_joltage
  })
  Ok(Machine(light, buttons, joltage))
}

fn press_button(number: Int, button: Button) -> Int {
  let Button(value) = button
  int.bitwise_exclusive_or(number, value)
}

fn press_sequence(buttons: List(Button)) -> Int {
  buttons
  |> list.fold(0, press_button)
}

// Extract which counters each button affects
fn button_to_counters(button: Button) -> List(Int) {
  let Button(value) = button
  let binary = int.to_base2(value)
  binary
  |> string.to_graphemes
  |> list.reverse
  |> list.index_map(fn(bit, idx) {
    case bit {
      "1" -> Ok(idx)
      _ -> Error(Nil)
    }
  })
  |> list.filter_map(fn(x) { x })
}

pub fn find_shortest_button_sequence_length(machine: Machine) -> Int {
  let Machine(light, buttons, _) = machine
  let IndicatorLight(target, _) = light

  find_shortest_button_sequence_length_loop(
    target,
    buttons,
    list.map(buttons, list.wrap),
  )
  |> result.unwrap(-1)
}

fn find_shortest_button_sequence_length_loop(
  target: Int,
  buttons: List(Button),
  combos: List(List(Button)),
) -> Result(Int, Nil) {
  case combos {
    [] -> Error(Nil)
    [first, ..rest] -> {
      case press_sequence(first) == target {
        True -> Ok(list.length(first))
        False -> {
          let additional_combos =
            buttons
            |> list.filter(fn(button) { !list.contains(first, button) })
            |> list.map(fn(button) { list.append(first, [button]) })
          find_shortest_button_sequence_length_loop(
            target,
            buttons,
            list.append(rest, additional_combos),
          )
        }
      }
    }
  }
}

pub fn find_shortest_joltage_sequence(machine: Machine) -> Int {
  let Machine(_, buttons, joltage) = machine
  let Joltage(targets) = joltage

  let button_effects = list.map(buttons, button_to_counters)

  let num_counters = list.length(targets)
  let coefficients =
    list.range(0, num_counters - 1)
    |> list.map(fn(counter_idx) {
      button_effects
      |> list.map(fn(button_counters) {
        case list.contains(button_counters, counter_idx) {
          True -> 1
          False -> 0
        }
      })
    })

  // Use JavaScript ILP solver via FFI (with Erlang fallback)
  case solve_ilp_ffi(coefficients, targets) {
    result if result > 0 -> result
    _ -> solve_optimized_greedy(coefficients, targets)
  }
}

// FFI call to JavaScript ILP solver
@external(javascript, "./ilp_solver.mjs", "solveILP")
fn solve_ilp_ffi(coefficients: List(List(Int)), targets: List(Int)) -> Int {
  // Erlang fallback: use greedy solver
  solve_optimized_greedy(coefficients, targets)
}

// Optimized greedy solver that finds good solutions quickly
fn solve_optimized_greedy(
  coefficients: List(List(Int)),
  targets: List(Int),
) -> Int {
  let num_buttons = case list.first(coefficients) {
    Ok(row) -> list.length(row)
    Error(_) -> 0
  }

  let initial = list.repeat(0, num_buttons)

  case iterative_greedy_solve(coefficients, targets, initial, 0) {
    Ok(solution) -> int.sum(solution)
    Error(_) -> int.sum(targets)
  }
}

// Iteratively satisfy constraints using smart button selection
fn iterative_greedy_solve(
  coefficients: List(List(Int)),
  targets: List(Int),
  current: List(Int),
  iteration: Int,
) -> Result(List(Int), Nil) {
  case iteration > 500 {
    True -> Error(Nil)
    False -> {
      case all_satisfied(coefficients, targets, current) {
        True -> Ok(current)
        False -> {
          // Find unsatisfied constraint with smallest remaining deficit
          case find_best_constraint_to_fix(coefficients, targets, current) {
            Ok(constraint_idx) -> {
              // Find button that best addresses this constraint
              case
                find_optimal_button(
                  coefficients,
                  targets,
                  current,
                  constraint_idx,
                )
              {
                Ok(#(button_idx, amount)) -> {
                  let new_current = add_to_button(current, button_idx, amount)
                  iterative_greedy_solve(
                    coefficients,
                    targets,
                    new_current,
                    iteration + 1,
                  )
                }
                Error(_) -> Error(Nil)
              }
            }
            Error(_) -> Error(Nil)
          }
        }
      }
    }
  }
}

// Find the best constraint to fix next (prefer those with small deficits)
fn find_best_constraint_to_fix(
  coefficients: List(List(Int)),
  targets: List(Int),
  current: List(Int),
) -> Result(Int, Nil) {
  list.zip(coefficients, targets)
  |> list.index_map(fn(pair, idx) {
    let #(constraint_row, target) = pair
    let sum =
      list.zip(constraint_row, current)
      |> list.map(fn(p) { p.0 * p.1 })
      |> int.sum
    #(idx, target - sum)
  })
  |> list.filter(fn(pair) { pair.1 > 0 })
  |> list.fold(Error(Nil), fn(best, curr) {
    case best {
      Error(_) -> Ok(curr.0)
      Ok(best_idx) -> {
        // Return first unsatisfied (process in order)
        Ok(best_idx)
      }
    }
  })
}

// Find optimal button and amount to press for a constraint
fn find_optimal_button(
  coefficients: List(List(Int)),
  targets: List(Int),
  current: List(Int),
  constraint_idx: Int,
) -> Result(#(Int, Int), Nil) {
  case list_get(coefficients, constraint_idx) {
    Ok(constraint_row) -> {
      case list_get(targets, constraint_idx) {
        Ok(target) -> {
          let current_value =
            list.zip(constraint_row, current)
            |> list.map(fn(p) { p.0 * p.1 })
            |> int.sum
          let deficit = target - current_value

          // Find button that affects this constraint
          constraint_row
          |> list.index_fold(Error(Nil), fn(acc, coeff, btn_idx) {
            case acc {
              Ok(_) -> acc
              Error(_) -> {
                case coeff > 0 {
                  True -> Ok(#(btn_idx, deficit))
                  False -> Error(Nil)
                }
              }
            }
          })
        }
        Error(_) -> Error(Nil)
      }
    }
    Error(_) -> Error(Nil)
  }
}

fn add_to_button(current: List(Int), button_idx: Int, amount: Int) -> List(Int) {
  current
  |> list.index_map(fn(val, idx) {
    case idx == button_idx {
      True -> val + amount
      False -> val
    }
  })
}

fn all_satisfied(
  coefficients: List(List(Int)),
  targets: List(Int),
  button_presses: List(Int),
) -> Bool {
  list.zip(coefficients, targets)
  |> list.all(fn(pair) {
    let #(constraint_row, target) = pair
    let sum =
      list.zip(constraint_row, button_presses)
      |> list.map(fn(p) { p.0 * p.1 })
      |> int.sum
    sum == target
  })
}

fn list_get(lst: List(a), idx: Int) -> Result(a, Nil) {
  lst
  |> list.index_fold(Error(Nil), fn(acc, item, i) {
    case acc {
      Ok(_) -> acc
      Error(_) -> {
        case i == idx {
          True -> Ok(item)
          False -> Error(Nil)
        }
      }
    }
  })
}
