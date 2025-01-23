# peano

> [!CAUTION]
> This package is in development and is not ready for use.

[![Package Version](https://img.shields.io/hexpm/v/peano)](https://hex.pm/packages/peano)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/peano/)

```sh
gleam add peano@0.1.0
```

```gleam
import gleam/io
import peano

pub fn main() {
  let n = peano.multiply(peano.six, with: peano.four)

  io.println(peano.to_string(n))
  // -> 24
}
```

Further documentation can be found at <https://hexdocs.pm/peano>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
