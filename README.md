# jmpread

[![R-CMD-check](https://github.com/JosephHill04/jmpread/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JosephHill04/jmpread/actions/workflows/R-CMD-check.yaml)

Read JMP (`.jmp`) tables directly in R, without Python or a JMP installation.
## Install

```r
install.packages("remotes")
remotes::install_github("JosephHill04/jmpread")
```

For an installation archive supplied separately:

```r
install.packages("jmpread_0.1.0.tar.gz", repos = NULL, type = "source")
```

Windows users can install the supplied `.zip` with `repos = NULL` and
`type = "win.binary"`. No additional runtime R packages or compiled code are
required.

## Read the bundled example

All distributed example data comes from the MIT-licensed JMPReader.jl fixtures.

```r
library(jmpread)
path <- system.file("extdata", "jmpreader_jl", "example1", "example1.jmp",
                    package = "jmpread")
table <- read_jmp(path)
table[, c("ints", "floats")]

# Select columns, preserving their order in the source table.
read_jmp(path, select = c("floats", "ints"))

# Return ordinary vectors without source metadata attributes.
read_jmp(path, metadata = FALSE)
```

For data you are authorised to use, replace `path` with your own local file path.
Do not upload private or unlicensed data in an issue or contribution.

## Supported features

- Float64 and signed 8/16/32-bit integer columns, including missing sentinels.
- Fixed-width, variable-width and pooled strings, including gzip variants.
- Unicode text and a header-encoding override.
- Recognised dates, datetimes and time displays as UTC POSIXct values.
- Durations as difftime; currency and geographic columns as numbers.
- Column selection/exclusion and original column names.
- File and column metadata, including raw post-header column blocks.
- Raw row-state list columns, retaining the stored bytes.

JMP temporal values use seconds since 1904-01-01. Date-looking values can contain
time of day, so date columns use POSIXct to retain precision. Use
`temporal = "raw"` for original seconds. Empty strings remain `""`; explicit
pooled missing values become `NA_character_`. Numeric missing sentinels become NA.
Formulas remain in raw metadata and are never executed.

## Validation

Tests cover 17 MIT-licensed JMPReader.jl fixtures, including numeric, text,
missing, compressed and temporal values. Comparisons against the pinned Python
reader agree across 168,717 cells. A separate comparison against an original
Excel source imported into JMP Pro 17.0.0 agrees exactly across 890,336 shared
cells, including 38,374 missing values. The private comparison data is not
distributed. See [validation results](validation/RESULTS.md) for scope.

## Help and support

Use `?read_jmp` for the function reference and
`vignette("getting-started", package = "jmpread")` for examples.
Report problems through [Issues](https://github.com/JosephHill04/jmpread/issues)
with your R version, package version and a small example you can share.

## Limitations

Compatibility outside the documented and tested encodings is unconfirmed. Notes,
units, labels and formulas are retained as raw blocks, not structured fields.
Row-state flags and palette meanings are not interpreted. Embedded NUL text is
rejected. The full file is read into memory, and raw metadata increases memory
use. Default input and declared per-column inflation limits are 256 MiB; they
are not protection against adversarial compressed files. See `?read_jmp`.

## Credits and licence

MIT. Format work and algorithms are adapted from
[jumpio](https://github.com/abardagjy/jumpio), pinned to
`e9cf1b85016637f90cbfca0760ded736475d20c1`, and
[JMPReader.jl](https://github.com/jaakkor2/JMPReader.jl).
Upstream notices and fixture provenance are included in inst/.
This project is independent of JMP and its owner.

Maintainer: Joseph Hill <joe@sixhillsgroup.com.au>.
