# Advent of Code 2025

This edition in gleam!

### Considerations
Taking another look at gleam as a language since it has moved a lot and there is a lot of interesting developments.

Taking on AOC this year not as a time first answer, or code golf, but instead as a way to explore the language features
and language design decisions that gleam has made (no if statements or loops to name a few).

The online community at [reddit](https://www.reddit.com/r/adventofcode/) is very adamant not to include inputs, so the `input.txt` in each directly is `.gitignore`d.


### Development
To run locally,

```
gleam run
```

To run tests:

```
gleam test
```

### Notes
#### Structure
Added each day in its own directory, with a 
* `PROBLEM.md` (for historical context)
* `input.txt` (gitignored)
* `dayX.gleam` the root solution
* some domain module 

#### Shared file processing
Added a root `shared` module that has a `process_input` function that handles most takes a path, a delimiter, a parser and a error_mapper and handles most of the file parsing and error handling for the daily problems.

#### Day modules
Each "day" module exposes a `main() -> Result(#(Int, Int), shared.AppError)` that
unpacks the data and hands it to the two sub-problems (problem_1 and problem_2) and returns the results as a tuple to the main code. 

#### Domain Modules
Each "domain" module tries to use opaque types and exposes parsing errors, which get grouped into AppErrors in the shared module. Via principle-of-least-access, it should expose the minimum amount of functions and types needed to solve the problem in an easy to read way in the main process. The `opaque` types typically mean we need a least a constructor or `parse` function. Naming functions so they make sense when used as a qualified import makes reading easier (ie. `dail.parse_rotation`, or `range.to_list`)

#### Solution Process
This allows the daily solutioning process to be:
1. Model a domain that fits the problem
2. Write a parser (with easy to read errors) that takes the text and creates Types
3. Add the error mapping to `shared.AppError`
4. Pass the domain parser and input to `process_input`
5. Handle the flow of data