import gleam/int
import gleam/string

pub type ProductID =
  Int

fn split_halfway(s: String) -> #(String, String) {
  let length = string.length(s)
  let first_half = string.slice(s, 0, length / 2)
  let second_half = string.slice(s, length / 2, length)
  #(first_half, second_half)
}

pub fn is_same_halves(product_id: ProductID) -> Bool {
  let #(first_half, second_half) = split_halfway(int.to_string(product_id))
  first_half == second_half
}

fn is_made_of_repeating_sequences(
  sequence: String,
  sequence_length: Int,
) -> Bool {
  let length = string.length(sequence)
  let segment = string.slice(sequence, 0, sequence_length)
  case string.repeat(segment, length / sequence_length) {
    _ if length == 1 -> False
    _ if sequence_length * 2 > length -> False
    repeated if repeated == sequence -> True
    _ -> is_made_of_repeating_sequences(sequence, sequence_length + 1)
  }
}

pub fn is_repeating_sequence(product_id: ProductID) -> Bool {
  let product_id_str = int.to_string(product_id)
  is_made_of_repeating_sequences(product_id_str, 1)
}
