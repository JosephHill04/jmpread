# Validation corpus and results

Updated 28 October 2026. The validation corpus is restricted to the 17
MIT-licensed JMPReader.jl fixtures included in inst/extdata/jmpreader_jl.
Their licence and provenance are retained with the files. No dataset of
unverified provenance is included in the package or these validation records.

## Differential comparison

Python reference: jumpio commit e9cf1b85016637f90cbfca0760ded736475d20c1.
All 168,717 comparable cells agree across the 16 licensed files with value
columns. Temporal values are normalised to raw JMP seconds. Numeric comparison
tolerance is 1e-12. The row-state-only fixture has separate raw-byte assertions.
See comparison-report.csv for the per-fixture summary.

The licensed fixtures include writer versions 17.2.0 and 18.2.1. This supports
these specific files, not a claim of universal version compatibility.

## Regression coverage

Numeric and compact integers; missing sentinels; fixed/variable/pooled strings;
Unicode; compression; dates/times and durations; geographic/currency values;
long names; selection; zero rows/columns; raw row states; malformed input;
invalid pool indices; gzip framing and length checks.

## Independent validation

Reader-to-reader agreement can share assumptions or bugs. Before final release,
use a synthetic table created in JMP or data with documented permission, and
compare a direct full-precision JMP CSV export with tools/validate_jmp_export.R.
No such independent acceptance comparison is claimed here.

Fresh package/manual/CI results after the documentation and corpus cleanup are
available in GitHub Actions. Historical check summaries do not establish the
status of a newly built archive.
