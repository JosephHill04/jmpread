# jmpread 0.1.0

- Restrict examples and validation records to the MIT-licensed fixture corpus.

- Prepare the first public release with the existing read_jmp() interface.
- Read common numeric, character, pooled and compressed encodings without a
  Python runtime or JMP installation, retaining source metadata and raw row states.
- Preserve temporal precision and documented missing-value behavior.
- Add exact-archive release checks with PDF manual building and R-devel validation.
- Clarify upstream contributor attribution and public installation examples.
- No decoding algorithm changes from the tested 0.0.2 version.

# jmpread 0.0.2

- Set Joseph Hill as author and maintainer, with the confirmed contact email.
- Record upstream copyright holders in package metadata and retain MIT notices.
- Clarify the description and prepare a focused first-release checklist.
- No changes to the reader's features or decoded values.

# jmpread 0.0.1

- Initial native R reader for common JMP numeric, character and temporal columns.
- Support gzip, pooled strings, missing values, selection and raw source metadata.
- Include licensed fixtures, regression tests, a vignette and CI configuration.
