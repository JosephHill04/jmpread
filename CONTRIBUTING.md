# Contributing to jmpread

Thanks for helping improve jmpread.

## Report a problem

Open an issue with your R version, operating system, jmpread version, the JMP
version that saved the file (if known), and a minimal example. Include the full
error message or describe the expected and actual values.

Do not upload confidential data, credentials or personal information. A small
synthetic table that reproduces the problem is best. Only share files you have
permission to redistribute. Label whether expected values came from a direct
JMP export or another reader; agreement with another reader is not independent
JMP validation.

## Make a change

1. Fork the repository and create a branch for your change.
2. Add a focused regression case when fixing decoding behavior. Retain fixture
   provenance and licenses for any added binary files.
3. Update help/examples and NEWS.md when user-facing behavior changes.
4. Build and check the package from the directory above the checkout:

   ```sh
   R CMD build jmpread
   R CMD check --no-manual jmpread_0.1.0.tar.gz
   ```

5. Open a pull request explaining the problem, solution and actual checks run.

The optional knitr package is needed to rebuild the vignette. Tests themselves
use base R. GitHub Actions checks Windows, macOS and Linux on R-release and
R-devel. Private exports, local package libraries and build output do not belong
in the repository.
