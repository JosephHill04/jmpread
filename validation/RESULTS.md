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

## Independent source comparison

An original Excel workbook was imported into JMP and the resulting table was
read with jmpread 0.1.0. File metadata identifies JMP Pro 17.0.0. Comparison on
28 October 2026 found exact agreement for 55,646 rows and all 16 shared columns:
890,336 cells, including 38,374 missing values. Column names and order match.
Numeric values compare equal as floating-point values without a tolerance
allowance. Text is compared without trimming. The compared workbook contains
no formulas. Two additional JMP-only numeric columns have no reference in
the workbook and are excluded from the agreement claim.

This independently exercises numeric/text values and missing values. It does
not independently validate temporal values or raw row-state meanings. The
source files, derived values and detailed private report are not distributed.

## Automated checks

GitHub Actions checks Windows, macOS and Linux with R-release and R-devel.
The Package validation workflow also builds PDF/HTML manuals and checks the
same source archive under R-release and R-devel. Consult the
[Actions results](https://github.com/JosephHill04/jmpread/actions) for each commit.
