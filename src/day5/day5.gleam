import day2/range
import day5/database
import gleam/int
import gleam/list
import gleam/result
import shared.{type AppError}

pub fn main() -> Result(#(Int, Int), AppError) {
  use data <- result.try(shared.process_whole_input(
    "src/day5/input.txt",
    database.parse,
    shared.ParseDatabaseError,
  ))
  let result_1 = problem_1(data)
  let result_2 = problem_2(data)
  Ok(#(result_1, result_2))
}

fn problem_1(db: database.Database) -> Int {
  db
  |> database.condense_ranges
  |> database.ids
  |> list.filter(database.id_in_any_range(db, _))
  |> list.length()
}

fn problem_2(db: database.Database) -> Int {
  db
  |> database.condense_ranges
  |> database.fresh_ranges
  |> list.map(range.size)
  |> int.sum()
}
