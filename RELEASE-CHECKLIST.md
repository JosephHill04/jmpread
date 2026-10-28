# First-release checklist

Keep the current reader feature set for the first submission. New encodings,
structured JSL properties and interpreted row states can be later enhancements.
Document limitations and validate the features actually offered.

## 1. Identity and package contents

- [x] Author/maintainer: Joseph Hill <joe@sixhillsgroup.com.au>.
- [x] Copyright holder: Joseph Hill, with upstream MIT notices preserved.
- [x] Record upstream copyright holders in Authors@R and add NEWS.md.
- [ ] Verify that jmpread is available and acceptable as a CRAN package name,
      including checking CRAN's archive immediately before submission.
- [ ] Review the built source archive: include code, help, vignette, tests and
      licensed fixtures; exclude private exports, reference checkout and work files.

## 2. Evidence for the existing features

- [ ] Compare a synthetic or permissibly licensed table with a direct full-precision JMP CSV export.
- [ ] Spot-check representative numeric/text/date/missing/compressed cases against
      independent JMP output, using redistributable fixtures where possible.
- [ ] Record tested file versions and unsupported cases honestly; resolve discrepancies.

## 3. Clean project and public home

- [x] Create a dedicated jmpread Git repository with DESCRIPTION at its root.
- [x] Commit source, tests, licenses, vignette and workflow. Exclude
      validation/private, local libraries, build output and data without documented redistribution permission.
- [x] Set repository and issue-tracker URLs in DESCRIPTION.
- [ ] Run GitHub Actions for Windows/macOS/Linux on R-release and R-devel.
      DESCRIPTION should be at the repository root for the current workflow.
- [ ] Review README examples, help, NEWS and the rendered vignette as a new user.

## 4. Check the exact submission archive

- [ ] Choose the release version (for example 0.1.0 after testing is complete).
- [ ] Build with current R-release or R-patched: R CMD build jmpread.
- [ ] Run R CMD check --as-cran on the exact tarball with current R-devel;
      investigate errors, warnings and significant notes. Explain legitimate notes.
- [ ] Build/check the PDF manual; earlier local checks used --no-manual.
- [ ] Consider Win-builder as a supplementary R-devel check. Local preparation
      does not upload anything to external check services.
- [ ] Record actual check results in cran-comments.md. Do not copy old check
      results onto a new candidate without rerunning them.

## 5. Submit when ready

- [ ] Read the current CRAN policy and submission checklist.
- [ ] Tag the tested release in the source repository.
- [ ] Upload the R CMD build source .tar.gz via the CRAN submission form.
      The Windows .zip is for users; it is not the CRAN submission file.
- [ ] Confirm the submission email at joe@sixhillsgroup.com.au and respond to review.
- [ ] Monitor checks and maintain the package after acceptance.

Official references:

- https://cran.r-project.org/web/packages/policies.html
- https://cran.r-project.org/web/packages/submission_checklist.html
- https://cran.r-project.org/submit.html

Current status: local preparation only. No repository, external check upload,
email or CRAN submission has been created by this checklist.
