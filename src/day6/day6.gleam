import day6/worksheet
import gleam/int
import gleam/list
import gleam/result
import shared.{type AppError}

pub fn main() -> Result(#(Int, Int), AppError) {
  use data <- result.try(shared.process_whole_input(
    "src/day6/input.txt",
    worksheet.parse,
    shared.ParseWorksheetError,
  ))
  let result_1 = problem_1(data)
  let result_2 = problem_2(data)
  Ok(#(result_1, result_2))
}

fn problem_1(ws: worksheet.Worksheet) -> Int {
  ws
  |> worksheet.columns
  |> list.map(worksheet.evalulate_as_int)
  |> int.sum
}

fn problem_2(ws: worksheet.Worksheet) -> Int {
  ws
  |> worksheet.columns
  |> list.map(worksheet.evaluate_as_cephalopod)
  |> int.sum
}
