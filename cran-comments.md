# jmpread 0.1.0: submission comments in preparation

This is a first submission candidate, not an uploaded submission.
Do not submit until the checks and independent validation in RELEASE.md are done.

## Test environments

- Historical baseline 0.0.2: all six GitHub Actions jobs passed on Windows,
  macOS and Linux with R-release and R-devel. These used --no-manual and
  disabled incoming checks. They are not the final candidate results.
- Candidate 0.1.0 results: pending, to be filled with the actual release workflow
  and local check outcomes before upload.

## Release status

First release, supporting the documented common encodings. No CRAN submission
has been made. JMP and Python are not required at runtime.
Maintainer: Joseph Hill <joe@sixhillsgroup.com.au>.
Independent validation against a direct export of a synthetic or permissibly licensed JMP table remains outstanding.
The first release intentionally retains the current feature set. Additional
encodings and structured metadata are future enhancements, not promised support.

## Before upload

Replace pending results with actual current R-release/R-devel environments,
check counts and explanations of remaining notes. A new-submission note is
expected, but must be recorded only if the checks actually produce it.

## Licensing and attribution

Native R implementation adapted from MIT-licensed jumpio and JMPReader.jl
format work. Upstream contributors/copyright holders are credited in Authors@R;
their notices and the provenance of the redistributable fixtures are included.
Private user tables and comparison exports are excluded from the source archive.

## Reverse dependencies

None known for this new package; recheck immediately before submission.
