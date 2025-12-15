import day11/network
import gleeunit/should

const test_input = "aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out"

pub fn parse_valid_network_test() {
  let result = network.parse(test_input)
  result |> should.be_ok
}

pub fn count_paths_test() {
  let net = network.parse(test_input) |> should.be_ok
  let path_count = network.count_paths(net, "you", "out")
  path_count |> should.equal(5)
}

pub fn parse_line_with_missing_colon_test() {
  let input = "invalid line without colon"
  network.parse(input)
  |> should.be_error
}

const test_input_part2 = "svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out"

pub fn count_paths_with_waypoints_test() {
  let net = network.parse(test_input_part2) |> should.be_ok
  let path_count =
    network.count_paths_with_waypoints(net, "svr", "out", ["dac", "fft"])
  path_count |> should.equal(2)
}
