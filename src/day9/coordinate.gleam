import gleam/int
import gleam/string

pub type Cord =
  #(Int, Int)

pub fn new(x: Int, y: Int) -> Cord {
  #(x, y)
}

pub type ParseCoordinateError {
  InvalidFormat(Nil)
}

pub fn parse(raw: String) -> Result(Cord, ParseCoordinateError) {
  let parts = raw |> string.split(",")
  case parts {
    [x_str, y_str] -> {
      case int.parse(x_str), int.parse(y_str) {
        Ok(x), Ok(y) -> Ok(#(x, y))
        _, _ -> Error(InvalidFormat(Nil))
      }
    }
    _ -> Error(InvalidFormat(Nil))
  }
}

pub fn rect_area(a: Cord, b: Cord) -> Int {
  let #(ax, ay) = a
  let #(bx, by) = b
  let width = int.absolute_value(bx - ax) + 1
  let height = int.absolute_value(by - ay) + 1
  width * height
}

pub fn to_string(coord: Cord) -> String {
  let #(x, y) = coord
  string.concat([int.to_string(x), ",", int.to_string(y)])
}
