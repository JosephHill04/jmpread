# jmpread

[![R-CMD-check](https://github.com/JosephHill04/jmpread/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JosephHill04/jmpread/actions/workflows/R-CMD-check.yaml)

Read JMP (`.jmp`) tables directly in R, without Python or a JMP installation.
Version 0.1.0 is a release candidate. It has not been submitted to CRAN
or published as a tagged release. See RELEASE.md for remaining steps.

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
required. The optional knitr package is needed only to rebuild the vignette.

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

## Validation and provenance

The distributed regression corpus contains **17 MIT-licensed fixtures**.
Differential comparisons against the pinned Python reader cover **168,717 cells
across 16 files with value columns**. The row-state-only fixture has separate
raw-byte assertions. These are reader-to-reader comparisons, not independent
validation against JMP itself. See validation/RESULTS.md for scope and provenance.

Before release, independently validate using a synthetic table you create in JMP
or another table you have documented permission to use. Export all rows and
columns as a full-precision CSV and compare it with the supplied helper:

```sh
Rscript tools/validate_jmp_export.R /path/example.jmp /path/trusted-export.csv
```

Keep private exports out of the repository. Tests and public validation summaries
use only the licensed fixtures; data of unverified provenance is not included.

## Development and support

```sh
R CMD build jmpread
R CMD check --as-cran jmpread_0.1.0.tar.gz
```

Tests use base R. Cross-platform checks run on Windows, macOS and Linux with
R-release and R-devel. See the [Actions tab](https://github.com/JosephHill04/jmpread/actions)
for actual results. Read CONTRIBUTING.md and report problems through
[Issues](https://github.com/JosephHill04/jmpread/issues), using synthetic examples.

## Current limits

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
