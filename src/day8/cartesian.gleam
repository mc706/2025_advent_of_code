import gleam/float
import gleam/int
import gleam/order
import gleam/result
import gleam/string

pub opaque type Cartesesian {
  Cartesian(x: Int, y: Int, z: Int)
}

pub fn new_cartesian(x: Int, y: Int, z: Int) -> Cartesesian {
  Cartesian(x, y, z)
}

pub fn x(cartesian: Cartesesian) -> Int {
  let Cartesian(x, _, _) = cartesian
  x
}

pub fn y(cartesian: Cartesesian) -> Int {
  let Cartesian(_, y, _) = cartesian
  y
}

pub fn z(cartesian: Cartesesian) -> Int {
  let Cartesian(_, _, z) = cartesian
  z
}

pub type ParseCartesianError {
  InvalidCoordinates(Nil)
}

pub fn parse(input: String) -> Result(Cartesesian, ParseCartesianError) {
  case string.split(input, ",") {
    [x_str, y_str, z_str] -> {
      case int.parse(x_str), int.parse(y_str), int.parse(z_str) {
        Ok(x), Ok(y), Ok(z) -> Ok(new_cartesian(x, y, z))
        _, _, _ -> Error(InvalidCoordinates(Nil))
      }
    }
    _ -> Error(InvalidCoordinates(Nil))
  }
}

pub fn values(cartesian: Cartesesian) -> #(Int, Int, Int) {
  let Cartesian(x, y, z) = cartesian
  #(x, y, z)
}

pub fn distance(a: Cartesesian, b: Cartesesian) -> Float {
  let #(ax, ay, az) = values(a)
  let #(bx, by, bz) = values(b)
  let axf = int.to_float(ax)
  let ayf = int.to_float(ay)
  let azf = int.to_float(az)
  let bxf = int.to_float(bx)
  let byf = int.to_float(by)
  let bzf = int.to_float(bz)
  let delta_x = bxf -. axf
  let delta_y = byf -. ayf
  let delta_z = bzf -. azf
  {
    use x_pow <- result.try(float.power(delta_x, 2.0))
    use y_pow <- result.try(float.power(delta_y, 2.0))
    use z_pow <- result.try(float.power(delta_z, 2.0))
    use distance <- result.map(float.square_root(x_pow +. y_pow +. z_pow))
    distance
  }
  |> result.unwrap(0.0)
}

pub fn distance_squared(a: Cartesesian, b: Cartesesian) -> Int {
  let #(ax, ay, az) = values(a)
  let #(bx, by, bz) = values(b)
  let delta_x = bx - ax
  let delta_y = by - ay
  let delta_z = bz - az
  delta_x * delta_x + delta_y * delta_y + delta_z * delta_z
}

pub fn compare(a: Cartesesian, b: Cartesesian) -> order.Order {
  let #(ax, ay, az) = values(a)
  let #(bx, by, bz) = values(b)
  case int.compare(ax, bx) {
    order.Lt -> order.Lt
    order.Gt -> order.Gt
    order.Eq -> {
      case int.compare(ay, by) {
        order.Lt -> order.Lt
        order.Gt -> order.Gt
        order.Eq -> int.compare(az, bz)
      }
    }
  }
}
