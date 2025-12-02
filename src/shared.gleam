import day1/errors as day1_errors
import day2/errors as day2_errors
import simplifile

pub type AppError {
  FileError(err: simplifile.FileError)
  ParseRotationError(err: day1_errors.ParseRotationError)
  ParseRangeError(err: day2_errors.ParseRangeError)
}

pub fn read_input(path: String) -> Result(String, simplifile.FileError) {
  simplifile.read(path)
}
