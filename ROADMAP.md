# Development phases

## Phase 1: proof of concept

- [x] Read the MIT-licensed JMPReader.jl fixtures in native R.
- [x] Compare every decoded cell with the pinned Python implementation.
- [ ] Validate a synthetic or permissibly licensed table against a direct JMP export.

## Phase 2: basic package

- [x] Export read_jmp() returning a data.frame.
- [x] Common numeric and character types, missing values and compression.
- [x] Lossless temporal conversion and column selection.
- [x] Documentation, licensed example files and regression tests.
- [x] Source and Windows installation archives.

## Phase 3: broader compatibility

- [x] Test the 17 MIT-licensed reference fixtures.
- [x] Validate malformed headers, dimensions, offsets and column encodings.
- [x] Retain raw metadata and row states.
- [ ] Independent JMP exports covering each supported encoding and missing case.
- [ ] Vendor-generated version/encoding matrix, including older formats.
- [ ] Structured notes, labels, units, formulas and row-state interpretation.
- [ ] Fuzzing, corruption corpus, streaming and decompression resource limits.
- [ ] Large-file performance and memory benchmarks.

## Phase 4: public release

- [x] README, examples, tutorial and CI configuration.
- [x] CRAN submission checklist and draft comments.
- [x] Set verified author/contact details for Joseph Hill.
- [ ] Confirm package name availability.
- [ ] Push to the chosen repository and obtain actual cross-platform CI results.
- [ ] Finish trusted-export validation for the existing release scope.
- [ ] Review documentation and check results, then submit to CRAN.

Checkboxes record delivered work; they do not imply the phase is complete.
