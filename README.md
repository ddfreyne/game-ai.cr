This repository contains an AI for simple board games, written in [Crystal](http://crystal-lang.org/). It has an implementation of Othello and Connect Four.

To build:

```sh
make
```

To play a game, run `./main` passing `--game` with the game name:

```sh
./main --game=othello
```

To run a AI-vs-AI simulation, run `./main` passing `--game` and `--benchmark`:

```sh
./main --game=connect-four --benchmark
```

Supported games:

* Othello (`othello`)
* Connect Four (`connect-four`)
