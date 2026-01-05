import day12/puzzle
import day12/solver
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import shared.{type AppError}

pub fn main() -> Result(#(Int, Int), AppError) {
  io.println("Starting day12...")
  use data <- result.try(shared.process_whole_input(
    "src/day12/test.txt",
    puzzle.parse,
    shared.ParsePuzzleError,
  ))
  io.println("Parsed input successfully")
  io.println("Number of regions: " <> int.to_string(list.length(data.regions)))
  let result_1 = problem_1(data)
  let result_2 = 0
  Ok(#(result_1, result_2))
}

fn problem_1(puz: puzzle.Puzzle) -> Int {
  io.println("Starting problem_1...")
  puz.regions
  |> list.index_map(fn(region, idx) {
    io.println("Testing region " <> int.to_string(idx + 1))
    #(region, solver.can_fit_presents(region, puz.shapes))
  })
  |> list.filter(fn(pair) { pair.1 })
  |> list.length
}
