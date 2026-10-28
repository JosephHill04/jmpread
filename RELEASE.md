# Release 0.1.0 preparation

Owner and maintainer: Joseph Hill <joe@sixhillsgroup.com.au>.
Prepared on 28 October 2026. This is a candidate, not a tagged release or a CRAN
submission. The reader's feature set and decoding algorithms are unchanged.

## What is already established

- The 0.0.2 source passed all six GitHub jobs on Windows, macOS and Linux with
  R-release and R-devel:
  https://github.com/JosephHill04/jmpread/actions/runs/40622573449
- The existing comparisons cover 168,827 cells against the pinned Python reader.
  Separate regressions cover raw row states and malformed data.
- Colleagues have successfully downloaded, loaded and analysed files. Joseph
  confirmed that independent JMP/CSV comparisons have not yet been performed.
- Name searches on 28 October found no case-insensitive jmpread conflict in the
  current CRAN index, CRAN archive, or the Bioconductor software, annotation,
  experiment and workflow indexes. See validation/name-check-0.1.0.json.
  This is a point-in-time check, not a reservation of the name.
- Licensing, maintainer details, repository links, help, vignette, source tests
  and issue-reporting instructions are present.

## Candidate check results

Use the Release candidate and R-CMD-check results for the release/0.1.0 branch
in the Actions tab. The candidate must pass its own checks; do not treat the
successful 0.0.2 checks as checks of the new archive. Final logs and checksum
records travel with the tested source artifact. A local RELEASE-STATUS.md in
the generated release/ folder records preparation results when available.

## What Joseph needs to do

1. Export ARGO and Incidents directly from JMP as UTF-8 CSVs. Include all rows
   and columns, retain source order, and use full numeric precision. Keep these
   exports in validation/private/ locally; do not put them in GitHub.
2. Compare the exports using the supplied helper, or provide them for comparison:

   ```sh
   Rscript tools/validate_jmp_export.R /path/ARGO.jmp /path/ARGO.csv
   Rscript tools/validate_jmp_export.R /path/Incidents.jmp /path/Incidents.csv
   ```

   Both must pass names, dimensions, missing-value and all-cell checks. Record
   which files/JMP versions were checked and the results. Address discrepancies
   before release. A few additional representative colleagues' files would
   strengthen confidence without promising support for every JMP version.
3. Review the rendered manual, help examples and vignette, and confirm that
   joe@sixhillsgroup.com.au receives external mail without sender challenges.
4. Once the independent comparisons and technical checks pass, approve the
   candidate for release. Until then, use the candidate branch for testing.

## Final publication sequence

1. Merge the reviewed release/0.1.0 branch and let the checks finish on main.
2. Use the successful Release candidate workflow's **jmpread-release-source**
   artifact. It contains the source archive, PDF manual, SHA256SUMS and check log.
   R-release builds this archive, then R-devel checks those same bytes.
   Match SOURCE-COMMIT to the final source commit. Any later source changes
   require a rebuild and fresh checks. Keep the checksum record.
3. Fill cran-comments.md with final factual results and remaining note explanations.
   Read the current CRAN policy/checklist. A final Win-builder check is a useful
   supplement, especially if a new issue appears during review.
4. Tag that tested source commit v0.1.0 and create a GitHub release with the source
   archive and notes. This makes an identifiable version available to colleagues.
   A Windows .zip is an optional convenience; CRAN does not accept that binary.
5. Submit the tested **jmpread_0.1.0.tar.gz** through
   https://cran.r-project.org/submit.html and confirm the email sent to Joseph.
   Respond to review; do not submit another version while this one is pending.
6. Only after CRAN acceptance, add the CRAN installation command/badge to README.
   Monitor CRAN checks and issue reports after publication.

These steps distinguish a GitHub release from CRAN acceptance. Neither is
performed automatically by the release-check workflow.

Official guidance:

- https://cran.r-project.org/web/packages/submission_checklist.html
- https://cran.r-project.org/web/packages/policies.html
