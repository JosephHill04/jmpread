# JMPReader.jl test fixtures

The `.jmp` files in this directory tree were copied from the test suite of
[JMPReader.jl](https://github.com/jaakkor2/JMPReader.jl) by Jaakko Ruohio,
licensed under the MIT License (see `LICENSE` in this directory).

- Upstream repo: https://github.com/jaakkor2/JMPReader.jl
- Source path:   `test/*.jmp`
- Commit:        `57dc2a604190ca26c20c6b4558ac7ff0cfe27617`
- Retrieved:     2026-04-16

Each fixture is placed in its own subdirectory (e.g. `example1/example1.jmp`)
to leave room for per-fixture reverse-engineering notes, hex dumps, or
reference exports without renaming the source file.

These fixtures are used by `tests/test_fixtures.py`, whose assertions are
hand-ported from `JMPReader.jl/test/runtests.jl`.
