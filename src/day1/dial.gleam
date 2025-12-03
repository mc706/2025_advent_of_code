import gleam/int
import gleam/result
import utils

pub opaque type Position {
  Position(current: Int)
}

pub opaque type Rotation {
  Left(ticks: Int)
  Right(ticks: Int)
}

/// Normalizes Position numbers to be within 0-99
pub fn new_position(i: Int) -> Position {
  Position({ { { i % 100 } + 100 } % 100 })
}

pub type ParseRotationError {
  MissingPrefix(msg: String)
  InvalidNumber(msg: String)
}

pub fn parse_rotation(rotation: String) -> Result(Rotation, ParseRotationError) {
  case rotation {
    "L" <> ticks ->
      ticks
      |> int.parse
      |> result.map_error(fn(_) { InvalidNumber(rotation) })
      |> result.map(Left)
    "R" <> ticks ->
      ticks
      |> int.parse
      |> result.map_error(fn(_) { InvalidNumber(rotation) })
      |> result.map(Right)
    _ -> Error(MissingPrefix(rotation <> " does not start with L or R"))
  }
}

pub fn apply_rotation(position: Position, rotation: Rotation) -> Position {
  case rotation {
    Left(ticks) -> new_position(position.current - ticks)
    Right(ticks) -> new_position(position.current + ticks)
  }
}

pub fn is_zero(position: Position) -> Bool {
  position.current == 0
}

fn count_zeros(position: Position, rotation: Rotation) -> Int {
  case rotation {
    Left(ticks) -> {
      let #(full_turns, remainder) = utils.div_mod(ticks, 100)
      let turns_past_zero =
        utils.bool_to_int(
          position.current - remainder < 0 && position.current != 0,
        )
      full_turns + turns_past_zero
    }
    Right(ticks) -> {
      let #(full_turns, remainder) = utils.div_mod(ticks, 100)
      let turns_past_zero =
        utils.bool_to_int(position.current + remainder > 100)
      full_turns + turns_past_zero
    }
  }
}

pub fn apply_rotation_counting_zeros(
  position_with_zeros: #(Position, Int),
  rotation: Rotation,
) -> #(Position, Int) {
  let #(position, _) = position_with_zeros
  #(apply_rotation(position, rotation), count_zeros(position, rotation))
}
