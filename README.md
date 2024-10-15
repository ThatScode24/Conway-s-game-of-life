# Problem Statement

## Formulation

Conway’s Game of Life is a two-dimensional zero-player game invented by mathematician John Horton Conway in 1970. The purpose of this game is to observe the evolution of a cell system, starting from an initial configuration, by introducing rules regarding the death and creation of new cells in the system. This evolutionary system is Turing-complete.

The state of a system is described by the cumulative state of its component cells, and for these, we have the following rules:

1. **Underpopulation**: Any live cell with fewer than two live neighbors dies in the next generation.
2. **Live Cell Continuity**: Any live cell with two or three live neighbors survives to the next generation.
3. **Overpopulation**: Any live cell with more than three live neighbors dies in the next generation.
4. **Reproduction**: Any dead cell with exactly three live neighbors becomes a live cell in the next generation.
5. **Dead Cell Continuity**: Any other dead cell remains dead.

The neighbors of a cell are considered to be the following 8 in a two-dimensional matrix:

```
a00 a01 a02
a10 current cell a12
a20 a21 a22
```
