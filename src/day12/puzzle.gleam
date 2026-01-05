import day12/shape.{type Shape}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Region {
  Region(width: Int, height: Int, presents: List(Int))
}

pub type Puzzle {
  Puzzle(shapes: Dict(Int, Shape), regions: List(Region))
}

pub type ParsePuzzleError {
  InvalidShapeId(msg: String)
  InvalidRegionFormat(msg: String)
  InvalidDimension(msg: String)
}

pub fn parse(input: String) -> Result(Puzzle, ParsePuzzleError) {
  let lines =
    input
    |> string.trim
    |> string.split("\n")

  // Find the line that separates shapes from regions (first line with "x" in it)
  let split_index = find_region_start(lines, 0)

  case split_index {
    Ok(idx) -> {
      let shape_lines = list.take(lines, idx)
      let region_lines = list.drop(lines, idx)

      use shapes <- result.try(parse_shapes(shape_lines))
      use regions <- result.try(parse_regions(region_lines))
      Ok(Puzzle(shapes: shapes, regions: regions))
    }
    Error(_) -> Error(InvalidRegionFormat("Could not find region section"))
  }
}

fn find_region_start(lines: List(String), index: Int) -> Result(Int, Nil) {
  case lines {
    [] -> Error(Nil)
    [line, ..rest] -> {
      case string.contains(line, "x") && string.contains(line, ":") {
        True -> Ok(index)
        False -> find_region_start(rest, index + 1)
      }
    }
  }
}

fn parse_shapes(
  lines: List(String),
) -> Result(Dict(Int, Shape), ParsePuzzleError) {
  lines
  |> group_shape_lines([], [])
  |> list.map(parse_shape_lines_to_shape)
  |> result.all
  |> result.map(dict.from_list)
}

fn group_shape_lines(
  lines: List(String),
  current: List(String),
  acc: List(List(String)),
) -> List(List(String)) {
  case lines {
    [] -> {
      case current {
        [] -> list.reverse(acc)
        _ -> list.reverse([list.reverse(current), ..acc])
      }
    }
    [line, ..rest] -> {
      case string.length(line) {
        0 -> {
          case current {
            [] -> group_shape_lines(rest, [], acc)
            _ -> group_shape_lines(rest, [], [list.reverse(current), ..acc])
          }
        }
        _ -> group_shape_lines(rest, [line, ..current], acc)
      }
    }
  }
}

fn parse_shape_lines_to_shape(
  lines: List(String),
) -> Result(#(Int, Shape), ParsePuzzleError) {
  case lines {
    [header, ..shape_lines] -> {
      case string.split(header, ":") {
        [id_str, ..] -> {
          use id <- result.try(
            int.parse(id_str)
            |> result.replace_error(InvalidShapeId(id_str)),
          )
          let shape = shape.parse_shape(id, shape_lines)
          Ok(#(id, shape))
        }
        _ -> Error(InvalidShapeId(header))
      }
    }
    _ -> Error(InvalidShapeId("Empty shape block"))
  }
}

fn parse_regions(lines: List(String)) -> Result(List(Region), ParsePuzzleError) {
  lines
  |> list.filter(fn(line) { string.length(line) > 0 })
  |> list.map(parse_region_line)
  |> result.all
}

fn parse_region_line(line: String) -> Result(Region, ParsePuzzleError) {
  case string.split_once(line, ": ") {
    Ok(#(dimensions, presents_str)) -> {
      use #(width, height) <- result.try(parse_dimensions(dimensions))
      use presents <- result.try(parse_presents(presents_str))
      Ok(Region(width: width, height: height, presents: presents))
    }
    Error(_) -> Error(InvalidRegionFormat(line))
  }
}

fn parse_dimensions(dim_str: String) -> Result(#(Int, Int), ParsePuzzleError) {
  case string.split_once(dim_str, "x") {
    Ok(#(w_str, h_str)) -> {
      use width <- result.try(
        int.parse(w_str)
        |> result.replace_error(InvalidDimension(dim_str)),
      )
      use height <- result.try(
        int.parse(h_str)
        |> result.replace_error(InvalidDimension(dim_str)),
      )
      Ok(#(width, height))
    }
    Error(_) -> Error(InvalidDimension(dim_str))
  }
}

fn parse_presents(presents_str: String) -> Result(List(Int), ParsePuzzleError) {
  presents_str
  |> string.split(" ")
  |> list.filter(fn(s) { string.length(s) > 0 })
  |> list.map(fn(s) {
    int.parse(s)
    |> result.replace_error(InvalidRegionFormat(s))
  })
  |> result.all
}
