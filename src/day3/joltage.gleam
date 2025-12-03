import gleam/int
import gleam/list
import gleam/result
import utils

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
  Ok(Joltage(utils.digits(as_number)))
}

@deprecated("Naive approach runs in ~O(n!)")
pub fn max_two_digit_activation_naive(joltage: Joltage) -> Int {
  joltage.value
  |> list.combinations(2)
  |> list.map(utils.undigits)
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
    0 -> digits |> list.reverse |> utils.undigits
    _ -> {
      let #(max_in_range, max_index) =
        utils.first_max_with_index_between(
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
