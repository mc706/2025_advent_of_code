import gleam/int
import gleam/list
import gleam/result
import gleam/string
import utils

pub type Operation {
  Sum
  Product
}

fn parse_operation(op_str: String) -> Result(Operation, ParseWorksheetError) {
  case string.trim(op_str) {
    "+" -> Ok(Sum)
    "*" -> Ok(Product)
    _ -> Error(InvalidFormat("Invalid operation in worksheet: " <> op_str))
  }
}

pub type Column =
  #(Operation, List(String))

pub opaque type Worksheet {
  Worksheet(columns: List(Column))
}

pub type ParseWorksheetError {
  InvalidWorksheetError(Nil)
  InvalidFormat(msg: String)
  InvalidNumber(Nil)
}

pub fn parse(input: String) -> Result(Worksheet, ParseWorksheetError) {
  let lines = input |> string.split("\n")
  use #(operations, numbers) <- result.try(
    list.reverse(lines)
    |> utils.head_tail
    |> result.map_error(InvalidWorksheetError),
  )
  let column_indicies =
    operations
    |> string.to_graphemes
    |> utils.success_indicies(parse_operation)
  use parsed_operations <- result.try(
    operations
    |> string.split(" ")
    |> list.filter(utils.not_equal_to(_, ""))
    |> list.try_map(parse_operation),
  )
  use parsed_numbers <- result.try(
    numbers
    |> list.reverse
    |> list.try_map(fn(row_str) {
      row_str
      |> string.to_graphemes
      |> utils.chunk_at_indicies(column_indicies)
      |> list.map(string.join(_, ""))
      |> list.try_map(utils.validate(
        _,
        fn(s) { int.parse(string.trim(s)) },
        InvalidNumber,
      ))
    })
    |> result.map(list.transpose),
  )

  list.zip(parsed_operations, parsed_numbers)
  |> Worksheet
  |> Ok
}

pub fn columns(worksheet: Worksheet) -> List(Column) {
  worksheet.columns
}

pub fn evalulate_as_int(column: Column) -> Int {
  let #(operation, values) = column
  let numbers =
    values
    |> list.map(fn(s) { string.trim(s) |> int.parse() |> result.unwrap(0) })
  case operation {
    Sum -> int.sum(numbers)
    Product -> int.product(numbers)
  }
}

pub fn evaluate_as_cephalopod(column: Column) -> Int {
  let #(operation, values) = column
  let numbers =
    values
    |> list.map(string.to_graphemes)
    |> list.transpose
    |> list.map(string.join(_, ""))
    |> list.map(string.trim)
    |> list.filter_map(int.parse)
  case operation {
    Sum -> int.sum(numbers)
    Product -> int.product(numbers)
  }
}
