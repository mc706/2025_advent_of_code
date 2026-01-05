import day12/puzzle
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(content) = simplifile.read("src/day12/test.txt")

  io.println("File content length: " <> int.to_string(string.length(content)))

  case puzzle.parse(content) {
    Ok(puz) -> {
      io.println("✓ Parsing succeeded!")
      io.println("Number of shapes: " <> int.to_string(dict.size(puz.shapes)))
      io.println(
        "Number of regions: " <> int.to_string(list.length(puz.regions)),
      )

      io.println("\nRegions:")
      list.each(puz.regions, fn(r) {
        io.println(
          "  "
          <> int.to_string(r.width)
          <> "x"
          <> int.to_string(r.height)
          <> ": "
          <> int.to_string(list.length(r.presents))
          <> " present types",
        )
      })
    }
    Error(e) -> {
      io.println("✗ Parsing failed:")
      case e {
        puzzle.InvalidShapeId(msg) -> io.println("InvalidShapeId: " <> msg)
        puzzle.InvalidRegionFormat(msg) ->
          io.println("InvalidRegionFormat: " <> msg)
        puzzle.InvalidDimension(msg) -> io.println("InvalidDimension: " <> msg)
      }
    }
  }
}
