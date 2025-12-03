import gleam/int
import gleam/list
import gleam/result

pub opaque type Joltage {
  Joltage(value: List(Int))
}

pub type ParseJoltageError {
  InvalidJoltageNumber(msg: String)
}

pub fn parse(input: String) -> Result(Joltage, ParseJoltageError) {
  use as_number <- result.try(
    int.parse(input)
    |> result.map_error(fn(_) {
      InvalidJoltageNumber(input <> " is not a valid integer")
    }),
  )
  use digits <- result.try(
    int.digits(as_number, 10)
    |> result.map_error(fn(_) {
      InvalidJoltageNumber(input <> " contains invalid digits")
    }),
  )
  Ok(Joltage(digits))
}

@deprecated("Naive approach runs in ~O(n!)")
pub fn max_two_digit_activation_naive(joltage: Joltage) -> Int {
  joltage.value
  |> list.combinations(2)
  |> list.map(int.undigits(_, 10))
  |> result.values
  |> list.max(int.compare)
  |> result.unwrap(0)
}

pub fn max_activation(joltage: Joltage, digits_count: Int) -> Int {
  max_activation_loop(joltage, [], digits_count, 0)
}

fn max_activation_loop(
  joltage: Joltage,
  digits: List(Int),
  remaining_digits: Int,
  from_index: Int,
) -> Int {
  case remaining_digits {
    // unsafe unwrap but digits list will never be empty for valid Joltage
    0 -> digits |> list.reverse |> int.undigits(10) |> result.unwrap(0)
    _ -> {
      let #(max_in_range, max_index) =
        first_max_with_index_between(
          joltage.value,
          from_index,
          list.length(joltage.value) - remaining_digits + 1,
        )
      max_activation_loop(
        joltage,
        [max_in_range, ..digits],
        remaining_digits - 1,
        max_index + 1,
      )
    }
  }
}

fn first_max_with_index_between(
  ints: List(Int),
  from_index: Int,
  to_index: Int,
) -> #(Int, Int) {
  list.index_fold(ints, #(-1, -1), fn(acc, i, index) {
    case { from_index <= index && index < to_index }, i > acc.0 {
      False, _ -> acc
      True, True -> #(i, index)
      True, False -> acc
    }
  })
}
