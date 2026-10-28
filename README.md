# jmpread

[![R-CMD-check](https://github.com/JosephHill04/jmpread/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JosephHill04/jmpread/actions/workflows/R-CMD-check.yaml)

Read JMP (`.jmp`) tables directly in R, without Python or a JMP installation.
Version 0.1.0 is prepared as the first release candidate. It has not been
submitted to CRAN or published as a tagged release. See [RELEASE.md](RELEASE.md)
for the remaining validation and release steps.

## Install from GitHub

Install the development version with:

```r
install.packages("remotes")
remotes::install_github("JosephHill04/jmpread")
```

Report problems through the repository's Issues tab. Please use synthetic
examples and avoid attaching confidential or personal data. See CONTRIBUTING.md.

## Try the release candidate

```r
remotes::install_github("JosephHill04/jmpread@release/0.1.0")
```

## Install an archive and read a table

In R or RStudio, install the supplied source archive:

```r
install.packages("jmpread_0.1.0.tar.gz", repos = NULL, type = "source")
library(jmpread)

# This small, licensed table is included with the package.
path <- system.file("extdata", "jmpreader_jl", "example1", "example1.jmp",
                    package = "jmpread")
data <- read_jmp(path)
head(data)
str(data)

# Preserve source order while reading only the requested columns.
read_jmp(path, select = c("floats", "ints"))

# Return ordinary vectors without attached source metadata.
read_jmp(path, metadata = FALSE)
```

For your own data, use `read_jmp("path/to/your-table.jmp")`.

The package has no additional runtime R package dependencies and no compiled code.
The optional knitr package is needed only to rebuild the vignette.
Share the source archive with another R user and use the same installation
command. Windows users can alternatively install the supplied `.zip` with
`install.packages("jmpread_0.1.0.zip", repos = NULL, type = "win.binary")`.
Keep the two original JMP files in your own data folder; they are not shipped
inside the public package.

## Implemented

- Float64 and signed 8/16/32-bit integer columns, including missing sentinels.
- Fixed-width, variable-width and pooled strings, with gzip variants.
- Unicode text; header-declared encodings with an explicit override available.
- Recognized dates, datetimes and time display formats as UTC `POSIXct`.
- Durations as `difftime`; currency and geographic values as numbers.
- Raw row-state list columns, retaining bytes without guessing palette meaning.
- Original column names, build string, save time, offsets, display widths and
  raw post-header column blocks under `jmp_metadata` attributes.
- Column inclusion/exclusion, bounded reads and informative parse errors.

JMP dates store seconds since 1904-01-01. A date-looking value can contain
time of day, so date columns use `POSIXct` to avoid discarding information.
Use `temporal = "raw"` to obtain the original seconds.
Empty character strings remain `""`; explicit pooled missing values become
`NA_character_`. Unknown numeric display formats remain numeric. Formulas
are preserved in raw metadata and never executed.

## Validation status

All 168,827 comparable cells in 17 licensed fixture files and the two supplied user
files were checked against the pinned Python reference (18 files with value
columns; the row-state-only file has separate raw-byte assertions).
This is differential agreement, not independent validation against JMP.
See `validation/RESULTS.md` in the project for exact scope and local check results.
The 0.0.2 baseline passed all six Windows/macOS/Linux R-release/R-devel jobs
using `--as-cran --no-manual`. Those routine jobs disable CRAN incoming checks;
they are not equivalent to an incoming submission check. See RELEASE.md for
fresh 0.1.0 results, including full manual and exact-archive checks.
Joseph Hill reports successful imports and analyses by colleagues. Direct JMP
CSV comparisons are still outstanding and must be completed before release.

To finish Phase 1, export each original table as CSV from JMP with all rows,
source column order and full numeric precision, then run:

```sh
Rscript tools/validate_jmp_export.R /path/ARGO.jmp /path/ARGO.csv
Rscript tools/validate_jmp_export.R /path/Incidents.jmp /path/Incidents.csv
```

The validator compares names, dimensions, missing values and every cell.
Do not generate those trusted CSVs with this package or the Python reference.

## Development

```sh
R CMD build jmpread
R CMD check --as-cran jmpread_0.1.0.tar.gz
```

The package tests use base R and run as part of `R CMD check`. Cross-platform
GitHub Actions is configured for Windows, macOS and Linux. See the
[Actions tab](https://github.com/JosephHill04/jmpread/actions) for actual run results.
The separate Release candidate workflow builds a source archive with R-release,
checks it with the PDF manual, and checks the identical archive under R-devel.
It uploads source/manual/check artifacts; it does not publish or submit anything.

## Current limits

The parser uses observed binary layouts rather than a vendor specification.
Compatibility outside the checked fixtures is unconfirmed. JSL properties
(notes, units, labels and formulas) are retained as raw blocks, not exposed
as structured properties. Row flags and palette colors are not interpreted.
Embedded NUL text is rejected. The reader loads the full file into memory,
and keeping raw metadata can increase memory use substantially.
The default input and declared per-column inflation limits are 256 MiB.
These are not guarantees against adversarial compressed input.

## Credits and license

MIT. Binary format work and algorithms are adapted from
[jumpio](https://github.com/abardagjy/jumpio), pinned to
`e9cf1b85016637f90cbfca0760ded736475d20c1`, and
[JMPReader.jl](https://github.com/jaakkor2/JMPReader.jl).
Full upstream notices and fixture provenance are included in `inst/`.
This project is independent of JMP and its owner.

Maintainer: Joseph Hill <joe@sixhillsgroup.com.au>.
Complete RELEASE-CHECKLIST.md before publishing. The first release can keep
the current feature set; additional encodings and structured metadata can be
considered for later versions.
