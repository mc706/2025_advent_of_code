import day2/range.{type Range}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub opaque type Database {
  Database(fresh_ranges: List(Range), ids: List(Int))
}

pub fn new_database(fresh_ranges: List(Range), ids: List(Int)) -> Database {
  Database(fresh_ranges, ids)
}

pub type ParseDatabaseError {
  ParseDatabaseSectionsError(Nil)
  ParseRangesError(range.ParseRangeError)
  ParseIdsError(Nil)
}

fn parse_ranges(
  ranges_section: String,
) -> Result(List(Range), ParseDatabaseError) {
  ranges_section
  |> string.split("\n")
  |> list.map(range.parse)
  |> result.all
  |> result.map_error(ParseRangesError)
}

fn parse_ids(ids_section: String) -> Result(List(Int), ParseDatabaseError) {
  ids_section
  |> string.split("\n")
  |> list.map(int.parse)
  |> result.all
  |> result.map_error(ParseIdsError)
}

pub fn parse(input: String) -> Result(Database, ParseDatabaseError) {
  use #(ranges_section, ids_section) <- result.try(
    string.split_once(input, "\n\n")
    |> result.map_error(ParseDatabaseSectionsError),
  )
  use fresh_ranges <- result.try(parse_ranges(ranges_section))
  use ids <- result.try(parse_ids(ids_section))
  Ok(new_database(fresh_ranges, ids))
}

pub fn ids(db: Database) -> List(Int) {
  db.ids
}

pub fn fresh_ranges(db: Database) -> List(Range) {
  db.fresh_ranges
}

pub fn id_in_any_range(db: Database, id: Int) -> Bool {
  db.fresh_ranges
  |> list.any(range.contains(_, id))
}

pub fn condense_ranges(db: Database) -> Database {
  db.fresh_ranges
  |> range.merge_all
  |> new_database(db.ids)
}
