# Validation results

Date: 27 October 2026 (Australia/Sydney).

## Original validation baseline (0.0.1)

jmpread 0.0.1, native R with no additional runtime package dependencies.
Windows source and binary installation archives are supplied beside the project
folder. knitr is an optional development dependency for the executable vignette.

## Local package checks

- Windows 11, R 4.5.2 x86_64.
- `R CMD build`: successful, including execution of the Rhtml vignette.
- `R CMD check --no-manual`: **Status: OK** (zero errors, warnings or notes).
- Examples, regression tests, vignette inspection and vignette rebuilding: pass.
- Windows binary: installed into a fresh library, loaded, and passed the full
  regression suite. Its generated HTML vignette is present.
- Package checks were run outside the restricted process because R's
  `file.access()` reported readable optional dependencies as unavailable inside
  that process. No parser checks were disabled to obtain a passing result.
- PDF reference-manual compilation was not run. Remote CI has not run.

Final full check log:
`../../.jmp-work/verified-check/jmpread.Rcheck/00check.log`.

## Differential value comparison

Reference: jumpio commit `e9cf1b85016637f90cbfca0760ded736475d20c1`.
The Python reference ran separately and generated CSVs. R compared dimensions,
column names, missing values and every comparable decoded value, with a numeric
comparison tolerance of 1e-12. Temporal values were normalized to raw JMP seconds.

**168,827 cells agree across 18 files containing value columns.**

The input corpus consists of 17 MIT-licensed reference fixtures plus the two
user-supplied files. The row-state-only fixture is omitted from the CSV comparison;
its raw width and known marker bytes have separate regression assertions.

| User file | Rows | Columns | Compared cells | Result |
| --- | ---: | ---: | ---: | --- |
| ARGO.jmp | 50 | 1 | 50 | Pass against Python |
| Incidents.jmp | 20 | 3 | 60 | Pass against Python |

Build strings observed in the tested files: JMP 14.2.0, 17.2.0 and 18.2.1.
This is evidence for these specific files, not blanket version compatibility.

The full per-file summary is in `comparison-report.csv`. User data and reference
CSV exports are retained in the ignored `private/` directory; original user JMP
files are read from their existing locations and are not redistributed.

## Regression scope

- Numeric and compact integer values; integer and floating missing sentinels.
- Fixed/variable/pooled strings, Unicode, gzip and compact index widths.
- Date/time precision, durations, currency and geographic numeric values.
- Arbitrary long names, source column order and select/exclude validation.
- Zero selected columns and a synthetic zero-row table.
- Raw row states and metadata attachment contracts.
- Explicit pooled missing sentinel and invalid pool index.
- Empty files, bad magic, truncated structures, unsupported type bytes,
  oversized inputs, invalid arguments, broken gzip sizes and inflated lengths.

## Outstanding validation

No trusted CSV export made by JMP has been supplied. Python agreement can share
the same assumptions or bugs as this R port, so Phase 1's independent acceptance
criterion is still open. Run `tools/validate_jmp_export.R` against direct JMP
exports of both files when available.

Additional JMP versions, legacy encodings, structured property interpretation,
row flags/palettes, adversarial-input hardening, large-file performance, remote
cross-platform checks and R-devel checks remain future work. Maintainer contact
details were confirmed for 0.0.2; the decoded-value baseline above is unchanged.
