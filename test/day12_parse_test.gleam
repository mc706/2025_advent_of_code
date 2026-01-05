import day12/puzzle
import gleam/int
import gleam/io
import gleam/list
import simplifile

pub fn main() {
  let assert Ok(content) = simplifile.read("src/day12/test.txt")

  case puzzle.parse(content) {
    Ok(puz) -> {
      io.println("✓ Parsing succeeded!")
      io.println(
        "Number of regions: " <> int.to_string(list.length(puz.regions)),
      )
    }
    Error(e) -> {
      io.println("✗ Parsing failed")
      case e {
        puzzle.InvalidShapeId(msg) -> io.println("InvalidShapeId: " <> msg)
        puzzle.InvalidRegionFormat(msg) ->
          io.println("InvalidRegionFormat: " <> msg)
        puzzle.InvalidDimension(msg) -> io.println("InvalidDimension: " <> msg)
      }
    }
  }
}
