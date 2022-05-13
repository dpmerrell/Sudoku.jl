# Sudoku.jl

A Julia package containing whatever Sudoku solvers I come up with

## Installation

Do the typical Julia thing:
```
julia> using Pkg; Pkg.add(url="https://github.com/dpmerrell/Sudoku.jl")
```

## Basic usage

Enter your Sudoku puzzle into a plain text file.
The file should contain 9 x 9 = 81 entries; each entry must either be (a) a digit in the range 1-9; or (2) or an underscore to represent empty spaces.
White space between entries is allowed.

Use the `solve` function to solve the puzzle:
```
julia> using Sudoku

julia> solve("my_sudoku_puzzle.txt"; solutions="first")
##### SOLUTION 1 #####
5 4 9|6 8 2|7 3 1
3 7 8|4 5 1|2 6 9
6 2 1|3 9 7|4 5 8
_________________
7 8 5|9 6 3|1 4 2
1 3 4|8 2 5|6 9 7
9 6 2|1 7 4|3 8 5
_________________
2 9 3|5 1 6|8 7 4
8 1 6|7 4 9|5 2 3
4 5 7|2 3 8|9 1 6

```

The function will print solutions to standard output.

The keyword argument `solutions` takes values `"first"` and `"all"`.


## Algorithmic ideas

For now the only solver is a simple tree-search based algorithm.
We first define an ordering on the free variables; then we recursively assign values to them (i.e., DFS) until we find a solution.
It finds solutions to "evil" problems in a fraction of a second.

I have other ideas I'd like to pursue -- more exotic techniques based on constrained optimization, SAT solvers, ROBDDs, etc.
