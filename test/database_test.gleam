import day2/range
import day5/database
import gleam/list
import gleeunit/should

pub fn new_database_test() {
  let ranges = [range.new_range(1, 5), range.new_range(10, 15)]
  let ids = [3, 7, 12]
  let db = database.new_database(ranges, ids)

  database.fresh_ranges(db) |> should.equal(ranges)
  database.ids(db) |> should.equal(ids)
}

pub fn parse_valid_input_test() {
  let input = "1-5\n10-15\n\n3\n7\n12"
  let result = database.parse(input)

  result |> should.be_ok
  let db = result |> should.be_ok
  database.ids(db) |> should.equal([3, 7, 12])
  database.fresh_ranges(db) |> list.length |> should.equal(2)
}

pub fn parse_missing_separator_test() {
  let input = "1-5\n10-15"
  database.parse(input)
  |> should.be_error
  |> should.equal(database.ParseDatabaseSectionsError(Nil))
}

pub fn parse_invalid_ranges_test() {
  let input = "invalid\n\n3\n7"
  database.parse(input)
  |> should.be_error
}

pub fn parse_invalid_ids_test() {
  let input = "1-5\n\nnot_a_number"
  database.parse(input)
  |> should.be_error
  |> should.equal(database.ParseIdsError(Nil))
}

pub fn id_in_any_range_found_test() {
  let db =
    database.new_database([range.new_range(1, 5), range.new_range(10, 15)], [])

  database.id_in_any_range(db, 3) |> should.be_true
  database.id_in_any_range(db, 12) |> should.be_true
}

pub fn id_in_any_range_not_found_test() {
  let db =
    database.new_database([range.new_range(1, 5), range.new_range(10, 15)], [])

  database.id_in_any_range(db, 7) |> should.be_false
  database.id_in_any_range(db, 20) |> should.be_false
}

pub fn condense_ranges_test() {
  let db =
    database.new_database([range.new_range(1, 5), range.new_range(3, 8)], [1, 2])
  let condensed = database.condense_ranges(db)

  database.ids(condensed) |> should.equal([1, 2])
  database.fresh_ranges(condensed) |> list.length |> should.equal(1)
}
