# Release candidate preparation

Maintainer: Joseph Hill <joe@sixhillsgroup.com.au>.
Package version 0.1.0 is a candidate, not a tagged release or CRAN submission.
No decoding algorithms changed during the example-data cleanup.

## Data and validation policy

Only the 17 MIT-licensed JMPReader.jl fixtures are distributed. Their notices
and provenance are included. Differential comparisons cover 168,717 cells
across 16 value-containing fixture files; raw row states have separate assertions.
Data without verified provenance has been removed from examples, requirements,
comparison records and locally regenerated installation/review artifacts.

## Remaining owner action

1. Create a small synthetic table in JMP, or choose a table with documented
   permission to use it. Include representative numeric/text/missing cases.
2. Export all rows and columns directly from JMP as a full-precision CSV, and
   compare using tools/validate_jmp_export.R. Keep private exports in the ignored
   validation/private/jmp-exports/ directory. Do not use Python-generated CSVs
   as independent JMP exports. Record the writer version and comparison outcome.
3. Review the manual, examples, release notes and maintainer contact details.
4. After independent validation and fresh checks pass, approve the candidate.

## Technical release process

The Release candidate workflow builds a source archive with current R-release,
checks the PDF/HTML manuals and incoming feasibility, and checks those same
archive bytes with R-devel. It records SHA256SUMS and SOURCE-COMMIT and uploads
the artifacts. The routine six-job matrix covers Windows/macOS/Linux on both
R-release and R-devel. Consult Actions for actual current results.

After approval, merge the reviewed candidate branch, let the final checks finish,
and use that final tested source archive. Fill the submission comments with the
actual results, tag v0.1.0, and publish a GitHub release. Submit the tested source
.tar.gz through https://cran.r-project.org/submit.html and confirm the email.
CRAN acceptance and a GitHub release are separate events. No release or CRAN
submission occurs automatically.

Older Git history or copies already downloaded by others can retain superseded
documentation. Current packages must be regenerated after this cleanup.
