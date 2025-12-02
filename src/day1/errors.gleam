pub type ParseRotationError {
  MissingPrefix(msg: String)
  InvalidNumber(msg: String)
}
