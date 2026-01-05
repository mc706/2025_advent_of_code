import day12/puzzle.{type Region}
import day12/shape.{type Coordinate, type Shape}
import gleam/dict.{type Dict}
import gleam/list
import gleam/set.{type Set}

pub fn can_fit_presents(region: Region, shapes_dict: Dict(Int, Shape)) -> Bool {
  let present_list = expand_present_list(region.presents, [])
  solve(present_list, region.width, region.height, shapes_dict, set.new())
}

fn expand_present_list(counts: List(Int), acc: List(Int)) -> List(Int) {
  expand_present_list_helper(counts, acc, 0)
}

fn expand_present_list_helper(
  counts: List(Int),
  acc: List(Int),
  index: Int,
) -> List(Int) {
  case counts {
    [] -> list.reverse(acc)
    [count, ..rest] -> {
      let new_acc = add_n_times(index, count, acc)
      expand_present_list_helper(rest, new_acc, index + 1)
    }
  }
}

fn add_n_times(value: Int, times: Int, acc: List(Int)) -> List(Int) {
  case times {
    0 -> acc
    n -> add_n_times(value, n - 1, [value, ..acc])
  }
}

fn solve(
  presents_to_place: List(Int),
  width: Int,
  height: Int,
  shapes_dict: Dict(Int, Shape),
  occupied: Set(Coordinate),
) -> Bool {
  case presents_to_place {
    [] -> True
    [shape_id, ..rest] -> {
      case dict.get(shapes_dict, shape_id) {
        Error(_) -> False
        Ok(base_shape) -> {
          let orientations = shape.all_orientations(base_shape)
          try_place_shape(
            orientations,
            rest,
            width,
            height,
            shapes_dict,
            occupied,
          )
        }
      }
    }
  }
}

fn try_place_shape(
  orientations: List(Shape),
  remaining_presents: List(Int),
  width: Int,
  height: Int,
  shapes_dict: Dict(Int, Shape),
  occupied: Set(Coordinate),
) -> Bool {
  case orientations {
    [] -> False
    [orientation, ..rest_orientations] -> {
      let result =
        try_all_positions(
          orientation,
          0,
          0,
          width,
          height,
          remaining_presents,
          shapes_dict,
          occupied,
        )

      case result {
        True -> True
        False ->
          try_place_shape(
            rest_orientations,
            remaining_presents,
            width,
            height,
            shapes_dict,
            occupied,
          )
      }
    }
  }
}

fn try_all_positions(
  shape: Shape,
  x: Int,
  y: Int,
  width: Int,
  height: Int,
  remaining_presents: List(Int),
  shapes_dict: Dict(Int, Shape),
  occupied: Set(Coordinate),
) -> Bool {
  case y >= height {
    True -> False
    False -> {
      case x >= width {
        True ->
          try_all_positions(
            shape,
            0,
            y + 1,
            width,
            height,
            remaining_presents,
            shapes_dict,
            occupied,
          )
        False -> {
          let translated = shape.translate(shape, x, y)
          let fits = shape.fits_in_region(translated, width, height, occupied)

          case fits {
            True -> {
              let new_occupied = set.union(occupied, translated.cells)
              let can_continue =
                solve(
                  remaining_presents,
                  width,
                  height,
                  shapes_dict,
                  new_occupied,
                )

              case can_continue {
                True -> True
                False ->
                  try_all_positions(
                    shape,
                    x + 1,
                    y,
                    width,
                    height,
                    remaining_presents,
                    shapes_dict,
                    occupied,
                  )
              }
            }
            False ->
              try_all_positions(
                shape,
                x + 1,
                y,
                width,
                height,
                remaining_presents,
                shapes_dict,
                occupied,
              )
          }
        }
      }
    }
  }
}
