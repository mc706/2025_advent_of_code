import day1/dial
import day2/range
import day3/joltage
import day4/bit_grid
import day4/bool_grid
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type AppError {
  FileError(err: simplifile.FileError)
  ParseRotationError(err: dial.ParseRotationError)
  ParseRangeError(err: range.ParseRangeError)
  ParseJoltageError(err: joltage.ParseJoltageError)
  ParseBoolGridError(err: bool_grid.ParseGridError)
  ParseBitGridError(err: bit_grid.BitGridParseError)
}

fn read_input(path: String) -> Result(String, simplifile.FileError) {
  simplifile.read(path)
}

pub fn process_input(
  path: String,
  split_by: String,
  parser: fn(String) -> Result(t, e),
  error_mapper: fn(e) -> AppError,
) -> Result(List(t), AppError) {
  use input <- result.try(read_input(path) |> result.map_error(FileError))

  let input_lines = string.split(input, split_by)

  input_lines
  |> list.map(parser)
  |> result.all
  |> result.map_error(error_mapper)
}

pub fn process_whole_input(
  path: String,
  parser: fn(String) -> Result(t, e),
  error_mapper: fn(e) -> AppError,
) -> Result(t, AppError) {
  use input <- result.try(read_input(path) |> result.map_error(FileError))
  input
  |> parser
  |> result.map_error(error_mapper)
}
